import 'package:flutter/material.dart';
import 'package:loccon/bloc/home_bloc.dart';
import 'package:loccon/models/feed.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/widgets/feed_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedFeedsPage extends StatefulWidget {
  @override
  _SavedFeedsPageState createState() => _SavedFeedsPageState();
}

class _SavedFeedsPageState extends State<SavedFeedsPage> {
  final _homeBloc = HomeBloc();
  String userId;

  _getUserId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = _prefs.getString('id') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserId();
    _homeBloc.fetchSavedFeeds();
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Feed>>(
        stream: _homeBloc.savedFeedStream,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.active) {
            return Center(child: Image.asset("assets/loading.gif",height: 60,));
          }
          if (s.hasError || s.data.isEmpty) {
            return Center(
              child: Text('No Feeds Saved',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: s.data.length,
            itemBuilder: (c, i) {
              return FeedListItem(index: i, feeds: s.data, userId: userId,
                like: () => _homeBloc.likeFeed(s.data[i].feedId),
                save: () => _homeBloc.saveFeed(s.data[i].feedId),
                report: () => _homeBloc.reportFeed(s.data[i].feedId, s.data[i].userId),
              );
            });
        }
      ),
    );
  }
}
