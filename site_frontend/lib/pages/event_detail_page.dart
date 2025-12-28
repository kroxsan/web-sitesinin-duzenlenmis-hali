import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../data/event.dart';
import '../providers/auth_provider.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int ticketQuantity = 1;
  late Event currentEvent;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentEvent = widget.event;
    fetchEvent(); // 👈 sayfa açılır açılmaz güncel kapasite
  }

  /// 🔄 Backend'den event'i tekrar çek
  Future<void> fetchEvent() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5151/api/events/${currentEvent.id}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentEvent = Event.fromJson(data);
        });
      }
    } catch (_) {}
  }

  Future<void> purchaseTicket() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilet almak için giriş yapmalısınız')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5151/api/tickets"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "eventId": int.parse(currentEvent.id),
          "quantity": ticketQuantity,
        }),
      );

      if (response.statusCode == 201) {
        await fetchEvent(); // 👈 SATIN ALDIKTAN SONRA GÜNCEL KAPASİTE

        setState(() {
          ticketQuantity = 1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilet başarıyla alındı'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err.toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Bilet Satın Al'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bilet Fiyatı: ${currentEvent.price.toStringAsFixed(0)} ₺'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: ticketQuantity > 1
                        ? () => setStateDialog(() => ticketQuantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$ticketQuantity',
                      style: const TextStyle(fontSize: 20)),
                  IconButton(
                    onPressed: ticketQuantity < currentEvent.capacity
                        ? () => setStateDialog(() => ticketQuantity++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Toplam: ${(currentEvent.price * ticketQuantity).toStringAsFixed(0)} ₺',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: currentEvent.capacity <= 0
                  ? null
                  : () {
                      Navigator.pop(context);
                      purchaseTicket();
                    },
              child: const Text('Satın Al'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSoldOut = currentEvent.capacity <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentEvent.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              currentEvent.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentEvent.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Text(currentEvent.city),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Text(
                        "${currentEvent.date.day}.${currentEvent.date.month}.${currentEvent.date.year}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Text(
                        isSoldOut
                            ? "Tamamen Satıldı"
                            : "Kalan Kapasite: ${currentEvent.capacity}",
                        style: TextStyle(
                          color: isSoldOut ? Colors.red : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(currentEvent.description),

                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          isSoldOut || isLoading ? null : showPurchaseDialog,
                      child: isSoldOut
                          ? const Text("Tükendi")
                          : const Text("Bilet Al"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
