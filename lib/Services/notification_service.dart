import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final String baseUrl = 'http://10.0.2.2:3000/api/notifications';

  Future<List<dynamic>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('userId');
    if (accountId == null) throw Exception("Không tìm thấy userId");

    final response = await http.get(Uri.parse('$baseUrl/$accountId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Lỗi khi lấy thông báo: ${response.body}");
    }
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('userId');
    if (accountId == null) throw Exception("Không tìm thấy userId");

    final response = await http.post(Uri.parse('$baseUrl/mark-read/$accountId'));

    if (response.statusCode != 200) {
      throw Exception("Lỗi khi đánh dấu đã đọc: ${response.body}");
    }
  }
  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('userId');
    if (accountId == null) throw Exception("Không tìm thấy userId");

    final response = await http.get(Uri.parse('$baseUrl/unread-count/$accountId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['unreadCount'];
    } else {
      throw Exception("Lỗi khi lấy số thông báo chưa đọc: ${response.body}");
    }
  }

}
