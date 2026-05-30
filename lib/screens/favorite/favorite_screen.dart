import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../services/firestore_service.dart';
import '../detail/detail_screen.dart';
import '../../models/hotel_model.dart';
import '../../widgets/hotel_card.dart';

class FavoritePage extends StatelessWidget {
  final service = FirestoreService();

  FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        title: const Text("Favorit Saya"),
        centerTitle: true,
      ),

      body: StreamBuilder(
        stream: service.getFavorite(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || (snapshot.data as QuerySnapshot).docs.isEmpty) {
            return const Center(child: Text("Belum ada favorit"));
          }

          var data = (snapshot.data as QuerySnapshot).docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: data.length,
            itemBuilder: (context, i) {
              var f = data[i].data() as Map<String, dynamic>;
              String imgUrl = f['image'] != null && f['image'].toString().isNotEmpty 
                  ? f['image'] 
                  : "https://picsum.photos/400/200";

              return HotelCard(
                hotel: HotelModel.fromMap(data[i].id, f),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(data: f, docId: data[i].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}