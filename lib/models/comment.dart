
class Comment {

  String commentId, userId, userName, photo, comment;
  var replies;

  Comment({this.commentId, this.userId, this.userName, this.photo,
    this.comment, this.replies});

  Comment.fromJson(Map<String, dynamic> json) :
    commentId = json['comment']['comment_id'],
    userId = json['comment']['user_id'],
    userName = json['comment']['user_name'],
    photo = json['comment']['photo'],
    comment = json['comment']['comment'],
    replies = json['comment_reply'];

}


class CommentReply {

  String replyId, commentId, userId, userName, photo, reply, replyDate;

  CommentReply({this.replyId, this.commentId, this.userId, this.userName, this.photo,
      this.reply, this.replyDate});

  CommentReply.fromJson(Map<String, dynamic> replyJson) :
    replyId = replyJson['reply_id'],
    commentId = replyJson['comment_id'],
    userId = replyJson['user_id'],
    userName = replyJson['user_name'],
    photo = replyJson['photo'],
    reply = replyJson['reply'],
    replyDate = replyJson['reply_date'];

}