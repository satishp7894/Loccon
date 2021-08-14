import 'package:flutter/material.dart';
import 'package:loccon/bloc/events_bloc.dart';
import 'package:loccon/bloc/home_bloc.dart';
import 'package:loccon/models/feed.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/widgets/feed_list_item.dart';

class EventsPage extends StatefulWidget {
  final String userId;
  EventsPage({this.userId});
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _eventsBloc = EventsBloc();
  final _homeBloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _eventsBloc.refreshAndFetchEventFeeds();
  }

  @override
  void dispose() {
    super.dispose();
    _eventsBloc.dispose();
    _homeBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false, elevation: 1,
        title:Text('Events', style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w600),),
      ),
      body: StreamBuilder<List<Feed>>(
        stream: _eventsBloc.eventsFeedStream,
        builder: (c, s) {
          print('connection state ${s.connectionState}');
          if (s.connectionState != ConnectionState.active) {
            return FutureBuilder(
              future: Future.delayed(Duration(seconds: 6)),
              builder: (c, s) {
                if (s.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator(color: AppTheme.accentColor,));
                } else {
                  return Center(
                    child: Text('No events at the moment ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  );
                }
              });
          }
          if (s.data.isEmpty) {
            return Center(
              child: Text('No events at the moment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            );
          }
          if (s.hasData) {
            return NotificationListener(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification) {
                  _eventsBloc.fetchEventFeeds();
                }
                return true;
              },
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: s.data.length,
                  itemBuilder: (c, i) {
                    return FeedListItem(index: i, feeds: s.data, userId: widget.userId,
                      like: () => _homeBloc.likeFeed(s.data[i].feedId),
                      save: () => _homeBloc.saveFeed(s.data[i].feedId),
                      report: () => _homeBloc.reportFeed(s.data[i].feedId, s.data[i].userId),
                    );
                  }),
            );
          } else {
            return Center(
              child: Text('No events at the moment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            );
          }
        }
      ),
    );
  }

}
