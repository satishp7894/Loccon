
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loccon/main.dart';
import 'package:loccon/pages/login/mobile_login_page.dart';
import 'package:loccon/pages/login/signup_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:loccon/utils/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool termsAgreed = false;

  _googleAuth() async {
    try {
      await googleSignIn.signIn().then((value) {
        _googleLogin(value.email, value.displayName);
      });
    } catch (error) {
      print('google sign-in error $error');
      Alerts.showAlert(context, 'Login Failed',
          'Failed to login through mail google sign in error. Please try again later.');
    }
  }

  _googleLogin(String email, String name) async {
    var response = await http.post(Connection.emailLogin, body: {
      'secretkey': '${Connection.secretKey}',
      'email': '$email',
    });
    var decodedData = json.decode(response.body);
    print('user exists $decodedData email $email');
    if (decodedData['status'] == true) {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('id', '${decodedData['data']['user_id']}');
      await _prefs.setString('type', '${decodedData['data']['user_type']}');
      await _prefs.setString('name', '${decodedData['data']['user_name']}');
      await _prefs.setString('username', '${decodedData['data']['userName']}');
      await _prefs.setString('email', '${decodedData['data']['email']}');
      await _prefs.setString('mobile', '${decodedData['data']['mobile']}');
      await _prefs.setString('profilepic', '${decodedData['data']['photo']}');
      await _prefs.setString('pincode', '${decodedData['data']['pincode']}');
      await _prefs.setString('category', '${decodedData['data']['category_id']}');
      await _prefs.setString('description', '${decodedData['data']['description']}');
      await _prefs.setString('altmobile', '${decodedData['data']['alt_mobile']}');
      await _prefs.setString('address', '${decodedData['data']['address']}');
      await _prefs.setString('state_id', '${decodedData['data']['state_id']}');
      await _prefs.setString('city_id', '${decodedData['data']['city_id']}');
      await _prefs.setString('login', 'g');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          Home()), (Route<dynamic> route) => false);
    } else if (decodedData['status'] == false) {
      Navigator.push(context, MaterialPageRoute(builder: (c) =>
          SignUpPage(email: email, name: name,)));
    } else {
      Alerts.showAlert(context, 'Login Failed',
          'Failed to login through mail. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.accentColorLight,
      body: Container(
        child: Column(
          children: [
            Flexible(flex: 8,
              child: Container(
                child: Center(
                  child: Image.asset('assets/loccon.png',
                    fit: BoxFit.contain, height: 70,),
                ),
              ),
            ),
            Flexible(flex: 8,
              child: Container(
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                ),
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SafeArea(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _agreementListTile(),
                      Spacer(),
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                          decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(
                              color: Colors.black87.withOpacity(.3),
                              blurRadius: 16, offset: Offset(2, 2),
                            )],
                          ),
                          alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icon_phone.png', height: 30,
                                fit: BoxFit.contain,),
                              SizedBox(width: 16,),
                              Text('Continue with Phone', style: TextStyle(fontSize: 20),),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (termsAgreed) {
                            Navigator.push(context, MaterialPageRoute(builder: (c) =>
                                MobileLoginPage()));
                          } else {
                            Alerts.showAlert(context, 'Alert',
                              'Please Accept the Terms & Conditions and Privacy Policy');
                          }
                        },
                      ),
                      SizedBox(height: 25,),
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                          decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(
                              color: Colors.black87.withOpacity(.3),
                              blurRadius: 16, offset: Offset(2, 2),
                            )],
                          ),
                          alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icon_google.png', height: 30,
                                fit: BoxFit.contain,),
                              SizedBox(width: 16,),
                              Text('Sign In with Google', style: TextStyle(fontSize: 20),),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (termsAgreed) {
                            _googleAuth();
                          } else {
                            Alerts.showAlert(context, 'Alert',
                              'Please Accept the Terms & Conditions and Privacy Policy');
                          }
                        },
                      ),
                      TextButton(
                        child: Text('Skip Login', style: TextStyle(color: AppTheme.accentColor,fontSize: 18,
                            decoration: TextDecoration.underline),),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) =>
                              Home()), (Route<dynamic> route) => false);
                        },),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _agreementListTile() {
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 16);
    TextStyle linkStyle = TextStyle(color: AppTheme.accentColor, fontSize: 16);
    return CheckboxListTile(
      value: termsAgreed,
      controlAffinity: ListTileControlAffinity.leading,
      title: RichText(text: TextSpan(style: defaultStyle,
        children: <TextSpan>[
          TextSpan(text: 'By clicking Sign Up, you agree to our '),
          TextSpan(text: 'Terms of Service', style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = () async {
              const url = "http://loccon.in/terms-&-condition.html";
              if (await canLaunch(url))
                await launch(url);
            }),
          TextSpan(text: ' and that you have read our '),
          TextSpan(text: 'Privacy Policy', style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = () async {
              const url = "http://loccon.in/privacy.html";
              if (await canLaunch(url))
                await launch(url);
            }),
          ],
        ),
      ),
      onChanged: (v) {
        setState(() {
          termsAgreed = v;
        });
      },
    );
  }

  Widget agreementView() {
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 16);
    TextStyle linkStyle = TextStyle(color: AppTheme.accentColor, fontSize: 16);
    return RichText(text: TextSpan(style: defaultStyle,
        children: <TextSpan>[
          TextSpan(text: 'By clicking Sign Up, you agree to our \n'),
          TextSpan(text: 'Terms of Service', style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = () async {
              const url = "http://loccon.in/terms-&-condition.html";
              if (await canLaunch(url))
                await launch(url);
            }),
          TextSpan(text: ' and that you have read our '),
          TextSpan(text: 'Privacy Policy', style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = () async {
              const url = "http://loccon.in/privacy.html";
              if (await canLaunch(url))
              await launch(url);
            }),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

}
