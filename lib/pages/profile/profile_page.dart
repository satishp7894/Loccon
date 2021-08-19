import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loccon/bloc/home_bloc.dart';
import 'package:loccon/models/user_details.dart';
import 'package:loccon/pages/login/login_page.dart';
import 'package:loccon/pages/profile/saved_feeds_page.dart';
import 'package:loccon/pages/profile/update_catgory_page.dart';
import 'package:loccon/pages/profile/user_feeds_page.dart';
import 'package:loccon/services/api_client.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/progress_dialog.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'dart:io';
import 'notification.dart';

class ProfilePage extends StatefulWidget {
  final String id, name, email, mobile, propic;
  ProfilePage({this.id, this.name, this.email, this.mobile, this.propic});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String name, email, mobile, userName, profilePic;
  SharedPreferences _prefs;
  final _homeBloc = HomeBloc();
  final _imagePicker = ImagePicker();
  File _imageFile;

  _uploadProfilePicture() async {
    final _pickedPic = await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(_pickedPic.path);
    });
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: 'Updating profile picture');
    pr.show();
    final _apiClient = ApiClient();
    await _apiClient.updateProfilePhoto(_imageFile);
    pr.hide();
  }

  _updateUserData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      name = _prefs.getString('name') ?? '';
      userName = _prefs.getString('username') ?? '';
      email = _prefs.getString('email') ?? '';
      mobile = _prefs.getString('mobile') ?? '';
      profilePic = _prefs.getString("profilepic") ?? '';
    });
  }

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _updateUserData();
    _homeBloc.fetchUserFeeds();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.name == ''
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You are not logged in',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                OutlineButton(
                  child: Text('Login',style: TextStyle(color: AppTheme.accentColor,fontSize: 16),),
                  borderSide: BorderSide(
                    color: AppTheme.accentColor
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (c) => LoginPage()),
                        (Route<dynamic> route) => false);
                  },
                ),
              ],
            ),
          )
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                elevation: 1,
                title: Row(
                  children: [
                    Image.asset(
                      "assets/profile_icon.png",
                      height: 15,
                      width: 15,
                      color: AppTheme.accentColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '$userName',
                      style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(200),
                  child: SafeArea(
                    child: ListView(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: <Widget>[
                        _profileView(),
                        SizedBox(height: 20,),
                        editProfileView(),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppTheme.accentColor,
                          indicatorWeight: 5.0,
                          labelColor: AppTheme.accentColor,
                          labelPadding: EdgeInsets.only(top: 10.0),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(
                              text: 'My Feed',
                            ),
                            Tab(
                              text: 'Saved Feeds',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              endDrawer: Drawer(
                child: _moreView(),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  UserFeedsPage(
                    id: widget.id,
                  ),
                  SavedFeedsPage()
                ],
              ),
            ),
          );
  }

  Widget _profileView() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(70),
                    border: Border.all(color: AppTheme.accentColor)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: _imageFile == null
                        ? FadeInImage.assetNetwork(
                            placeholder: 'assets/avatar.png' ?? " ",
                            height: 80,
                            width: 80,
                            fit: BoxFit.contain,
                            image: Connection.profilePicPath + '$profilePic') ?? " "
                        : Image.file(_imageFile,
                            height: 80, width: 80, fit: BoxFit.contain)?? " ",
                  ),
                ),
                onTap: () {
                  _uploadProfilePicture();
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  Text(
                    '$name',
                    style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Email : $email',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 5,
                  ), Text(
                    'Contact : $mobile',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget editProfileView() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
                  context, MaterialPageRoute(builder: (c) => EditProfilePage()))
              .then((_) {
            _updateUserData();
          });
        },
        child: Container(
          height: 30,
          width: MediaQuery.of(context).size.width,
          decoration:
              BoxDecoration(border: Border.all(color: AppTheme.accentColor)),
          child: Center(
            child: Text("Edit Profile"),
          ),
        ),
      ),
    );
  }

  Widget _moreView() {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: 100,
          child: UserAccountsDrawerHeader(
            accountName: Text(
              '$userName',
              style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
            ),
            accountEmail: Expanded(
              child: Text(
                '$email - $mobile',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.info_outlined,
              color: AppTheme.accentColor,
            ),
            title: Text(
              'About this app',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {
              _aboutDialog(context);
            },
          ),
        ),
        Divider(
          indent: 15,
          endIndent: 10,
          color: Colors.grey.withOpacity(.8),
        ),
        /*  SizedBox(height: 50,
          child: ListTile(
            leading: Icon(Icons.bookmark_border, color: AppTheme.accentColor,),
            title: Text('Saved Feeds', style: TextStyle(fontSize: 18,),),
            trailing: Icon(Icons.chevron_right,
              color: Colors.grey,),
            onTap: () async {
              _prefs = await SharedPreferences.getInstance();
              if (_prefs.containsKey('id')) {
                Navigator.push(context, MaterialPageRoute(builder: (c) => SavedFeedsPage()));
              } else {
                Alerts.showAlertLogin(context);
              }
            },
          ),
        ),
        Divider(indent: 15, endIndent: 10,
          color: Colors.grey.withOpacity(.8),),*/
        SizedBox(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.category,
              color: AppTheme.accentColor,
            ),
            title: Text(
              'Interests',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () async {
              _prefs = await SharedPreferences.getInstance();
              if (_prefs.containsKey('id')) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => UpdateCategoryPage()));
              } else {
                Alerts.showAlertLogin(context);
              }
            },
          ),
        ),
        Divider(
          indent: 15,
          endIndent: 10,
          color: Colors.grey.withOpacity(.8),
        ),
        SizedBox(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.notifications,
              color: AppTheme.accentColor,
            ),
            title: Text(
              'Notification',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () async {
              _prefs = await SharedPreferences.getInstance();
              if (_prefs.containsKey('id')) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => NotificationPage()));
              } else {
                Alerts.showAlertLogin(context);
              }
            },
          ),
        ),
        Divider(
          indent: 15,
          endIndent: 10,
          color: Colors.grey.withOpacity(.8),
        ),
        /*SizedBox(height: 50,
          child: ListTile(
            leading: Icon(Icons.amp_stories, color: AppTheme.accentColor,),
            title: Text('Your Posts', style: TextStyle(fontSize: 18,),),
            trailing: Icon(Icons.chevron_right,
              color: Colors.grey,),
            onTap: () async {
             _prefs = await SharedPreferences.getInstance();
              if (_prefs.containsKey('id')) {
                Navigator.push(context, MaterialPageRoute(builder: (c) =>
                    UserFeedsPage(id: widget.id,)));
              } else {
                Alerts.showAlertLogin(context);
              }
            },
          ),
        ),
        Divider(indent: 15, endIndent: 10,
          color: Colors.grey.withOpacity(.8),),*/
        SizedBox(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.list,
              color: AppTheme.accentColor,
            ),
            title: Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () async {
              const url = 'http://loccon.in/terms-&-condition.html';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
        Divider(
          indent: 15,
          endIndent: 10,
          color: Colors.grey.withOpacity(.8),
        ),
        SizedBox(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.security,
              color: AppTheme.accentColor,
            ),
            title: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () async {
              const url = 'http://loccon.in/privacy.html';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
        Divider(
          indent: 15,
          endIndent: 10,
          color: Colors.grey.withOpacity(.8),
        ),
        SizedBox(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.share,
              color: AppTheme.accentColor,
            ),
            title: Text(
              'Share this app',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {
              Share.share(
                  'Download The Loccon App.https://play.google.com/store/apps/details?id=com.proactii.loccon');
            },
          ),
        ),
        Divider(
          indent: 15,
          endIndent: 10,
          color: Colors.grey.withOpacity(.8),
        ),
        ListTile(
          leading: Icon(
            Icons.power_settings_new,
            color: AppTheme.accentColor,
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: () {
            _logout(context);
          },
        ),
        Divider(
          indent: 15,
          endIndent: 10,
          color: Colors.grey.withOpacity(.8),
        ),
        SizedBox(
          height: 25,
        ),
      ],
    );
  }

  _aboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/logo_icon.png',
        width: 60,
        fit: BoxFit.cover,
      ),
      children: [
        Text('Loccon connects with the local people who can help.'),
      ],
    );
  }

  _logout(BuildContext context) async {
    _prefs = await SharedPreferences.getInstance();
    String social = _prefs.getString('login') ?? '';
    if (social == 'g') {
      googleSignIn.signOut().then((_) {
        _prefs.clear();
      });
    } else {
      await _prefs.clear();
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
  }
}
