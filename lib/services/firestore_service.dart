import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;

  // 🔥 GET HOTEL (AMAN)
  Stream<QuerySnapshot<Map<String, dynamic>>> getHotels() {
    return db.collection('hotels').snapshots();
  }

  // ➕ TAMBAH HOTEL
  Future<void> addHotel(Map<String, dynamic> data) async {
    await db.collection('hotels').add(data);
  }

  // ❌ HAPUS HOTEL
  Future<void> deleteHotel(String id) async {
    await db.collection('hotels').doc(id).delete();
  }

  // ✏️ UPDATE HOTEL
  Future<void> updateHotel(String id, Map<String, dynamic> data) async {
    await db.collection('hotels').doc(id).update(data);
  }

  // ❤️ TAMBAH FAVORIT
  Future<void> addFavorite(Map<String, dynamic> data) async {
    await db.collection('favorites').add(data);
  }

  // 🔥 GET FAVORIT
  Stream<QuerySnapshot<Map<String, dynamic>>> getFavorite() {
    return db.collection('favorites').snapshots();
  }

  // ❌ HAPUS FAVORIT
  Future<void> deleteFavorite(String id) async {
    await db.collection('favorites').doc(id).delete();
  }
}