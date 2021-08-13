import 'dart:async';
import 'package:loccon/models/comment.dart';
import 'package:loccon/services/api_client.dart';

class CommentsBloc {

  final _client = ApiClient();
  final _commentsController = StreamController<List<Comment>>.broadcast();
  Stream<List<Comment>> get commentsStream => _commentsController.stream;

  fetchComments(String feedId) async {
    try {
      final results = await _client.getCommentsList(feedId);
      _commentsController.sink.add(results);
    } on Exception catch (e) {
      _commentsController.addError('Something went wrong ${e.toString()}');
    }
  }

  Future<bool> addComment(String feedId, String comment) async {
    var commentAdded = await _client.addComment(feedId, comment);
    return commentAdded;
  }

  Future<bool> deleteComment(String commentId) async {
    var commentDeleted = await _client.deleteComment(commentId);
    return commentDeleted;
  }

  Future<bool> addCommentReply(String feedId, String commentId, String comment) async {
    var commentReplyAdded = await _client.addCommentReply(feedId, commentId, comment);
    return commentReplyAdded;
  }

  Future<bool> updateComment(String commentId, String comment) async {
    var commentUpdated = await _client.updateComment(commentId, comment);
    return commentUpdated;
  }

  dispose() {
    _commentsController.close();
  }

}