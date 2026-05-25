import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/firestore_service.dart';
import 'map_picker_screen.dart';

class PostPage extends StatefulWidget {
  final Map<String, dynamic>? existingHotel;
  final String? docId;

  const PostPage({super.key, this.existingHotel, this.docId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _service = FirestoreService();
  final _picker = ImagePicker();

  String _selectedCategory = 'Hotel';
  bool _isLoading = false;
  String? _imageBase64;

  bool get _isEditing => widget.existingHotel != null;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Hotel', 'icon': Icons.hotel},
    {'label': 'Resort', 'icon': Icons.beach_access},
    {'label': 'Budget', 'icon': Icons.savings},
    {'label': 'Luxury', 'icon': Icons.star},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final h = widget.existingHotel!;
      _nameCtrl.text = h['name'] ?? '';
      _descCtrl.text = h['desc'] ?? '';
      _locationCtrl.text = h['location'] ?? '';
      _priceCtrl.text = h['price'] ?? '';
      _selectedCategory = h['category'] ?? 'Hotel';
      _imageBase64 = h['image'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── PILIH GAMBAR ────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 900,
        maxHeight: 900,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBase64 = base64Encode(bytes));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceBtn(Icons.camera_alt, 'Kamera',
                    () => _pickImage(ImageSource.camera)),
                _sourceBtn(Icons.photo_library, 'Galeri',
                    () => _pickImage(ImageSource.gallery)),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sourceBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFFFEBEE),
            child: Icon(icon, size: 28, color: const Color(0xFFC62828)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── AMBIL LOKASI DARI MAPS ────────────────────────────────
  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (result != null && result is String) {
      _locationCtrl.text = result;
    }
  }

  // ── SIMPAN DATA ─────────────────────────────────────────
  Future<void> _submit() async {
    if (_isLoading) return;

    if (_nameCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Deskripsi wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final hotelData = {
        'name': _nameCtrl.text.trim(),
        'desc': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'price': _priceCtrl.text.trim(),
        'category': _selectedCategory,
        'image': _imageBase64 ?? '',
        'author': 'User',
      };

      if (_isEditing && widget.docId != null) {
        await _service.updateHotel(widget.docId!, hotelData);
      } else {
        await _service.addHotel(hotelData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Hotel berhasil diperbarui' : 'Hotel berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: Text(
          _isEditing ? 'Edit Hotel' : 'Tambah Hotel',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── FOTO ──────────────────────────────────────
            GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.grey.shade300, width: 1.5),
                ),
                child: _imageBase64 != null && _imageBase64!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          base64Decode(_imageBase64!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Ketuk untuk tambah foto',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ── KATEGORI ──────────────────────────────────
            const Text('Kategori',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isActive = _selectedCategory == cat['label'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat['label'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFFEBEE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 16,
                          color: isActive
                              ? Colors.red
                              : Colors.black54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color: isActive
                                ? Colors.red
                                : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── FORM FIELDS ───────────────────────────────
            _buildField(_nameCtrl, 'Nama Hotel', Icons.hotel),
            const SizedBox(height: 12),
            _buildField(_descCtrl, 'Deskripsi', Icons.description,
                maxLines: 4),
            const SizedBox(height: 12),
            _buildField(
              _locationCtrl,
              'Lokasi',
              Icons.location_on,
              suffixIcon: IconButton(
                icon: const Icon(Icons.map, color: Colors.blue),
                tooltip: 'Pilih Lokasi dari Peta',
                onPressed: _openMapPicker,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(_priceCtrl, 'Harga (cth: Rp 350.000/malam)',
                Icons.attach_money),

            const SizedBox(height: 30),

            // ── TOMBOL SIMPAN ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Perbarui Hotel' : 'Simpan Hotel',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFC62828), width: 1.5),
        ),
      ),
    );
  }
}
