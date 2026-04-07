import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'contact_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final auth = AuthService();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Column(
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person)),
          const SizedBox(height: 10),
          const Text("User"),
          ListTile(
            leading: const Icon(Icons.contact_page),
            title: const Text("Kontak"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPage()),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }
}