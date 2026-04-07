import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;

  Stream getHotels() => db.collection('hotels').snapshots();

  Future addHotel(Map<String, dynamic> data) async {
    await db.collection('hotels').add(data);
  }

  Future addFavorite(Map<String, dynamic> data) async {
    await db.collection('favorites').add(data);
  }

  Stream getFavorite() => db.collection('favorites').snapshots();
}