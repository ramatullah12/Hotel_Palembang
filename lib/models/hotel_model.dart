import 'package:cloud_firestore/cloud_firestore.dart';

class HotelModel {
  final String id;
  final String name;
  final String desc;
  final String location;
  final int price;
  final String category;
  final String image;
  final String author;

  final double latitude;
  final double longitude;

  final int favoriteCount;

  final DateTime createdAt;

  HotelModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.location,
    required this.price,
    required this.category,
    required this.image,
    required this.author,
    required this.latitude,
    required this.longitude,
    required this.favoriteCount,
    required this.createdAt,
  });

  factory HotelModel.fromMap(String id, Map<String, dynamic> map) {
    return HotelModel(
      id: id,
      name: map['name'] ?? '',
      desc: map['desc'] ?? '',
      location: map['location'] ?? '',
      price: map['price'] ?? 0,
      category: map['category'] ?? 'Hotel',
      image: map['image'] ?? '',
      author: map['author'] ?? 'User',

      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),

      favoriteCount: map['favoriteCount'] ?? 0,

      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'desc': desc,
      'location': location,
      'price': price,
      'category': category,
      'image': image,
      'author': author,

      'latitude': latitude,
      'longitude': longitude,

      'favoriteCount': favoriteCount,

      'createdAt': createdAt,
    };
  }
}
