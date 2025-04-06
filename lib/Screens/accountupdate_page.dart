import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/account_service.dart';
import 'dart:io';
import 'dart:convert';

class AccountUpdatePage extends StatefulWidget {
  @override
  _AccountUpdatePageState createState() => _AccountUpdatePageState();
}

class _AccountUpdatePageState extends State<AccountUpdatePage> {
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  final AccountService _accountService = AccountService();
  bool _isChangingPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('fullName') ?? '';
      _imagePath = prefs.getString('imageUrl');
    });
  }

  Future<String?> _encodeImageToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return 'data:image/jpeg;base64,' + base64.encode(bytes);
  }

  Future<void> _updateAccount() async {
    final String userId = (await SharedPreferences.getInstance()).getString('userId') ?? '';

    if (userId.isEmpty) {
      _showErrorDialog('ID tài khoản không hợp lệ');
      return;
    }

    final String fullName = _usernameController.text;
    if (fullName.isEmpty) {
      _showErrorDialog('Tên người dùng không được để trống.');
      return;
    }

    final Map<String, dynamic> accountData = {
      'fullName': fullName,
    };

    if (_isChangingPassword && _newPasswordController.text.isNotEmpty) {
      final isValidPassword = await _accountService.validatePassword(userId, _oldPasswordController.text);
      if (isValidPassword['status'] != 'thành công') {
        _showErrorDialog('Mật khẩu cũ không đúng, vui lòng thử lại.');
        return;
      }

      if (_newPasswordController.text != _confirmPasswordController.text) {
        _showErrorDialog('Mật khẩu mới và xác nhận không trùng nhau.');
        return;
      }

      accountData['password'] = _newPasswordController.text;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageBase64;

      // Nếu có hình ảnh, mã hóa nó thành base64
      if (_imagePath != null && _imagePath!.isNotEmpty) {
        imageBase64 = await _encodeImageToBase64(_imagePath!);
      }

      final result = await _accountService.updateAccount(userId, accountData, imageBase64);
      final prefs = await SharedPreferences.getInstance();

      // Cập nhật dữ liệu trong SharedPreferences
      await prefs.setString('fullName', accountData['fullName']);
      if (result['account']['image'] != null) {
        await prefs.setString('imageUrl', result['account']['image']);
      }

      // Notify success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thành công! Đăng xuất để áp dụng thay đổi.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog('Lỗi: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Cập nhật tài khoản', style: TextStyle(fontSize: 24)),
        backgroundColor: Color(0xFF755DC1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/vector-3.png",
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Color(0xFF755DC1)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isChangingPassword,
                    onChanged: (value) {
                      setState(() {
                        _isChangingPassword = value!;
                        _oldPasswordController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      });
                    },
                  ),
                  Text('Thay đổi mật khẩu'),
                ],
              ),
              if (_isChangingPassword) ...[
                TextField(
                  controller: _oldPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu cũ',
                    labelStyle: TextStyle(color: Color(0xFF755DC1)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    labelStyle: TextStyle(color: Color(0xFF755DC1)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    labelStyle: TextStyle(color: Color(0xFF755DC1)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: Color(0xFF9F7BFF)),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Chọn ảnh đại diện', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9F7BFF),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (_imagePath != null && _imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: _imagePath!.startsWith('http')
                      ? Image.network(
                    _imagePath!,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    File(_imagePath!),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9F7BFF),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Cập nhật',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}