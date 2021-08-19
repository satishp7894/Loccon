import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loccon/bloc/comments_bloc.dart';
import 'package:loccon/models/comment.dart';
import 'package:loccon/pages/feed/comment_options_page.dart';
import 'package:loccon/pages/feed/home_page.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/connection.dart';

class CommentsPage extends StatefulWidget {
  final String feedId;
  final String userId;
  final int feedValue;
  CommentsPage({this.feedId, this.userId, this.feedValue});
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _commentsBloc = CommentsBloc();
  final TextEditingController _commentController = TextEditingController();
  bool _isCommentEmpty = true;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _commentsBloc.fetchComments(widget.feedId);
  }

  @override
  void dispose() {
    super.dispose();
    _commentsBloc.dispose();
    _commentController.dispose();
  }

  Future<bool> backPressed() {
    return Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> HomePage(userId:widget.userId,feedCategoryValue: widget.feedValue)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () { Navigator.pop(context); },
      child: Scaffold(
        appBar: AppBar(elevation: 1,
          centerTitle: false,
          title: Text('Comments'),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _commentsListView(),
              Container(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: _commentController,
                        style: TextStyle(color: Colors.black87),
                        onChanged: (v) {
                          if (v.isEmpty) {
                            setState(() {
                              _isCommentEmpty = true;
                            });
                          } else {
                            setState(() {
                              _isCommentEmpty = false;
                            });
                          }
                        },
                        onSubmitted: (v) {
                          if (_isCommentEmpty == false) {
                            _commentsBloc.addComment(widget.feedId,
                                _commentController.text).then((commentAdded) {
                              if (commentAdded) {
                                setState(() {
                                  _comments.clear();
                                  _isCommentEmpty = true;
                                  _commentController.clear();
                                });
                                _commentsBloc.fetchComments(widget.feedId);
                              } else {
                                Alerts.showAlert(context, 'Alert',
                                    'Failed to add comment. Please try again later.');
                              }
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Add a Comment',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, bottom: 11,
                              top: 11, right: 15),
                        ),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.send),
                      onPressed: _isCommentEmpty ? null : () {
                        _commentsBloc.addComment(widget.feedId,
                            _commentController.text).then((commentAdded) {
                          if (commentAdded) {
                            setState(() {
                              _isCommentEmpty = true;
                              _commentController.clear();
                            });
                            _commentsBloc.fetchComments(widget.feedId);
                          } else {
                            Alerts.showAlert(context, 'Alert',
                                'Failed to add comment. Please try again later.');
                          }
                        });
                        FocusScope.of(context).requestFocus(FocusNode());
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _commentsListView() {
    return Expanded(
      child: StreamBuilder<List<Comment>>(
        stream: _commentsBloc.commentsStream,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.active) {
            return Center(child: Image.asset("assets/loading.gif",height: 60,));
          }
          if (s.hasError || s.data.isEmpty) {
            return Center(child: Text('No Comments Found', style: TextStyle(fontSize: 16.5),));
          }
          return ListView.separated(
            itemCount: s.data.length,
            itemBuilder: (c, i) {
              return _commentListItem(s, i);
            },
            separatorBuilder: (c, i) {
              return Divider(color: Colors.grey[800], indent: 8);
            },
          );
        },
      ),
    );
  }

  Widget _commentListItem(AsyncSnapshot<List<Comment>> s, int i) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              s.data[i].photo != '' ?
              CircleAvatar(radius: 13,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(Connection.profilePicPath + '${s.data[i].photo}'),
              ) : CircleAvatar(radius: 13,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              SizedBox(width: 6,),
              Expanded(
                child: RichText(
                  text: TextSpan(text: '${s.data[i].userName}  ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                        color: Colors.black87),
                    children: [
                      TextSpan(text: '${s.data[i].comment}',
                        style: TextStyle(fontSize: 16,
                          color: Colors.black87, fontWeight: FontWeight.w400)),
                    ]),
                ),
              ),
              GestureDetector(child: Icon(Icons.more_vert),
                onTap: () {
                  showOptionSheet(context, s.data[i].commentId, s.data[i].comment);
                },),
            ],
          ),
          ListView.builder(shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 45, bottom: 8),
            itemCount: s.data[i].replies.length + 1,
            itemBuilder: (c, j) {
              if (j == s.data[i].replies.length) {
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('Reply', style: TextStyle(color: AppTheme.accentColor,
                        fontSize: 15.6, fontWeight: FontWeight.w600),),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) =>
                      CommentOptionsPage(option: 'Reply', feedId: widget.feedId,
                          id: s.data[i].commentId,))).then((value) {
                            _commentsBloc.fetchComments(widget.feedId);
                        // setState(() {
                        //   _allComments = getCommentsList();
                        // });
                    });
                  },
                );
              }
              return Padding(padding: const EdgeInsets.all(6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    s.data[i].photo != '' ?
                    CircleAvatar(radius: 13,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(Connection.profilePicPath + '${s.data[i].photo}'),
                    ) : CircleAvatar(radius: 13,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage('assets/avatar.png'),
                    ),
                    SizedBox(width: 6,),
                    Expanded(
                      child: RichText(
                        text: TextSpan(text: '${s.data[i].replies[j]['user_name']}  ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                              color: Colors.black87),
                          children: [
                            TextSpan(text: '${s.data[i].replies[j]['reply']}',
                              style: TextStyle(fontSize: 16,
                                color: Colors.black87, fontWeight: FontWeight.w400)),
                          ]),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  showOptionSheet(BuildContext context, String commentId, String comment) {
    showModalBottomSheet(context: context,
      builder: (ctx) {
        return Container(
          height: 250,
          child: ListView(
            children: <Widget>[
              ListTile(title: Text('Select Option', style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.w600),),),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Comment'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (c) =>
                    CommentOptionsPage(option: 'Edit', id: commentId, comment: comment,)))
                      .then((value) {
                        _commentsBloc.fetchComments(widget.feedId);
                        // setState(() {
                        //   _allComments = getCommentsList();
                        // });
                  });
                },
              ),
              Divider(color: Colors.grey,),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Comment'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _commentsBloc.deleteComment(commentId).then((bool commentDeleted) {
                    if (commentDeleted) {
                      _commentsBloc.fetchComments(widget.feedId);
                    } else {
                      Alerts.showAlert(context, 'Alert',
                          'Could not delete comment. Please try again later.');
                    }
                  });
                  //_deleteComment(commentId);
                },
              ),
            ],
          ),
        );
      });
  }

}
