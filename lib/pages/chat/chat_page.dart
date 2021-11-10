import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loccon/services/api_client.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/widgets/message_tile.dart';
import '../../services/firestore_database.dart';

List<bool> selectedChatItems = [];
List<DocumentSnapshot> selectedChatDocs = [];

class ChatPage extends StatefulWidget {
  final String chatRoomId, userName, myName, myId, userDp;
  ChatPage({this.chatRoomId, this.userName, this.myName, this.myId, this.userDp});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  TextEditingController _chatController = TextEditingController();
  final _apiClient = ApiClient();
  int _sentMessageCount = 0;
  bool isDeleteMode = false;

  String getReceiverId() {
    String f = widget.chatRoomId.split('_').first;
    String l = widget.chatRoomId.split('_').last;
    if (f == widget.myId) {
      return l;
    } else {
      return f;
    }
  }

  _sendMessage() async {
    if (_chatController.text.isNotEmpty) {
      Map<String, dynamic> _message = {
        'message': _chatController.text,
        'sender': widget.myId,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      FirestoreDatabase.addChatMessages(widget.chatRoomId, _message);
      if (!await FirestoreDatabase.checkActiveStatus(widget.chatRoomId, getReceiverId())) {
        _apiClient.sendChatNotification(title: '${widget.myName}',
          message: _chatController.text, receiverId: '${getReceiverId()}',
          chatRoomId: '${widget.chatRoomId}', userName: '${widget.myName}');
        _sentMessageCount += 1;
        FirestoreDatabase.addUnread(widget.chatRoomId, getReceiverId(), _sentMessageCount);
      }
      _chatController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print(widget.userDp);
    FirestoreDatabase.addActiveStatus(widget.chatRoomId,
        [widget.myName, widget.userName], widget.myId).then((_) {
      FirestoreDatabase.removeUnread(widget.chatRoomId, widget.myId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatController.dispose();
    FirestoreDatabase.removeActiveStatus(widget.chatRoomId, widget.myId);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FirestoreDatabase.addActiveStatus(widget.chatRoomId,
          [widget.myName, widget.userName], widget.myId).then((_) {
        FirestoreDatabase.removeUnread(widget.chatRoomId, widget.myId);
      });
    }
    if (state == AppLifecycleState.inactive) {
      FirestoreDatabase.removeActiveStatus(widget.chatRoomId, widget.myId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, centerTitle: true,
        title: Text('${widget.userName}', style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.w600,color: AppTheme.accentColor),),
        actions: [
          isDeleteMode ?
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              FirestoreDatabase.deleteSelectedChatItems(selectedChatDocs);
              setState(() {
                isDeleteMode = false;
                selectedChatItems.clear();
                selectedChatDocs.clear();
              });
            }
          ) :
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return {'Clear Chat'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice, child: Text(choice),
                );
              }).toList();
            },
            onSelected: (String value) {
              FirestoreDatabase.deleteChat(widget.chatRoomId);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _chatListView(),),
            SizedBox(height: 12,),
            _sendMessageView(),
          ],
        ),
      ),
    );
  }

  // List<bool> _selectedChatItems = [];
  // List<DocumentSnapshot> _selectedChatDocs = [];
  Widget _chatListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreDatabase.getChatMessages(widget.chatRoomId),
      builder: (c, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return Center(child: Image.asset("assets/loading.gif",height: 60,));
        }
        if (s.hasData) {
          return ChatListView(s: s, myId: widget.myId,
            deleteOffCallBack: () {
              setState(() {
                isDeleteMode = false;
              });
            },
            deleteOnCallBack: () {
              setState(() {
                isDeleteMode = true;
              });
            },
          );
        } else {
          return SizedBox();
        }
      });
  }



  Widget _sendMessageView() {
    return Padding(padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Theme(
              data: ThemeData(primaryColor: Colors.grey),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _chatController,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(hintText: 'Type a message',
                  hintStyle: TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black87),
                  ),focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.accentColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 13, horizontal: 10),
                ),
              ),
            ),
          ),
          SizedBox(width: 8,),
          SizedBox(height: 50,
            child: FloatingActionButton(
              backgroundColor: AppTheme.accentColor,
              child: Icon(Icons.send,
                color: Colors.white,),
              onPressed: () {
                _sendMessage();
              },
            ),
          ),
        ],
      ),
    );
  }

}

class ChatListView extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> s;
  final String myId;
  final VoidCallback deleteOnCallBack, deleteOffCallBack;
  ChatListView({@required this.s, @required this.myId, this.deleteOnCallBack, this.deleteOffCallBack});
  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(reverse: true,
      physics: BouncingScrollPhysics(),
      itemCount: widget.s.data.docs.length,
      itemBuilder: (c, i) {
        selectedChatItems.add(false);
        return GestureDetector(
          onTap: () {
            if (selectedChatItems[i] == true) {
              setState(() {
                selectedChatItems[i] = false;
                selectedChatDocs.remove(widget.s.data.docs[i]);
              });
            } else {
              setState(() {
                selectedChatItems[i] = true;
                selectedChatDocs.add(widget.s.data.docs[i]);
              });
            }
            if (!selectedChatItems.contains(true)) {
              // setState(() {
              //   isDeleteMode = false;
              // });
              widget.deleteOffCallBack();
            }
            print('selected ids ${selectedChatDocs.map((e) => e.id).toList()}');
          },
          onLongPress: () {
            setState(() {
              selectedChatItems[i] = true;
              // isDeleteMode = true;
              selectedChatDocs.add(widget.s.data.docs[i]);
              print('selected ids ${selectedChatDocs.map((e) => e.id).toList()}');
            });
            widget.deleteOnCallBack();
          },
          child: MessageTile(message: widget.s.data.docs[i]['message'],
              isSelected: selectedChatItems[i],
              isSender: widget.s.data.docs[i]['sender'] == widget.myId),
        );
      });
  }



// Widget _backupList() {
//   return ListView.builder(reverse: true,
//       physics: BouncingScrollPhysics(),
//       itemCount: s.data.docs.length,
//       itemBuilder: (c, i) {
//         _selectedChatItems.add(false);
//         return GestureDetector(
//           onTap: () {
//             if (_selectedChatItems[i] == true) {
//               setState(() {
//                 _selectedChatItems[i] = false;
//                 _selectedChatDocs.remove(s.data.docs[i]);
//               });
//             } else {
//               setState(() {
//                 _selectedChatItems[i] = true;
//                 _selectedChatDocs.add(s.data.docs[i]);
//               });
//             }
//             if (!_selectedChatItems.contains(true)) {
//               setState(() {
//                 isDeleteMode = false;
//               });
//             }
//             print('selected ids ${_selectedChatDocs.map((e) => e.id).toList()}');
//           },
//           onLongPress: () {
//             setState(() {
//               _selectedChatItems[i] = true;
//               isDeleteMode = true;
//               _selectedChatDocs.add(s.data.docs[i]);
//               print('selected ids ${_selectedChatDocs.map((e) => e.id).toList()}');
//             });
//           },
//           child: MessageTile(message: s.data.docs[i]['message'],
//               isSelected: _selectedChatItems[i],
//               isSender: s.data.docs[i]['sender'] == widget.myId),
//         );
//       });
// }
}



