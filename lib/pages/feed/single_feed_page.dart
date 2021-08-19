import 'package:flutter/material.dart';
import 'package:loccon/bloc/home_bloc.dart';
import 'package:loccon/models/feed.dart';
import 'package:loccon/pages/user_profile_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/widgets/youtube_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'comments_page.dart';


class SingleFeedPage extends StatefulWidget {
  final String feedId, userId;
  SingleFeedPage({this.feedId, this.userId});
  @override
  _SingleFeedPageState createState() => _SingleFeedPageState();
}

class _SingleFeedPageState extends State<SingleFeedPage> {
  final _homeBloc = HomeBloc();

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, elevation: 1,
      ),
      body: FutureBuilder(
        future: _homeBloc.getSingleFeed(widget.feedId),
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return  Center(child: Image.asset("assets/loading.gif",height: 60,));
          }
          if (s.hasError || s.data == null) {
            print('error is ${s.error}');
            return Center(child: Text('Feed not found', style: TextStyle(
              color: AppTheme.accentColor, fontSize: 20,
              fontWeight: FontWeight.w600),));
          }
          return SingleFeedItem(feed: s.data, userId: widget.userId,
            like: () => _homeBloc.likeFeed(widget.feedId),
            save: () => _homeBloc.saveFeed(widget.feedId),
            report: () => _homeBloc.reportFeed(widget.feedId, s.data.userId),
            share: () async {
              // String _dynamicLink = await DynamicLinkService.createDynamicLink(s.data.feedId);
              // Share.share(_dynamicLink);
            },
          );
        },
      ),
    );
  }
}


class SingleFeedItem extends StatefulWidget {
  final Feed feed;
  final String userId;
  final VoidCallback like, save, report, share;
  SingleFeedItem({this.userId, this.feed, this.like, this.save, this.report, this.share});
  @override
  _SingleFeedItemState createState() => _SingleFeedItemState();
}

class _SingleFeedItemState extends State<SingleFeedItem> {
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    print('feed user ${widget.feed.userName} and desc ${widget.feed.description}');
    _isLiked = widget.feed.like;
    _isSaved = widget.feed.save;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(top: 10,right: 10),
      child: Column(mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 8),
          GestureDetector(
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: FadeInImage.assetNetwork(placeholder: 'assets/avatar.png',
                    height: 36, width: 36, fit: BoxFit.cover,
                    image: Connection.profilePicPath +
                        '${widget.feed.profilePic}'),
                ),
                SizedBox(width: 10,),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${widget.feed.userName}',
                      style: TextStyle(fontWeight: FontWeight.w700),),
                    SizedBox(height: 2,),
                    Text('${timeAgo.format(widget.feed.feedDate)}',
                      style: TextStyle(color: Colors.grey),),
                  ],
                ),
                Spacer(),
                if (widget.userId != '' &&
                    widget.userId != widget.feed.userId)
                  PopupMenuButton<String>(
                    onSelected: (s) {
                      if (s == 'Report') {
                        widget.report();
                      } else {
                        print('Message');
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Message', 'Report'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice, child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) =>
                  UserProfilePage(userId: widget.userId,
                    profileId: widget.feed.userId,)));
            },
          ),
          SizedBox(height: 14,),
          _typeView(),
          Row(
            children: <Widget>[
              _likeView(),
              SizedBox(width: 10,),
              _commentsView(),
              _shareView(),
              Spacer(),
              _saveView(),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 0.8),
            ),
            child: Text('${widget.feed.feedType} - ${widget.feed.category}',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600,
                  fontSize: 16), maxLines: null,),
          ),
          if (widget.feed.photo.isNotEmpty ||
              widget.feed.videoLink != '')
            Padding(padding: const EdgeInsets.only(top: 6),
              child: Text('${widget.feed.description}',
                style: TextStyle(color: Colors.black.withOpacity(.7),
                    fontSize: 16), maxLines: null,),
            ),
        ],
      ),
    );
  }

  Widget _typeView() {
    if (widget.feed.photo.isEmpty &&
        widget.feed.videoLink != '') {
      return Container(height: 220,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),),
        child: YoutubeView(youtubeUrl: '${widget.feed.videoLink}'),
      );
    } else if (widget.feed.photo.length == 1) {
      return Container(height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(fit: BoxFit.cover,
            image: NetworkImage('${Connection.feedImagePath}' +
                '${widget.feed.photo[0]}'),
          ),
        ),
      );
    } else if (widget.feed.photo.length > 1) {
      return _multiPhotoView();
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(minHeight: 220,),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Text('${widget.feed.description}',
            style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center,),
        ),
      );
    }
  }

  int currentPageValue = 0;
  Widget _multiPhotoView() {
    return Column(
      children: <Widget>[
        Container(height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: PageView.builder(
              physics: ClampingScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  currentPageValue = page;
                });
              },
              itemCount: widget.feed.photo.length,
              itemBuilder: (c, i) {
                return Container(
                  decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(fit: BoxFit.cover,
                      image: NetworkImage(Connection.feedImagePath +
                          '${widget.feed.photo[i]}'),
                    ),
                  ),
                );
              }),
        ),
        SizedBox(height: 10,),
        SizedBox(height: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i=0; i<widget.feed.photo.length; i++)
                if (i == currentPageValue) ...[circleBar(true)] else
                  circleBar(false),
            ],
          ),
        ),
      ],
    );
  }

  Widget circleBar(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 6),
      height: isActive ? 9 : 6,
      width: isActive ? 9 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.black :
        Colors.black.withOpacity(.5),
        borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }

  Widget _likeView() {
    return Row(
      children: <Widget>[
        IconButton(
          icon: _isLiked ? Icon(Icons.favorite,
            color: Colors.red, size: 27,) :
          Icon(Icons.favorite_border,
            color: Colors.black.withOpacity(.7), size: 27,),
          onPressed: () {
            if (widget.userId == '') {
              Alerts.showAlertLogin(context);
              return;
            }
            setState(() {
              _isLiked ? _isLiked = false : _isLiked = true;
              _isLiked ? widget.feed.totalLikes += 1 :
              widget.feed.totalLikes -= 1;
            });
            widget.feed.like = true;
            widget.like();
          },
        ),
        Text('${widget.feed.totalLikes}',
          style: TextStyle(color: Colors.black87),),
      ],
    );
  }

  Widget _saveView() {
    return IconButton(
      icon: _isSaved ? Icon(Icons.bookmark,
        color: Colors.black87, size: 27,) :
      Icon(Icons.bookmark_border,
        color: Colors.black.withOpacity(.7), size: 27,),
      onPressed: () {
        if (widget.userId == '') {
          Alerts.showAlertLogin(context);
          return;
        }
        setState(() {
          _isSaved ? _isSaved = false : _isSaved = true;
        });
        widget.feed.save = true;
        widget.save();
      },
    );
  }

  Widget _commentsView() {
    return Row(
      children: <Widget>[
        IconButton(icon: Icon(Icons.comment),
          color: Colors.black.withOpacity(.7),
          onPressed: () {
            if (widget.userId == '') {
              Alerts.showAlertLogin(context);
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (c) =>
                CommentsPage(feedId: widget.feed.feedId,)));
          },),
        Text('${widget.feed.totalComments}',
          style: TextStyle(color: Colors.black87),),
      ],
    );
  }

  // Widget _messageView() {
  //   return Column(mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       IconButton(icon: Icon(Icons.message),
  //         color: Colors.black.withOpacity(.7),
  //         onPressed: () async {
  //           if (widget.userId == '') {
  //             Alerts.showAlertLogin(context);
  //             return;
  //           }
  //           var box = await Hive.openBox(Connection.chatList);
  //           Map<String, dynamic> chatPerson = Map<String , dynamic>();
  //           chatPerson['id'] = '${widget.snapshot.data[widget.index].userId}';
  //           chatPerson['name'] = '${widget.snapshot.data[widget.index].userName}';
  //           box.put('${widget.snapshot.data[widget.index].userId}', chatPerson);
  //           Navigator.push(context, MaterialPageRoute(builder: (c) => ChatListPage()));
  //         },),
  //       Text('Message', style: TextStyle(color: Colors.black87),),
  //     ],
  //   );
  // }

  Widget _shareView() {
    return IconButton(icon: Icon(Icons.share),
      color: Colors.black.withOpacity(.7),
      onPressed: () {
        widget.share();
      },);
  }


}

