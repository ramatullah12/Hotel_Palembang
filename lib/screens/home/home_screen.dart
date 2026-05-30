import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../widgets/hotel_card.dart';
import '../favorite/favorite_screen.dart';
import '../profile/profile_screen.dart';
import '../post/post_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _service = FirestoreService();

  String _selectedCategory = 'Semua';
  String _search = '';
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Semua', 'icon': Icons.apps},
    {'label': 'Hotel', 'icon': Icons.hotel},
    {'label': 'Resort', 'icon': Icons.beach_access},
    {'label': 'Budget', 'icon': Icons.savings},
    {'label': 'Luxury', 'icon': Icons.star},
  ];

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _currentIndex = 0);
      return;
    }
    if (index == 1) {
      setState(() => _currentIndex = 1);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FavoritePage()),
      ).then((_) => setState(() => _currentIndex = 0));
    }
    if (index == 2) {
      setState(() => _currentIndex = 2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage()),
      ).then((_) => setState(() => _currentIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5),

      // ── APP BAR ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text(
          'Hotel Palembang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            tooltip: 'Favorit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritePage()),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── SEARCH BAR ──────────────────────────────────
          Container(
            color: const Color(0xFFC62828),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari hotel di Palembang...',
                hintStyle: const TextStyle(color: Colors.black45),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── KATEGORI ────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isActive = _selectedCategory == cat['label'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat['label'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFC62828)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFC62828)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 15,
                          color: isActive ? Colors.white : Colors.black54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color:
                                isActive ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── LIST HOTEL ──────────────────────────────────
          Expanded(
            child: StreamBuilder(
              stream: _service.getHotels(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Color(0xFFC62828),
                  ));
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
                        Icon(Icons.hotel, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada hotel',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tekan + untuk menambahkan hotel',
                          style: TextStyle(
                              color: Colors.black38, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // Filter kategori & search
                final filtered = docs.where((doc) {
                  final h = doc.data();
                  if (_selectedCategory != 'Semua') {
                    if ((h['category'] ?? '').toString().toLowerCase() !=
                        _selectedCategory.toLowerCase()) {
                      return false;
                    }
                  }
                  if (_search.isNotEmpty) {
                    return (h['name'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(_search);
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada hotel yang sesuai',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final doc = filtered[i];
                    final h = doc.data();
                    return HotelCard(data: h, docId: doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB TAMBAH ──────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostPage()),
        ),
        backgroundColor: const Color(0xFFFFB300),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Tambah Hotel',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      // ── BOTTOM NAV ──────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFC62828),
        unselectedItemColor: Colors.grey,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Favorit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
