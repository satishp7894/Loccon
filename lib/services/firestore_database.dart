import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {

  static addUnread(String chatRoomId, String userId, int totalMsgs) async {
    CollectionReference chatRoom = FirebaseFirestore.instance.collection('chatRoom');
    Map<String, dynamic> _unreads = Map<String, dynamic>();
    List _ids = [];
    List _users = [];
    var userDataList = await chatRoom.doc(chatRoomId).get();
    if (userDataList.data() != null) {
      _ids = userDataList.data()['active'];
      _unreads = userDataList.data()['unread'];
      _users = userDataList.data()['users'];
    }
    _unreads[userId] = totalMsgs;
    print('active $_ids unread $_unreads users $_users');
    Map<String, dynamic> active = {
      'active': _ids,
      'unread': _unreads,
      'users': _users,
    };
    chatRoom.doc(chatRoomId).set(active).catchError((e) {
      print('error in active chat room ${e.toString()}');
    });
  }

  static removeUnread(String chatRoomId, String userId) async {
    CollectionReference chatRoom = FirebaseFirestore.instance.collection('chatRoom');
    Map<String, dynamic> _unreads = Map<String, dynamic>();
    List _ids = [];
    List _users = [];
    var userDataList = await chatRoom.doc(chatRoomId).get();
    if (userDataList.data() != null) {
      _ids = userDataList.data()['active'] ?? [];
      _unreads = userDataList.data()['unread'] ?? {};
      _users = userDataList.data()['users'] ?? [];
    }
    _unreads.remove(userId);
    print('active $_ids unread $_unreads users $_users');
    Map<String, dynamic> active = {
      'active': _ids,
      'unread': _unreads,
      'users': _users,
    };
    chatRoom.doc(chatRoomId).set(active).catchError((e) {
      print('error in active chat room ${e.toString()}');
    });
  }

  static Future<bool> checkActiveStatus(String chatRoomId, String userId) async {
    var activeList = await FirebaseFirestore.instance.collection('chatRoom')
        .doc(chatRoomId).get();
    List _ids = [];
    if (activeList.data() != null) {
      _ids = activeList.data()['active'];
    }
    return _ids.contains(userId);
  }

  static Future<void> addActiveStatus(String chatRoomId, List users, String userId) async {
    CollectionReference chatRoom = FirebaseFirestore.instance.collection('chatRoom');
    Map<String, dynamic> _unreads = Map<String, dynamic>();
    List _ids = [];
    List _users = [];
    var userDataList = await chatRoom.doc(chatRoomId).get();
    if (userDataList.data() != null) {
      _ids = userDataList.data()['active'];
      _unreads = userDataList.data()['unread'] ?? {};
    }
    _users = users;
    if (!_ids.contains(userId)) {
      _ids.add(userId);
    }
    print('active $_ids unread $_unreads users $_users');
    Map<String, dynamic> active = {
      'active': _ids,
      'unread': _unreads,
      'users': _users,
    };
    chatRoom.doc(chatRoomId).set(active).catchError((e) {
        print('error in active chat room ${e.toString()}');
    });
  }

  static removeActiveStatus(String chatRoomId, String userId) async {
    CollectionReference chatRoom = FirebaseFirestore.instance.collection('chatRoom');
    Map<String, dynamic> _unreads = Map<String, dynamic>();
    List _ids = [];
    List _users = [];
    var userDataList = await chatRoom.doc(chatRoomId).get();
    if (userDataList.data() != null) {
      _ids = userDataList.data()['active'];
      _unreads = userDataList.data()['unread'];
      _users = userDataList.data()['users'];
    }
    _ids.remove(userId);
    print('active $_ids unread $_unreads users $_users');
    Map<String, dynamic> active = {
      'active': _ids,
      'unread': _unreads,
      'users': _users,
    };
    chatRoom.doc(chatRoomId).set(active).catchError((e) {
      print('error in active chat room ${e.toString()}');
    });
  }

  static Stream getChatRooms(String userName) {
    return FirebaseFirestore.instance.collection('chatRoom')
        .where('users', arrayContains: userName).snapshots();
  }

  static addChatMessages(String chatRoomId, Map messageMap) {
    FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId)
      .collection('chats').add(messageMap).catchError((e) {
          print('error in add chat message ${e.toString()}');
      });
  }

  static Stream getChatMessages(String chatRoomId) {
    return FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId)
        .collection('chats').orderBy('time', descending: true).snapshots();
  }

  static deleteChatRoom(String chatRoomId) {
    //doc.reference.delete();
    FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId)
      .delete().then((value) {
        print('Chat Room Deleted');
      }).catchError((e) {
        print('error in chat room ${e.toString()}');
      });
  }

  static deleteChat(String chatRoomId) {
    FirebaseFirestore.instance.collection('chatRoom')
      .doc(chatRoomId).collection('chats').get().then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
      }).catchError((e) {
      print('error in deleting chat ${e.toString()}');
    });
  }

  static deleteSelectedChatItems(List<DocumentSnapshot> docs) {
    for (DocumentSnapshot ds in docs) {
      ds.reference.delete();
    }
  }


}
