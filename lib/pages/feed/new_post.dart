import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loccon/main.dart';
import 'package:loccon/models/category.dart';
import 'package:loccon/models/feed_type.dart';
import 'package:loccon/pages/login/login_page.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/progress_dialog.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewPost extends StatefulWidget {
  const NewPost({Key key}) : super(key: key);

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {




  String name, email, mobile, userName, profilePic;
  SharedPreferences _prefs;
  List<Asset> images = <Asset>[];
  //List<String> _tagsList = [];
  bool _showImagesGrid = true;
  //int _postLimitCounter = 3;
  TextEditingController _tagController = TextEditingController();
  TextEditingController _youtubeUrlController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  List<Category> _categories = [];
  List<FeedType> _feedTypes = [];
  String _category = 'Select Category';
  String _categoryId = '';
  String _feedType = 'Select Post Type';
  String _feedTypeId = '';

  _userStoredDetails() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      name = _prefs.getString('name') ?? '';
      userName = _prefs.getString('username') ?? '';
      email = _prefs.getString('email') ?? '';
      mobile = _prefs.getString('mobile') ?? '';
      profilePic = _prefs.getString("profilepic") ?? '';
    });
  }

  _addCategoriesAndFeedTypes() {
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

    _feedTypes.add(FeedType(id: '1', feedType: 'Sell'));
    _feedTypes.add(FeedType(id: '2', feedType: 'Buy'));
    _feedTypes.add(FeedType(id: '3', feedType: 'News'));
    _feedTypes.add(FeedType(id: '4', feedType: 'Offers'));
    _feedTypes.add(FeedType(id: '5', feedType: 'Events'));
    _feedTypes.add(FeedType(id: '6', feedType: 'Jobs'));
    _feedTypes.add(FeedType(id: '7', feedType: 'Request'));

  }


  _addFeed() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString('id') == null) {
      Alerts.showAlertLogin(context);
      return;
    }
   else if (_categoryId == '' || _feedTypeId == '') {
      Alerts.showAlert(context, 'Alert', 'Please select category and feed type.');
      return;
    }
   else if (images.isEmpty && _youtubeUrlController.text.isEmpty && _descriptionController.text.isEmpty) {
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
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
            Home()), (Route<dynamic> route) => false);
      } else {
        Alerts.showAlert(context, 'Upload Failed',
            'Failed to submit your feed. Please try again later.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _addCategoriesAndFeedTypes();
    _userStoredDetails();
  }



  @override
  void dispose() {
    super.dispose();
    _tagController.dispose();
    _youtubeUrlController.dispose();
    _category = 'Select Category';
  }




  @override
  Widget build(BuildContext context) {
    return name == "" ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You are not logged in',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 20,
          ),
          // ignore: deprecated_member_use
          OutlineButton(
            child: Text('Login',style: TextStyle(color: AppTheme.accentColor,fontSize: 16),),
            borderSide: BorderSide(
                color: AppTheme.accentColor
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => LoginPage()),
                      (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    )
        : Scaffold(
      appBar: AppBar(
        title: Text("Share Post", style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w600),),
        actions: [
          // ignore: deprecated_member_use
          TextButton(
            child: Text('Post', style: TextStyle(color: AppTheme.accentColor, fontSize: 16),),
            onPressed: () {
              _addFeed();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0,right: 10,top: 20,bottom: 10),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: AppTheme.accentColor)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/avatar.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        image: Connection.profilePicPath + '$profilePic'?? null),
                  ),
                ),
                SizedBox(width: 10,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            _showFeedTypeList(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Text(_feedType, style: TextStyle(color: Colors.black, fontSize: 12),),
                                Icon(Icons.arrow_drop_down,size: 20,)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        GestureDetector(
                          onTap: (){
                            _showCategoryList(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Text(_category, style: TextStyle(color: Colors.black, fontSize: 12),),
                                Icon(Icons.arrow_drop_down,size: 20,)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )

              ],
            ),
            SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey)
              ),
              child: TextField(maxLines: 5, maxLength: 500,
                controller: _descriptionController,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black87,fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Share a photo, video or text',
                  suffix: GestureDetector(
                      onTap: (){
                        setState(() {
                          _descriptionController.clear();
                        });
                      },
                      child: Icon(Icons.clear,color: Colors.red,size: 24,)),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 15,
                      bottom: 20,top: 10, right: 15),
                ),
              ),
            ),
            SizedBox(height: 15,),
            _showImagesGrid ? _imagesGridView() : _youtubeLinkView(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton.extended(onPressed: (){
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
                }, label: Text("Upload Images"),icon: Icon(Icons.photo),backgroundColor: AppTheme.accentColor,),
                FloatingActionButton.extended(onPressed: (){
                  if (images == null || images.isEmpty) {
                    setState(() {
                      _showImagesGrid = false;
                    });
                  } else {
                    setState(() {
                      _showImagesGrid = true;
                    });
                  }
                }, label: Text("Upload Video"),icon: Icon(Icons.video_call),backgroundColor: AppTheme.secondary,),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _youtubeLinkView() {
    return TextField(maxLines: 2,
      controller: _youtubeUrlController,
      style: TextStyle(color: Colors.black87),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: 'Paste your youtube video link here...',
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
      images = <Asset>[];
    });


    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(maxImages: 5,
      );
    } on Exception catch (e) {
      print('pick image exception ${e.toString()}');
    }

    if (!mounted) return;
    setState(() {
      images = resultList;
    });
  }

  int _selectedImage;
  Widget _imagesGridView() {
    if (images != null)
      return images.isNotEmpty ? GridView.count(shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        children: List.generate(images.length, (i) {
          Asset asset = images[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: GestureDetector(
              child: _selectedImage == i ?
              Stack(
                children: <Widget>[
                  AssetThumb(asset: asset,
                      width: 500, height: 500,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.5),
                      border: Border.all(color: Colors.red, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: IconButton(icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          images.removeAt(i);
                          _selectedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              ) :
              AssetThumb(asset: asset,
                  width: 500, height: 500),
              onTap: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              onLongPress: () {
                print('pic pressed');
                setState(() {
                  _selectedImage = i;
                });
              },
            ),
          );
        }),
      ) : SizedBox();
    else
      return SizedBox();
  }
  _showCategoryList(BuildContext context) {
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight:Radius.circular(20) ),
        ),
        builder: (BuildContext ctx) {
          return SafeArea(
            child: Padding(padding: const EdgeInsets.only(top: 12, left: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Select Category', style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w600),),
                  SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _categories.length,
                        itemBuilder: (c, i) {
                          return SizedBox(height: 40,
                            child: ListTile(
                              title: Text('${_categories[i].category}'),
                              onTap: () {
                                setState(() {
                                  _category = '${_categories[i].category}';
                                  _categoryId = _categories[i].categoryId;
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

  _showFeedTypeList(BuildContext context) {
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight:Radius.circular(20) ),


        ),
        builder: (BuildContext ctx) {
          return SafeArea(
            child: Padding(padding: const EdgeInsets.only(top: 12, left: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Select Post Type', style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w600),),
                  SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _feedTypes.length,
                        itemBuilder: (c, i) {
                          return SizedBox(height: 40,
                            child: ListTile(
                              title: Text('${_feedTypes[i].feedType}'),
                              onTap: () {
                                setState(() {
                                  _feedType = '${_feedTypes[i].feedType}';
                                  _feedTypeId = _feedTypes[i].id;
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
}
