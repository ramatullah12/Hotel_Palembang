import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../services/firestore_service.dart';
import '../pages/favorite_page.dart';
import '../pages/profile_page.dart';
import '../pages/post_page.dart';
import '../pages/detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = FirestoreService();

  String selectedCategory = "Semua";
  int currentIndex = 0;
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5),

      // 🔴 APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text(
          "Hotel Palembang",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const Icon(Icons.menu, color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FavoritePage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari hotel...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔴 KATEGORI
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 15),
                _buildCategoryItem("Semua", Icons.check),
                _buildCategoryItem("Hotel", null),
                _buildCategoryItem("Resort", null),
                _buildCategoryItem("Budget", null),
                _buildCategoryItem("Luxury", null),
              ],
            ),
          ),

          // 🔥 DATA FIRESTORE
          Expanded(
            child: StreamBuilder(
              stream: service.getHotels(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada data hotel"));
                }

                List data = snapshot.data!.docs;

                // 🔍 FILTER
                List filtered = data.where((doc) {
                  var h = doc.data() as Map<String, dynamic>;

                  // kategori
                  if (selectedCategory != "Semua") {
                    if (h['category']
                            ?.toString()
                            .toLowerCase() !=
                        selectedCategory.toLowerCase()) {
                      return false;
                    }
                  }

                  // search
                  if (search.isNotEmpty) {
                    return h['name']
                        .toString()
                        .toLowerCase()
                        .contains(search);
                  }

                  return true;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: List<Widget>.from(
                    filtered.map((doc) {
                      var h = doc.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(data: h, docId: doc.id),
                            ),
                          );
                        },
                        child: _buildHotelCard(
                          context,
                          h['name'] ?? "Tanpa Nama",
                          h['category'] ?? "Hotel",
                          h['desc'] ?? "Tidak ada deskripsi",
                          h['location'] ?? "Palembang",
                          h['price'] ?? "Rp 0",
                          h['image'] ?? "https://picsum.photos/400/200",
                          _getColor(h['category']),
                          h,
                          doc.id,
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ➕ TAMBAH
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostPage()),
          );
        },
        backgroundColor: const Color(0xFFFFB300),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "Tambah",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      // 🔻 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFFC62828),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritePage()),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Favorit"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }

  // 🔴 KATEGORI
  Widget _buildCategoryItem(String title, IconData? icon) {
    bool isActive = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFEBEE) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? Colors.red : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, size: 16, color: Colors.red),
            if (icon != null) const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.red : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏨 CARD
  Widget _buildHotelCard(BuildContext context, String title, String tag,
      String desc, String location, String price, String imgUrl, Color tagColor, Map<String, dynamic> h, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                      )
                    : Image.memory(
                        base64Decode(imgUrl),
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
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(tag,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('favorites').doc(docId).snapshots(),
                  builder: (context, snapshot) {
                    bool isFavorite = snapshot.hasData && snapshot.data != null && snapshot.data!.exists;

                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            if (isFavorite) {
                              await FirestoreService().deleteFavorite(docId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Dihapus dari Favorit!")),
                                );
                              }
                            } else {
                              await FirestoreService().addFavorite(docId, h);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Ditambahkan ke Favorit!")),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal: $e")),
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
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    Text(location),
                    const Spacer(),
                    Text(price,
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String? category) {
    switch (category) {
      case "Hotel":
        return Colors.blue;
      case "Resort":
        return Colors.green;
      case "Luxury":
        return Colors.purple;
      case "Budget":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}