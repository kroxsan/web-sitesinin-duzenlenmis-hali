import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/event_provider.dart';
import 'providers/auth_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/admin_panel_page.dart';
import 'pages/my_tickets_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // AuthProvider'ı oluştur ve token'ı yükle
  final authProvider = AuthProvider();
  await authProvider.loadToken();
  
  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  
  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        // EventProvider AuthProvider'a bağımlı, bu yüzden ProxyProvider kullanıyoruz
        ChangeNotifierProxyProvider<AuthProvider, EventProvider>(
          create: (_) => EventProvider(),
          update: (_, authProvider, eventProvider) {
            eventProvider!.token = authProvider.token;
            return eventProvider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Etkinlik Sitesi',
        theme: ThemeData(
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/admin': (context) => const AdminPanelPage(),
          '/my-tickets': (context) => const MyTicketsPage(),
        },
      ),
    );
  }
}
