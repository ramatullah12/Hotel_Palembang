import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text(
          'Kontak Developer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar Developer
            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.person, size: 55, color: Color(0xFFC62828)),
            ),

            const SizedBox(height: 16),

            const Text(
              'Developer Hotel Palembang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Flutter Developer',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // Info Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  _infoTile(
                    context,
                    Icons.person_outline,
                    'Nama',
                    'Yuan Ramatullah',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _infoTile(
                    context,
                    Icons.email_outlined,
                    'Email',
                    'ramatullah@gmail.com',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _infoTile(
                    context,
                    Icons.school_outlined,
                    'Universitas',
                    'Universitas Palembang',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _infoTile(
                    context,
                    Icons.book_outlined,
                    'Mata Kuliah',
                    'Pemrograman Aplikasi Bergerak',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _infoTile(
                    context,
                    Icons.calendar_today_outlined,
                    'Tahun',
                    '2026',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // About App
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3B1C1C) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFC62828)),
                      SizedBox(width: 8),
                      Text(
                        'Tentang Aplikasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hotel Palembang adalah aplikasi mobile berbasis Flutter '
                    'yang memungkinkan pengguna untuk melihat, menambah, '
                    'mengedit, dan menyimpan daftar hotel di Palembang. '
                    'Data disimpan secara real-time menggunakan Firebase Firestore.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '© 2026 Hotel Palembang App',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(BuildContext context, IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFC62828)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
