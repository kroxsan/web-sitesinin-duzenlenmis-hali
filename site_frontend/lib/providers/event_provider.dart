import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/event.dart';

class EventProvider extends ChangeNotifier {
  final String apiUrl = "http://localhost:5151/api/events";
  String? token; // Token artık dışarıdan set edilecek (main.dart'tan)

  List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  // Backend'den etkinlikleri çek
  Future<void> fetchEvents() async {
    print(' Etkinlikler backend\'den çekiliyor...');
    
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: token != null ? {"Authorization": "Bearer $token"} : {},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(' ${data.length} etkinlik alındı');

      _events = data.map((e) {
        // Location kontrolü yap
        String location = e['location'] ?? '';
        if (location.isEmpty) {
          location = '${e['city'] ?? 'Bilinmeyen Şehir'}, Konum Belirtilmemiş';
          print(' Event ${e['id']} - ${e['name']}: Location boş, otomatik atandı: $location');
        }
        
        return Event(
          id: e['id'].toString(),
          name: e['name'] ?? 'İsimsiz Etkinlik',
          description: e['description'] ?? '',
          category: e['category'] ?? 'Kategori Yok',
          city: e['city'] ?? 'Bilinmeyen Şehir',
          price: (e['price'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.parse(e['date']),
          imageUrl: e['imageUrl'] ?? 'https://picsum.photos/400/200',
          location: location,
          capacity: e['capacity'] ?? 0,
        );
      }).toList();

      print(' Etkinlikler başarıyla yüklendi');
      notifyListeners();
    } else {
      print(' Etkinlikler alınamadı! Status: ${response.statusCode}');
      throw Exception("Etkinlikler alınamadı!");
    }
  }

  // EVENT ADD
  Future<void> addEvent(Event event) async {
    if (token == null) throw Exception("Giriş yapmalısınız");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "name": event.name,
        "description": event.description,
        "category": event.category,
        "city": event.city,
        "price": event.price,
        "date": event.date.toIso8601String(),
        "imageUrl": event.imageUrl,
        "location": event.location.isEmpty ? '${event.city}, Konum Belirtilmemiş' : event.location,
        "capacity": event.capacity,
      }),
    );

    if (response.statusCode == 201) {
      await fetchEvents(); // Listeyi yenile
    } else {
      throw Exception("Etkinlik eklenemedi! ${response.statusCode}: ${response.body}");
    }
  }

  // UPDATE EVENT
  Future<void> updateEvent(Event event) async {
    if (token == null) throw Exception("Giriş yapmalısınız");

    final response = await http.put(
      Uri.parse("$apiUrl/${event.id}"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "id": int.parse(event.id),
        "name": event.name,
        "description": event.description,
        "category": event.category,
        "city": event.city,
        "price": event.price,
        "date": event.date.toIso8601String(),
        "imageUrl": event.imageUrl,
        "location": event.location.isEmpty ? '${event.city}, Konum Belirtilmemiş' : event.location,
        "capacity": event.capacity,
      }),
    );

    if (response.statusCode == 204) {
      await fetchEvents(); // Listeyi yenile
    } else {
      throw Exception("Etkinlik güncellenemedi! ${response.statusCode}: ${response.body}");
    }
  }

  // DELETE EVENT
  Future<void> deleteEvent(String id) async {
    if (token == null) throw Exception("Giriş yapmalısınız");

    final response = await http.delete(
      Uri.parse("$apiUrl/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 204) {
      _events.removeWhere((e) => e.id == id);
      notifyListeners();
    } else {
      throw Exception("Etkinlik silinemedi!");
    }
  }
}
