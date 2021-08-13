
class SingleFeed {

  String feedId, userId, userName, photos, videoLink, description, feedType,
      feedIcon, categoryId, category;
  DateTime feedDate;
  List photo;
  bool like, save, report;
  int totalLikes;

  SingleFeed({this.feedId, this.userId, this.userName, this.photos, this.videoLink,
    this.description, this.feedType, this.feedIcon, this.categoryId, this.category,
    this.feedDate, this.photo, this.like, this.save, this.report, this.totalLikes});


}