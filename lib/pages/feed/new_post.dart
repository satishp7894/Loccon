import 'package:flutter/material.dart';
import 'package:loccon/models/feed_type.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key key}) : super(key: key);

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {


  List<FeedType> _feedTypes = [];

  _addFeedTypes() {
    _feedTypes.add(FeedType(id: '1', feedType: 'Sell'));
    _feedTypes.add(FeedType(id: '2', feedType: 'Buy'));
    _feedTypes.add(FeedType(id: '3', feedType: 'News'));
    _feedTypes.add(FeedType(id: '4', feedType: 'Offers'));
    _feedTypes.add(FeedType(id: '5', feedType: 'Events'));
    _feedTypes.add(FeedType(id: '6', feedType: 'Jobs'));
    _feedTypes.add(FeedType(id: '7', feedType: 'Request'));
  }

  @override
  void initState() {
    _addFeedTypes();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share Post"),
      ),
    );
  }
}
