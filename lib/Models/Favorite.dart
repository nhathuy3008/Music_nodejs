class Favorite {
  String id; // Sử dụng String cho ObjectId
  String accountId; // UUID của Account
  String songId; // ID của Song

  Favorite({
    required this.id,
    required this.accountId,
    required this.songId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'], // Lấy _id từ JSON
      accountId: json['account'], // Sử dụng tên trường từ model Mongoose
      songId: json['song'], // Sử dụng tên trường từ model Mongoose
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Đặt tên trường là _id để phù hợp với MongoDB
      'account': accountId, // Đặt tên trường là account
      'song': songId, // Đặt tên trường là song
    };
  }
}