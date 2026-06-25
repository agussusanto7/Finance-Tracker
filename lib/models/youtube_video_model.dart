class YouTubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      id: json['id'] is Map ? json['id']['videoId'] ?? '' : json['id'] ?? '',
      title: json['title'] ?? (json['snippet'] != null ? json['snippet']['title'] : ''),
      thumbnailUrl: json['thumbnailUrl'] ?? (json['snippet'] != null ? json['snippet']['thumbnails']['high']['url'] : ''),
      channelTitle: json['channelTitle'] ?? (json['snippet'] != null ? json['snippet']['channelTitle'] : ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'channelTitle': channelTitle,
    };
  }
}
