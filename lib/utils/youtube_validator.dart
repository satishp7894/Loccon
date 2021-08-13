import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

/// Youtube Video Validator
class YoutubeVideoValidator {
  static const String _uriVideoInfo = 'http://youtube.com/get_video_info';
  static final Map<String, String> _playabilityStatus = {
    'ok': 'OK',
    'login_required': 'LOGIN_REQUIRED',
    'unplayable': 'UNPLAYABLE',
    'error': 'ERROR',
  };
  static YoutubeVideo video = YoutubeVideo();

  /// Validate the specified Youtube video URL.
  static bool validateUrl(String url) {
    if (url == null) {
      throw ArgumentError('url');
    }

    if (url.isEmpty) {
      return false;
    }

    final RegExp pattern = RegExp(
        r'^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$');
    final bool match = pattern.hasMatch(url);

    return match;
  }

  /// Validate the specified Youtube video ID.
  static Future<bool> validateID(String videoID,
      {bool loadData = false}) async {
    if (videoID == null) {
      throw ArgumentError('videoID');
    }

    if (videoID.isEmpty || videoID.length != 11) {
      return false;
    }

    final String url = '$_uriVideoInfo?video_id=$videoID';

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return false;
    }

    final List<String> options = (response.body).split('&');
    options.retainWhere((value) => value.contains('player_response='));

    if (options[0].startsWith('player_response=')) {
      final Map<String, dynamic> videoJson = jsonDecode(
          Uri.decodeFull(options[0].substring('player_response='.length)));

      final bool isRealVideo = (videoJson['playabilityStatus']['status'] ==
          _playabilityStatus['ok'] ||
          videoJson['playabilityStatus']['status'] ==
              _playabilityStatus['login_required'])
          ? true
          : false;

      if (loadData && isRealVideo) {
        video.fromJson(videoJson['videoDetails']);
      }

      return isRealVideo;
    } else {
      return false;
    }
  }
}

class YoutubeVideo {
  YoutubeVideo();

  String id;
  String title;
  int length;
  int views;
  String channelID;
  String author;
  String description;
  String tags;
  String thubmnail;
  double rating;

  @override
  String toString() {
    return '$title ($id) - $author';
  }

  String shareUrl() {
    return 'https://youtu.be/$id';
  }

  String channelUrl() {
    return (channelID == null) ? null : 'https://youtube.com/user/$channelID';
  }

  void fromJson(Map<String, dynamic> json) {
    id = json['videoId'];
    title = json['title'].toString().replaceAll('+', ' ');
    length = int.tryParse(json['lengthSeconds']);
    views = int.tryParse(json['viewCount']);
    channelID = json['channelId'];
    author = json['author'].toString().replaceAll('+', ' ');
    description = json['viewCount'];
    tags = json['keywords'].toString().replaceAll('+', ' ');
    thubmnail = json['thumbnail']['thumbnails'][4]['url'].toString();
    rating = json['averageRating'];
  }

  void clear() {
    id = null;
    title = null;
    length = null;
    views = null;
    channelID = null;
    author = null;
    description = null;
    tags = null;
    thubmnail = null;
    rating = null;
  }
}