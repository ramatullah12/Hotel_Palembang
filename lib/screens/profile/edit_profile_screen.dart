import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();

    if (doc.exists) {
      final d = doc.data()!;
      _nameCtrl.text = d['name'] ?? '';
      _emailCtrl.text = d['email'] ?? _user.email ?? '';
      _bioCtrl.text = d['bio'] ?? '';
    } else {
      _emailCtrl.text = _user.email ?? '';
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveProfile() async {
    if (_isLoading || _user == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .set({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _user.updateDisplayName(_nameCtrl.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text(
          'Edit Profil',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _saveProfile,
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Avatar
            const CircleAvatar(
              radius: 52,
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.person, size: 52, color: Color(0xFFC62828)),
            ),

            const SizedBox(height: 8),
            const Text(
              'Foto profil belum didukung',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 28),

            // Nama
            _buildField(
              controller: _nameCtrl,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Email (readonly)
            _buildField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              readOnly: true,
              hint: 'Email tidak dapat diubah',
            ),
            const SizedBox(height: 16),

            // Bio
            _buildField(
              controller: _bioCtrl,
              label: 'Bio / Deskripsi Singkat',
              icon: Icons.notes,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Simpan Profil',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFC62828), width: 1.5),
        ),
      ),
    );
  }
}
