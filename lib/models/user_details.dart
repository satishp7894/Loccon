
class UserDetails {

  String userId, userType, userName, name, mobile, email, state, city, photo;
  UserDetails({this.userId, this.userType, this.userName, this.name, this.mobile,
      this.email, this.state, this.city, this.photo});

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
    userId: json['user_id'],
    userType: json['user_type'],
    userName: json['user_name'],
    name: json['userName'],
    mobile: json['mobile'],
    email: json['email'],
    state: json['state'],
    city: json['city'],
    photo: json['photo'],
  );

}