import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/youtube_video_model.dart';

class SavedVideoProvider with ChangeNotifier {
  List<YouTubeVideo> _savedVideos = [];
  
  List<YouTubeVideo> get savedVideos => _savedVideos;

  SavedVideoProvider() {
    loadSavedVideos();
  }

  Future<void> loadSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? videosJson = prefs.getString('saved_videos');
    if (videosJson != null) {
      final List<dynamic> decodedList = json.decode(videosJson);
      _savedVideos = decodedList.map((item) => YouTubeVideo.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> saveVideo(YouTubeVideo video) async {
    if (!isSaved(video.id)) {
      _savedVideos.add(video);
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> removeVideo(String videoId) async {
    _savedVideos.removeWhere((video) => video.id == videoId);
    await _saveToPrefs();
    notifyListeners();
  }

  bool isSaved(String videoId) {
    return _savedVideos.any((video) => video.id == videoId);
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _savedVideos.map((video) => video.toJson()).toList(),
    );
    await prefs.setString('saved_videos', encodedData);
  }
}
