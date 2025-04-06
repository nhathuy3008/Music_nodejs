// import 'package:flutter/material.dart';
// import './login_page.dart';
// import 'register_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import './accountupdate_page.dart';
// import '../Services/playlist_service.dart';
// import '../Models/Playlist.dart';
// import './song_in_playlist.dart';
// import 'search.dart';
// import './create_song.dart';
// import './create_playlist.dart';
// import '../Models/Favorite.dart';
// import '../Screens/list_favorite.dart';
// import '../Services/song_service.dart';
// import '../Models/Song.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String? userId;
//   String? fullName;
//   String? image;
//   List<Playlist> playlists = [];
//   List<Song> popularSongs = [];
//   final PlaylistService _playlistService = PlaylistService();
//   final SongService _songService = SongService();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _fetchPlaylists();
//     _fetchPopularSongs();
//   }
//
//   _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     setState(() {
//       userId = prefs.getString('userId');
//       fullName = prefs.getString('fullName');
//       image = prefs.getString('image');
//     });
//
//     // Lấy token và in ra console
//     final token = prefs.getString('token');
//     print('Token: $token');  // In token ra console
//
//     // In thông tin người dùng ra console
//     print('User ID: $userId');
//     print('Full Name: $fullName');
//     print('Image: $image');
//   }
//
//   _fetchPlaylists() async {
//     try {
//       List<Playlist> fetchedPlaylists = await _playlistService.fetchPlaylists();
//       setState(() {
//         playlists = fetchedPlaylists;
//       });
//     } catch (e) {
//       print('Error fetching playlists: $e');
//     }
//   }
//
//   _fetchPopularSongs() async {
//     try {
//       List<Song> fetchedPopularSongs = await _songService.getPopularSongs();
//       setState(() {
//         popularSongs = fetchedPopularSongs;
//       });
//     } catch (e) {
//       print('Error fetching popular songs: $e');
//     }
//   }
//
//   _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('userId');
//     await prefs.remove('fullName');
//     await prefs.remove('image');
//     setState(() {
//       userId = null;
//       fullName = null;
//       image = null;
//     });
//   }
//
//   void _showLoginPrompt(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _onItemTapped(int index) {
//     if (index == 0) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//     } else if (index == 1) {
//       if (userId == null) {
//         _showLoginPrompt('Vui lòng đăng nhập để tìm kiếm bài hát.');
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SearchScreen()),
//         );
//       }
//     } else if (index == 2) {
//       if (userId == null) {
//         _showLoginPrompt('Vui lòng đăng nhập để xem bài hát yêu thích.');
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FavoriteSongsPage(accountId: userId!)),
//         );
//       }
//     } else if (index == 3) {
//       if (userId == null) {
//         _showLoginPrompt('Vui lòng đăng nhập để quản lý thông tin cá nhân.');
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AccountUpdatePage()),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final double baseFontSize = screenSize.width * 0.025;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: fullName != null
//             ? Row(
//           children: [
//             if (image != null && image!.isNotEmpty)
//               CircleAvatar(
//                 backgroundImage: NetworkImage(image!),
//                 radius: baseFontSize * 2,
//               ),
//             SizedBox(width: 8),
//             Text('Chào, $fullName', style: TextStyle(fontSize: baseFontSize * 1.5)),
//           ],
//         )
//             : Text('Trang chủ'),
//         backgroundColor: Color(0xFF755DC1),
//         actions: [
//           if (userId != null)
//             IconButton(
//               icon: Icon(Icons.add, color: Colors.black),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CreatePlaylistPage()),
//                 );
//               },
//             ),
//           if (fullName != null)
//             IconButton(
//               icon: Icon(Icons.logout, color: Colors.black),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text('Xác nhận đăng xuất'),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           _logout();
//                           Navigator.of(context).pop();
//                         },
//                         child: Text('Có'),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: Text('Không'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//           else
//             Row(
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginPage()),
//                     );
//                   },
//                   child: Text(
//                     'Đăng nhập',
//                     style: TextStyle(
//                       fontSize: baseFontSize,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => RegisterPage()),
//                     );
//                   },
//                   child: Text(
//                     'Đăng ký',
//                     style: TextStyle(
//                       fontSize: baseFontSize,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Text(
//               'Danh sách album',
//               style: TextStyle(fontSize: baseFontSize * 2, fontWeight: FontWeight.bold, color: Color(0xFF755DC1)),
//             ),
//           ),
//           SizedBox(height: 5),
//           ...playlists.map((playlist) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: GestureDetector(
//                   onTap: userId != null
//                       ? () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SongListPage(playlist: playlist),
//                       ),
//                     );
//                   }
//                       : () => _showLoginPrompt('Vui lòng đăng nhập để xem danh sách bài hát.'),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (playlist.image != null && playlist.image!.isNotEmpty)
//                         ClipRRect(
//                           borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 60.0),
//                             child: Container(
//                               height: screenSize.height * 0.2,
//                               width: double.infinity,
//                               child: Image.network(
//                                 playlist.image!,
//                                 fit: BoxFit.fill,
//                               ),
//                             ),
//                           ),
//                         ),
//                       SizedBox(height: 8),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           playlist.name,
//                           style: TextStyle(fontSize: baseFontSize * 1.5, fontWeight: FontWeight.bold, color: Color(0xFF755DC1)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//           SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Text(
//               'Các bài hát đang Hot hiện nay',
//               style: TextStyle(fontSize: baseFontSize * 2, fontWeight: FontWeight.bold, color: Color(0xFF755DC1)),
//             ),
//           ),
//           SizedBox(height: 10),
//           ...popularSongs.map((song) {
//             return ListTile(
//               leading: song.image != null && song.image!.isNotEmpty
//                   ? ClipOval(
//                 child: Image.network(
//                   song.image!,
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               )
//                   : Icon(Icons.music_note),
//               title: Text(song.name),
//               subtitle: Text(song.artist),
//               onTap: () {
//                 // Navigate to song details or play the song
//               },
//             );
//           }).toList(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 14),
//                 Icon(Icons.home, size: baseFontSize * 1.5),
//                 SizedBox(height: 4),
//                 Text('Trang chủ', style: TextStyle(fontSize: baseFontSize)),
//               ],
//             ),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.search, size: baseFontSize * 1.5),
//                 SizedBox(height: 4),
//                 Text('Tìm kiếm', style: TextStyle(fontSize: baseFontSize)),
//               ],
//             ),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.favorite, size: baseFontSize * 1.5),
//                 SizedBox(height: 4),
//                 Text('Yêu thích', style: TextStyle(fontSize: baseFontSize)),
//               ],
//             ),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (image != null && image!.isNotEmpty)
//                   CircleAvatar(
//                     backgroundImage: NetworkImage(image!),
//                     radius: baseFontSize * 0.8,
//                   )
//                 else
//                   Icon(
//                     Icons.person,
//                     size: baseFontSize * 1.5,
//                     color: Colors.grey,
//                   ),
//                 SizedBox(height: 4),
//                 Text(
//                   fullName != null ? fullName! : 'Cá nhân',
//                   style: TextStyle(color: Colors.grey, fontSize: baseFontSize),
//                 ),
//               ],
//             ),
//             label: '',
//           ),
//         ],
//         currentIndex: 0,
//         selectedItemColor: Color(0xFF755DC1),
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//       ),
//       floatingActionButton: userId != null
//           ? FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => CreateSongPage()),
//           );
//         },
//         child: Icon(Icons.upload_file),
//         backgroundColor: Color(0xFF755DC1),
//       )
//           : null,
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }

import 'package:flutter/material.dart';
import './login_page.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './accountupdate_page.dart';
import '../Services/playlist_service.dart';
import '../Models/Playlist.dart';
import './song_in_playlist.dart';
import 'search.dart';
import './create_song.dart';
import './create_playlist.dart';
import '../Models/Favorite.dart';
import '../Screens/list_favorite.dart';
import '../Services/song_service.dart';
import '../Models/Song.dart';
import './AdminManage.dart'; // Import AdminPage
import '../pages/notification_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';  // Thêm package để giải mã JWT
import '../Services/notification_service.dart';
import './play_song.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;
  String? fullName;
  String? image;
  bool isAdmin = false;  // Biến mới để xác định xem người dùng có phải admin không
  int unreadNotifications = 0; // Thêm biến này
  List<Playlist> playlists = [];
  List<Song> popularSongs = [];
  final PlaylistService _playlistService = PlaylistService();
  final SongService _songService = SongService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchPlaylists();
    _fetchPopularSongs();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('userId');
      fullName = prefs.getString('fullName');
      image = prefs.getString('image');
    });

    final token = prefs.getString('token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (decodedToken['roles'] != null && decodedToken['roles'].contains('Admin')) {
        setState(() {
          isAdmin = true;
        });
      }
    }

    if (userId != null) {
      _fetchUnreadNotifications(); // Cập nhật số thông báo chưa đọc
    }
  }

  void _fetchUnreadNotifications() async {
    try {
      int count = await NotificationService().getUnreadCount();
      setState(() {
        unreadNotifications = count;
      });
      print("Số thông báo chưa đọc: $unreadNotifications"); // In ra console để kiểm tra
    } catch (e) {
      print('Lỗi khi lấy số lượng thông báo chưa đọc: $e');
    }
  }



  _fetchPlaylists() async {
    try {
      List<Playlist> fetchedPlaylists = await _playlistService.fetchPlaylists();
      setState(() {
        playlists = fetchedPlaylists;
      });
    } catch (e) {
      print('Error fetching playlists: $e');
    }
  }

  _fetchPopularSongs() async {
    try {
      List<Song> fetchedPopularSongs = await _songService.getPopularSongs();
      setState(() {
        popularSongs = fetchedPopularSongs;
      });
    } catch (e) {
      print('Error fetching popular songs: $e');
    }
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('fullName');
    await prefs.remove('image');
    await prefs.remove('token');  // Đảm bảo xóa token khi đăng xuất
    setState(() {
      userId = null;
      fullName = null;
      image = null;
      isAdmin = false; // Khi đăng xuất, reset isAdmin
    });
  }

  void _showLoginPrompt(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 1) {
      if (userId == null) {
        _showLoginPrompt('Vui lòng đăng nhập để tìm kiếm bài hát.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        );
      }
    } else if (index == 2) {
      if (userId == null) {
        _showLoginPrompt('Vui lòng đăng nhập để xem bài hát yêu thích.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoriteSongsPage(accountId: userId!)),
        );
      }
    } else if (index == 3) {
      if (userId == null) {
        _showLoginPrompt('Vui lòng đăng nhập để quản lý thông tin cá nhân.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountUpdatePage()),
        );
      }
    } else if (index == 4 && isAdmin) {  // Nếu là admin, chuyển tới AdminPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminManage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double baseFontSize = screenSize.width * 0.025;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: fullName != null
            ? Row(
          children: [
            if (image != null && image!.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(image!),
                radius: baseFontSize * 2,
              ),
            SizedBox(width: 8),
            Text('Chào, $fullName', style: TextStyle(fontSize: baseFontSize * 1.5)),
          ],
        )
            : Text('Trang chủ'),
        backgroundColor: Color(0xFF755DC1),
        actions: [
          if (userId != null)
            IconButton(
              icon: Icon(Icons.add, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePlaylistPage()),
                );
              },
            ),

          if (userId != null)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage()),
                    );
                    _fetchUnreadNotifications();
                  },
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // viền trắng mỏng tạo cảm giác "trong suốt"
                          width: 1,
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Center(
                        child: Text(
                          unreadNotifications.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),



          if (fullName != null)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Xác nhận đăng xuất'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _logout();
                          Navigator.of(context).pop();
                        },
                        child: Text('Có'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Không'),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: baseFontSize,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontSize: baseFontSize,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
        ],

      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Danh sách album',
              style: TextStyle(fontSize: baseFontSize * 2, fontWeight: FontWeight.bold, color: Color(0xFF755DC1)),
            ),
          ),
          SizedBox(height: 5),
          ...playlists.map((playlist) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GestureDetector(
                  onTap: userId != null
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongListPage(playlist: playlist),
                      ),
                    );
                  }
                      : () => _showLoginPrompt('Vui lòng đăng nhập để xem danh sách bài hát.'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (playlist.image != null && playlist.image!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60.0),
                            child: Container(
                              height: screenSize.height * 0.2,
                              width: double.infinity,
                              child: Image.network(
                                playlist.image!,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          playlist.name,
                          style: TextStyle(fontSize: baseFontSize * 1.5, fontWeight: FontWeight.bold, color: Color(0xFF755DC1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Các bài hát đang Hot hiện nay',
              style: TextStyle(fontSize: baseFontSize * 2, fontWeight: FontWeight.bold, color: Color(0xFF755DC1)),
            ),
          ),
          SizedBox(height: 10),
          ...popularSongs.asMap().entries.map((entry) {
            int index = entry.key;
            Song song = entry.value;
            return ListTile(
              leading: song.image != null && song.image!.isNotEmpty
                  ? ClipOval(
                child: Image.network(
                  song.image!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(Icons.music_note),
              title: Text(song.name),
              subtitle: Text(song.artist),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaySongScreen(
                      playlist: popularSongs,
                      currentSongIndex: index,
                      accountId: userId ?? '',
                    ),
                  ),
                );
              },

            );
          }).toList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 14),
                Icon(Icons.home, size: baseFontSize * 1.5),
                SizedBox(height: 4),
                Text('Trang chủ', style: TextStyle(fontSize: baseFontSize)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: baseFontSize * 1.5),
                SizedBox(height: 4),
                Text('Tìm kiếm', style: TextStyle(fontSize: baseFontSize)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: baseFontSize * 1.5),
                SizedBox(height: 4),
                Text('Yêu thích', style: TextStyle(fontSize: baseFontSize)),
              ],
            ),
            label: '',
          ),


          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (image != null && image!.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(image!),
                    radius: baseFontSize * 0.8,
                  )
                else
                  Icon(
                    Icons.person,
                    size: baseFontSize * 1.5,
                    color: Colors.grey,
                  ),
                SizedBox(height: 4),
                Text(
                  fullName != null ? fullName! : 'Cá nhân',
                  style: TextStyle(color: Colors.grey, fontSize: baseFontSize),
                ),
              ],
            ),
            label: '',
          ),
          if (isAdmin)  // Hiển thị item "Admin" nếu là admin
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: baseFontSize * 1.5),
                  SizedBox(height: 4),
                  Text('Admin', style: TextStyle(fontSize: baseFontSize)),
                ],
              ),
              label: '',
            ),
        ],
        currentIndex: 0,
        selectedItemColor: Color(0xFF755DC1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,

      ),
            floatingActionButton: userId != null
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateSongPage()),
          );
        },
        child: Icon(Icons.upload_file),
        backgroundColor: Color(0xFF755DC1),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

