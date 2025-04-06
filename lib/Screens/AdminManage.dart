import 'package:flutter/material.dart';
import 'adminpage.dart'; // Import trang AdminPage của bạn
import 'Manage_song.dart';
class AdminManage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Manage"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Các mục quản lý khác ở đây

            // Mục xét duyệt bài hát
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text("Xét duyệt bài hát"),
              onTap: () {
                // Khi bấm vào sẽ điều hướng tới trang AdminPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.library_music),
              title: Text("Quản lý bài hát"),
              onTap: () {
                // Khi bấm vào sẽ điều hướng tới trang AdminPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageSong()),
                );
              },
            ),

            // Các mục khác có thể thêm vào đây
          ],
        ),
      ),
    );
  }
}
