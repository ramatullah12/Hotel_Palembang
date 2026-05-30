import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;

  // Foto profile user
  final String image;

  // Bio profile
  final String bio;

  // Jumlah posting user
  final int postCount;

  // Jumlah favorite user
  final int favoriteCount;

  // Waktu akun dibuat
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.bio,
    required this.postCount,
    required this.favoriteCount,
    required this.createdAt,
  });

  // Dari Firestore (Map) ke UserModel
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,

      name: map['name'] ?? '',

      email: map['email'] ?? '',

      image: map['image'] ?? '',

      bio: map['bio'] ?? '',

      postCount: int.tryParse(map['postCount']?.toString() ?? '') ?? 0,

      favoriteCount: int.tryParse(map['favoriteCount']?.toString() ?? '') ?? 0,

      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Dari UserModel ke Map
  // untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,

      'email': email,

      'image': image,

      'bio': bio,

      'postCount': postCount,

      'favoriteCount': favoriteCount,

      'createdAt': createdAt,
    };
  }
}
