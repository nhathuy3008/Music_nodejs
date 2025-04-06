import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Comment.dart';
//final String baseUrl = 'http://192.168.155.219:8080/api/comments';
class CommentService {
  final String baseUrl = 'http://10.0.2.2:3000/api/comments';

  //final String baseUrl= 'http://localhost:3000/api/comments';
  // Lấy ID người dùng từ SharedPreferences
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  // Thêm bình luận mới
  Future<Comment> addComment(String commentContent, String songId) async {
    String accountId = await getUserId();

    if (accountId.isEmpty) throw 'Account ID cannot be empty.';
    if (commentContent.trim().isEmpty) throw 'Comment content cannot be empty.';
    if (songId.trim().isEmpty) throw 'Song ID cannot be empty.';

    final commentData = {
      'comment': commentContent,
      'accountId': accountId,
      'songId': songId,
    };

    print("Sending comment data: $commentData");

    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(commentData),
    );

    if (response.statusCode == 201) {
      return Comment.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      String errorMessage = 'Failed to add comment: ${response.statusCode}';
      try {
        final responseBody = jsonDecode(response.body);
        if (responseBody['message'] != null) {
          errorMessage = responseBody['message'];
        }
      } catch (e) {
        print("Error decoding error message: $e");
      }
      throw errorMessage;
    }
  }


  // Lấy tất cả bình luận cho một bài hát
  Future<List<Comment>> getCommentsBySongId(String songId) async {
    final response = await http.get(Uri.parse('$baseUrl/song/$songId'));

    if (response.statusCode == 200) {
      final commentsJson = jsonDecode(utf8.decode(response.bodyBytes));

      // Đảm bảo dữ liệu là List
      if (commentsJson is List) {
        return commentsJson
            .map((json) => Comment.fromJson(json))
            .toList();
      } else {
        throw Exception("Expected a list of comments but got something else");
      }
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}, Body: ${response.body}');
    }
  }



  // Xóa bình luận
  Future<void> deleteComment(String commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$commentId'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // Lấy tổng số bình luận cho một bài hát
  Future<int> getCommentCountBySongId(String songId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/song/$songId/count'),
    );

    if (response.statusCode == 200) {
      // Giải mã UTF-8 và chuyển đổi từ JSON
      String responseBody = utf8.decode(response.bodyBytes);
      return int.parse(responseBody); // Chuyển đổi sang int
    } else {
      throw Exception('Failed to load comment count: ${response.statusCode}, Body: ${response.body}');
    }
  }
}