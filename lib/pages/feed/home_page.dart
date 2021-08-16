import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loccon/bloc/home_bloc.dart';
import 'package:loccon/main.dart';
import 'package:loccon/models/feed.dart';
import 'package:loccon/models/feed_type.dart';
import 'package:loccon/services/dynamic_link_service.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/widgets/feed_list_item.dart';
import 'package:share/share.dart';


class HomePage extends StatefulWidget {
  final String userId;
  final int feedCategoryValue;
  HomePage({this.userId, this.feedCategoryValue});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _homeBloc = HomeBloc();
  static int _feedCategoryValue;
  String feedTypeId = '';

  Map<int, Widget> _titles = <int, Widget>{
    0: Text('For You',style: TextStyle(color:Colors.black,),),
    1 :Text('Loccon',style: TextStyle(color:Colors.black, ),),
  };

    static int _selectedFeedType = 0;

  @override
  void initState() {
    super.initState();
    _feedCategoryValue = widget.feedCategoryValue;
    DynamicLinkService.initialDynamicLinkCheck(context, widget.userId);
    _homeBloc.fetchFeedTypes();
    _homeBloc.feedCategory.add([FeedCategory.forYou, feedTypeId]);
    _homeBloc.fetchCategoryWiseFeeds();
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: CupertinoSlidingSegmentedControl(
          backgroundColor:Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          children: _titles,
          thumbColor:AppTheme.accentColor,
          groupValue: _feedCategoryValue,
          onValueChanged: (int v) {
            setState(() {
              _feedCategoryValue = v;

            });
            if (_feedCategoryValue == 0) {
              _homeBloc.feedCategory.add([FeedCategory.forYou, feedTypeId]);
            } else {
              _homeBloc.feedCategory.add([FeedCategory.loccon, feedTypeId]);
            }
          },
        ),
      ),
      body: Column(
        children: [
          _categoriesView(),
          Expanded(
            child: FeedList(homeBloc: _homeBloc, feedCategory: _feedCategoryValue,
              userId: widget.userId, feedTypeId: feedTypeId,),
          ),
        ],
      ),
    );
  }

  Widget _categoriesView() {
    return Container(height: 45,
      margin: const EdgeInsets.only(bottom: 10),
      child: StreamBuilder<List<FeedType>>(
        stream: _homeBloc.feedTypeStream,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.active) {
            return SizedBox();
          }
          if (s.hasError) {
            return SizedBox();
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 10, top: 12),
            scrollDirection: Axis.horizontal,
            itemCount: s.data.length,
            itemBuilder: (c, i) {
              return GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _selectedFeedType == i ?
                  Column(mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('${s.data[i].feedType}', style: TextStyle(fontSize: 18,
                          color: AppTheme.accentColor, fontWeight: FontWeight.w700),),
                      SizedBox(height: 4,),
                      Container(height: 5, width: 5,
                        decoration: BoxDecoration(color: AppTheme.accentColor,
                          shape: BoxShape.circle,),
                      ),
                    ],
                  ) : Text('${s.data[i].feedType}', style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w600, color: Colors.grey),),
                ),
                onTap: () {
                  setState(() {
                    _selectedFeedType = i;
                    feedTypeId = s.data[i].id;
                  });
                  if (_feedCategoryValue == 0) {

                    _homeBloc.feedCategory.add([FeedCategory.forYou, feedTypeId]);
                  } else {
                    _homeBloc.feedCategory.add([FeedCategory.loccon, feedTypeId]);
                  }
                },
              );
            });
        },
      ),
    );
  }

}


class FeedList extends StatefulWidget {
  final HomeBloc homeBloc;
  final int feedCategory;
  final String userId, feedTypeId;
  FeedList({this.homeBloc, this.feedCategory, this.userId, this.feedTypeId});
  @override
  _FeedListState createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  ScrollController _scrollController;

  _addPagination() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (widget.feedCategory == 0) {
        widget.homeBloc.fetchForYouFeeds(widget.feedTypeId ?? '');
      } else {
        widget.homeBloc.fetchLocconFeeds(widget.feedTypeId ?? '');
      }
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_addPagination);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Feed>>(
      stream: widget.homeBloc.feedStream,
      builder: (c, s) {
        if (s.connectionState != ConnectionState.active) {
          return Center(child: CircularProgressIndicator(
            color: AppTheme.accentColor,
          ));
        }
        if (s.hasError) {
          print('error is ${s.error}');
          return Center(child: Text('No Feeds', style: TextStyle(
            color: AppTheme.accentColor, fontSize: 20,
            fontWeight: FontWeight.w600),));
        }
        if (s.data.isEmpty) {
          return FutureBuilder(
            future: Future.delayed(Duration(seconds: 6)),
            builder: (c, s) {
              if (s.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator(
                  color: AppTheme.accentColor,
                ));
              } else {
                return Center(
                  child: Text('No events at the moment ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                );
              }
            });
        }
        print("feed category value ${widget.feedCategory} ${widget.feedTypeId}");
        return RefreshIndicator(
          color: AppTheme.accentColor,
          onRefresh: () async {
            if (widget.feedCategory == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Home(userId: widget.userId,feedCategoryValue: 0,)));
              //FeedList(feedCategory: 0, homeBloc: widget.homeBloc, userId: widget.userId, feedTypeId: widget.feedTypeId,);
              //return widget.homeBloc.fetchForYouFeeds(widget.feedTypeId);
            } else {
              FeedList(feedCategory: 1,);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Home(userId: widget.userId,feedCategoryValue: 1,)));
              //return widget.homeBloc.fetchLocconFeeds(widget.feedTypeId);
            }
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            itemCount: s.data.length,
            itemBuilder: (c, i) {
              Uri uri;
              return FeedListItem(index: i, feeds: s.data, userId: widget.userId,
                feedValue: widget.feedCategory,
                like: () => widget.homeBloc.likeFeed(s.data[i].feedId),
                save: () => widget.homeBloc.saveFeed(s.data[i].feedId),
                report: () => widget.homeBloc.reportFeed(s.data[i].feedId, s.data[i].userId),
                share: () async {
                if(s.data[i].photos.isNotEmpty && s.data[i].videoLink.isEmpty){
                  uri = Uri.parse('${Connection.feedImagePath}' + '${s.data[i].photo[0]}');
                } else if(s.data[i].photos.isEmpty && s.data[i].videoLink.isNotEmpty){
                  Uri v = Uri.parse(s.data[i].videoLink);
                  String x = "https://img.youtube.com/vi/${v.queryParameters['v']}/0.jpg";
                  uri = Uri.parse(x);
                  print("value of x $x $uri ");
                }
                  String _dynamicLink = await DynamicLinkService.createDynamicLink(s.data[i].feedId, s.data[i].description, uri);
                  print("details from the sharing point $_dynamicLink");
                  Share.share(_dynamicLink);
                },
              );
            },
          ),
        );
      },
    );
  }

}


