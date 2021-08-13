import 'package:flutter/material.dart';
import 'package:loccon/bloc/home_bloc.dart';
import 'package:loccon/models/feed.dart';
import 'package:loccon/models/user_details.dart';
import 'package:loccon/services/api_client.dart';
import 'package:loccon/services/dynamic_link_service.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/widgets/feed_list_item.dart';
import 'package:share/share.dart';

class UserProfilePage extends StatefulWidget {
  final String profileId, userId;
  UserProfilePage({this.profileId, this.userId});
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _apiClient = ApiClient();
  final _homeBloc = HomeBloc();
  Future userProfile;

  @override
  void initState() {
    userProfile = _apiClient.getUserProfile(widget.profileId);
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, centerTitle: true,
        title: Text('Profile'),
      ),
      body: FutureBuilder(
        future: userProfile,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(
              color: AppTheme.accentColor,
            ));
          }
          if (s.hasError) {
            print('error is ${s.error}');
            return Center(
              child: Text('No User Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            );
          }
          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              SizedBox(height: 10,),
              _profileView(s.data[0]),
              SizedBox(height: 20,),
              _postsView(s.data[1]),
            ],
          );
        }
      ),
    );
  }

  Widget _profileView(UserDetails userDetails) {
    return Column(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: FadeInImage.assetNetwork(placeholder: 'assets/avatar.png',
                height: 140, width: 140, fit: BoxFit.cover,
                image: Connection.profilePicPath + '${userDetails.photo}')?? null ,
            ),
          ],
        ),
        SizedBox(height: 15,),
        Text('${userDetails.userName}', style: TextStyle(color: AppTheme.accentColor,
            fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,),
        SizedBox(height: 5,),
        Text('${userDetails.email} - ${userDetails.mobile}',
          style: TextStyle(color: Colors.grey, fontSize: 16,),
          textAlign: TextAlign.center,),
        SizedBox(height: 14,),
      ],
    );
  }

  Widget _postsView(List<Feed> userPosts) {
    return ListView.builder(shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: userPosts.length,
      itemBuilder: (c, i) {
        return FeedListItem(
          index: i, feeds: userPosts, userId: widget.userId,
          like: () => _homeBloc.likeFeed(userPosts[i].feedId),
          save: () => _homeBloc.saveFeed(userPosts[i].feedId),
          report: () => _homeBloc.reportFeed(userPosts[i].feedId, userPosts[i].userId),
          share: () async {
            // String _dynamicLink = await DynamicLinkService.createDynamicLink(userPosts[i].feedId);
            // Share.share(_dynamicLink);
          },
        );
      });
  }

}
