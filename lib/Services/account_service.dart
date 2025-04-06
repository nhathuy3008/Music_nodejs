import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AccountService {
  final String baseUrl = 'http://10.0.2.2:3000/api/accounts';
  // final String baseUrl = 'http://192.168.155.219:8080/api/accounts';
  //final String baseUrl= 'http://localhost:3000/api/accounts';
  // Tải hình ảnh từ URL và lưu vào file tạm thời
  Future<File> downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp_image.jpg');

    await file.writeAsBytes(bytes);
    return file;
  }

  // Hàm xử lý phản hồi từ API
  // Future<dynamic> handleResponse(http.Response response) async {
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return json.decode(utf8.decode(response.bodyBytes)); // Giải mã UTF-8
  //   } else {
  //     final errorResponse = json.decode(utf8.decode(response.bodyBytes));
  //     print('Error from API: ${response.statusCode} - ${response.body}');
  //     throw Exception('Error: ${errorResponse['message'] ?? 'Unknown error'}'); // Lấy thông điệp lỗi từ phản hồi
  //   }
  // }
  Future<dynamic> handleResponse(http.Response response) async {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        // Nếu phản hồi không phải JSON, in ra để kiểm tra
        print('Error from API: ${response.statusCode} - ${response.body}');
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error decoding response: $e');
      throw Exception('Failed to decode response: $e');
    }
  }
  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> accountData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(accountData),
      );

      // Kiểm tra mã trạng thái HTTP
      if (response.statusCode == 201) {
        // Tài khoản đã được tạo thành công
        return {'success': true, 'message': response.body};
      } else if (response.statusCode == 400) {
        // Email đã được sử dụng
        return {'success': false, 'message': response.body};
      } else {
        // Xử lý lỗi khác
        print('Error: ${response.statusCode} - ${response.body}');
        return {'success': false, 'message': 'Có lỗi xảy ra!'}; // Trả về phản hồi mặc định
      }
    } catch (e) {
      print('Connection error: $e');
      throw Exception('Cannot connect to API: $e');
    }
  }
  // Lấy tất cả tài khoản
  Future<List<dynamic>> getAllAccounts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }
// Cập nhật tài khoản
  Future<Map<String, dynamic>> updateAccount(String id, Map<String, dynamic> accountData, String? image) async {
    final String url = '$baseUrl/$id';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'fullName': accountData['fullName'],
        'password': accountData['password'],
        'image': image,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Trả về dữ liệu JSON
    } else {
      throw Exception('Cập nhật tài khoản thất bại: ${response.reasonPhrase}');
    }
  }


  // Xóa tài khoản
  Future<Map<String, dynamic>> deleteAccount(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Đăng nhập
  // Future<Map<String, dynamic>> login(String email, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/login'),
  //       headers: {'Content-Type': 'application/json; charset=utf-8'},
  //       body: json.encode({'email': email, 'password': password}), // Gửi email và password trong body
  //     );
  //
  //     return await handleResponse(response);
  //   } catch (e) {
  //     throw Exception('Cannot connect to API: $e');
  //   }
  // }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), // Đảm bảo baseUrl đã được định nghĩa
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'email': email, 'password': password}), // Gửi email và password trong body
      );

      if (response.statusCode == 200) {
        // Nếu login thành công, parse response JSON
        final data = json.decode(response.body);
        return {
          'status': data['status'],
          'message': data['message'],
          'id': data['id'],
          'fullName': data['fullName'],
          'image': data['image'],
          'token': data['token'],  // Lưu token từ API
        };
      } else {
        // Nếu không thành công, trả về lỗi từ API
        final data = json.decode(response.body);
        return {
          'status': data['status'],
          'message': data['message'],
        };
      }
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }
  // Future<String> login(String email, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/login'),
  //       headers: {'Content-Type': 'application/json; charset=utf-8'},
  //       body: json.encode({'email': email, 'password': password}),
  //     );
  //
  //     final responseData = await handleResponse(response);
  //
  //     // Kiểm tra nếu đăng nhập thành công và token có mặt trong phản hồi
  //     if (responseData['status'] == 'thành công' && responseData['token'] != null) {
  //       // Trả về token từ phản hồi
  //       return responseData['token'];
  //     } else {
  //       throw Exception('Login failed: ${responseData['message']}');
  //     }
  //   } catch (e) {
  //     throw Exception('Cannot connect to API: $e');
  //   }
  // }

  // Xác thực mật khẩu
  Future<Map<String, dynamic>> validatePassword(String id, String oldPassword) async {
    try {
      final uri = Uri.parse('$baseUrl/validate-password?id=$id&oldPassword=$oldPassword');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      // Ghi lại phản hồi
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Lấy tổng số người dùng
  Future<int> getTotalUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/total'));
      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'email': email.trim()}), // Gửi email trong body
      );

      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String verificationCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'email': email,
        'verificationCode': verificationCode,
      }),
    );

    return await handleResponse(response);
  }
  Future<Map<String, dynamic>> resetPassword(String email, String verificationCode, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'email': email,
          'verificationCode': verificationCode,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về phản hồi từ API
      } else {
        throw Exception('Failed to reset password: ${response.body}');
      }
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }
}