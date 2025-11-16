import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  String? token;

  final String apiUrl = "http://localhost:5151/api/auth";

  bool get isLoggedIn => token != null;

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$apiUrl/login"),     //authcontroller içindeki login endpointine istek atılır
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['token'];
      notifyListeners();
    } else {
      throw Exception("Giriş başarısız: ${response.body}");
    }
  }

  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$apiUrl/register"),        //authcontroller içindeki register endpointine istek atılır
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "email": email, "password": password}),
    );

    if (response.statusCode != 200) {
      throw Exception("Kayıt başarısız: ${response.body}");
    }
  }

  void logout() {
    token = null;
    notifyListeners();
  }
}
