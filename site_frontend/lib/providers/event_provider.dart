import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/event.dart';

class EventProvider extends ChangeNotifier {
  final String apiUrl = "http://localhost:5151/api/events";
  String? token; // JWT token

  List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  // LOGIN
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("http://localhost:5151/api/auth/login"),    //verilen username ve password ile backend'e istek atar
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {         //backend'den 200 başarı kodu gelmişse token atar
      final data = jsonDecode(response.body);
      token = data['token'];

      // Login olur olmaz backend'den eventleri al
      await fetchEvents();

      return true;
    } else {
      return false;
    }
  }

  // Backend’den etkinlikleri çek
  Future<void> fetchEvents() async {
    if (token == null) return;

    final response = await http.get(
      Uri.parse(apiUrl),                //apiUrl = "http://localhost:5151/api/events"
      headers: {"Authorization": "Bearer $token"},    //token'ı header'da gönderir
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      _events = data.map((e) {          //Backend’den gelen JSON parse edilir
        return Event(
          id: e['id'].toString(),
          name: e['name'],
          description: e['description'],
          category: e['category'],
          city: e['city'],
          price: (e['price'] as num).toDouble(),
          date: DateTime.parse(e['date']),
          imageUrl: e['imageUrl'],
          location: e['location'],
          capacity: e['capacity'],
        );
      }).toList();

      notifyListeners();
    } else {
      throw Exception("Etkinlikler alınamadı!");
    }
  }

  // EVENT ADD (backend’e uygun format)
  Future<void> addEvent(Event event) async {
    if (token == null) return;

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
        "location": event.location,
        "capacity": event.capacity,
      }),
    );

    if (response.statusCode == 201) {
      final e = jsonDecode(response.body);

      _events.add(Event(
        id: e['id'].toString(),
        name: e['name'],
        description: e['description'],
        category: e['category'],
        city: e['city'],
        price: (e['price'] as num).toDouble(),
        date: DateTime.parse(e['date']),
        imageUrl: e['imageUrl'],
        location: e['location'],
        capacity: e['capacity'],
      ));

      notifyListeners();
    } else {
      throw Exception("Etkinlik eklenemedi! Code: ${response.statusCode}");
    }
  }

  // UPDATE EVENT
  Future<void> updateEvent(Event event) async {
    if (token == null) return;

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
        "location": event.location,
        "capacity": event.capacity,
      }),
    );

    if (response.statusCode == 204) {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
        notifyListeners();
      }
    } else {
      throw Exception("Etkinlik güncellenemedi!");
    }
  }

  // DELETE EVENT
  Future<void> deleteEvent(String id) async {
    if (token == null) return;

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
