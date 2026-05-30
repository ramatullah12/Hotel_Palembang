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

  factory HotelModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return HotelModel(
      id: id,

      name: map['name']?.toString() ?? '',

      desc: map['desc']?.toString() ?? '',

      location: map['location']?.toString() ?? '',

      price: int.tryParse(
            map['price'].toString(),
          ) ??
          0,

      category:
          map['category']?.toString() ??
              'Hotel',

      image: map['image']?.toString() ?? '',

      author:
          map['author']?.toString() ??
              'User',

      latitude:
          (map['latitude'] ?? 0)
              .toDouble(),

      longitude:
          (map['longitude'] ?? 0)
              .toDouble(),

      favoriteCount:
          int.tryParse(
                map['favoriteCount']
                    .toString(),
              ) ??
              0,

      createdAt:
          map['createdAt'] != null
              ? (map['createdAt']
                      as Timestamp)
                  .toDate()
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
      'createdAt':
          Timestamp.fromDate(createdAt),
    };
  }
}