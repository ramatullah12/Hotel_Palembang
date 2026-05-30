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
}