import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loccon/pages/chat/chat_page.dart';
import 'package:loccon/pages/chat/chatroom_page.dart';
import 'package:loccon/pages/events_page.dart';
import 'package:loccon/pages/feed/create_page.dart';
import 'package:loccon/pages/feed/home_page.dart';
import 'package:loccon/pages/feed/new_create_page.dart';
import 'package:loccon/pages/feed/new_post.dart';
import 'package:loccon/pages/login/onboard_page.dart';
import 'package:loccon/pages/login/signup_page.dart';
import 'package:loccon/pages/profile/edit_profile_page.dart';
import 'package:loccon/pages/profile/profile_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/widgets/unread_message_count_bubble.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

SharedPreferences prefs;
FirebaseAnalytics analytics = FirebaseAnalytics();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent));
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Loccon',
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),

      ],
      theme: ThemeData(
        fontFamily: "Rubik",
        primaryColor: Colors.white,
        accentColor: AppTheme.accentColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: prefs.getBool('onboard') == true ? Home() : IntroScreen(),
      home: FutureBuilder(
        future: _initialization,
        builder: (c, s) {
          if (s.hasError) {
            return Center(child: Text('Failed To Initialize Firebase ${s.error}'));
          }
          if (s.connectionState == ConnectionState.done) {
            return prefs.getBool('onboard') == true ? Home() : IntroScreen();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  final String userId;
  final int feedCategoryValue;
  Home({this.userId, this.feedCategoryValue});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2;
  String _name = '', _username = '', _email = '', _mobile = '', _id = '',profilePic = '';

  _getUserInfo() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id') ?? '';
      _name = prefs.getString('name') ?? '';
      _username = prefs.getString('username') ?? '';
      _email = prefs.getString('email') ?? '';
      _mobile = prefs.getString('mobile') ?? '';
      profilePic = prefs.getString("profilepic") ?? '';

    });
  }

  Route _customRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => NewPost(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  _initOneSignal() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.init("9b8fe5fe-881f-430c-881b-144d469c9d94",
      iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: false,
      }
    );
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    await OneSignal.shared.promptUserForPushNotificationPermission(
        fallbackToSettings: true);
    // Setting OneSignal External User Id
    if (_id != '') {
      OneSignal.shared.setExternalUserId(_id);
    }
    OneSignal.shared.setNotificationOpenedHandler((openedResult) async {
      String chatRoomId = openedResult.notification.payload.additionalData['chatroom_id'];
      String userName = openedResult.notification.payload.additionalData['user_name'];
      Navigator.push(context, MaterialPageRoute(builder: (c) =>
        ChatPage(chatRoomId: chatRoomId, userName: userName, myId: _id, myName: _username,)));
    });
  }
  static const PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.proactii.loccon';
  @override
  void initState() {
    _getUserInfo();
    super.initState();
    _initOneSignal();
    //versionCheck(context);
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
  }

  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }
  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                // ignore: deprecated_member_use
                FlatButton(
                  child: Text(btnLabel),
                  onPressed: () => _launchURL(PLAY_STORE_URL),
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  child: Text(btnLabelCancel),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_selectedIndex == 2) {
          Alerts.showAlertExit(context);
          return Future.value(true);
        } else {
          setState(() {
            _selectedIndex = 2;
          });
          return Future.value(false);
        }
      },
      child: Scaffold(
         // body: _pageOptions[_selectedIndex],
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            NewPost(),
            ChatRoomPage(myId: _id, myUserName: _username),
            HomePage(userId: _id, feedCategoryValue: 0,),
            EventsPage(userId: _id,),
            ProfilePage(id: _id, name: _name, email: _email, mobile: _mobile),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset('assets/add.png', height: 25, width: 25,
                      color: _selectedIndex == 0 ?
                      null : Colors.grey,),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                Stack(clipBehavior: Clip.none, children: [
                    GestureDetector(
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset('assets/chat.png', height: 25, width: 25,
                          color: _selectedIndex == 1 ?
                          null : Colors.grey,),
                      ),
                      onTap: () {
                        print('chat list provider called');
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    Positioned(right: 3, top: -8,
                      height: 20, width: 20,
                      child: UnreadMessageCountBubble(myUserName: _username, myId: _id,)),
                  ],
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset('assets/logo_icon.png',height: 50,width: 50,
                      color: _selectedIndex == 2 ? null : Colors.grey,),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset('assets/calendar.png', height: 25, width: 25,
                      color: _selectedIndex == 3 ?
                      null : Colors.grey,),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      child: Image.asset('assets/user.png',
                          height: 25,
                          width: 25,
                        color: _selectedIndex == 4 ?
                        null : Colors.grey,
                          fit: BoxFit.contain,),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 4;
                        });
                      },
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


