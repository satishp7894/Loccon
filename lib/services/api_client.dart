import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:loccon/models/comment.dart';
import 'package:loccon/models/feed.dart';
import 'dart:convert';
import 'package:loccon/models/feed_type.dart';
import 'package:loccon/models/user_details.dart';
import 'package:loccon/utils/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  SharedPreferences _prefs;

  // ----------------------------------- Feeds -----------------------------------------
  Future<List<FeedType>> getFeedTypes() async {
    var response = await http.post(Connection.feedTypeList, body: {
      'secretkey': '${Connection.secretKey}',
    });
    var decodedData = json.decode(response.body);
    List<FeedType> _feedTypes = [];
    if (decodedData['status'] == true) {
      _feedTypes = (decodedData['data'] as List).map<FeedType>((json) =>
          FeedType.fromJson(json)).toList();
    }
    return _feedTypes;
  }

  Future<List<Feed>> getForYouFeed(String feedTypeId, int pageNo) async {
    _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    var response = await http.post(Connection.forYouFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '$_userId',
      'feed_type': '$feedTypeId',
      'page_no': '$pageNo',
    });
    var decodedData = json.decode(response.body);
    List<Feed> _forYouFeeds = [];
    if (decodedData['status'] == true) {
      _forYouFeeds = (decodedData['feedData'] as List).map<Feed>((json) =>
          Feed.fromJson(json)).toList();
      return _forYouFeeds;
    }
    return [];
  }

  Future<List<Feed>> getLocconFeed(String feedTypeId, int pageNo) async {
    _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    var response = await http.post(Connection.locconFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '$_userId',
      'feed_type': '$feedTypeId',
      'page_no': '$pageNo',
    });
    var decodedData = json.decode(response.body);
    List<Feed> _locconFeeds = [];
    if (decodedData['status'] == true) {
      _locconFeeds = (decodedData['feedData'] as List).map<Feed>((json) =>
          Feed.fromJson(json)).toList();
      return _locconFeeds;
    }
    return [];
  }

  Future<Feed> getSingleFeed(String feedId) async {
    _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    var response = await http.post(Connection.viewFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'feed_id': '$feedId',
      'user_id': '$_userId',
    });
    var decodedData = json.decode(response.body);
    Feed _feed;
    if (decodedData['status'] == true) {
      _feed = Feed.fromJson(decodedData['feedData'][0]);
      return _feed;
    }
    return null;
  }

  Future<bool> likeFeed(String feedId) async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.likeFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '${_prefs.getString('id')}',
      'feed_id': '$feedId',
    });
    var decodedData = json.decode(response.body);
    print('like $decodedData ');
    if (decodedData['status'] == true) {
      return decodedData['status'];
    }
    return false;
  }

  Future<bool> saveFeed(String feedId) async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.saveFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '${_prefs.getString('id')}',
      'feed_id': '$feedId',
    });
    var decodedData = json.decode(response.body);
    print('save $decodedData');
    if (decodedData['status'] == true) {
      return decodedData['status'];
    }
    return false;
  }

  Future<bool> reportFeed(String feedId, String feedUserId) async {
    _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    var response = await http.post(Connection.reportFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '$_userId',
      'feed_id': '$feedId',
      'feed_user_id': '$feedUserId',
    });
    var decodedData = json.decode(response.body);
    print('report feed $decodedData');
    if (decodedData['status'] == true) {
      return decodedData['status'];
    }
    return false;
  }

  Future<bool> deleteFeed(String feedId) async {
    var response = await http.post(Connection.deleteFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'feed_id': '$feedId',
    });
    var decodedData = json.decode(response.body);
    print('delete feed $decodedData');
    if (decodedData['status'] == true) {
      return decodedData['status'];
    }
    return false;
  }

  Future<List<Feed>> getUserFeed() async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.userFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '${_prefs.getString('id')}',
    });
    var decodedData = json.decode(response.body);
    print('user feeds $decodedData');
    List<Feed> _feeds = [];
    if (decodedData['status'] == true) {
      _feeds = (decodedData['feedData'] as List).map<Feed>((json) =>
          Feed.fromJson(json)).toList();
      return _feeds;
    }
    return [];
  }

  Future<List<Feed>> getSavedFeed() async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.getSavedFeed, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '${_prefs.getString('id')}',
    });
    var decodedData = json.decode(response.body);
    List<Feed> _feeds = [];
    if (decodedData['status'] == true) {
      _feeds = (decodedData['feedData'] as List).map<Feed>((json) =>
          Feed.fromJson(json)).toList();
      return _feeds;
    }
    return [];
  }

  // ----------------------------------- Comments -----------------------------------------
  Future<List<Comment>> getCommentsList(String feedId) async {
    var response = await http.post(Connection.feedCommentsList, body: {
      'secretkey': '${Connection.secretKey}',
      'feed_id': '$feedId',
    });
    var decodedData = json.decode(response.body);
    List<Comment> _comments = [];
    if (decodedData['status'] == true) {
      _comments = (decodedData['feedComment'] as List).map<Comment>((json) =>
          Comment.fromJson(json)).toList();
      return _comments;
    }
    return [];
  }

  Future<bool> addComment(String feedId, String comment) async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.addComment, body: {
      'secretkey': '${Connection.secretKey}',
      'feed_id': '$feedId',
      'user_id': '${_prefs.getString('id')}',
      'comment': '$comment',
    });
    var decodedData = json.decode(response.body);
    if (decodedData['status'] == true) {
      return true;
    }
    return false;
  }

  Future<bool> deleteComment(String commentId) async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.deleteComment, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '${_prefs.getString('id')}',
      'comment_id': '$commentId',
    });
    var decodedData = json.decode(response.body);
    if (decodedData['status'] == true) {
       return decodedData['status'];
    }
    return false;
  }

  Future<bool> addCommentReply(String feedId, String commentId, String comment) async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.addCommentReply, body: {
      'secretkey': '${Connection.secretKey}',
      'feed_id': '$feedId',
      'user_id': '${_prefs.getString('id')}',
      'comment_id': '$commentId',
      'reply': '$comment',
    });
    var decodedData = json.decode(response.body);
    if (decodedData['status'] == true) {
        return true;
    } else {
      return false;
    }
  }

  Future<bool> updateComment(String commentId, String comment) async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.updateComment, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '${_prefs.getString('id')}',
      'comment_id': '$commentId',
      'comment': '$comment',
    });
    var decodedData = json.decode(response.body);
    if (decodedData['status'] == true) {
      return true;
    } else {
      return false;
    }
  }

  // ----------------------------------- Profile -----------------------------------------
  Future<String> updateProfilePhoto(File photo) async {
    _prefs = await SharedPreferences.getInstance();
    var request = http.MultipartRequest("POST", Uri.parse(Connection.updateProfilePhoto));
    request.fields['secretkey'] = '${Connection.secretKey}';
    request.fields['user_id'] = '${_prefs.getString('id')}';
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path,
        filename: 'profilepic${_prefs.getString('id')}.jpg'));
    final streamResponse = await request.send();
    if (streamResponse.statusCode >= 200 && streamResponse.statusCode <= 299) {
      final response = await http.Response.fromStream(streamResponse);
      final results = json.decode(response.body);
      if (results['status'] == true) {
        _prefs.setString('profilepic', results['data'][0]['photo']);
        return results['data'][0]['photo'];
      } else {
        return null;
      }
    }
    return null;
  }

  Future getUserProfile(String profileId) async {
    _prefs = await SharedPreferences.getInstance();
    var response = await http.post(Connection.viewUserProfile, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '${_prefs.getString('id')}',
      'profile_id': '$profileId',
    });
    var results = json.decode(response.body);
    print('user profile $results');
    UserDetails userDetails;
    List<Feed> userPosts = [];
    if (results['status'] == true) {
       userDetails = UserDetails.fromJson(results['user_data'][0]);
       userPosts = (results['user_post'] as List).map<Feed>((json) =>
           Feed.fromJson(json)).toList();
       return [userDetails, userPosts];
    }
    return null;
  }

  // ----------------------------------- Notification -----------------------------------------
  Future<bool> sendChatNotification({String title, String message, String receiverId,
    String chatRoomId, String userName}) async {
    print('title $title message $message recId $receiverId chatRmId $chatRoomId username $userName');
    var response = await http.post(Connection.sendChatNotification, body: {
      'secretkey': '${Connection.secretKey}',
      'title': '$title',
      'message': '$message',
      'receiver_id': '$receiverId',
      'chatroom_id': '$chatRoomId',
      'user_name': '$userName',
    });
    var results = json.decode(response.body);
    print('chat notification $results');
    if (results['status'] == true) {
      return true;
    }
    return false;
  }


}