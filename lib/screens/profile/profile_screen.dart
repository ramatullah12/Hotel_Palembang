import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'contact_screen.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Belum login')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // BELUM ADA PROFIL
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(Icons.person,
                          size: 50, color: Color(0xFFC62828)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.email ?? 'User',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Profil belum diisi',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Lengkapi Profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── HEADER PROFIL ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 36, horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC62828), Color(0xFFEF9A9A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 52, color: Color(0xFFC62828)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfilePage()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit,
                                    size: 16, color: Color(0xFFC62828)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Nama
                      Text(
                        data['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Email
                      Text(
                        data['email'] ?? user.email ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),

                      const SizedBox(height: 8),

                      // Bio
                      if ((data['bio'] ?? '').toString().isNotEmpty)
                        Text(
                          data['bio'],
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 16),

                      // Tombol Edit
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfilePage()),
                        ),
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 16),
                        label: const Text('Edit Profil',
                            style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── MENU LIST ─────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _menuTile(
                        Icons.contact_page_outlined,
                        'Kontak Developer',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ContactPage()),
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _menuTile(
                        Icons.info_outline,
                        'Tentang Aplikasi',
                        onTap: () => _showAboutDialog(context),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _menuTile(
                        Icons.logout,
                        'Keluar',
                        color: Colors.red,
                        onTap: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String title, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFFC62828)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      trailing: Icon(Icons.chevron_right,
          color: color ?? Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Hotel Palembang',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Hotel Palembang App',
      children: const [
        SizedBox(height: 10),
        Text('Aplikasi untuk menemukan dan memesan hotel terbaik di Palembang.'),
      ],
    );
  }
}
