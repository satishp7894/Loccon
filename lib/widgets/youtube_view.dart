import 'package:flutter/material.dart';
import 'package:loccon/utils/youtube_validator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeView extends StatefulWidget {
  final String youtubeUrl;
  YoutubeView({@required this.youtubeUrl});
  @override
  _YoutubeViewState createState() => _YoutubeViewState();
}

class _YoutubeViewState extends State<YoutubeView> {
  bool _isValidUrl = false;
  String videoId;
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _validateYoutube(widget.youtubeUrl).then((value) {
      if (value) {
        setState(() {
          _isValidUrl = value;
          videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);
          _controller = YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(autoPlay: false),
          );
        });
      }
    });
  }

  Future<bool> _validateYoutube(String url) {
    return Future<bool>.value(YoutubeVideoValidator.validateUrl(url));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isValidUrl ? Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
        bottomActions: [],
        topActions: [
        ],
      ),
    ) :
    Container(height: 220,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.8),
      ),
      alignment: Alignment.center,
      child: Text('Broken Link or Video removed',
        style: TextStyle(color: Colors.white, fontSize: 18),),
    );
  }
}