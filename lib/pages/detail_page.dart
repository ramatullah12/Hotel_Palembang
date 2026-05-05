import 'package:flutter/material.dart';
import 'dart:convert';
import 'post_page.dart';
import '../services/firestore_service.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const DetailPage({super.key, required this.data, required this.docId});

  @override
  Widget build(BuildContext context) {
    String imgUrl = data['image'] != null && data['image'].toString().isNotEmpty 
        ? data['image'] 
        : "https://picsum.photos/400/200";

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? ""),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostPage(existingHotel: data, docId: docId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Hapus Hotel"),
                  content: const Text("Yakin ingin menghapus hotel ini?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirestoreService().deleteHotel(docId);
                        if (context.mounted) {
                          Navigator.pop(ctx); // close dialog
                          Navigator.pop(context); // close detail page
                        }
                      },
                      child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          imgUrl.startsWith('http')
              ? Image.network(imgUrl)
              : Image.memory(base64Decode(imgUrl)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(data['desc'] ?? ""),
          ),
        ],
      ),
    );
  }
}