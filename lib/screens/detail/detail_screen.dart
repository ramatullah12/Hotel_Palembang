import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/firestore_service.dart';
import '../post/post_screen.dart';
import 'package:intl/intl.dart';

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

    return Scaffold(

      body: CustomScrollView(
        slivers: [
          // ── SLIVER APP BAR (GAMBAR) ─────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFFC62828),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
                  background: imgUrl.isEmpty
                  ? Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.hotel,
                          size: 80, color: Colors.grey),
                    )
                  : imgUrl.startsWith('http')
                      ? Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.hotel,
                                size: 80, color: Colors.grey),
                          ),
                        )
                      : Image.memory(
                          base64Decode(imgUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.hotel,
                                size: 80, color: Colors.grey),
                          ),
                        ),
            ),
            actions: [
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
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

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

                  // Tombol Edit bawah
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PostPage(existingHotel: data, docId: docId),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Hotel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tombol Hapus bawah
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Hapus Hotel',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
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