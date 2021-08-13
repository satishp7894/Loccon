
class Feed {

  String feedId, userId, name, userName, photos, videoLink, description, feedType,
    feedIcon, categoryId, category, profilePic;
  DateTime feedDate;
  List photo;
  bool like, save, report;
  int totalLikes, totalComments;

  Feed({this.feedId, this.userId, this.name, this.userName, this.photos, this.videoLink,
    this.description, this.feedType, this.feedIcon, this.categoryId, this.category,
    this.profilePic, this.feedDate, this.photo, this.like, this.save, this.report,
    this.totalLikes, this.totalComments});

  Feed.fromJson(Map<String, dynamic> json) :
      feedId = json['data']['feed_id'],
      userId = json['data']['user_id'],
      name = json['data']['userName'],
      userName = json['data']['user_name'],
      photos = json['data']['photos'],
      videoLink = json['data']['video_link'],
      description = json['data']['description'],
      feedType = json['data']['feed_type'],
      feedIcon = json['data']['icon'],
      categoryId = json['data']['category_id'],
      category = json['data']['category'],
      profilePic = json['data']['profilepic'],
      feedDate = DateTime.parse(json['data']['feed_date']),
      photo = json['photo'],
      like = json['like'],
      save = json['save'],
      report = json['report'],
      totalLikes = json['totalLike'],
      totalComments = json['totalComment'];

}