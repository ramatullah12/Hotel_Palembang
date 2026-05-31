import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/firestore_service.dart';
import '../post/post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/comment_widget.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const DetailPage({super.key, required this.data, required this.docId});

  Color _getCategoryColor(String? cat) {
    switch (cat) {
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
    final String name = data['name'] ?? 'Detail Hotel';
    final String desc = data['desc'] ?? 'Tidak ada deskripsi.';
    final String location = data['location'] ?? '-';
    final String priceRaw = data['price']?.toString() ?? '0';
    final String price = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(num.tryParse(priceRaw) ?? 0);
    final String category = data['category'] ?? 'Hotel';
    final String author = data['author'] ?? 'User';
    final String authorEmail = data['authorEmail'] ?? '';
    final String imgUrl =
        (data['image'] != null && data['image'].toString().isNotEmpty)
            ? data['image']
            : '';
    final List<String> images = data['images'] != null ? List<String>.from(data['images']) : [];
    if (images.isEmpty && imgUrl.isNotEmpty) {
      images.add(imgUrl);
    }
    final String phone = data['phone'] ?? '';
    final List<String> amenities = data['amenities'] != null ? List<String>.from(data['amenities']) : [];

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Harga / Malam', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: phone.isNotEmpty ? () async {
                  String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                  if (cleanPhone.startsWith('0')) {
                    cleanPhone = '62${cleanPhone.substring(1)}';
                  }
                  
                  final url = Uri.parse('https://wa.me/$cleanPhone');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka WhatsApp')));
                    }
                  }
                } : null,
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // Warna hijau khas WhatsApp
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── SLIVER APP BAR (GAMBAR) ─────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFFC62828),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
                  background: images.isEmpty
                  ? Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.hotel,
                          size: 80, color: Colors.grey),
                    )
                  : PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        String currentImg = images[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            currentImg.startsWith('http')
                                ? Image.network(
                                    currentImg,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.hotel,
                                          size: 80, color: Colors.grey),
                                    ),
                                  )
                                : Image.memory(
                                    base64Decode(currentImg),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.hotel,
                                          size: 80, color: Colors.grey),
                                    ),
                                  ),
                            if (images.length > 1)
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    '${index + 1} / ${images.length}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
            actions: [
              // Tombol Favorit
              StreamBuilder<DocumentSnapshot>(
                stream: FirestoreService().favorites.doc(docId).snapshots(),
                builder: (context, snapshot) {
                  bool isFavorite = false;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    isFavorite = true;
                  }

                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    tooltip: 'Favorit',
                    onPressed: () async {
                      try {
                        if (isFavorite) {
                          await FirestoreService().deleteFavorite(docId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dihapus dari Favorit")));
                          }
                        } else {
                          // Copy data but with docId attached for saving
                          Map<String, dynamic> favData = Map.from(data);
                          favData['id'] = docId;
                          await FirestoreService().addFavorite(docId, favData);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ditambahkan ke Favorit")));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                        }
                      }
                    },
                  );
                }
              ),
              // Tombol Edit
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: 'Edit',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostPage(existingHotel: data, docId: docId),
                  ),
                ),
              ),
              // Tombol Hapus
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                tooltip: 'Hapus',
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),

          // ── KONTEN DETAIL ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Hotel + Badge Kategori
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Rating Bintang Dinamis
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('hotels').doc(docId).collection('comments').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const SizedBox.shrink(); // Sembunyikan jika tidak ada ulasan
                      }
                      
                      final docs = snapshot.data!.docs;
                      double totalRating = 0;
                      int ratingCount = 0;
                      
                      for (var doc in docs) {
                        final commentData = doc.data() as Map<String, dynamic>;
                        if (commentData['rating'] != null) {
                          totalRating += (commentData['rating'] as num).toDouble();
                          ratingCount++;
                        }
                      }
                      
                      if (ratingCount == 0) return const SizedBox.shrink();
                      
                      final avgRating = totalRating / ratingCount;
                      
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(' ($ratingCount Ulasan)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Lokasi
                  GestureDetector(
                    onTap: () async {
                      final lat = data['latitude'];
                      final lng = data['longitude'];
                      Uri url;
                      if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
                        url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                      } else {
                        final query = Uri.encodeComponent(location);
                        url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                      }

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: Colors.red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 14, 
                              color: Colors.blue, 
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Harga
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  if (amenities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text('Fasilitas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: amenities.map((a) => Chip(
                        label: Text(a, style: TextStyle(fontSize: 12, color: Colors.red.shade900, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.red.shade50,
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Deskripsi
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.6),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Info penulis
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(Icons.person,
                            color: Color(0xFFC62828), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Diposting oleh',
                              style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
                          Text(author,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          if (authorEmail.isNotEmpty)
                            Text(authorEmail,
                                style: TextStyle(
                                    fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  CommentWidget(hotelId: docId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Hotel'),
        content: const Text('Yakin ingin menghapus hotel ini? '
            'Data yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirestoreService().deleteHotel(docId);
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}