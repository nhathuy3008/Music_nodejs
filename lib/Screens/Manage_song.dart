import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Song.dart';
import '../Services/song_service.dart';
import 'play_song.dart';

class ManageSong extends StatefulWidget {
  const ManageSong({Key? key}) : super(key: key);

  @override
  _ManageSongState createState() => _ManageSongState();
}

class _ManageSongState extends State<ManageSong> {
  final SongService _songService = SongService();
  late Future<List<Song>> _futureSongs;
  String _accountId = '';

  @override
  void initState() {
    super.initState();
    _loadAccountId();
    _futureSongs = _songService.getAllSongs();
  }

  Future<void> _loadAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accountId = prefs.getString('accountId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài hát'),
      ),
      body: FutureBuilder<List<Song>>(
        future: _futureSongs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có bài hát nào.'));
          } else {
            final songs = snapshot.data!;
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(song.name),
                    subtitle: Text('Ca sĩ: ${song.artist}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await _songService.deleteSong(song.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã xóa bài hát "${song.name}"')),
                          );
                          setState(() {
                            _futureSongs = _songService.getAllSongs();
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi khi xóa: $e')),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      if (song.url.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaySongScreen(
                              playlist: songs,
                              currentSongIndex: index,
                              accountId: _accountId,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('URL không có cho bài hát này')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
