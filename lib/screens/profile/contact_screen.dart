import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kontak")),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Developer: Nama Kamu"),
            Text("Email: kamu@email.com"),
            Text("Universitas: Kampus Kamu"),
          ],
        ),
      ),
    );
  }
}