import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference get hotels =>
      _firestore.collection('hotels');

  CollectionReference get users =>
      _firestore.collection('users');

  CollectionReference get comments =>
      _firestore.collection('comments');

  CollectionReference get favorites =>
      _firestore.collection('favorites');

  Stream<QuerySnapshot> getHotels() {
    return hotels.snapshots();
  }

  Future<void> addHotel(Map<String, dynamic> data) {
    return hotels.add(data);
  }

  Future<void> updateHotel(String docId, Map<String, dynamic> data) {
    return hotels.doc(docId).update(data);
  }

  Future<void> deleteHotel(String docId) {
    return hotels.doc(docId).delete();
  }

  Stream<QuerySnapshot> getFavorite() {
    return favorites.snapshots();
  }

  Future<void> deleteFavorite(String docId) {
    return favorites.doc(docId).delete();
  }
}