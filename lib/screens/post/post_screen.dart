import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(newText);
    final formatter = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    String formatted = formatter.format(value).trim();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
  final phone = TextEditingController();

  final service = FirestoreService();

  String selectedCategory = "Hotel";
  List<String> selectedAmenities = [];
  bool isLoading = false;
  double? _lat;
  double? _lng;

  bool get isEditing => widget.existingHotel != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      name.text = widget.existingHotel!['name'] ?? '';
      desc.text = widget.existingHotel!['desc'] ?? '';
      location.text = widget.existingHotel!['location'] ?? '';
      String p = widget.existingHotel!['price']?.toString() ?? '';
      if (p.isNotEmpty) {
        final int value = int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final formatter = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
        price.text = formatter.format(value).trim();
      } else {
        price.text = '';
      }
      selectedCategory = widget.existingHotel!['category'] ?? 'Hotel';
      _lat = (widget.existingHotel!['latitude'] as num?)?.toDouble();
      _lng = (widget.existingHotel!['longitude'] as num?)?.toDouble();
      phone.text = widget.existingHotel!['phone'] ?? '';
      selectedAmenities = List<String>.from(widget.existingHotel!['amenities'] ?? []);
      
      if (widget.existingHotel!['images'] != null) {
        _base64Images = List<String>.from(widget.existingHotel!['images']);
      } else if (widget.existingHotel!['image'] != null && widget.existingHotel!['image'].toString().isNotEmpty) {
        _base64Images = [widget.existingHotel!['image']];
      }
    }
  }

  final List<String> categories = ["Hotel", "Resort", "Budget", "Luxury"];
  final List<String> availableAmenities = ["WiFi", "AC", "Kolam Renang", "Parkir", "Restoran", "Resepsionis 24 Jam"];

  List<String> _base64Images = [];
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (_base64Images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimal 5 foto!')));
      return;
    }

    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 30, // Kompresi tinggi
        maxWidth: 600,
        maxHeight: 600,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64 = base64Encode(bytes);
        setState(() {
          _base64Images.add(base64);
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

  // 📍 AMBIL LOKASI GPS
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan lokasi dinonaktifkan.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak permanen.')));
      return;
    } 

    setState(() {
      isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          location.text = '${place.street}, ${place.subLocality}, ${place.locality}';
        } else {
          location.text = '${position.latitude}, ${position.longitude}';
        }
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // 🚀 SIMPAN DATA
  Future submit() async {
    if (isLoading) return;

    if (name.text.isEmpty || desc.text.isEmpty || phone.text.isEmpty || price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi semua kolom wajib (termasuk telepon dan harga)")));
      return;
    }

    if (desc.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deskripsi minimal 10 karakter")));
      return;
    }

    if (int.tryParse(price.text.replaceAll('.', '')) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harga tidak boleh 0")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String authorName = "User";
      String authorEmail = "";
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          authorName = userData['name'] ?? "User";
          authorEmail = userData['email'] ?? "";
        }
      }

      final data = {
        "name": name.text,
        "desc": desc.text,
        "location": location.text,
        "price": price.text.replaceAll('.', ''),
        "category": selectedCategory,
        "image": _base64Images.isNotEmpty ? _base64Images.first : "",
        "images": _base64Images,
        "author": authorName,
        "authorEmail": authorEmail,
        "latitude": _lat ?? 0.0,
        "longitude": _lng ?? 0.0,
        "phone": phone.text,
        "amenities": selectedAmenities,
      };

      if (isEditing && widget.docId != null) {
        await service.updateHotel(widget.docId!, data);
      } else {
        await service.addHotel(data);
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload gagal: $e")));
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: Text(
          isEditing ? "Edit Hotel" : "Tambah Hotel",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: submit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Kirim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 FOTO CAROUSEL
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _base64Images.length + 1,
                itemBuilder: (context, index) {
                  if (index == _base64Images.length) {
                    if (_base64Images.length >= 5) return const SizedBox();
                    return GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 5),
                            Text("Tambah", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: MemoryImage(base64Decode(_base64Images[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 15,
                        child: GestureDetector(
                          onTap: () => setState(() => _base64Images.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Kategori",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: categories.map((cat) {
                bool isActive = selectedCategory == cat;

                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.red.shade100 : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? Colors.red : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(cat, style: TextStyle(color: isActive ? Colors.black87 : Theme.of(context).textTheme.bodyMedium?.color)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _input(context, name, "Nama Hotel", Icons.hotel),
            const SizedBox(height: 10),
            _input(context, desc, "Deskripsi", Icons.description, maxLines: 4),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _input(
                    context,
                    location,
                    "Pilih Lokasi dari Peta",
                    Icons.map,
                    readOnly: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text(
                                "Pilih Lokasi",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFFC62828),
                              iconTheme: const IconThemeData(color: Colors.white),
                            ),
                            body: OpenStreetMapSearchAndPick(
                              buttonColor: const Color(0xFFC62828),
                              buttonText: 'Pilih Lokasi Ini',
                              onPicked: (pickedData) {
                                setState(() {
                                  location.text = pickedData.addressName;
                                  _lat = pickedData.latLong.latitude;
                                  _lng = pickedData.latLong.longitude;
                                });

                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.red),
                    onPressed: _getCurrentLocation,
                    tooltip: "Gunakan GPS Saat Ini",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _input(
              context,
              price, 
              "Harga", 
              Icons.attach_money,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),
            const SizedBox(height: 10),
            _input(
              context,
              phone, 
              "Nomor Telepon", 
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const Text(
              "Fasilitas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: -8,
              children: availableAmenities.map((amenity) {
                final isSelected = selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  selectedColor: Colors.red.shade100,
                  checkmarkColor: Colors.red,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedAmenities.add(amenity);
                      } else {
                        selectedAmenities.remove(amenity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context,
    TextEditingController c,
    String hint,
    IconData icon, {
    int maxLines = 1,
    VoidCallback? onTap,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: c,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
