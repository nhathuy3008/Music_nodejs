import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../Models/Song.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SongService {
  //final String baseUrl = 'http://localhost:8080/api/songs';
  final String baseUrl = 'http://10.0.2.2:3000/api/songs';
  //final String baseUrl = 'http://192.168.155.219:8080/api/songs';
  //final String baseUrl = 'http://localhost:3000/api/songs';

  Future<List<Song>> findSongsByName(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/find/$name'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<Song> songs = jsonResponse.map((song) => Song.fromJson(song)).toList();

      // In ra console danh sách bài hát
      for (var song in songs) {
        print('Song: ${song.name}, Artist: ${song.artist}, URL: ${song.url}');
      }

      return songs;
    } else if (response.statusCode == 404) {
      print('Không tìm thấy bài hát.');
      throw Exception('Không tìm thấy bài hát');
    } else {
      print('Lỗi: Không thể tải bài hát - ${response.statusCode}');
      throw Exception('Không thể tải bài hát: ${response.statusCode}');
    }
  }

  /// Lấy tất cả bài hát từ API.
  Future<List<Song>> getAllSongs() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<Song> songs = jsonResponse.map((song) => Song.fromJson(song)).toList();

      // In ra console danh sách bài hát
      for (var song in songs) {
        print('Song: ${song.name}, Artist: ${song.artist}, URL: ${song.url}');
      }

      return songs;
    } else {
      print('Lỗi: Không thể tải danh sách bài hát.');
      throw Exception('Không thể tải danh sách bài hát');
    }
  }


  Future<Song> createSong(
      Song song,
      Uint8List audioBytes,
      String audioFileName,
      Uint8List? imageBytes,
      String? imageFileName,
      ) async {
    // 🔒 Lấy accountId từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('accountId');

    if (accountId == null) {
      throw Exception('Không tìm thấy tài khoản người dùng!');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl'), // Đảm bảo đúng URL API
    );

    // Thêm các field bắt buộc
    request.fields['name'] = song.name;
    request.fields['artist'] = song.artist;
    request.fields['category'] = song.genreId ?? '';
    request.fields['account'] = accountId; // 👈 Rất quan trọng

    // Thêm file nhạc
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: audioFileName,
      ),
    );

    // Nếu có ảnh thì thêm
    if (imageBytes != null && imageFileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName,
        ),
      );
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final decoded = json.decode(responseBody);
        return Song.fromJson(decoded['song']); // giả sử API trả về { message, song }
      } else {
        final responseBody = await response.stream.bytesToString();
        print('❌ Lỗi từ API: ${response.statusCode}, $responseBody');
        throw Exception('Không thể tạo bài hát.');
      }
    } catch (e) {
      print('⚠️ Lỗi khi gửi yêu cầu: $e');
      throw Exception('Lỗi mạng hoặc kết nối.');
    }
  }
  // Cập nhật bài hát
  Future<Song> updateSong(Song song) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${song.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(song.toJson()),
    );

    if (response.statusCode == 200) {
      return Song.fromJson(json.decode(response.body));
    } else {
      throw Exception('Không thể cập nhật bài hát.');
    }
  }

  // Xóa bài hát
  Future<void> deleteSong(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Xóa thành công, bạn có thể xử lý thêm nếu muốn
      final responseData = jsonDecode(response.body);
      print(responseData['message']);
    } else if (response.statusCode == 404) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message']); // "Bài hát không tìm thấy hoặc chưa được duyệt"
    } else {
      throw Exception('Lỗi khi xóa bài hát: ${response.reasonPhrase}');
    }
  }

  Future<String> playSong(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/play/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Giả sử API trả về URL của bài hát
      return jsonDecode(response.body)['url']; // Cập nhật để lấy URL từ phản hồi
    } else if (response.statusCode == 404) {
      throw Exception('Bài hát không tồn tại.');
    } else {
      throw Exception('Lỗi khi phát bài hát: ${response.statusCode}');
    }
  }
  Future<List<Song>> getPopularSongs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/popular'), // URL mới để lấy bài hát phổ biến
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<Song> songs = jsonResponse.map((song) => Song.fromJson(song)).toList();

      // In ra console danh sách bài hát
      for (var song in songs) {
        print('Song: ${song.name}, Artist: ${song.artist}, URL: ${song.url}, Likes: ${song.likeCount}');
      }

      return songs;
    } else {
      print('Lỗi: Không thể tải danh sách bài hát phổ biến.');
      throw Exception('Không thể tải danh sách bài hát phổ biến');
    }
  }
}