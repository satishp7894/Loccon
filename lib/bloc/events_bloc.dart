import 'dart:async';
import 'package:loccon/models/feed.dart';
import 'package:loccon/services/api_client.dart';

class EventsBloc {

  int _page = 1;
  List<Feed> _eventFeeds = [];

  final _client = ApiClient();
  final _eventsFeedController = StreamController<List<Feed>>();
  Stream<List<Feed>> get eventsFeedStream => _eventsFeedController.stream;

  refreshAndFetchEventFeeds() async {
    _page = 1;
    _eventFeeds = [];
    print('refresh events page $_page');
    try {
      final results = await _client.getLocconFeed('5', 1);
      if (results.isNotEmpty) {
        _eventFeeds.addAll(results);
        _eventsFeedController.sink.add(_eventFeeds);
        _page += 1;
        print('refresh events results ${_eventFeeds.length}');
      }
    } on Exception catch (e) {
      _eventsFeedController.addError('Something went wrong ${e.toString()}');
    }
  }

  fetchEventFeeds() async {
    print('events page $_page');
    try {
      final results = await _client.getLocconFeed('5', _page);
      if (results.isNotEmpty) {
        _eventFeeds.addAll(results);
        _eventsFeedController.sink.add(_eventFeeds);
        _page += 1;
        print('events results ${_eventFeeds.length}');
      }
    } on Exception catch (e) {
      _eventsFeedController.addError('Something went wrong ${e.toString()}');
    }
  }

  dispose() {
    _eventsFeedController.close();
  }

}