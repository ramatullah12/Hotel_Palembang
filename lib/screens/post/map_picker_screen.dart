import 'package:flutter/material.dart';
import '../../widgets/osm_search_and_pick/osm_search_and_pick.dart';

class MapPickerScreen extends StatelessWidget {
  const MapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFC62828),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: OpenStreetMapSearchAndPick(
        buttonColor: const Color(0xFFC62828),
        buttonText: 'Pilih Lokasi Ini',
        onPicked: (pickedData) {
          // Mengembalikan alamat yang dipilih
          Navigator.pop(context, pickedData.addressName);
        },
      ),
    );
  }
}
