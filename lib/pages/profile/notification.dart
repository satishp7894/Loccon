import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loccon/models/category.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Category> _categories = [];
  List<String> _selectedCategories = [];
  List<bool> _inputs = [false, false, false];

  _addCategories() {
    _categories.add(Category(categoryId: '1', category: 'Post Notification'));
    _categories.add(Category(categoryId: '2', category: 'Comment Notification'));
    _categories.add(Category(categoryId: '3', category: 'Message Notification'));
    // for (int i=0; i<_categories.length; i++) {
    //   _inputs.add(false);
    //   //print("categories value ${_categories[i].categoryId}");
    // }

    _getInterests();
  }

  Future<List<Category1>> _getInterests() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    print('user id $_userId');
    var response = await http.post(Connection.interestNotifications, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '$_userId',
    });
    var decodedData = json.decode(response.body);
    print('update category ${decodedData['notify']}');
    List<Category1> _interests = [];
    if (decodedData['status'] == true) {
      _interests = (decodedData['notify'] as List).map<Category1>((json) =>
          Category1.fromJson(json)).toList();
    }
    // for (int i=0; i<_categories.length; i++) {
    //   for (int j=0; j<_interests.length; j++) {
    //     if (_categories[i].categoryId == _interests[j].categoryId) {
    //       setState(() {
    //         _inputs.insert(i, true);
    //       });
    //       // print("categories interest value ${_interests[j].id} ${_inputs[j]}");
    //       // _selectedCategories.add(_categories[i].categoryId.toString());
    //     }
    //   }
    // }
    //print('selected categories $_selectedCategories');

    for(int i = 0; i<_interests.length; i++){
      print("interest ${_interests[i].categoryId}");
      if(_interests[i].categoryId == "1"){
        setState(() {
          _inputs[0]=true;
          _selectedCategories.add(_categories[0].categoryId.toString());
        });
      }
      if(_interests[i].categoryId == "2"){
        setState(() {
          _inputs[1]=true;
          _selectedCategories.add(_categories[1].categoryId.toString());
        });
      }
      if(_interests[i].categoryId == "3"){
        setState(() {
          _inputs[2]=true;
          _selectedCategories.add(_categories[2].categoryId.toString());
        });
      }
      print("inputs ${_inputs[0]} ${_inputs[1]} ${_inputs[2]} $i");
    }
    return _interests;
  }

  _updateInterestNotifications() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    var response = await http.post(Connection.updateInterestNotifications, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '$_userId',
      'notify_New_interest': '${json.encode(_selectedCategories)}'.replaceAll("\"", "").replaceAll("[", "").replaceAll("]", ""),
    });
    var results = json.decode(response.body);
    if (results['status'] == true) {
      Alerts.showAlertAndBack(context, 'Notification interests updated',
          'Your notification interests are updated successfully.');
    } else {
      Alerts.showAlert(context, 'Update failed', 'Failed to update notification interests.');
    }
  }

  @override
  void initState() {
    _addCategories();
    super.initState();
  }
    @override
  Widget build(BuildContext context) {

    print("inputs value ${_inputs[0]} ${_inputs[1]} ${_inputs[2]}");
    return Scaffold(
      appBar: AppBar(centerTitle: true, elevation: 2,
        title: Text('Notifications'),),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      itemBuilder: (c, i) {
                        return CheckboxListTile(
                            title: Text('${_categories[i].category}'),
                            value: _inputs[i],
                            onChanged: (bool val) {
                              _itemChanged(val, i);
                            }
                        );
                      },
                      separatorBuilder: (c, i) {
                        return Divider(color: Colors.grey,);
                      },
                  ),
            ),
            SizedBox(height: 14,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(width: double.infinity,
                child: CupertinoButton(color: AppTheme.accentColor,
                    child: Text('Update Notifications'),
                    onPressed: () {
                  print("value from json categories ${json.encode(_selectedCategories).replaceAll("\"", "").replaceAll("[", "").replaceAll("]", "")}");
                      _updateInterestNotifications();
                    }),
              ),
            ),
            SizedBox(height: 14,),
          ],
        ),
      ),
    );
  }

  _itemChanged(bool val, int index) {
    print("values on changed ${_categories[index].categoryId} $val");
    setState(() {
      _inputs[index] = val;
      // if (val == true) {
      //   _selectedCategories.add(_categories[index].categoryId.toString());
      // }
      if(val == false){
        _selectedCategories.remove(_categories[index].categoryId.toString());
      } else {
        _selectedCategories.add(_categories[index].categoryId.toString());

      }
      print('selected services ${_selectedCategories[int.parse(_categories[index].categoryId)]}');
    });
  }
}
