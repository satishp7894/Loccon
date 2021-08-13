import 'package:flutter/material.dart';
import 'package:loccon/pages/login/login_page.dart';
import 'package:loccon/pages/profile/edit_profile_page.dart';
import 'package:loccon/pages/profile/saved_feeds_page.dart';
import 'package:loccon/pages/profile/update_catgory_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1,
        title: Text('More'),),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 50,
            child: ListTile(
              leading: Icon(Icons.info_outlined, color: AppTheme.accentColor,),
              title: Text('About this app', style: TextStyle(fontSize: 18,),),
              trailing: Icon(Icons.chevron_right,
                color: Colors.grey,),
              onTap: () {
                _aboutDialog(context);
              },
            ),
          ),
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          SizedBox(height: 50,
            child: ListTile(
              leading: Icon(Icons.bookmark_border, color: AppTheme.accentColor,),
              title: Text('Saved Feeds', style: TextStyle(fontSize: 18,),),
              trailing: Icon(Icons.chevron_right,
                color: Colors.grey,),
              onTap: () async {
                SharedPreferences _prefs = await SharedPreferences.getInstance();
                if (_prefs.containsKey('id')) {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SavedFeedsPage()));
                } else {
                  Alerts.showAlertLogin(context);
                }
              },
            ),
          ),
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          SizedBox(height: 50,
            child: ListTile(
              leading: Icon(Icons.category, color: AppTheme.accentColor,),
              title: Text('Interests', style: TextStyle(fontSize: 18,),),
              trailing: Icon(Icons.chevron_right,
                color: Colors.grey,),
              onTap: () async {
                SharedPreferences _prefs = await SharedPreferences.getInstance();
                if (_prefs.containsKey('id')) {
                  Navigator.push(context, MaterialPageRoute(builder: (c) =>
                      UpdateCategoryPage()));
                } else {
                  Alerts.showAlertLogin(context);
                }
              },
            ),
          ),
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          SizedBox(height: 50,
            child: ListTile(
              leading: Icon(Icons.edit, color: AppTheme.accentColor,),
              title: Text('Edit Profile', style: TextStyle(fontSize: 18,),),
              trailing: Icon(Icons.chevron_right,
                color: Colors.grey,),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) =>
                  EditProfilePage()));
              },
            ),
          ),
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          SizedBox(height: 50,
            child: ListTile(
              leading: Icon(Icons.list, color: AppTheme.accentColor,),
              title: Text('Terms & Conditions', style: TextStyle(fontSize: 18,),),
              trailing: Icon(Icons.chevron_right,
                color: Colors.grey,),
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
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          SizedBox(height: 50,
            child: ListTile(
              leading: Icon(Icons.security, color: AppTheme.accentColor,),
              title: Text('Privacy Policy', style: TextStyle(fontSize: 18,),),
              trailing: Icon(Icons.chevron_right,
                color: Colors.grey,),
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
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          SizedBox(height: 50,
            child: ListTile(
              leading: Icon(Icons.share, color: AppTheme.accentColor,),
              title: Text('Share', style: TextStyle(fontSize: 18,),),
              trailing: Icon(Icons.chevron_right,
                color: Colors.grey,),
              onTap: () {
                Share.share('Download The Loccon App.');
              },
            ),
          ),
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          ListTile(
            leading: Icon(Icons.power_settings_new, color: AppTheme.accentColor,),
            title: Text('Logout', style: TextStyle(fontSize: 18,),),
            trailing: Icon(Icons.chevron_right,
              color: Colors.grey,),
            onTap: () {
               _logout(context);
            },
          ),
          Divider(indent: 15, endIndent: 10,
            color: Colors.grey.withOpacity(.8),),
          SizedBox(height: 25,),
        ],
      ),
    );
  }

  _aboutDialog(BuildContext context) {
    showAboutDialog(context: context,
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset('assets/logo_icon.png', width: 60, fit: BoxFit.cover,),
      children: [
        Text('Loccon connects with the local people who can help.'),
      ],
    );
  }

  _logout(BuildContext context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String social = _prefs.getString('login') ?? '';
    if (social == 'g') {
      googleSignIn.signOut().then((_) {
        _prefs.clear();
      });
    } else {
      await _prefs.clear();
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
        LoginPage()), (Route<dynamic> route) => false);
  }

}
