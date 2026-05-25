import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/firestore_service.dart';
import '../detail/detail_screen.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService service = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text(
          'Favorit Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder(
        stream: service.getFavorite(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada favorit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan hotel ke favorit\ndengan menekan ikon ❤️',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final f = docs[i].data();
              final docId = docs[i].id;
              final String imgUrl =
                  (f['image'] != null && f['image'].toString().isNotEmpty)
                      ? f['image']
                      : '';

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(data: f, docId: docId),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── GAMBAR ──────────────────────────
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: imgUrl.isEmpty
                                ? Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.hotel,
                                        size: 60, color: Colors.grey),
                                  )
                                : imgUrl.startsWith('http')
                                    ? Image.network(
                                        imgUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.hotel,
                                                  size: 60, color: Colors.grey),
                                            ),
                                      )
                                    : Image.memory(
                                        base64Decode(imgUrl),
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.hotel,
                                                  size: 60, color: Colors.grey),
                                            ),
                                      ),
                          ),

                          // Badge kategori
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC62828),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                f['category'] ?? 'Hotel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Tombol hapus favorit
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.favorite,
                                    color: Colors.red, size: 22),
                                onPressed: () async {
                                  try {
                                    await service.deleteFavorite(docId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Dihapus dari Favorit'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Gagal: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── INFO ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f['name'] ?? 'Hotel',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              f['desc'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final location = f['location'] ?? 'Palembang';
                                    final query = Uri.encodeComponent(location);
                                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        f['location'] ?? 'Palembang',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  f['price'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
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