class CommentModel {
  final String id;
  final String hotelId;
  final String userId;
  final String userName;
  final String userImage;
  final String comment;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.hotelId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.comment,
    required this.createdAt,
  });

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
    return CommentModel(
      id: id,
      hotelId: map['hotelId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'User',
      userImage: map['userImage'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? map['createdAt'].toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
