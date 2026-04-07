import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  final name = TextEditingController();
  final email = TextEditingController();
  final bio = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 🔥 LOAD DATA USER
  Future loadData() async {
    if (user == null) return;

    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      var data = doc.data()!;
      name.text = data['name'] ?? "";
      email.text = data['email'] ?? user!.email!;
      bio.text = data['bio'] ?? "";
    } else {
      email.text = user!.email ?? "";
    }

    setState(() {});
  }

  // 🔥 SIMPAN DATA
  Future saveProfile() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        "name": name.text,
        "email": email.text,
        "bio": bio.text,
        "updated_at": DateTime.now(),
      });

      await user!.updateDisplayName(name.text);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil disimpan")),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text("Edit Profil"),
        actions: [
          IconButton(
            onPressed: saveProfile,
            icon: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.red.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: bio,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}