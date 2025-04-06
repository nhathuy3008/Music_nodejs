class Account {
  String id; // UUID or ObjectId
  String fullName;
  String email;
  String password;
  String? image;
  bool enabled;
  String? verificationToken;
  List<String>? roles; // Mảng roles để lưu các Role IDs

  Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.image,
    this.enabled = false,
    this.verificationToken,
    this.roles,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Người dùng',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      image: json['image'],
      enabled: json['enabled'] ?? false,
      verificationToken: json['verificationToken'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null, // Xử lý mảng roles
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'image': image,
      'enabled': enabled,
      'verificationToken': verificationToken,
      'roles': roles,
    };
  }
}
