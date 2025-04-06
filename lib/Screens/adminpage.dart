
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/role_service.dart';
import 'play_song_pending.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<dynamic> songs = [];
  RoleService _roleService = RoleService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSongsPending();
  }

  // Lấy danh sách bài hát đang chờ duyệt từ API
  _fetchSongsPending() async {
    try {
      List<dynamic> fetchedSongs = await _roleService.getAllSongsPending();
      setState(() {
        songs = fetchedSongs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi tải bài hát: $e'),
      ));
    }
  }

  // Hàm cập nhật trạng thái bài hát
  _updateSongStatus(String? songId, String status) async {
    if (songId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ID bài hát không hợp lệ!'),
      ));
      return;
    }

    try {
      // Gọi phương thức cập nhật trạng thái bài hát từ RoleService
      await _roleService.updateSongStatus(songId, status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bài hát đã được $status'),
      ));
      // Sau khi cập nhật trạng thái, reload lại danh sách bài hát
      _fetchSongsPending();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi cập nhật trạng thái bài hát: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Bài Hát'),
        backgroundColor: Color(0xFF755DC1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh sách bài hát đang chờ duyệt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF755DC1),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  var song = songs[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(song['name'] ?? 'Không tên'),
                      subtitle: Text('Nghệ sĩ: ${song['artist'] ?? 'Chưa có mô tả'}'),
                      onTap: () {
                        if (song['_id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaySongPending(songId: song['_id']),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('ID bài hát không hợp lệ!'),
                          ));
                        }
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nút duyệt bài hát
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: song['_id'] != null
                                ? () => _updateSongStatus(song['_id'], 'approved')
                                : null,
                          ),
                          // Nút từ chối bài hát
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: song['_id'] != null
                                ? () => _updateSongStatus(song['_id'], 'rejected')
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
