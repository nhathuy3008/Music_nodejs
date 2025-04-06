import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Services/role_service.dart';

class PlaySongPending extends StatefulWidget {
  final String songId;

  PlaySongPending({required this.songId});

  @override
  _PlaySongPendingState createState() => _PlaySongPendingState();
}

class _PlaySongPendingState extends State<PlaySongPending>
    with SingleTickerProviderStateMixin {
  final RoleService _roleService = RoleService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _songUrl;
  String? _songImage;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPlaying = false;
  bool _isLooping = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late AnimationController _controller;

  // Define avatarRadius (size of the avatar image)
  double avatarRadius = 50;

  // Song data
  String? currentSongImage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isLooping) {
        _playAudio();
      }
    });
    _fetchAndPlaySong(widget.songId);
  }

  Future<void> _fetchAndPlaySong(String songId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Gọi API lấy thông tin bài hát
      final songData = await RoleService().getSongById(songId);

      setState(() {
        _songUrl = songData['url'];  // Lấy đường dẫn bài hát
        _songImage = songData['image'] ?? 'https://example.com/default_image.jpg';  // Lấy hình ảnh bài hát
        currentSongImage = _songImage; // Cập nhật ảnh
      });

      if (_songUrl != null) {
        _playAudio();
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  void _playAudio() async {
    if (_songUrl != null) {
      await _audioPlayer.play(UrlSource(_songUrl!));
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phát Nhạc Pending')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) CircularProgressIndicator(),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            if (_songUrl != null)
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * 3.14159265359,
                        child: CircleAvatar(
                          radius: avatarRadius, // Avatar size
                          backgroundImage: NetworkImage(currentSongImage ?? 'https://example.com/default_image.jpg'),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble(),
                    onChanged: (value) {
                      _seekTo(value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
                        onPressed: _isPlaying ? _pauseAudio : _playAudio,
                      ),
                      IconButton(
                        icon: Icon(Icons.repeat,
                            color: _isLooping ? Colors.orange : Colors.black),
                        onPressed: _toggleLoop,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
