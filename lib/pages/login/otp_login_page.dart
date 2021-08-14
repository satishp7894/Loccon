import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loccon/main.dart';
import 'package:loccon/pages/login/signup_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:shared_preferences/shared_preferences.dart';


class OTPLoginPage extends StatefulWidget {
  final String phone, verificationId;
  OTPLoginPage({this.phone, this.verificationId});

  @override
  _OTPLoginPageState createState() => _OTPLoginPageState();
}

class _OTPLoginPageState extends State<OTPLoginPage> with Validator {
  TextEditingController _otpController = TextEditingController();
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _verifyOTP() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FirebaseAuth _auth = FirebaseAuth.instance;
      var _cred = PhoneAuthProvider.credential(verificationId: '${widget.verificationId}',
          smsCode: '${_otpController.text.trim()}');
      _auth.signInWithCredential(_cred).then((UserCredential credential) {
          _phoneLogin('${widget.phone}');
      });
    } else {
      setState(() {
        _autoValidate = true;
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
          SignUpPage(mobile: mobile,)));
    } else {
      Alerts.showAlert(context, 'Login Failed',
          'Failed to login through mail. Please try again later.');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
  }


  String number;
  String newNumber;
  hideNumber(){
     number = "+91${widget.phone}";
     newNumber= number;

    String replaceCharAt(String oldString, int index, String newChar) {
      return oldString.substring(0, index) + newChar + oldString.substring(index + 1);
    }


    for(int i=6; i<number.length;i++){
      newNumber = replaceCharAt(newNumber, i, "*") ;
      print("PHONE_NUMBER_LOOP:$newNumber");

    }

    print("FinalNumber:$newNumber");


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset("assets/loccon.png",height: 150,width: 200,),
              ),
              SizedBox(height: 20,),
              Center(
                child: Text('Enter your confirmation code', style: TextStyle(fontSize: 25,color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600),),
              ),
              SizedBox(height: 12,),
              Center(
                child: Text('We sent you 6-digit code to ${widget.phone}', style: TextStyle(
                    fontSize: 16.5, color: Colors.black87),),
              ),
              SizedBox(height: 15,),
              Theme(data: ThemeData(primaryColor: Colors.black87,),
                child: Form(autovalidate: _autoValidate, key: _formKey,
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: _otpController,
                    validator: validateRequired,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: TextStyle(color: Colors.black87),
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Confirmation code',
                      hintStyle: TextStyle(color: Colors.black87),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87),
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
                  child: Text('Confirm Otp'),
                  onPressed: () {
                    _verifyOTP();

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
