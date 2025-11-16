import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/event_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/admin_panel_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Etkinlik Sitesi',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: '/login', // Login sayfasını başlangıç yapıyoruz
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/admin': (context) => const AdminPanelPage(),
        },
      ),
    );
  }
}
