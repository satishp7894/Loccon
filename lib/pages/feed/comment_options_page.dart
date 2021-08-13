import 'package:flutter/material.dart';
import 'package:loccon/bloc/comments_bloc.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/alerts.dart';

class CommentOptionsPage extends StatefulWidget {
  final String option, feedId, id, comment;
  CommentOptionsPage({this.option, this.feedId, this.id, this.comment});
  @override
  _CommentOptionsPageState createState() => _CommentOptionsPageState();
}

class _CommentOptionsPageState extends State<CommentOptionsPage> {
  final _commentsBloc = CommentsBloc();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.option == 'Edit') {
      _controller.text = widget.comment;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _commentsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1,
        centerTitle: true,
        title: Text('${widget.option}'),
      ),
      body: ListView(
        children: <Widget>[
           Card(
             margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
             child: Column(
               children: <Widget>[
                 TextField(maxLines: 3, maxLength: 500,
                   controller: _controller,
                   style: TextStyle(color: Colors.black87),
                   decoration: InputDecoration(
                     hintText: 'Write a reply...',
                     border: InputBorder.none,
                     focusedBorder: InputBorder.none,
                     enabledBorder: InputBorder.none,
                     errorBorder: InputBorder.none,
                     disabledBorder: InputBorder.none,
                     contentPadding: const EdgeInsets.only(left: 15,
                         bottom: 5, top: 15, right: 15),
                   ),
                 ),
                 SizedBox(height: 20,),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: <Widget>[
                     // ignore: deprecated_member_use
                     FlatButton(
                        child: Text('Cancel', style: TextStyle(color: AppTheme.accentColor),),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                     ),
                     // ignore: deprecated_member_use
                     FlatButton(color: AppTheme.accentColor,
                       child: Text('Submit', style: TextStyle(color: Colors.white),),
                       onPressed: () {
                          if (widget.option == 'Reply') {
                            _commentsBloc.addCommentReply(widget.feedId, widget.id, _controller.text).then((replyAdded) {
                              if (replyAdded) {
                                Navigator.of(context).pop();
                              } else {
                                Alerts.showAlert(context, 'Alert', 'Something went wrong. Please try again later.');
                              }
                            });
                          } else if (widget.option == 'Edit') {
                            _commentsBloc.updateComment(widget.id, _controller.text).then((commentUpdated) {
                              if (commentUpdated) {
                                Navigator.of(context).pop();
                              } else {
                                Alerts.showAlert(context, 'Alert', 'Something went wrong. Please try again later.');
                              }
                            });
                          }
                       },
                     ),
                   ],
                 ),
                 SizedBox(height: 10,),
               ],
             ),
           ),
        ],
      ),
    );
  }
}
