import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loccon/models/category.dart';
import 'package:loccon/models/city.dart';
import 'package:loccon/models/state.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with Validator {
  SharedPreferences _prefs;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _altMobileController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _categoryId, _stateId, _cityId;
  List<Category> _categories = [];

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

  _getCategoryStateCity() async {
    _prefs = await SharedPreferences.getInstance();
    for (var ctg in _categories) {
      if (ctg.categoryId == _prefs.getString('category')) {
        _categoryId = ctg.categoryId;
        _categoryController.text = ctg.category;
      }
    }
    List<States> _states = await _getStates();
    print('state id ${_prefs.getString('state_id')}');
    for(var s in _states) {
      if (s.stateId == _prefs.getString('state_id')) {
         _stateId = s.stateId;
         _stateController.text = s.state;
      }
    }
    List<City> _cities = await _getCities();
    for(var c in _cities) {
      if (c.cityId == _prefs.getString('city_id')) {
        _cityId = c.cityId;
        _cityController.text = c.city;
      }
    }
  }

  int _sharedValue = 0;
  final Map<int, Widget> _titles = <int, Widget>{
    0: Text('General',style: TextStyle(color: Colors.white),),
    1: Text('Business',style: TextStyle(color: Colors.white),),
  };

  _addUserData() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString('type') == 'Business') {
        setState(() {
          _sharedValue = 1;
        });
    }
    _nameController.text = _prefs.getString('name') ?? '';
    _userNameController.text = _prefs.getString('username') ?? '';
    _emailController.text = _prefs.getString('email') ?? '';
    _mobileController.text = _prefs.getString('mobile') ?? '';
    _pinCodeController.text = _prefs.getString('pincode') ?? '';
    _descriptionController.text = _prefs.getString('description') ?? '';
    _addressController.text = _prefs.getString('address') ?? '';
    _stateId = _prefs.getString('state_id') ?? '';
    _cityId = _prefs.getString('city_id') ?? '';
    _categoryId = _prefs.getString('category') ?? '';
  }

  _updateProfile() async {
    var response = await http.post(Connection.updateProfile, body: {
      'user_id': '${_prefs.getString('id')}',
      'user_type': _sharedValue == 0 ? 'Normal' : 'Business',
      'userName': '${_userNameController.text}',
      'user_name': '${_nameController.text}',
      'email': '${_emailController.text}',
      'mobile': '${_mobileController.text}',
      'category_id': _sharedValue == 0 ? '' : '$_categoryId',
      'description': '${_descriptionController.text}',
      'alt_mobile': '${_altMobileController.text}',
      'address': '${_addressController.text}',
      'pincode': '${_pinCodeController.text}',
      'state_id': '$_stateId',
      'city_id': '$_cityId',
      'photo': '',
      'secretkey': '${Connection.secretKey}',
    });
    var decodedData = json.decode(response.body);
    print('profile update $decodedData');
    if (decodedData['status'] == true) {
        await _prefs.setString('type', '${_sharedValue == 0 ? 'Normal' : 'Business'}');
        await _prefs.setString('name', '${_nameController.text}');
        await _prefs.setString('username', '${_userNameController.text}');
        await _prefs.setString('email', '${_emailController.text}');
        await _prefs.setString('mobile', '${_mobileController.text}');
        await _prefs.setString('pincode', '${_pinCodeController.text}');
        await _prefs.setString('category', '$_categoryId');
        await _prefs.setString('description', '${_descriptionController.text}');
        await _prefs.setString('altmobile', '${_altMobileController.text}');
        await _prefs.setString('address', '${_addressController.text}');
        await _prefs.setString('state_id', '$_stateId');
        await _prefs.setString('city_id', '$_cityId');
        Alerts.showAlertAndBack(context, 'Profile Updated', 'User profile updated successfully.');
    } else {
      Alerts.showAlert(context, 'Update Failed',
          'Failed to update user profile, Please try again later.');
    }
  }

  @override
  void initState() {
    _addCategories();
    _addUserData();
    _getCategoryStateCity();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _altMobileController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1,
        title:Text('Edit Profile', style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w600),),
      actions: [
        TextButton(onPressed: (){ _updateProfile();}, child: Text("Submit",style: TextStyle(color: AppTheme.accentColor,fontSize: 18,fontWeight: FontWeight.bold),)),
        SizedBox(width: 10,),
      ],
      ),
      body: editProfileView(),
    );
  }




  Widget editProfileView(){
    return Padding(
      padding: const EdgeInsets.only(left: 10.0,right: 10),
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidateMode,
        child: ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0,bottom: 10.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Text('Account Type', style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                  Flexible(
                    flex: 3,
                    child: CupertinoSlidingSegmentedControl(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      children: _titles,
                      groupValue: _sharedValue,
                      backgroundColor:AppTheme.secondary,
                      thumbColor: AppTheme.accentColor,
                      onValueChanged: (int v) {
                        setState(() {
                          _sharedValue = v;
                          _autoValidateMode = AutovalidateMode.disabled;
                        });
                        if (_sharedValue == 0) {
                          _categoryController.clear();
                          _descriptionController.clear();
                          _altMobileController.clear();
                          _addressController.clear();
                        }
                      },),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Flexible(
                child: TextFormField(
                controller: _userNameController,
                validator: validateRequired,
                style: TextStyle(color: Colors.black87),
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    hintText: 'Enter Username', hintStyle: TextStyle(fontSize: 18),
                    labelText: 'Username', labelStyle: TextStyle(fontSize: 18,color: AppTheme.accentColor),
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                ),
              ),),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _nameController,
                validator: validateName,
                keyboardType: TextInputType.name,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    hintText: 'Enter Name', hintStyle: TextStyle(fontSize: 18),
                    labelText: 'Name', labelStyle: TextStyle(fontSize: 18,color: AppTheme.accentColor),
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextFormField(
                controller: _emailController,
                validator: validateEmail,
                style: TextStyle(color: Colors.black87),
                keyboardType: TextInputType.emailAddress,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    hintText: 'Enter Email', hintStyle: TextStyle(fontSize: 18),
                    labelText: 'Email', labelStyle: TextStyle(fontSize: 18,color: AppTheme.accentColor),
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextFormField(
                controller: _mobileController,
                validator: validateMobile,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black87),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: InputDecoration(
                    hintText: 'Enter Mobile Number', hintStyle: TextStyle(fontSize: 18),
                    labelText: 'Mobile', labelStyle: TextStyle(fontSize: 18,color: AppTheme.accentColor),
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text("Select State: ",style: TextStyle(color: AppTheme.accentColor ),)),
                  Flexible(
                    flex: 3,
                    child:  TextFormField(
                      controller: _stateController,
                      showCursor: false,
                      validator: validateRequired,
                      enableInteractiveSelection: false,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _cityController.clear();
                        _showStateList();
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(), focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppTheme.accentColor
                          ),
                      )
                      ),
                    ),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text("Select City: ",style: TextStyle(color: AppTheme.accentColor ),)),
                  Flexible(
                    flex: 3,
                    child: TextFormField(
                      showCursor: false,
                      controller: _cityController,
                      validator: validateRequired,
                      enableInteractiveSelection: false,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if (_stateId == null) {
                          Alerts.showAlert(context, 'Alert', 'Please select state first.');
                        } else {
                          _showCityList();
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintText: 'City', hintStyle: TextStyle(fontSize: 16),
                          border: UnderlineInputBorder(), focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        ),
                      )
                      ),
                    ),)

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Flexible(
                child: TextFormField(
                  controller: _pinCodeController,
                  validator: validateRequired,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.black87),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                      hintText: 'Enter Pin Code', hintStyle: TextStyle(fontSize: 18),
                      labelText: 'Pin Code', labelStyle: TextStyle(fontSize: 18,color: AppTheme.accentColor),
                      border: UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppTheme.accentColor
                          )
                      )
                  ),
                ),),
            ),
            if (_sharedValue == 1)
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      showCursor: false,
                      enableInteractiveSelection: false,
                      controller: _categoryController,
                      validator: _sharedValue == 1 ? validateRequired : null,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _showCategoriesList(context);
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintText: 'Enter Category', hintStyle: TextStyle(fontSize: 16),
                          border: UnderlineInputBorder(), focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppTheme.accentColor
                          )
                      )
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.black,
                      controller: _altMobileController,
                      validator: _sharedValue == 1 ? validateAlternateMobile : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintText: 'Enter Alternate Mobile Number', hintStyle: TextStyle(fontSize: 16),
                          border: UnderlineInputBorder(), focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppTheme.accentColor
                          )
                      )
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _descriptionController,
                      validator: _sharedValue == 1 ? validateRequired : null,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintText: 'Enter Description', hintStyle: TextStyle(fontSize: 16),
                          border: UnderlineInputBorder(), focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppTheme.accentColor
                          )
                      )
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
                ],
              ),




          ],
        ),
      ),
    );

  }


  Widget oldEditProfileView(){
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: <Widget>[
        SizedBox(height: 30,),
        Form(autovalidateMode: _autoValidateMode, key: _formKey,
          child: Theme(data: ThemeData(primaryColor: AppTheme.accentColor),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                          });
                          if (_sharedValue == 0) {
                            _categoryController.clear();
                            _descriptionController.clear();
                            _altMobileController.clear();
                            _addressController.clear();
                          }
                        },),
                    ],
                  ),
                  SizedBox(height: 18,),
                  Text('Enter Name', style: TextStyle(fontSize: 18,
                      color: Colors.black54),),
                  SizedBox(height: 6,),
                  TextFormField(
                    controller: _nameController,
                    validator: validateName,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Enter Name', hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(

                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppTheme.accentColor
                            )
                        )
                    ),
                  ),
                  SizedBox(height: 18,),
                  Text('Enter Username', style: TextStyle(fontSize: 18,
                      color: Colors.black54),),
                  SizedBox(height: 6,),
                  TextFormField(
                    controller: _userNameController,
                    validator: validateRequired,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Enter Username', hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                    ),
                  ),
                  SizedBox(height: 18,),
                  Text('Enter Email', style: TextStyle(fontSize: 18,
                      color: Colors.black54),),
                  SizedBox(height: 6,),
                  TextFormField(
                    controller: _emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Enter Email', hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                    ),
                  ),
                  SizedBox(height: 18,),
                  Text('Enter Mobile', style: TextStyle(fontSize: 18,
                      color: Colors.black54),),
                  SizedBox(height: 6,),
                  TextFormField(
                    controller: _mobileController,
                    validator: validateMobile,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Enter Mobile', hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                    ),
                  ),
                  SizedBox(height: 24,),
                  Text('Enter State', style: TextStyle(fontSize: 18,
                      color: Colors.black54),),
                  SizedBox(height: 6,),
                  TextFormField(
                    controller: _stateController,
                    showCursor: false,
                    validator: validateRequired,
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      _cityController.clear();
                      _showStateList();
                    },
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Enter State', hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                    ),
                  ),
                  SizedBox(height: 24,),
                  Text('Enter City', style: TextStyle(fontSize: 18,
                      color: Colors.black54),),
                  SizedBox(height: 6,),
                  TextFormField(
                    controller: _cityController,
                    validator: validateRequired,
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if (_stateId == null) {
                        Alerts.showAlert(context, 'Alert', 'Please select state first.');
                      } else {
                        _showCityList();
                      }
                    },
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Enter City', hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                    ),
                  ),
                  SizedBox(height: 24,),
                  Text('Enter Pincode', style: TextStyle(fontSize: 18,
                      color: Colors.black54),),
                  SizedBox(height: 6,),
                  TextFormField(
                    controller: _pinCodeController,
                    validator: validateRequired,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.black87),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Enter Pin code', hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.accentColor
                        )
                    )
                    ),
                  ),
                  SizedBox(height: 24,),

                  if (_sharedValue == 1)
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter Category', style: TextStyle(fontSize: 18,
                            color: Colors.black54),),
                        SizedBox(height: 6,),
                        TextFormField(
                          controller: _categoryController,
                          validator: _sharedValue == 1 ? validateRequired : null,
                          onTap: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            _showCategoriesList(context);
                          },
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              hintText: 'Enter Category', hintStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppTheme.accentColor
                              )
                          )
                          ),
                        ),
                        SizedBox(height: 24,),
                        Text('Enter Alternate mobile', style: TextStyle(fontSize: 18,
                            color: Colors.black54),),
                        SizedBox(height: 6,),
                        TextFormField(
                          controller: _altMobileController,
                          validator: _sharedValue == 1 ? validateAlternateMobile : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              hintText: 'Enter Alternate Mobile', hintStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppTheme.accentColor
                              )
                          )
                          ),
                        ),
                        SizedBox(height: 24,),
                        Text('Enter Description', style: TextStyle(fontSize: 18,
                            color: Colors.black54),),
                        SizedBox(height: 6,),
                        TextFormField(
                          controller: _descriptionController,
                          validator: _sharedValue == 1 ? validateRequired : null,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              hintText: 'Enter Description', hintStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppTheme.accentColor
                              )
                          )
                          ),
                        ),
                        SizedBox(height: 24,),
                      ],
                    ),

                  SizedBox(width: double.infinity,
                    child: CupertinoButton(color: AppTheme.accentColor,
                        child: Text('Submit'),
                        onPressed: () {
                          _updateProfile();
                        }),
                  ),
                  SizedBox(height: 8,),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 30,),
      ],
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
                return Center(child: Image.asset("assets/loading.gif",height: 60,));
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
                return Center(child: Image.asset("assets/loading.gif",height: 60,));
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
