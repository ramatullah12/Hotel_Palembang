import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

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
  double progress = 0; // 🔥 PROGRESS

  final List<String> categories = [
    "Hotel",
    "Resort",
    "Budget",
    "Luxury",
  ];

  final picker = ImagePicker();

  Uint8List? webImage;
  File? imageFile;

  // 📸 PILIH GAMBAR (LEBIH RINGAN)
  Future pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // 🔥 biar cepat
    );

    if (picked != null) {
      if (kIsWeb) {
        webImage = await picked.readAsBytes();
      } else {
        imageFile = File(picked.path);
      }
      setState(() {});
    }
  }

  // ☁️ UPLOAD + PROGRESS
  Future<String> uploadImage() async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child("hotel_images")
        .child(fileName);

    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = ref.putData(webImage!);
    } else {
      uploadTask = ref.putFile(imageFile!);
    }

    // 🔥 TRACK PROGRESS
    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        progress = event.bytesTransferred / event.totalBytes;
      });
    });

    await uploadTask;

    return await ref.getDownloadURL();
  }

  // 🚀 SIMPAN DATA
  Future submit() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      progress = 0;
    });

    if (name.text.isEmpty || desc.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      String imageUrl = "https://picsum.photos/400/200";

      if (webImage != null || imageFile != null) {
        imageUrl = await uploadImage();
      }

      await service.addHotel({
        "name": name.text,
        "desc": desc.text,
        "location": location.text,
        "price": price.text,
        "category": selectedCategory,
        "image": imageUrl,
        "author": "User"
      });

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload gagal")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text("Tambah Hotel"),
        actions: [
          TextButton(
            onPressed: submit,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Kirim",
                    style: TextStyle(color: Colors.white)),
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
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7C5C0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: webImage == null && imageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50),
                          SizedBox(height: 10),
                          Text("Tambahkan Foto Hotel"),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            ? Image.memory(webImage!, fit: BoxFit.cover)
                            : Image.file(imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),

            // 🔥 PROGRESS BAR
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 5),
                    Text("${(progress * 100).toStringAsFixed(0)}%"),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            const Text("Kategori",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: categories.map((cat) {
                bool isActive = selectedCategory == cat;

                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isActive ? Colors.red.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isActive ? Colors.red : Colors.grey.shade300,
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