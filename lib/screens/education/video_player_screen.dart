import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/saved_video_provider.dart';
import '../../models/youtube_video_model.dart';
import '../../constants/app_constants.dart';

class VideoPlayerScreen extends StatefulWidget {
  final YouTubeVideo video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  
  // State untuk interaktivitas tombol
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppConstants.primaryColor,
        progressColors: ProgressBarColors(
          playedColor: AppConstants.primaryColor,
          handleColor: AppConstants.primaryColor,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text(''),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                player,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Video
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Info Views & Date (Dummy data for UI)
                      Text(
                        '125rb x ditonton • Baru saja',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Action Row (Like, Share, etc.)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildActionButton(
                              icon: _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                              label: 'Suka',
                              isActive: _isLiked,
                              onTap: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                  if (_isLiked) _isDisliked = false;
                                });
                              },
                            ),
                            _buildActionButton(
                              icon: _isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                              label: 'Tidak Suka',
                              isActive: _isDisliked,
                              onTap: () {
                                setState(() {
                                  _isDisliked = !_isDisliked;
                                  if (_isDisliked) _isLiked = false;
                                });
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.reply_outlined,
                              label: 'Bagikan',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Membuka menu bagikan...')),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.download_outlined,
                              label: 'Download',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Fitur download khusus YouTube Premium')),
                                );
                              },
                            ),
                            Consumer<SavedVideoProvider>(
                              builder: (context, savedProvider, child) {
                                final isSaved = savedProvider.isSaved(widget.video.id);
                                return _buildActionButton(
                                  icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                  label: 'Simpan',
                                  isActive: isSaved,
                                  onTap: () {
                                    if (isSaved) {
                                      savedProvider.removeVideo(widget.video.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Dihapus dari daftar putar tersimpan')),
                                      );
                                    } else {
                                      savedProvider.saveVideo(widget.video);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Video berhasil disimpan! Cek di Pengaturan.')),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Channel Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              widget.video.channelTitle[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.video.channelTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '1,2 jt subscriber', // Dummy data
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tombol Subscribe
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSubscribed = !_isSubscribed;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isSubscribed ? Colors.grey.shade200 : Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isSubscribed ? 'Disubscribe' : 'Subscribe',
                                style: TextStyle(
                                  color: _isSubscribed ? Colors.black87 : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Kolom Komentar (Dummy)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Komentar',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '842',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Wah materinya daging banget, sangat membantu untuk mengatur gaji UMR saya! Terima kasih.',
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget bantuan untuk Action Button ala YouTube
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black.withOpacity(0.08) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isActive ? Colors.black : Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
