

class FeedType {

  String id, feedType, icon;
  FeedType({this.id, this.feedType, this.icon});

  FeedType.fromJson(Map<String, dynamic> json) :
     id = json['feed_type_id'],
    feedType = json['feed_type'],
    icon = json['icon'];

}