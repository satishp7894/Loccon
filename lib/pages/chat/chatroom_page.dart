import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/widgets/message_count_view.dart';
import '../../services/firestore_database.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChatRoomPage extends StatefulWidget {
  final String myUserName, myId;
  ChatRoomPage({this.myUserName, this.myId});
  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  bool _isDeleteMode = false;
  List<bool> _selectedChatRoom = [];
  String chatRoomId = '';
  String name, email, mobile, userName, profilePic;
  SharedPreferences _prefs;

  _userStoredDetails() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      name = _prefs.getString('name') ?? '';
      userName = _prefs.getString('username') ?? '';
      email = _prefs.getString('email') ?? '';
      mobile = _prefs.getString('mobile') ?? '';
      profilePic = _prefs.getString("profilepic") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userStoredDetails();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(elevation: 1, centerTitle: false,
        title: Text('Messages', style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w600),),
        actions: [
          _isDeleteMode ?
          IconButton(
            icon: Icon(Icons.delete,color: Colors.red,),
            onPressed: () {
              if (chatRoomId != '') {
                FirestoreDatabase.deleteChatRoom(chatRoomId);
                setState(() {
                  _isDeleteMode = false;
                  chatRoomId = '';
                  _selectedChatRoom.clear();
                });
              }
            }) : SizedBox(),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreDatabase.getChatRooms(widget.myUserName),
        builder: (c, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              color: AppTheme.accentColor,
            ));
          }
          if (s.hasError || s.data.docs.isEmpty) {
            print('message error is ${s.error}');
            return Center(child: Text('No Messages', style: TextStyle(
              color: AppTheme.accentColor, fontSize: 20,
              fontWeight: FontWeight.w600),));
          }
          return ListView.builder(
            itemCount: s.data.docs.length,
            itemBuilder: (c, i) {
              print("value for dp ${s.data.docs[i]['users']}");
              _selectedChatRoom.add(false);
              String name = s.data.docs[i]['users'][0] == widget.myUserName ?
                 s.data.docs[i]['users'][1] : s.data.docs[i]['users'][0];
              bool isUnread = s.data.docs[i]['unread'].containsKey(widget.myId);
              if (isUnread) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0,bottom: 10.0),
                  child: ListTileTheme(
                    selectedTileColor: Colors.grey.withOpacity(.4),
                    selectedColor: AppTheme.accentColor,
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: 20,right: 60),
                      selected: _selectedChatRoom[i],
                     leading: Container(
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(40),
                           border: Border.all(color: AppTheme.accentColor)
                       ),
                       child: ClipRRect(
                         borderRadius: BorderRadius.circular(40),
                         child: Image.asset('assets/avatar.png' ?? null),
                       ),
                     ),
                      title: Text('$name', style: TextStyle(fontWeight: FontWeight.bold,),),
                      trailing: MessageCountView(count: s.data.docs[i]['unread'][widget.myId],),
                      onLongPress: () {
                        if (_selectedChatRoom[i] == true) {
                          setState(() {
                            _selectedChatRoom[i] = false;
                            chatRoomId = '';
                            _isDeleteMode = false;
                          });
                        } else {
                          setState(() {
                            _selectedChatRoom[i] = true;
                            chatRoomId = s.data.docs[i].id;
                            _isDeleteMode = true;
                          });
                        }
                      },
                      onTap: () {
                        setState(() {
                          _selectedChatRoom[i] = false;
                          chatRoomId = null;
                          _isDeleteMode = false;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (c) =>
                          ChatPage(chatRoomId: s.data.docs[i].id, userName: name, myName: widget.myUserName,
                            myId: widget.myId,)));
                      },
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0,bottom: 10),
                  child: ListTileTheme(
                    selectedTileColor: Colors.grey.withOpacity(.4),
                    selectedColor: AppTheme.accentColor,
                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: AppTheme.accentColor)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child:  Image.asset('assets/avatar.png' ?? null),
                        ),
                      ),
                      selected: _selectedChatRoom[i],
                      title: Text('$name'),
                      onLongPress: () {
                        if (_selectedChatRoom[i] == true) {
                          setState(() {
                            _selectedChatRoom[i] = false;
                            chatRoomId = '';
                            _isDeleteMode = false;
                          });
                        } else {
                          setState(() {
                            _selectedChatRoom[i] = true;
                            chatRoomId = s.data.docs[i].id;
                            _isDeleteMode = true;
                          });
                        }
                      },
                      onTap: () {
                        setState(() {
                          _selectedChatRoom[i] = false;
                          chatRoomId = '';
                          _isDeleteMode = false;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (c) =>
                          ChatPage(chatRoomId: s.data.docs[i].id, userName: name, myName: widget.myUserName,
                            myId: widget.myId,)));
                      },
                    ),
                  ),
                );
              }
            },

          );
        }
      ),
    );
  }
}


