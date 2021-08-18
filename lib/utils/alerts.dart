import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loccon/main.dart';
import 'package:loccon/pages/login/login_page.dart';
import 'package:loccon/utils/apptheme.dart';


class Alerts {

  static showAlert(BuildContext context, String title, String message) {
    showDialog(context: context,
      builder: (BuildContext context) {
        return Platform.isIOS ? CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoButton(
              child: Text("Okay", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ) : AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Okay", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static showAlertAndBack(BuildContext context, String title, String message) {
    showDialog(context: context,
      builder: (BuildContext c) {
        return Platform.isIOS ? CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoButton(
              child: Text("Okay", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.pop(context, true);
              },
            ),
          ],
        ) : AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Okay", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  static showAlertLogin(BuildContext context) {
    showDialog(context: context,
      builder: (BuildContext c) {
        return Platform.isIOS ? CupertinoAlertDialog(
          title: Text('Login Required'),
          content: Text('You must login first.'),
          actions: <Widget>[
            CupertinoButton(
              child: Text("Cancel", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
            CupertinoButton(
              child: Text("Login", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false);
              },
            ),
          ],
        ) : AlertDialog(
          title: Text('Login Required'),
          content: Text('You must login first.'),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
            FlatButton(
              child: Text("Login", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  static showAlertExit(BuildContext context) {
    showDialog(context: context,
      builder: (BuildContext c) {
        return Platform.isIOS ? CupertinoAlertDialog(
          title: Row(
            children: [
              Image.asset("assets/logo_icon.png"),
              SizedBox(width: 5,),
              Text('Loccon App',style: TextStyle(color: AppTheme.accentColor),),
            ],
          ),
          content: Text('Are you sure you want to exit from app?'),
          actions: <Widget>[
            CupertinoButton(
              child: Text("Dismiss", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
            CupertinoButton(
              child: Text("Exit", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        ) : AlertDialog(
          title:Row(
            children: [
              Image.asset("assets/logo_icon.png",height: 50,width: 50,),
              SizedBox(width: 5,),
              Text('Loccon App',style: TextStyle(color: AppTheme.accentColor),),
            ],
          ),
          content: Text('Are you sure you want to exit from app?'),
          actions: <Widget>[
            FlatButton(
              child: Text("Dismiss", style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
            FlatButton(
              child: Text("Exit", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(c).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

}