
class ServerMessage {

  String senderId, receiverId, message, name;
  ServerMessage({this.senderId, this.receiverId, this.message, this.name});

  ServerMessage.fromJson(Map<String, dynamic> json) :
    senderId = json['sender_user_id'],
    receiverId = json['receiver_user_id'],
    message = json['messages'],
    name = json['user_name'];

}