import 'dart:async';
import 'package:loccon/models/feed.dart';
import 'package:loccon/models/feed_type.dart';
import 'package:loccon/services/api_client.dart';

enum FeedCategory {
  forYou, loccon
}

class HomeBloc {

  int _page = 1;
  List<Feed> _feeds = [];

  final _client = ApiClient();

  final _feedTypeController = StreamController<List<FeedType>>.broadcast();
  Stream<List<FeedType>> get feedTypeStream => _feedTypeController.stream;

  final _feedController = StreamController<List<Feed>>.broadcast();
  Stream<List<Feed>> get feedStream => _feedController.stream;

  Sink<List> get feedCategory => _feedCategoryController.sink;
  final _feedCategoryController = StreamController<List>();

  final _savedFeedController = StreamController<List<Feed>>();
  Stream<List<Feed>> get savedFeedStream => _savedFeedController.stream;

  final _userFeedController = StreamController<List<Feed>>();
  Stream<List<Feed>> get userFeedStream => _userFeedController.stream;

  fetchCategoryWiseFeeds() {
    _feedCategoryController.stream.listen((feedCategory) {
      if (feedCategory[0] == FeedCategory.forYou) {
         refreshAndFetchForYouFeeds(feedCategory[1]);
      } else {
         refreshAndFetchLocconFeeds(feedCategory[1]);
      }
    });
  }

  Future<String> fetchFeedTypes() async {
    try {
      final results = await _client.getFeedTypes();
      _feedTypeController.sink.add(results);
      return results[0].id;
    } on Exception catch (e) {
      _feedTypeController.addError('Something went wrong ${e.toString()}');
      return null;
    }
  }

  Future<bool> refreshAndFetchForYouFeeds(String feedTypeId) async {
    _page = 1;
    _feeds.clear();
    try {
      final results = await _client.getForYouFeed(feedTypeId, 1);
      if (results.isNotEmpty) {
        _feeds.addAll(results);
        _feedController.sink.add(_feeds);
        _page += 1;
        print('refresh for you results ${_feeds.length}');
        return true;
      }
    } on Exception catch (e) {
      _feedController.addError('Something went wrong ${e.toString()}');
      return false;
    }
    return false;
  }

  fetchForYouFeeds(String feedTypeId) async {
    print('for you page $_page');
    try {
      final results = await _client.getForYouFeed(feedTypeId, _page);
      if (results.isNotEmpty) {
        _feeds.addAll(results);
        _feedController.sink.add(_feeds);
        _page += 1;
        print('for you results ${_feeds.length}');
      }
    } on Exception catch (e) {
      _feedController.addError('Something went wrong ${e.toString()}');
    }
  }

  Future<bool> refreshAndFetchLocconFeeds(String feedTypeId) async {
    _page = 1;
    _feeds.clear();
    try {
      final results = await _client.getLocconFeed(feedTypeId, 1);
      if (results.isNotEmpty) {
        _feeds.addAll(results);
        _feedController.sink.add(_feeds);
        _page += 1;
        return true;
      }
      print('refresh loccon results ${_feeds.length}');
    } on Exception catch (e) {
      _feedController.addError('Something went wrong ${e.toString()}');
      return false;
    }
    return false;
  }

  fetchLocconFeeds(String feedTypeId) async {
    print('loccon page $_page');
    try {
      final results = await _client.getLocconFeed(feedTypeId, _page);
      if (results.isNotEmpty) {
        _feeds.addAll(results);
        _feedController.sink.add(_feeds);
        _page += 1;
      }
      print('loccon results ${results.length} ${_feeds.last.userName}');
    } on Exception catch (e) {
      _feedController.addError('Something went wrong ${e.toString()}');
    }
  }

  fetchUserFeeds() async {
    try {
      final results = await _client.getUserFeed();
      _userFeedController.sink.add(results);
    } on Exception catch (e) {
      _userFeedController.addError('Something went wrong ${e.toString()}');
    }
  }

  fetchSavedFeeds() async {
    try {
      final results = await _client.getSavedFeed();
      _savedFeedController.sink.add(results);
    } on Exception catch (e) {
      _savedFeedController.addError('Something went wrong ${e.toString()}');
    }
  }

  Future<Feed> getSingleFeed(String feedId) async {
    var feed = await _client.getSingleFeed(feedId);
    return feed;
  }

  Future<bool> likeFeed(String feedId) async {
    var isLiked = await _client.likeFeed(feedId);
    return isLiked;
  }

  Future<bool> saveFeed(String feedId) async {
    var isSaved = await _client.saveFeed(feedId);
    return isSaved;
  }

  Future<bool> reportFeed(String feedId, String feedUserId) async {
    var isReported = await _client.reportFeed(feedId, feedUserId);
    return isReported;
  }

  Future<bool> deleteFeed(String feedId) async {
    var isReported = await _client.deleteFeed(feedId);
    return isReported;
  }

  dispose() {
    _feedTypeController.close();
    _feedController.close();
    _feedCategoryController.close();
    _savedFeedController.close();
    _userFeedController.close();
  }

}