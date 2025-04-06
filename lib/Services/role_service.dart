import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RoleService {
  final String baseUrl = 'http://10.0.2.2:3000/api/roles';
  final String baseUrl1 = 'http://10.0.2.2:3000/api/songs';
  // Hàm lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');  // Lấy token từ SharedPreferences
  }

  // Lấy tất cả vai trò (chỉ admin)
  Future<List<dynamic>> getAllRoles() async {
    String? token = await _getToken();  // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/roles'),
      headers: {
        'Authorization': 'Bearer $token',  // Truyền token vào header
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể tải các vai trò');
    }
  }

  // Lấy vai trò theo ID (chỉ admin)
  Future<Map<String, dynamic>> getRoleById(String roleId) async {
    String? token = await _getToken();  // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/roles/$roleId'),
      headers: {
        'Authorization': 'Bearer $token',  // Truyền token vào header
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể tìm thấy vai trò');
    }
  }

  // Tạo vai trò mới (chỉ admin)
  Future<Map<String, dynamic>> createRole(Map<String, dynamic> roleData) async {
    String? token = await _getToken();  // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/roles/create'),
      headers: {
        'Authorization': 'Bearer $token',  // Truyền token vào header
        'Content-Type': 'application/json',
      },
      body: json.encode(roleData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể tạo vai trò');
    }
  }

  // Cập nhật vai trò (chỉ admin)
  Future<Map<String, dynamic>> updateRole(String roleId, Map<String, dynamic> roleData) async {
    String? token = await _getToken();  // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/roles/$roleId'),
      headers: {
        'Authorization': 'Bearer $token',  // Truyền token vào header
        'Content-Type': 'application/json',
      },
      body: json.encode(roleData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể cập nhật vai trò');
    }
  }

  // Xóa vai trò (chỉ admin)
  Future<Map<String, dynamic>> deleteRole(String roleId) async {
    String? token = await _getToken();  // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/roles/$roleId'),
      headers: {
        'Authorization': 'Bearer $token',  // Truyền token vào header
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể xóa vai trò');
    }
  }

  // Gán vai trò cho tài khoản (chỉ admin)
// Trong RoleService.dart
  Future<Map<String, dynamic>> updateSongStatus(String songId, String status) async {
    String? token = await _getToken();  // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    // Kiểm tra nếu trạng thái hợp lệ
    if (!['approved', 'rejected'].contains(status)) {
      throw Exception('Trạng thái không hợp lệ!');
    }

    final response = await http.post(
      Uri.parse('$baseUrl1/$songId/status'),  // Gọi API cập nhật trạng thái bài hát
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Trả về thông tin bài hát đã được cập nhật
    } else {
      throw Exception('Không thể cập nhật trạng thái bài hát');
    }
  }

  Future<List<dynamic>> getAllSongsPending() async {
    String? token = await _getToken();  // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    final response = await http.get(
      Uri.parse('$baseUrl1/pending'),  // Gọi API để lấy bài hát với trạng thái 'pending'
      headers: {
        'Authorization': 'Bearer $token',  // Truyền token vào header
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Trả về danh sách bài hát
    } else {
      throw Exception('Không thể tải danh sách bài hát đang chờ duyệt');
    }
  }
  Future<Map<String, dynamic>> playSongByIdPending(String songId) async {
    String? token = await _getToken(); // Lấy token

    if (token == null) {
      throw Exception('Token không tồn tại');
    }

    final response = await http.get(
      Uri.parse('$baseUrl1/play/$songId/pending'), // Gọi API phát bài hát pending
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Trả về URL bài hát
    } else {
      throw Exception('Không thể phát bài hát có trạng thái pending');
    }
  }
  Future<Map<String, dynamic>> getSongById(String songId) async {
    final response = await http.get(
      Uri.parse('$baseUrl1/$songId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> songData = json.decode(response.body);

      // Kiểm tra lại và cập nhật các trường dữ liệu nếu cần
      return {
        'id': songData['_id'],  // Lấy _id thay vì id nếu cần
        'name': songData['name'],
        'artist': songData['artist'],
        'url': songData['url'],
        'image': songData['image'],
        'category': songData['category'],
        'likeCount': songData['likeCount'],
      };
    } else {
      throw Exception('Không thể lấy thông tin bài hát');
    }
  }


}
