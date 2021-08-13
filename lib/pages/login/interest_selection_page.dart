import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loccon/models/category.dart';
import 'package:loccon/utils/apptheme.dart';

class InterestSelectionPage extends StatefulWidget {
  @override
  _InterestSelectionPageState createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  List<Category> _categories = [];
  List<String> _selectedCategories = [];
  List<bool> _inputs = [];
  String _categoryNames = '';

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

  @override
  void initState() {
    _addCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, elevation: 2,
        title: Text('Select Interests'),
      ),
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
                  child: Text('Add Categories'),
                  onPressed: () {
                    Map<String, dynamic> _categoryData = Map<String, dynamic>();
                    _categoryData['ids'] = _selectedCategories;
                    _categoryData['name'] = _categoryNames;
                    Navigator.pop(context, _categoryData);
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
        _categoryNames += '${_categories[index].category}, ';
      } else {
        _selectedCategories.remove(_categories[index].categoryId.toString());
      }
      print('selected services $_selectedCategories');
    });
  }


}
