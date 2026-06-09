import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get hotels => _firestore.collection('hotels');
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get comments => _firestore.collection('comments');
  CollectionReference get favorites => _firestore.collection('favorites');

  // ── HOTEL ────────────────────────────────────────────────
  Stream<QuerySnapshot> getHotels() => hotels.snapshots();

  Future<void> addHotel(Map<String, dynamic> data) => hotels.add(data);

  Future<void> updateHotel(String docId, Map<String, dynamic> data) =>
      hotels.doc(docId).update(data);

  /// Hapus hotel beserta semua favorit yang merujuk ke hotel ini
  Future<void> deleteHotel(String docId) async {
    // Hapus semua dokumen favorit yang punya field hotelId == docId
    final favSnap = await favorites
        .where('hotelId', isEqualTo: docId)
        .get();
    final batch = _firestore.batch();
    for (final doc in favSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(hotels.doc(docId));
    await batch.commit();
  }

  // ── FAVORIT (per-user) ───────────────────────────────────
  String _favDocId(String hotelId) => '${_uid}_$hotelId';

  /// Stream favorit hanya milik user yang sedang login
  Stream<QuerySnapshot> getFavorite() {
    if (_uid == null) return const Stream.empty();
    return favorites.where('userId', isEqualTo: _uid).snapshots();
  }

  /// Cek apakah hotel tertentu sudah difavoritkan oleh user aktif
  Stream<DocumentSnapshot> getFavoriteStatus(String hotelId) {
    return favorites.doc(_favDocId(hotelId)).snapshots();
  }

  Future<void> addFavorite(String hotelId, Map<String, dynamic> data) {
    final favData = Map<String, dynamic>.from(data);
    favData['hotelId'] = hotelId;
    favData['userId'] = _uid;
    return favorites.doc(_favDocId(hotelId)).set(favData);
  }

  Future<void> deleteFavorite(String hotelId) {
    return favorites.doc(_favDocId(hotelId)).delete();
  }
}