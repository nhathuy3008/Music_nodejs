import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../Models/Playlist.dart';
import '../Models/Song.dart';
class PlaylistService {

  final String baseUrl = 'http://10.0.2.2:3000/api/playlists';

  //final String baseUrl = 'http://localhost:8080/api/playlists';
 // final String baseUrl = 'http://192.168.155.219:8080/api/playlists';
  //final String baseUrl= 'http://localhost:3000/api/playlists';
  Future<List<Playlist>> fetchPlaylists() async {
    final response = await http.get(Uri.parse(baseUrl));


    if (response.statusCode == 200) {
      // Sử dụng utf8.decode để đảm bảo mã hóa đúng
      List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      print('Fetched Playlists: $jsonData');
      return jsonData.map((json) => Playlist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load playlists');
    }
  }

  Future<List<Song>> fetchSongs(String playlistId) async {
    final response = await http.get(Uri.parse('$baseUrl/$playlistId/songs'));

    if (response.statusCode == 200) {
      // Decode response thành map, sau đó lấy list từ key 'songs'
      final Map<String, dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> songList = jsonData['songs'];

      return songList.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }


  Future<Map<String, dynamic>> createPlaylist(Playlist playlist, Uint8List imageBytes, String imageFileName) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/create'),
    );

    request.fields['name'] = playlist.name;
    request.fields['artist'] = playlist.artist ?? 'Nghệ Sĩ Mặc Định'; // Gán giá trị mặc định nếu là null

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFileName,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final playlistResponse = Playlist.fromJson(json.decode(responseBody));
      return {'message': 'Playlist đã được tạo thành công!', 'playlist': playlistResponse};
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Lỗi từ API: ${response.statusCode}, Nội dung: $responseBody');
      throw Exception('Không thể tạo playlist: ${responseBody}');
    }
  }
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-song'), // API path bạn định nghĩa bên backend
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'playlistId': playlistId,
        'songId': songId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Bài hát đã được thêm vào playlist thành công!');
    } else {
      final responseBody = utf8.decode(response.bodyBytes);
      print('Lỗi từ API: ${response.statusCode}, Nội dung: $responseBody');
      throw Exception('Không thể thêm bài hát vào playlist: $responseBody');
    }
  }


  // Lấy bài hát theo nghệ sĩ
  Future<List<Song>> fetchSongsByArtist(String artist) async {
    if (artist.isEmpty) {
      return [];
    }

    final response = await http.get(Uri.parse('$baseUrl/songs?artist=$artist'));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> songJson = data['songs'];
      return songJson.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load songs by artist');
    }
  }
}
//final String baseUrl = 'http://localhost:8080/api/playlists'