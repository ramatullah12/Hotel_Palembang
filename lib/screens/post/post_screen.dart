import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';

class PostPage extends StatefulWidget {
  final Map<String, dynamic>? existingHotel;
  final String? docId;

  const PostPage({super.key, this.existingHotel, this.docId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final name = TextEditingController();
  final desc = TextEditingController();
  final location = TextEditingController();
  final price = TextEditingController();

  final service = FirestoreService();

  String selectedCategory = "Hotel";
  bool isLoading = false;

  bool get isEditing => widget.existingHotel != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      name.text = widget.existingHotel!['name'] ?? '';
      desc.text = widget.existingHotel!['desc'] ?? '';
      location.text = widget.existingHotel!['location'] ?? '';
      price.text = widget.existingHotel!['price'] ?? '';
      selectedCategory = widget.existingHotel!['category'] ?? 'Hotel';
      _imageBase64 = widget.existingHotel!['image'];
    }
  }

  final List<String> categories = [
    "Hotel",
    "Resort",
    "Budget",
    "Luxury",
  ];

  String? _imageBase64;
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64 = base64Encode(bytes);
        setState(() {
          _imageBase64 = base64;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil gambar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pilih Sumber Gambar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(
                  icon: Icons.camera_alt,
                  label: "Kamera",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceButton(
                  icon: Icons.photo_library,
                  label: "Galeri",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red.shade100,
            child: Icon(icon, size: 30, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 🚀 SIMPAN DATA
  Future submit() async {
    if (isLoading) return;

    if (name.text.isEmpty || desc.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = {
        "name": name.text,
        "desc": desc.text,
        "location": location.text,
        "price": price.text,
        "category": selectedCategory,
        "image": _imageBase64 ?? "", // SIMPAN SEBAGAI BASE64
        "author": "User"
      };

      if (isEditing && widget.docId != null) {
        await service.updateHotel(widget.docId!, data);
      } else {
        await service.addHotel(data);
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload gagal: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: Text(isEditing ? "Edit Hotel" : "Tambah Hotel", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: submit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text("Kirim", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 FOTO
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7C5C0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imageBase64 != null && _imageBase64!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          base64Decode(_imageBase64!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50),
                          SizedBox(height: 10),
                          Text("Tambahkan Foto Hotel"),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: categories.map((cat) {
                bool isActive = selectedCategory == cat;

                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.red.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? Colors.red : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(cat),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _input(name, "Nama Hotel", Icons.hotel),
            const SizedBox(height: 10),
            _input(desc, "Deskripsi", Icons.description, maxLines: 4),
            const SizedBox(height: 10),
            _input(location, "Lokasi", Icons.location_on),
            const SizedBox(height: 10),
            _input(price, "Harga", Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}