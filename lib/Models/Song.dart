// class Song {
//   String id; // Thay đổi từ int thành String
//   String name;
//   String artist;
//   String url; // Đường dẫn file nhạc
//   String? image; // Hình ảnh có thể là null
//   String? genreId;
//   int likeCount;
//
//   Song({
//     required this.id,
//     required this.name,
//     required this.artist,
//     required this.url,
//     this.image,
//     required this.genreId,
//     required this.likeCount,
//   });
//
//   factory Song.fromJson(Map<String, dynamic> json) {
//     return Song(
//       id: json['_id'] ?? '', // Lấy id từ trường _id trong JSON
//       name: json['name'] ?? 'Unknown',
//       artist: json['artist'] ?? 'Unknown Artist',
//       url: json['url'] ?? '',
//       image: json['image'] ?? null,
//       genreId: json['category'] ?? null, // Cập nhật để lấy category
//       likeCount: json['likeCount'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'artist': artist,
//       'url': url,
//       'image': image,
//       'category': genreId, // Cập nhật để sử dụng category
//       'likeCount': likeCount,
//     };
//   }
// }
class Song {
  String id;
  String name;
  String artist;
  String url;
  String? image;
  String? genreId;
  int likeCount;
  int commentCount;
  String status;
  String accountId;

  Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.url,
    this.image,
    required this.genreId,
    required this.likeCount,
    required this.commentCount,
    required this.status,
    required this.accountId,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown Artist',
      url: json['url'] ?? '',
      image: json['image'],
      genreId: json['category'],
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      status: json['status'] ?? 'pending',
      accountId: json['account'] is Map<String, dynamic>
          ? json['account']['_id'] ?? ''
          : json['account'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artist': artist,
      'url': url,
      'image': image,
      'category': genreId,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'status': status,
      'account': accountId,
    };
  }
}
