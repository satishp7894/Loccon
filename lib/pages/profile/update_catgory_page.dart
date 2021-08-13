import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loccon/models/category.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'dart:convert';
import 'package:loccon/utils/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Categ {
  String id, name;
  Categ({this.id, this.name});
  Categ.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    name = json['name'];
}

class UpdateCategoryPage extends StatefulWidget {
  @override
  _UpdateCategoryPageState createState() => _UpdateCategoryPageState();
}

class _UpdateCategoryPageState extends State<UpdateCategoryPage> {
  List<Category> _categories = [];
  List<String> _selectedCategories = [];
  List<bool> _inputs = [];

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

    for (int i=0; i<_categories.length; i++) {
      _inputs.add(false);
    }
  }

  Future<List<Categ>> _allInterests;
  Future<List<Categ>> _getInterests() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    print('user id $_userId');
    var response = await http.post(Connection.interests, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '$_userId',
    });
    var decodedData = json.decode(response.body);
    print('update category $decodedData');
    List<Categ> _interests = [];
    if (decodedData['status'] == true) {
      _interests = (decodedData['data'] as List).map<Categ>((json) =>
          Categ.fromJson(json)).toList();
    }
    for (int i=0; i<_categories.length; i++) {
      for (int j=0; j<_interests.length; j++) {
        if (_categories[i].categoryId == _interests[j].id) {
          _inputs.insert(i, true);
          _selectedCategories.add(_categories[i].categoryId.toString());
        }
      }
    }
    print('selected categories $_selectedCategories');
    return _interests;
  }

  _updateCategories() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _userId = _prefs.getString('id') ?? '0';
    var response = await http.post(Connection.updateInterests, body: {
      'secretkey': '${Connection.secretKey}',
      'user_id': '$_userId',
      'interest': '${json.encode(_selectedCategories)}',
    });
    var results = json.decode(response.body);
    if (results['status'] == true) {
      Alerts.showAlertAndBack(context, 'Interests updated',
        'Your feed interests are updated successfully.');
    } else {
      Alerts.showAlert(context, 'Update failed', 'Failed to update user interests.');
    }
  }

  @override
  void initState() {
    _addCategories();
    _allInterests = _getInterests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, elevation: 2,
        title: Text('Update Interests'),),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Categ>>(
                future: _allInterests,
                builder: (c, s) {
                  if (s.connectionState != ConnectionState.done) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (s.hasError) {
                    print('error is ${s.error}');
                    return Center(child: Text('No Interests Found.', style: TextStyle(
                      color: AppTheme.accentColor, fontSize: 20,
                      fontWeight: FontWeight.w600),));
                  }
                  return ListView.separated(
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
                  );
                }),
            ),
            SizedBox(height: 14,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(width: double.infinity,
                child: CupertinoButton(color: AppTheme.accentColor,
                    child: Text('Update Categories'),
                    onPressed: () {
                      _updateCategories();
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
    setState(() {
      _inputs[index] = val;
      if (val == true) {
        _selectedCategories.add(_categories[index].categoryId.toString());
      } else {
        _selectedCategories.remove(_categories[index].categoryId.toString());
      }
      print('selected services $_selectedCategories');
    });
  }

}

