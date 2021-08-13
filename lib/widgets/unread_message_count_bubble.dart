import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loccon/services/firestore_database.dart';
import 'package:loccon/utils/apptheme.dart';

class UnreadMessageCountBubble extends StatefulWidget {
  final String myUserName, myId;
  UnreadMessageCountBubble({this.myUserName, this.myId});
  @override
  _UnreadMessageCountBubbleState createState() => _UnreadMessageCountBubbleState();
}

class _UnreadMessageCountBubbleState extends State<UnreadMessageCountBubble> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreDatabase.getChatRooms(widget.myUserName),
        builder: (c, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }
          if (s.hasError || s.data.docs.isEmpty) {
            print('msg count error is ${s.error}');
            return SizedBox();
          }
          int _count = 0;
          for (DocumentSnapshot ds in s.data.docs) {
            if (ds['unread'].containsKey(widget.myId)) {
              _count += ds['unread'][widget.myId];
            }
          }
          if (_count == 0) {
            return SizedBox();
          } else {
            return Container(height: 24, width: 24,
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text('$_count', style: TextStyle(color: Colors.white, fontSize: 12),),
            );
          }
        }
    );
  }
}