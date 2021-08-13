import 'package:flutter/material.dart';
import 'package:loccon/bloc/home_bloc.dart';
import 'package:loccon/models/feed.dart';
import 'package:loccon/pages/feed/comments_page.dart';
import 'package:loccon/pages/feed/interactive_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/widgets/youtube_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class UserFeedsPage extends StatefulWidget {
  final String id;
  UserFeedsPage({this.id});
  @override
  _UserFeedsPageState createState() => _UserFeedsPageState();
}

class _UserFeedsPageState extends State<UserFeedsPage> {
  final _homeBloc = HomeBloc();
  String userId;

  _getUserId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = _prefs.getString('id') ?? '';
    });
  }

  @override
  void initState() {
    _getUserId();
    super.initState();
    _homeBloc.fetchUserFeeds();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Feed>>(
        stream: _homeBloc.userFeedStream,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.active) {
            return Center(child: CircularProgressIndicator(
              color: AppTheme.accentColor,
            ));
          }
          if (s.hasError || s.data.isEmpty) {
            return Center(child: Text('No feeds found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
            );
          } else {
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: s.data.length,
              itemBuilder: (c, i) {
                return UserFeedListItem(index: i, feeds: s.data, userId: widget.id,
                  like: () => _homeBloc.likeFeed(s.data[i].feedId),
                  save: () => _homeBloc.saveFeed(s.data[i].feedId),
                  delete: () {
                    _homeBloc.deleteFeed(s.data[i].feedId).then((isDeleted) {
                      if (isDeleted == true) {
                        setState(() {
                          s.data.removeAt(i);
                        });
                      }
                    });
                  },
                );
              });
          }
        }
      ),
    );
  }
}

class UserFeedListItem extends StatefulWidget {
  final int index;
  final String userId;
  final List<Feed> feeds;
  final VoidCallback like, save, delete, share;
  UserFeedListItem({this.index, this.feeds, this.userId, this.like, this.save,
    this.delete, this.share});
  @override
  _UserFeedListItemState createState() => _UserFeedListItemState();
}

class _UserFeedListItemState extends State<UserFeedListItem> {
  bool _isLiked = false;
  bool _isSaved = false;
  int _totalComments = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.feeds[widget.index].like;
    _isSaved = widget.feeds[widget.index].save;
    _totalComments = widget.feeds[widget.index].totalComments ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(left: 10,right: 10),
      child: Column(mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 8,),
          Row(mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: FadeInImage.assetNetwork(placeholder: 'assets/avatar.png',
                    height: 36, width: 36, fit: BoxFit.cover,
                    image: Connection.profilePicPath +
                        '${widget.feeds[widget.index].profilePic}'),
              ),
              SizedBox(width: 10,),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${widget.feeds[widget.index].userName}',
                    style: TextStyle(fontWeight: FontWeight.w700),),
                  SizedBox(height: 2,),
                  Text('${timeAgo.format(widget.feeds[widget.index].feedDate)}',
                    style: TextStyle(color: Colors.grey),),
                ],
              ),
              Spacer(),
              PopupMenuButton<String>(
                onSelected: (s) {
                  widget.delete();
                },
                itemBuilder: (BuildContext context) {
                  return {'Delete'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice, child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
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
            padding: const EdgeInsets.only(left: 10, right: 10,top: 2,bottom: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${widget.feeds[widget.index].feedType} - ${widget.feeds[widget.index].category}',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600,
                  fontSize: 16), maxLines: null,),
          ),
          if (widget.feeds[widget.index].photo.isNotEmpty ||
              widget.feeds[widget.index].videoLink != '')
            Padding(padding: const EdgeInsets.only(top: 6),
              child: Text('${widget.feeds[widget.index].description}',
                style: TextStyle(color: Colors.black.withOpacity(.7),
                    fontSize: 16), maxLines: null,),
            ),
        ],
      ),
    );
  }

  Widget _typeView() {
    if (widget.feeds[widget.index].photo.isEmpty &&
        widget.feeds[widget.index].videoLink != '') {
      return Container(height: 220,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),),
        child: YoutubeView(youtubeUrl: '${widget.feeds[widget.index].videoLink}'),
      );
    } else if (widget.feeds[widget.index].photo.length == 1) {
      return GestureDetector(
        child: Container(height:400,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            image: DecorationImage(fit: BoxFit.contain,
              image: NetworkImage('${Connection.feedImagePath}' +
                  '${widget.feeds[widget.index].photo[0]}'),
            ),
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) =>
              InteractivePage(images: ['${widget.feeds[widget.index].photo[0]}'],)));
        },
      );
    } else if (widget.feeds[widget.index].photo.length > 1) {
      return _multiPhotoView();
    } else {
      return Container(
        constraints: BoxConstraints(minHeight: 220,),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Text('${widget.feeds[widget.index].description}',
            style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center,),
        ),
      );
    }
  }

  int currentPageValue = 0;
  Widget _multiPhotoView() {
    return Column(
      children: <Widget>[
        GestureDetector(
          child: Container(height: 220,
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
                itemCount: widget.feeds[widget.index].photo.length,
                itemBuilder: (c, i) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(fit: BoxFit.cover,
                        image: NetworkImage(Connection.feedImagePath +
                            '${widget.feeds[widget.index].photo[i]}'),
                      ),
                    ),
                  );
                }),
          ),
          onTap: () {
            List<String> _photos = (widget.feeds[widget.index].photo).map((e) => e as String).toList();
            Navigator.push(context, MaterialPageRoute(builder: (c) =>
                InteractivePage(images: _photos,)));
          },
        ),
        SizedBox(height: 10,),
        SizedBox(height: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i=0; i<widget.feeds[widget.index].photo.length; i++)
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
              _isLiked ? widget.feeds[widget.index].totalLikes += 1 :
              widget.feeds[widget.index].totalLikes -= 1;
            });
            widget.feeds[widget.index].like = true;
            widget.like();
          },
        ),
        Text('${widget.feeds[widget.index].totalLikes}',
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
        widget.feeds[widget.index].save = true;
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
                CommentsPage(feedId: widget.feeds[widget.index].feedId,)));
          },),
        Text('$_totalComments',
          style: TextStyle(color: Colors.black87),),
      ],
    );
  }

  Widget _shareView() {
    return IconButton(icon: Icon(Icons.share),
      color: Colors.black.withOpacity(.7),
      onPressed: () {
        widget.share();
      },);
  }

}
