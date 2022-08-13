import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:loccon/main.dart';
import 'package:loccon/pages/login/otp_login_page.dart';
import 'package:loccon/pages/login/signup_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:shared_preferences/shared_preferences.dart';

class MobileLoginPage extends StatefulWidget {
  @override
  _MobileLoginPageState createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> with Validator {
  TextEditingController _mobileController = TextEditingController();
  // bool _autoValidate = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _phoneAuth() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FirebaseAuth _auth = FirebaseAuth.instance;
      _auth.verifyPhoneNumber(
        phoneNumber: '+91 ${_mobileController.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          _auth.signInWithCredential(credential).then((UserCredential credential) {
            _phoneLogin(_mobileController.text);
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone Auth Failed ${e.message}');
          Alerts.showAlert(context, 'Login Failed', 'Login Failed. Please try again later.');
        },
        codeSent: (String verificationId, int resendToken) {
           Navigator.push(context, MaterialPageRoute(builder: (c) =>
               OTPLoginPage(phone: _mobileController.text, verificationId: verificationId,)));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      setState(() {
        // _autoValidate = true;
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  _phoneLogin(String mobile) async {
    var response = await http.post(Connection.phoneLogin, body: {
      'secretkey': '${Connection.secretKey}',
      'mobile': '$mobile',
    });
    var decodedData = json.decode(response.body);
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
      await _prefs.setString('login', 'p');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          Home()), (Route<dynamic> route) => false);
    } else if (decodedData['status'] == false) {
      Navigator.push(context, MaterialPageRoute(builder: (c) =>
          SignUpPage(mobile: mobile, )));
    } else {
      Alerts.showAlert(context, 'Login Failed',
          'Failed to login through mail. Please try again later.');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mobileController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset("assets/loccon.png",height: 150,width: 200,),
              ),
              SizedBox(height: 20,),
              Center(
                child: Text('Register/Sign In', style: TextStyle(fontSize: 25,color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600),),
              ),
              SizedBox(height: 12,),
              Center(
                child: Text('We will send a confirmation code to your phone', style: TextStyle(
                 fontSize: 16.5, color: Colors.black87),),
              ),
              SizedBox(height: 15,),
              Theme(data: ThemeData(primaryColor: Colors.black87,),
                child: Form(autovalidateMode: _autoValidateMode, key: _formKey,
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: _mobileController,
                    validator: validateMobile,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: TextStyle(color: Colors.black87),
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                     hintText: 'Type Mobile Number',
                     hintStyle: TextStyle(color: Colors.grey),
                     border: UnderlineInputBorder(
                       borderSide: BorderSide(color: Colors.grey),
                     ),
                     enabledBorder: UnderlineInputBorder(
                       borderSide: BorderSide(color: Colors.grey),
                     ),focusedBorder: UnderlineInputBorder(
                       borderSide: BorderSide(color: Colors.black87),
                     ),
                   ),
                  ),
                ),
              ),
              Spacer(),
              SizedBox(width: double.infinity,
                child: CupertinoButton(color: AppTheme.accentColor,
                  child: Text('Get Otp'),
                  onPressed: () {
                    _phoneAuth();
                  }),
              ),
              SizedBox(height: 25,),
            ],
          ),
        ),
      ),
    );
  }
}
