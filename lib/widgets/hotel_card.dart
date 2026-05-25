import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';
import '../screens/detail/detail_screen.dart';

class HotelCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const HotelCard({super.key, required this.data, required this.docId});

  Color _getTagColor(String? category) {
    switch (category) {
      case 'Hotel':
        return Colors.blue;
      case 'Resort':
        return Colors.green;
      case 'Luxury':
        return Colors.purple;
      case 'Budget':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = data['name'] ?? 'Tanpa Nama';
    final String desc = data['desc'] ?? '';
    final String location = data['location'] ?? 'Palembang';
    final String price = data['price'] ?? 'Rp 0';
    final String category = data['category'] ?? 'Hotel';
    final String imgUrl = (data['image'] != null &&
            data['image'].toString().isNotEmpty)
        ? data['image']
        : 'https://picsum.photos/400/200';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(data: data, docId: docId),
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
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── GAMBAR + BADGE + FAVORIT ───────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imgUrl.startsWith('http')
                      ? Image.network(
                          imgUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : Image.memory(
                          base64Decode(imgUrl),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
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
                      color: _getTagColor(category),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Tombol favorit (realtime)
                Positioned(
                  top: 10,
                  right: 10,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('favorites')
                        .doc(docId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final isFav =
                          snapshot.hasData && snapshot.data!.exists;
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            try {
                              if (isFav) {
                                await FirestoreService()
                                    .deleteFavorite(docId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Dihapus dari Favorit')),
                                  );
                                }
                              } else {
                                await FirestoreService()
                                    .addFavorite(docId, data);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Ditambahkan ke Favorit')),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal: $e')),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ─── INFO HOTEL ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  // Lokasi dan Harga
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final query = Uri.encodeComponent(location);
                          final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 13,
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
                        price,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
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
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.hotel, size: 50, color: Colors.grey),
      ),
    );
  }
}
