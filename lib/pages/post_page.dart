import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class PostPage extends StatelessWidget {
  final name = TextEditingController();
  final desc = TextEditingController();
  final image = TextEditingController();
  final service = FirestoreService();

  PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Posting")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: name),
            TextField(controller: desc),
            TextField(controller: image),
            ElevatedButton(
              onPressed: () async {
                await service.addHotel({
                  "name": name.text,
                  "desc": desc.text,
                  "image": image.text,
                  "category": "Wisata",
                  "author": "User"
                });

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}