import 'dart:convert';
import 'package:http/http.dart' as http;

class VerifyService {
  //final String baseUrl = 'http://localhost:3000/api/accounts'; // Cập nhật baseUrl
  final String baseUrl = 'http://10.0.2.2:3000/api/accounts';
  Future<bool> verifyAccount(String verificationCode, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'), // Cập nhật đường dẫn đến verify-code
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'verificationCode': verificationCode, 'email': email}), // Thay đổi key 'code' thành 'verificationCode'
    );

    print('Raw response: ${response.body}'); // In ra phản hồi thô

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print('Xác thực thành công: ${responseBody['message']}');
      return true;
    } else {
      final responseBody = json.decode(response.body);
      print('Có lỗi xảy ra: ${responseBody['message']}');
      return false;
    }
  }
}