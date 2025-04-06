class Comment {
  final String id; // ID bình luận (có thể là ObjectId)
  final String content; // Nội dung bình luận
  final String accountId; // ID người dùng
  final String fullName; // Tên người dùng
  final String songId; // ID bài hát

  Comment({
    required this.id,
    required this.content,
    required this.accountId,
    required this.fullName,
    required this.songId,
  });

  // Phương thức chuyển đổi từ JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      content: json['comment'] ?? '',
      accountId: json['account']?['_id'] ?? '',
      fullName: json['account']?['fullName'] ?? 'Unknown',
      songId: json['song']?.toString() ?? '', // ✅ Đã sửa ở đây
    );
  }


  // Phương thức chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Sử dụng _id cho ObjectId
      'comment': content.isNotEmpty ? content : 'No content provided',
      'account': {
        '_id': accountId.isNotEmpty ? accountId : 'Unknown',
        'fullName': fullName.isNotEmpty ? fullName : 'Unknown',
      },
      'song': {
        '_id': songId.isNotEmpty ? songId : 'Unknown',
      },
    };
  }
}