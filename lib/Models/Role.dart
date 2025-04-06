class Role {
  String id; // UUID or ObjectId, tương tự như trong MongoDB
  String name;

  Role({
    required this.id,
    required this.name,
  });

  // Hàm chuyển JSON thành đối tượng Role
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['_id'] ?? '', // Sử dụng _id thay vì id
      name: json['name'] ?? '',
    );
  }

  // Hàm chuyển đối tượng Role thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Lưu lại _id trong JSON
      'name': name,
    };
  }
}
