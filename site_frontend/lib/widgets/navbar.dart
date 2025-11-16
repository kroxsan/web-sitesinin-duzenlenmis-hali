import 'package:flutter/material.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Etkinlik Platformu',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepPurple,
      elevation: 2,
      actions: [
        // Admin Girişi butonu
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            'Admin Girişi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Profil ikonu (ileride kullanıcı girişi olunca aktifleşecek)
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            // Şimdilik işlev yok
            // Giriş yapılınca dropdown menü gelecek
          },
        ),

        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
