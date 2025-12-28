import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  List<dynamic> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    print('🎫 Biletler yükleniyor...');
    print('Token var mı: ${token != null}');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen giriş yapınız')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://localhost:5151/api/tickets/my-tickets"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final loadedTickets = jsonDecode(response.body) as List<dynamic>;
        
        // Her ticket için location kontrolü
        for (var ticket in loadedTickets) {
          if (ticket['event'] != null) {
            var event = ticket['event'];
            if (event['location'] == null || event['location'].toString().isEmpty) {
              print('⚠️ Bilet ${ticket['id']} için location boş, düzeltiliyor...');
              event['location'] = '${event['city'] ?? 'Bilinmeyen Şehir'}, Konum Belirtilmemiş';
            }
          }
        }
        
        setState(() {
          tickets = loadedTickets;
          isLoading = false;
        });
        print('✅ ${tickets.length} bilet yüklendi');
      } else {
        throw Exception('Biletler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Hata: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> deleteTicket(int ticketId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.delete(
        Uri.parse("http://localhost:5151/api/tickets/$ticketId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bilet başarıyla iptal edildi')),
        );
        loadTickets(); // Listeyi yenile
      } else {
        throw Exception('Bilet iptal edilemedi');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biletlerim'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz biletiniz yok',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadTickets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      final event = ticket['event'];
                      final purchaseDate = DateTime.parse(ticket['purchaseDate']);

                      // Location kontrolü
                      String location = event['location'] ?? '';
                      if (location.isEmpty) {
                        location = '${event['city'] ?? 'Bilinmeyen Şehir'}, Konum Belirtilmemiş';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Etkinlik görseli
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.network(
                                event['imageUrl'] ?? 'https://picsum.photos/400/200',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image, size: 64),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['name'] ?? 'İsimsiz Etkinlik',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateTime.parse(event['date']).toString().split(' ')[0],
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Bilet Sayısı',
                                            style: TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                          Text(
                                            '${ticket['quantity']} Adet',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Toplam Tutar',
                                            style: TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                          Text(
                                            '${ticket['totalPrice'].toStringAsFixed(0)} ₺',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Satın alma: ${purchaseDate.day}.${purchaseDate.month}.${purchaseDate.year}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Bilet İptali'),
                                            content: const Text(
                                              'Bu bileti iptal etmek istediğinize emin misiniz?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Vazgeç'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  deleteTicket(ticket['id']);
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('İptal Et'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.cancel),
                                      label: const Text('Bileti İptal Et'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[400],
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
