import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loccon/main.dart';
import 'package:loccon/models/category.dart';
import 'package:loccon/models/city.dart';
import 'package:loccon/models/state.dart';
import 'package:loccon/pages/login/interest_selection_page.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/flip_view.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  final String email, name, mobile;
  SignUpPage({this.email, this.name, this.mobile});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin, Validator {
  AnimationController _animationController;
  Animation<double> _curvedAnimation;
  bool _isBackView = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _altMobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String _categoryId, _stateId, _cityId;
  List<Category> _categories = [];
  List<String> _categoryIds = [];

  int _sharedValue = 0;
  final Map<int, Widget> _titles = <int, Widget>{
    0: Text('General'),
    1: Text('Business'),
  };

  _addCategories() {
    _categories.add(Category(categoryId: '1', category: 'Real Estate'));
    _categories.add(Category(categoryId: '2', category: 'Shopping'));
    _categories.add(Category(categoryId: '3', category: 'Industrial'));
    _categories.add(Category(categoryId: '4', category: 'Jobs'));
    _categories.add(Category(categoryId: '5', category: 'Education'));
    _categories.add(Category(categoryId: '6', category: 'Entertainment'));
    _categories.add(Category(categoryId: '7', category: 'Hospital'));
    _categories.add(Category(categoryId: '8', category: 'Medical'));
    _categories.add(Category(categoryId: '9', category: 'Property'));
    _categories.add(Category(categoryId: '10', category: 'Travel'));
    _categories.add(Category(categoryId: '11', category: 'Discounts'));
    _categories.add(Category(categoryId: '12', category: 'Events'));
    _categories.add(Category(categoryId: '13', category: 'News'));
  }

  Future<List<States>> _getStates() async {
    var response = await http.post(Connection.state, body: {
      'secretkey': '${Connection.secretKey}',
    });
    var decodedData = json.decode(response.body);
    List<States> _states = [];
    if (decodedData['status'] == true) {
      _states = (decodedData['data'] as List).map<States>((json) =>
          States.fromJson(json)).toList();
    }
    return _states;
  }

  Future<List<City>> _getCities() async {
    var response = await http.post(Connection.city, body: {
      'state_id': '$_stateId',
      'secretkey': '${Connection.secretKey}',
    });
    var decodedData = json.decode(response.body);
    List<City> _cities = [];
    if (decodedData['status'] == true) {
      _cities = (decodedData['data'] as List).map<City>((json) =>
          City.fromJson(json)).toList();
    }
    return _cities;
  }

  _register() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_categoryIds.isEmpty) {
        Alerts.showAlert(context, 'Interests Required', 
            'Please select interests and try again.');
        return;
      }
      print('interest ${json.encode(_categoryIds)} \n categ $_categoryId \n statte $_stateId \n city $_cityId');
      var response = await http.post(Connection.signUp, body: {
        'user_type': _sharedValue == 0 ? 'Normal' : 'Business',
        'userName': '${_userNameController.text}',
        'user_name': '${_nameController.text}',
        'email': '${_emailController.text}',
        'mobile': '${_mobileController.text}',
        'interest': '${json.encode(_categoryIds)}',
        'category_id': _sharedValue == 0 ? '' : '$_categoryId',
        'description': '${_descriptionController.text}',
        'alt_mobile': '${_altMobileController.text}',
        'address': '${_addressController.text}',
        'pincode': '${_pincodeController.text}',
        'state_id': '$_stateId',
        'city_id': '$_cityId',
        'photo': '',
        'secretkey': '${Connection.secretKey}',
      });
      var decodedData = json.decode(response.body);
      print('decoded register $decodedData');
      if (decodedData['status'] == true) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        await _prefs.setString('id', '${decodedData['data'][0]['user_id']}');
        await _prefs.setString('type', '${decodedData['data'][0]['user_type']}');
        await _prefs.setString('name', '${decodedData['data'][0]['user_name']}');
        await _prefs.setString('username', '${decodedData['data'][0]['userName']}');
        await _prefs.setString('email', '${decodedData['data'][0]['email']}');
        await _prefs.setString('mobile', '${decodedData['data'][0]['mobile']}');
        await _prefs.setString('profilepic', '${decodedData['data'][0]['photo']}');
        await _prefs.setString('pincode', '${decodedData['data'][0]['pincode']}');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
            Home()), (Route<dynamic> route) => false);
      } else {
        Alerts.showAlert(context, 'Registration Failed', '${decodedData['message']}');
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  _flip(bool reverse) {
    if (_animationController.isAnimating) return;
    if (reverse) {
      _animationController.forward();
      setState(() {
        _isBackView = true;
      });
    } else {
      _animationController.reverse();
      setState(() {
        _isBackView = false;
      });
    }
  }

  @override
  void initState() {
    _addCategories();
    super.initState();
    _nameController.text = widget.name ?? '';
    _mobileController.text = widget.mobile ?? '';
    _emailController.text = widget.email ?? '';
    _animationController = AnimationController(vsync: this,
        duration: Duration(milliseconds: 700));
    _curvedAnimation = CurvedAnimation(parent: _animationController,
        curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _userNameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _interestController.dispose();
    _categoryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _altMobileController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: false, elevation: 2,
        title: Text('Complete your profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Form(autovalidateMode: _autoValidateMode, key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15,),
                FlipView(
                  animationController: _curvedAnimation,
                  front: _userSignUpView(),
                  back: _businessSignUpView(),
                ),
                SizedBox(height: 20,),
                _sharedValue == 1 ?
                SizedBox(width: double.infinity,
                  child: _isBackView ?
                  CupertinoButton(color: AppTheme.accentColor,
                      child: Text('Submit', style: TextStyle(color: Colors.white),),
                      onPressed: () {
                       _register();
                    }) :
                  CupertinoButton(color: AppTheme.accentColor,
                    child: Text('Continue', style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      _flip(true);
                    }),
                ) :
                SizedBox(width: double.infinity,
                  child: CupertinoButton(color: AppTheme.accentColor,
                    child: Text('Submit', style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      _register();
                  }),
                ),
                SizedBox(height: 26,),
                Center(
                  child: GestureDetector(
                    child: RichText(text: TextSpan(text: 'Already Registered ?',
                      style: TextStyle(color: Colors.black87, fontSize: 19),
                      children: <TextSpan>[
                        TextSpan(text: ' Login', style: TextStyle(color: Colors.black87,
                            fontSize: 19, fontWeight: FontWeight.w600)),
                      ]),),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(height: 26,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userSignUpView() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
          color: Colors.black87.withOpacity(.08),
          blurRadius: 16, offset: Offset(6, 6),
        )],
      ),
      child: Theme(
        data: ThemeData(primaryColor: Colors.black87,),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Account Type', style: TextStyle(fontSize: 16),),
                CupertinoSlidingSegmentedControl(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  children: _titles,
                  groupValue: _sharedValue,
                  onValueChanged: (int v) {
                    setState(() {
                      _sharedValue = v;
                      _autoValidateMode = AutovalidateMode.disabled;
                      _formKey.currentState.reset();
                    });
                    if (_sharedValue == 0) {
                      _categoryController.clear();
                      _descriptionController.clear();
                      _altMobileController.clear();
                      _addressController.clear();
                      _pincodeController.clear();
                    }
                  },),
              ],
            ),
            TextFormField(
              controller: _userNameController,
              validator: validateRequired,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 8,),
            TextFormField(
              controller: _nameController,
              validator: validateName,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 8,),
            TextFormField(
              controller: _emailController,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                icon: Icon(Icons.alternate_email),
                labelText: 'Email Address',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 8,),
            TextFormField(
              controller: _mobileController,
              validator: validateMobile,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                icon: Icon(Icons.phone),
                labelText: 'Mobile Number',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 8,),
            TextFormField(
              controller: _interestController,
              validator: validateRequired,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                icon: Icon(Icons.category),
                labelText: 'Interests',
                labelStyle: TextStyle(color: Colors.black87),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black87),
              ),
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                Navigator.push(context, MaterialPageRoute(builder: (c) =>
                    InterestSelectionPage())).then((value) {
                  _categoryIds = value['ids'];
                  _interestController.text = value['name'];
                  print('categ ids $_categoryIds and name ${value['name']}');
                });
              },
            ),
            SizedBox(height: 8,),
            TextFormField(
              controller: _stateController,
              validator: validateRequired,
              style: TextStyle(color: Colors.black87),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _cityController.clear();
                _showStateList();
              },
              decoration: InputDecoration(
                icon: Icon(Icons.location_on),
                labelText: 'Select State',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 8,),
            TextFormField(
              controller: _cityController,
              validator: validateRequired,
              style: TextStyle(color: Colors.black87),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (_stateId == null) {
                  Alerts.showAlert(context, 'Alert', 'Please select state first.');
                } else {
                  _showCityList();
                }
              },
              decoration: InputDecoration(
                icon: Icon(Icons.my_location),
                labelText: 'Select City',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  _businessSignUpView() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
          color: Colors.black87.withOpacity(.08),
          blurRadius: 16, offset: Offset(6, 6),
        )],
      ),
      child: Theme(
        data: ThemeData(primaryColor: Colors.black87,),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: Row(
                children: <Widget>[
                  Icon(Icons.arrow_back_ios, size: 20,),
                  Text('Back', style: TextStyle(color: Colors.black87, fontSize: 18,
                      fontWeight: FontWeight.w500),),
                ],
              ),
              onTap: () {
                _flip(false);
              },
            ),
            SizedBox(height: 8,),
            TextFormField(
              controller: _categoryController,
              validator: _sharedValue == 1 ? validateRequired : null,
              style: TextStyle(color: Colors.black87),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _showCategoriesList(context);
              },
              decoration: InputDecoration(
                labelText: 'Select Category',
                labelStyle: TextStyle(color: Colors.black87),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 8,),
            TextFormField(
              controller: _descriptionController,
              validator: _sharedValue == 1 ? validateRequired : null,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Add Description',
                labelStyle: TextStyle(color: Colors.black87),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 8,),
            TextFormField(
              controller: _altMobileController,
              validator: _sharedValue == 1 ? validateAlternateMobile : null,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Alternate Mobile',
                labelStyle: TextStyle(color: Colors.black87),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 8,),
            TextFormField(
              controller: _addressController,
              validator: _sharedValue == 1 ? validateRequired : null,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Add Address',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 8,),
            TextFormField(
              controller: _pincodeController,
              validator: _sharedValue == 1 ? validatePincode : null,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Pincode',
                labelStyle: TextStyle(color: Colors.black87),
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
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }


  _showCategoriesList(BuildContext context) {
    showModalBottomSheet(context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(padding: const EdgeInsets.only(top: 12, left: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Select Categories', style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w600),),
                SizedBox(height: 10,),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _categories.length,
                    itemBuilder: (c, i) {
                      return SizedBox(height: 40,
                        child: ListTile(
                          title: Text('${_categories[i].category}'),
                          onTap: () {
                            setState(() {
                              _categoryId = '${_categories[i].categoryId}';
                              _categoryController.text = '${_categories[i].category}';
                            });
                            Navigator.of(ctx).pop();
                          },
                        ),
                      );
                    }),
                ),
              ],
            ),
          ),
        );
      });
  }


  _showStateList() {
    showModalBottomSheet(context: context,
      builder: (BuildContext ctx) {
        return FutureBuilder<List<States>>(
          future: _getStates(),
          builder: (c, s) {
            if (s.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SafeArea(
                child: Padding(padding: const EdgeInsets.only(top: 12, left: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Select State', style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w600),),
                      SizedBox(height: 10,),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: s.data.length,
                          itemBuilder: (c, i) {
                            return SizedBox(height: 40,
                              child: ListTile(
                                title: Text('${s.data[i].state}'),
                                onTap: () {
                                  setState(() {
                                    _stateId = '${s.data[i].stateId}';
                                    _stateController.text = '${s.data[i].state}';
                                  });
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            );
                          }),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      });
  }

  _showCityList() {
    showModalBottomSheet(context: context,
      builder: (BuildContext ctx) {
        return FutureBuilder<List<City>>(
          future: _getCities(),
          builder: (c, s) {
            if (s.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SafeArea(
                child: Padding(padding: const EdgeInsets.only(top: 12, left: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Select City', style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w600),),
                      SizedBox(height: 10,),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: s.data.length,
                          itemBuilder: (c, i) {
                            return SizedBox(height: 40,
                              child: ListTile(
                                title: Text('${s.data[i].city}'),
                                onTap: () {
                                  setState(() {
                                    _cityId = '${s.data[i].cityId}';
                                    _cityController.text = '${s.data[i].city}';
                                  });
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            );
                          }),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      });
  }


}
