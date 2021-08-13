import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loccon/main.dart';
import 'package:loccon/models/category.dart';
import 'package:loccon/models/feed_type.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/progress_dialog.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

PageController _pageController;
int currentPage = 0;
String _feedTypeId = '';
int selectedFeedTypeIndex;
String _categoryId = '';
int selectedCategoryIndex;

class NewCreatePage extends StatefulWidget {
  @override
  _NewCreatePageState createState() => _NewCreatePageState();
}

class _NewCreatePageState extends State<NewCreatePage> {

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, centerTitle: false,
        title: Text('New Post'),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (i) {
          setState(() {
            currentPage = i;
          });
        },
        children: [
          FirstPage(),
          SecondPage(),
          PostPage(),
        ],
      ),
    );
  }

}

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<FeedType> _feedTypes = [];

  _addFeedTypes() {
    _feedTypes.add(FeedType(id: '1', feedType: 'Sell'));
    _feedTypes.add(FeedType(id: '2', feedType: 'Buy'));
    _feedTypes.add(FeedType(id: '3', feedType: 'News'));
    _feedTypes.add(FeedType(id: '4', feedType: 'Offers'));
    _feedTypes.add(FeedType(id: '5', feedType: 'Events'));
    _feedTypes.add(FeedType(id: '6', feedType: 'Jobs'));
    _feedTypes.add(FeedType(id: '7', feedType: 'Request'));
  }

  @override
  void initState() {
    _addFeedTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text('Select Post Type', style: TextStyle(fontSize: 26,
                fontWeight: FontWeight.w600),),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 2,
              ),
              itemCount: _feedTypes.length,
              itemBuilder: (c, i) {
                return GestureDetector(
                  child: selectedFeedTypeIndex == i ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white,
                      border: Border.all(color: AppTheme.accentColor, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(
                        color: Colors.black87.withOpacity(.08),
                        blurRadius: 16, offset: Offset(6, 6),
                      )],
                    ),
                    child: Text('${_feedTypes[i].feedType}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  ) : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(
                        color: Colors.black87.withOpacity(.08),
                        blurRadius: 16, offset: Offset(6, 6),
                      )],
                    ),
                    child: Text('${_feedTypes[i].feedType}',
                      style: TextStyle(fontSize: 20,),),
                  ),
                  onTap: () {
                    setState(() {
                      selectedFeedTypeIndex = i;
                      _feedTypeId = _feedTypes[i].id;
                    });
                  },
                );
              }),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 60,),
              CupertinoButton(color: AppTheme.accentColor,
                child: Text('Continue'),
                onPressed: () {
                print('feed type $_feedTypeId');
                  if (_feedTypeId == '') {
                    Alerts.showAlert(context, 'Alert', 'Please select post type');
                    return;
                  }
                  _pageController.animateToPage(1,
                      duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
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

  @override
  void initState() {
    _addCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Padding(padding: const EdgeInsets.only(left: 16),
            child: Text('Select Category', style: TextStyle(fontSize: 26,
                fontWeight: FontWeight.w600),),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (c, i) {
                return GestureDetector(
                  child: selectedCategoryIndex == i ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(color: Colors.white,
                      border: Border.all(color: AppTheme.accentColor, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(
                        color: Colors.black87.withOpacity(.08),
                        blurRadius: 16, offset: Offset(6, 6),
                      )],
                    ),
                    child: Text('${_categories[i].category}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  ) : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(
                        color: Colors.black87.withOpacity(.08),
                        blurRadius: 16, offset: Offset(6, 6),
                      )],
                    ),
                    child: Text('${_categories[i].category}',
                      style: TextStyle(fontSize: 20,),),
                  ),
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = i;
                      _categoryId = _categories[i].categoryId;
                    });
                  },
                );
              }),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CupertinoButton(child: Text('Back',
                style: TextStyle(color: AppTheme.accentColor),),
                onPressed: () {
                  _pageController.animateToPage(0,
                      duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                },
              ),
              CupertinoButton(color: AppTheme.accentColor,
                child: Text('Continue'),
                onPressed: () {
                  if (_categoryId == '') {
                    Alerts.showAlert(context, 'Alert', 'Please select category');
                    return;
                  }
                  _pageController.animateToPage(2,
                      duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Asset> images = List<Asset>();
  bool _showImagesGrid = true;
  TextEditingController _youtubeUrlController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  _addFeed() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString('id') == null) {
      Alerts.showAlertLogin(context);
      return;
    }
    if (images.isEmpty && _youtubeUrlController.text.isEmpty && _descriptionController.text.isEmpty) {
      Alerts.showAlert(context, 'Alert', 'Please add either images, youtube link or description.');
      return;
    }

    // ByteData byteData = await images[0].getByteData();
    // List<int> imageData = byteData.buffer.asUint8List();
    ProgressDialog pr = ProgressDialog(context, type: ProgressDialogType.Normal,
        isDismissible: false, showLogs: true);
    pr.style(message: 'Posting Feed...');
    pr.show();
    print('youtube link ${_youtubeUrlController.text}');
    var request = http.MultipartRequest("POST", Uri.parse(Connection.uploadFeed));
    request.fields['secretkey'] = '${Connection.secretKey}';
    request.fields['user_id'] = '${_prefs.getString('id')}';
    request.fields['video_link'] = '${_youtubeUrlController.text}';
    request.fields['description'] = '${_descriptionController.text}';
    request.fields['feed_type_id'] = '$_feedTypeId';
    request.fields['category_id'] = '$_categoryId';

    if (images.isNotEmpty) {
      List<List<int>> _imagesData = [];
      List<ByteData> _bytes = [];
      for (var i=0; i<images.length; i++) {
        _bytes.add(await images[i].getByteData());
        _imagesData.add(_bytes[i].buffer.asUint8List());
        request.files.add(http.MultipartFile.fromBytes('photos[]', _imagesData[i],
            filename: '${DateTime.now().millisecondsSinceEpoch}$i.jpg'));
      }
    } else {
      request.fields['photos[]'] = '';
    }
    request.send().then((value) {
      pr.hide();
      if (value.statusCode == 200) {
        _feedTypeId = '';
        selectedFeedTypeIndex = null;
        _categoryId = '';
        selectedCategoryIndex = null;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
            Home()), (Route<dynamic> route) => false);
      } else {
        Alerts.showAlert(context, 'Upload Failed',
            'Failed to submit your feed. Please try again later.');
      }
    });
  }

  @override
  void dispose() {
    _youtubeUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: 5,),
                Padding(padding: const EdgeInsets.only(left: 16),
                  child: Text('Create Post', style: TextStyle(fontSize: 26,
                      fontWeight: FontWeight.w600),),
                ),
                SizedBox(height: 30,),
                Row(
                  children: <Widget>[
                    Flexible(flex: 5,
                      child: GestureDetector(
                        child: Container(height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.camera_alt),
                              SizedBox(width: 8,),
                              Text('Images', style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w600),),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (_youtubeUrlController.text.isNotEmpty) {
                            setState(() {
                              _showImagesGrid = false;
                            });
                          } else {
                            setState(() {
                              _showImagesGrid = true;
                              _pickImages();
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 25,),
                    Flexible(flex: 5,
                      child: GestureDetector(
                        child: Container(height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.videocam),
                              SizedBox(width: 8,),
                              Text('Video', style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w600),),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (images == null || images.isEmpty) {
                            setState(() {
                              _showImagesGrid = false;
                            });
                          } else {
                            setState(() {
                              _showImagesGrid = true;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18,),
                _showImagesGrid ? _imagesGridView() : _youtubeLinkView(),
                TextField(maxLines: 5, maxLength: 500,
                  controller: _descriptionController,
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Write a Description...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 15,
                        bottom: 11, top: 11, right: 15),
                  ),
                ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CupertinoButton(child: Text('Back',
                style: TextStyle(color: AppTheme.accentColor),),
                onPressed: () {
                  _pageController.animateToPage(1,
                      duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                },
              ),
              CupertinoButton(color: AppTheme.accentColor,
                child: Text('Create Post'),
                onPressed: () {
                  _addFeed();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _youtubeLinkView() {
    return TextField(maxLines: 2,
      controller: _youtubeUrlController,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'Add a youtube link',
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.only(
            left: 15, bottom: 11, top: 11, right: 15),
      ),
    );
  }

  Future<void> _pickImages() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(maxImages: 5,);
    } on Exception catch (e) {
      print('pick image exception ${e.toString()}');
    }

    if (!mounted) return;
    setState(() {
      images = resultList;
    });
  }

  Widget _imagesGridView() {
    if (images != null)
      return images.isNotEmpty ? GridView.count(shrinkWrap: true,
        padding: const EdgeInsets.all(5),
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        children: List.generate(images.length, (i) {
          Asset asset = images[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: GestureDetector(
              child: Stack(clipBehavior: Clip.none, children: <Widget>[
                  AssetThumb(asset: asset,
                      width: 300, height: 300),
                  Positioned(right: -6, top: -6,
                    height: 26, width: 26,
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.close, size: 18,
                          color: Colors.white,),
                      ),
                      onTap: () {
                        setState(() {
                          images.removeAt(i);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ) : SizedBox();
    else
      return SizedBox();
  }


}

