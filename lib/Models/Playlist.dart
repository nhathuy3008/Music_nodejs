// class Playlist {
//   int id;
//   String name;
//   String? artist; // Thêm trường artist
//   int? artistId; // Thêm trường artistId
//   String? image;
//   List<int> songIds; // Danh sách ID bài hát
//
//   Playlist({
//     required this.id,
//     required this.name,
//     this.artist, // Thay đổi trường artist thành optional
//     this.artistId, // Thêm trường artistId
//     this.image,
//     required this.songIds,
//   });
//
//   factory Playlist.fromJson(Map<String, dynamic> json) {
//     print(json); // In ra dữ liệu JSON để kiểm tra
//     return Playlist(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? 'Tên Playlist Mặc Định', // Gán mặc định cho name
//       artist: json['artist'] ?? 'Nghệ Sĩ Mặc Định', // Gán mặc định cho artist
//       artistId: json['artistId'], // Lấy artistId từ JSON
//       image: json['image'],
//       songIds: List<int>.from(json['songs']?.map((song) => song['id']) ?? []), // Kiểm tra trường 'songs'
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'artist': artist, // Thêm trường artist vào JSON
//       'artistId': artistId, // Thêm trường artistId vào JSON
//       'image': image,
//       'songIds': songIds,
//     };
//   }
// }
class Playlist {
  String id; // Đổi từ int sang String vì MongoDB lưu ID dạng String
  String name;
  String artist; // Tên nghệ sĩ
  String image; // Đường dẫn hoặc URL ảnh của playlist
  List<String> songIds; // Danh sách ID bài hát (dạng String, vì là ObjectId trong MongoDB)

  Playlist({
    required this.id,
    required this.name,
    required this.artist,
    required this.image,
    required this.songIds,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Tên Playlist Mặc Định',
      artist: json['artist'] ?? 'Nghệ Sĩ Mặc Định',
      image: json['image'] ?? '',
      songIds: List<String>.from(json['songs']?.map((songId) => songId.toString()) ?? []), // Map sang String nếu cần
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'artist': artist,
      'image': image,
      'songs': songIds,
    };
  }
}
