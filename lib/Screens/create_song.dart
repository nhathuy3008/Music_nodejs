// import 'dart:typed_data';
// import 'dart:io'; // Thêm import này
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import '../Models/Song.dart';
// import '../Models/Genre.dart';
// import '../Services/song_service.dart';
// import '../Services/genre_service.dart';
//
// class CreateSongPage extends StatefulWidget {
//   @override
//   _CreateSongPageState createState() => _CreateSongPageState();
// }
//
// class _CreateSongPageState extends State<CreateSongPage> {
//   final _formKey = GlobalKey<FormState>();
//   final SongService _songService = SongService();
//   final GenreService _genreService = GenreService();
//   final ImagePicker _picker = ImagePicker();
//
//   String? name;
//   String? artist;
//   String? audioPath;
//   Uint8List? bytes;
//   String? image;
//   int genreId = 1;
//   List<Genre> genres = [];
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchGenres();
//   }
//
//   _fetchGenres() async {
//     try {
//       genres = await _genreService.fetchGenres();
//       setState(() {});
//     } catch (e) {
//       print('Error fetching genres: $e');
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         image = pickedFile.path;
//       });
//     }
//   }
//
//   Future<void> _pickAudio() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//     );
//
//     if (result != null && result.files.isNotEmpty) {
//       audioPath = result.files.first.path;
//
//       // Đọc bytes từ tệp âm thanh
//       if (audioPath != null) {
//         bytes = await File(audioPath!).readAsBytes();
//       }
//
//       print('Audio Path: $audioPath');
//       print('Bytes: ${bytes != null}'); // Kiểm tra bytes
//     } else {
//       print('No audio file selected.');
//     }
//   }
//
//   void _submit() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//
//       if (audioPath == null || bytes == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Vui lòng chọn tệp âm thanh.')),
//         );
//         return;
//       }
//
//       setState(() {
//         isLoading = true;
//       });
//
//       try {
//         Song newSong = Song(
//           id: 0,
//           name: name!,
//           artist: artist!,
//           url: audioPath!,
//           image: image,
//           genreId: genreId,
//           likeCount: 0,
//         );
//
//         print('Submitting song: $newSong');
//         await _songService.createSong(newSong, bytes!, audioPath!);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Bài hát đã được thêm thành công!')),
//         );
//
//         _formKey.currentState!.reset();
//         setState(() {
//           audioPath = null;
//           image = null;
//           bytes = null;
//           isLoading = false;
//         });
//       } catch (e) {
//         print('Error during song submission: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Lỗi: $e'),
//             duration: Duration(seconds: 5),
//           ),
//         );
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Thêm Bài Hát Mới'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Tên Bài Hát'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập tên bài hát';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => name = value,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Nghệ Sĩ'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập tên nghệ sĩ';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => artist = value,
//               ),
//               GestureDetector(
//                 onTap: _pickAudio,
//                 child: AbsorbPointer(
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Tệp Âm Thanh',
//                       hintText: audioPath != null ? audioPath!.split('/').last : 'Chọn tệp âm thanh',
//                     ),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: AbsorbPointer(
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Hình Ảnh',
//                       hintText: image != null ? image!.split('/').last : 'Chọn hình ảnh',
//                     ),
//                   ),
//                 ),
//               ),
//               DropdownButtonFormField<int>(
//                 value: genreId,
//                 decoration: InputDecoration(labelText: 'Chọn Thể Loại'),
//                 items: genres.map((genre) {
//                   return DropdownMenuItem<int>(
//                     value: genre.id,
//                     child: Text(genre.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     genreId = value!;
//                   });
//                 },
//               ),
//               SizedBox(height: 20),
//               isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : ElevatedButton(
//                 onPressed: _submit,
//                 child: Text('Thêm Bài Hát'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../Models/Song.dart';
import '../Models/Genre.dart';
import '../Services/song_service.dart';
import '../Services/genre_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CreateSongPage extends StatefulWidget {
  @override
  _CreateSongPageState createState() => _CreateSongPageState();
}

class _CreateSongPageState extends State<CreateSongPage> {
  final _formKey = GlobalKey<FormState>();
  final SongService _songService = SongService();
  final GenreService _genreService = GenreService();
  final ImagePicker _picker = ImagePicker();

  String? name;
  String? artist;
  String? audioPath;
  Uint8List? audioBytes;
  Uint8List? imageBytes;
  String? genreId; // Đổi thành String? để phù hợp với genre.id
  List<Genre> genres = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  _fetchGenres() async {
    try {
      genres = await _genreService.fetchGenres();
      setState(() {});
    } catch (e) {
      print('Error fetching genres: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageBytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          print('Selected image path: ${pickedFile.path}');
        });
      } else {
        print('No image selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn hình ảnh.')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn hình ảnh: $e')),
      );
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      audioPath = result.files.first.path;
      if (audioPath != null) {
        audioBytes = await File(audioPath!).readAsBytes();
      }

      print('Audio Path: $audioPath');
      print('Bytes: ${audioBytes != null}');
    } else {
      print('No audio file selected.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn tệp âm thanh.')),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (audioPath == null || audioBytes == null || imageBytes == null || genreId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn tệp âm thanh, hình ảnh và thể loại.')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        // ✅ Lấy accountId từ SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        print('DEBUG accountId: ${prefs.getString('accountId')}');
        final accountId = prefs.getString('accountId');

        if (accountId == null) {
          throw Exception('Không tìm thấy accountId trong bộ nhớ cục bộ!');
        }


        Song newSong = Song(
          id: '', // Tạm thời để trống
          name: name!,
          artist: artist!,
          url: audioPath!,
          image: '',
          genreId: genreId!,
          likeCount: 0,
          commentCount: 0,         // ✅ Thêm mặc định
          status: 'pending',       // ✅ Ví dụ: trạng thái chờ duyệt
          accountId: accountId,    // ✅ từ SharedPreferences
        );

        await _songService.createSong(
          newSong,
          audioBytes!,
          audioPath!.split('/').last,
          imageBytes!,
          'image.jpg',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bài hát đã được thêm thành công!')),
        );

        _formKey.currentState!.reset();
        setState(() {
          audioPath = null;
          imageBytes = null;
          audioBytes = null;
          genreId = null;
          isLoading = false;
        });
      } catch (e) {
        print('Lỗi khi tạo bài hát: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Bài Hát Mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Tên Bài Hát'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên bài hát';
                  }
                  return null;
                },
                onSaved: (value) => name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nghệ Sĩ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên nghệ sĩ';
                  }
                  return null;
                },
                onSaved: (value) => artist = value,
              ),
              GestureDetector(
                onTap: _pickAudio,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tệp Âm Thanh',
                      hintText: audioPath != null ? audioPath!.split('/').last : 'Chọn tệp âm thanh',
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Hình Ảnh',
                      hintText: imageBytes != null ? 'Hình ảnh đã chọn' : 'Chọn hình ảnh',
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: genreId,
                decoration: InputDecoration(labelText: 'Chọn Thể Loại'),
                items: genres.map((genre) {
                  return DropdownMenuItem<String>(
                    value: genre.id, // genre.id là String
                    child: Text(genre.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    genreId = value; // genreId là String
                  });
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submit,
                child: Text('Thêm Bài Hát'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}