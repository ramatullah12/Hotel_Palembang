import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'detail_page.dart';

class FavoritePage extends StatelessWidget {
  final service = FirestoreService();

  FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text("Favorit Saya"),
        centerTitle: true,
      ),

      body: StreamBuilder(
        stream: service.getFavorite(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi error"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada favorit"));
          }

          var data = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: data.length,
            itemBuilder: (context, i) {
              var f = data[i].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  // 🔥 buka detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(data: f),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 🔥 IMAGE + TAG
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: Image.network(
                              f['image'] ?? "",
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              ),
                            ),
                          ),

                          // TAG KATEGORI
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                f['category'] ?? "Umum",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          // ICON FAVORIT
                          const Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(Icons.favorite, color: Colors.red),
                          ),
                        ],
                      ),

                      // 🔥 INFO
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f['name'] ?? "",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              f['desc'] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.red),
                                Expanded(
                                  child: Text(
                                    f['location'] ?? "Lokasi tidak diketahui",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 12,
                                  child: Icon(Icons.person, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(f['author'] ?? "User"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}