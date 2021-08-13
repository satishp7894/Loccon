import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loccon/main.dart';
import 'package:loccon/models/category.dart';
import 'package:loccon/models/feed_type.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:loccon/utils/connection.dart';
import 'package:loccon/utils/alerts.dart';
import 'package:loccon/utils/progress_dialog.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  List<Asset> images = <Asset>[];
  //List<String> _tagsList = [];
  bool _showImagesGrid = true;
  //int _postLimitCounter = 3;
  TextEditingController _tagController = TextEditingController();
  TextEditingController _youtubeUrlController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  List<Category> _categories = [];
  List<FeedType> _feedTypes = [];
  String _category = 'Select';
  String _categoryId = '';
  String _feedType = 'Select';
  String _feedTypeId = '';

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
    if (_categoryId == '' || _feedTypeId == '') {
      Alerts.showAlert(context, 'Alert', 'Please select category and feed type.');
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
  }

  @override
  void dispose() {
    super.dispose();
    _tagController.dispose();
    _youtubeUrlController.dispose();
    _category = 'Select';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(elevation: 1, centerTitle: false,
        title: Text('New Post'),
        actions: [
          // ignore: deprecated_member_use
          FlatButton(
            child: Text('Post', style: TextStyle(color: AppTheme.accentColor, fontSize: 21),),
            onPressed: () {
              _addFeed();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          GestureDetector(
            child: Container(color: Colors.white,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
                      color: Colors.black87),),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    alignment: Alignment.center,
                    child: Text(_category, style: TextStyle(color: Colors.grey, fontSize: 18),),
                  ),
                ],
              ),
            ),
            onTap: () {
              _showCategoryList(context);
            },
          ),
          SizedBox(height: 5,),
          Divider( color: Colors.grey,),
          SizedBox(height: 5,),
          GestureDetector(
            child: Container(color: Colors.white,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Post Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
                      color: Colors.black87),),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    alignment: Alignment.center,
                    child: Text(_feedType, style: TextStyle(color: Colors.grey, fontSize: 18),),
                  ),
                ],
              ),
            ),
            onTap: () {
              _showFeedTypeList(context);
            },
          ),
          SizedBox(height: 5,),
          Divider( color: Colors.grey,),
          SizedBox(height: 15,),
          Row(
            children: <Widget>[
              Flexible(flex: 5,
                child: GestureDetector(
                  child: Container(
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
                  child: Container(width: double.infinity,
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
          SizedBox(height: 15,),
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
          SizedBox(height: 35,),
        ],
      ),
    );
  }

  // Widget _backUpView() {
  //   return SafeArea(
  //     child: ListView(
  //       padding: const EdgeInsets.symmetric(horizontal: 12),
  //       children: <Widget>[
  //         SizedBox(height: 24,),
  //         _postView(),
  //         SizedBox(height: 8,),
  //         Center(
  //           child: Text('$_postLimitCounter of 3 Posts Left', style: TextStyle(
  //             color: AppTheme.accentColor, fontSize: 16,),),
  //         ),
  //         SizedBox(height: 5,),
  //         Divider( color: Colors.black87,),
  //         SizedBox(height: 15,),
  //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: <Widget>[
  //             Text('Category :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
  //                 color: Colors.black87),),
  //             GestureDetector(
  //               child: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(width: 0.8, color: Colors.black87),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 alignment: Alignment.center,
  //                 child: Text(_category),
  //               ),
  //               onTap: () {
  //                 _showCategoryList(context);
  //               },
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 15,),
  //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: <Widget>[
  //             Text('Post Type :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
  //                 color: Colors.black87),),
  //             GestureDetector(
  //               child: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(width: 0.8, color: Colors.black87),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 alignment: Alignment.center,
  //                 child: Text(_feedType),
  //               ),
  //               onTap: () {
  //                 _showFeedTypeList(context);
  //               },
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 25,),
  //         Row(
  //           children: <Widget>[
  //             Flexible(flex: 5,
  //               child: GestureDetector(
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.withOpacity(.2),
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   alignment: Alignment.center,
  //                   child: Row(mainAxisAlignment: MainAxisAlignment.center,
  //                     children: <Widget>[
  //                       Icon(Icons.camera_alt),
  //                       SizedBox(width: 8,),
  //                       Text('Images', style: TextStyle(fontSize: 16,
  //                           fontWeight: FontWeight.w600),),
  //                     ],
  //                   ),
  //                 ),
  //                 onTap: () {
  //                   if (_youtubeUrlController.text.isNotEmpty) {
  //                     setState(() {
  //                       _showImagesGrid = false;
  //                     });
  //                   } else {
  //                     setState(() {
  //                       _showImagesGrid = true;
  //                       _pickImages();
  //                     });
  //                   }
  //                 },
  //               ),
  //             ),
  //             SizedBox(width: 25,),
  //             Flexible(flex: 5,
  //               child: GestureDetector(
  //                 child: Container(width: double.infinity,
  //                   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.withOpacity(.2),
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   alignment: Alignment.center,
  //                   child: Row(mainAxisAlignment: MainAxisAlignment.center,
  //                     children: <Widget>[
  //                       Icon(Icons.videocam),
  //                       SizedBox(width: 8,),
  //                       Text('Video', style: TextStyle(fontSize: 16,
  //                           fontWeight: FontWeight.w600),),
  //                     ],
  //                   ),
  //                 ),
  //                 onTap: () {
  //                   if (images == null || images.isEmpty) {
  //                     setState(() {
  //                       _showImagesGrid = false;
  //                     });
  //                   } else {
  //                     setState(() {
  //                       _showImagesGrid = true;
  //                     });
  //                   }
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 15,),
  //         _showImagesGrid ? _imagesGridView() : _youtubeLinkView(),
  //         SizedBox(height: 15,),
  //         TextField(maxLines: 5, maxLength: 500,
  //           controller: _descriptionController,
  //           style: TextStyle(color: Colors.black87),
  //           decoration: InputDecoration(
  //             hintText: 'Write a Description...',
  //             border: InputBorder.none,
  //             focusedBorder: InputBorder.none,
  //             enabledBorder: InputBorder.none,
  //             errorBorder: InputBorder.none,
  //             disabledBorder: InputBorder.none,
  //             contentPadding: const EdgeInsets.only(left: 15,
  //                 bottom: 11, top: 11, right: 15),
  //           ),
  //         ),
  //         SizedBox(height: 35,),
  //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: <Widget>[
  //             Text('Tags :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
  //                 color: Colors.black87),),
  //             GestureDetector(
  //               child: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(width: 0.8, color: Colors.black87),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 alignment: Alignment.center,
  //                 child: Text('Add Tag',),
  //               ),
  //               onTap: () {
  //                 _showTagsDialog();
  //               },
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 12,),
  //         Wrap(
  //           children: <Widget>[
  //             for (var i in _tagsList) Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
  //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //                 border: Border.all(width: 0.8, color: Colors.black87),
  //               ),
  //               child: Row(mainAxisAlignment: MainAxisAlignment.end,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: <Widget>[
  //                   SizedBox(width: 6,),
  //                   Text('$i', style: TextStyle(fontSize: 18,
  //                       color: Colors.black87),),
  //                   SizedBox(width: 4,),
  //                   GestureDetector(
  //                     child: Container(
  //                         padding: const EdgeInsets.all(3),
  //                         decoration: BoxDecoration(
  //                           color: AppTheme.accentColor,
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: Icon(Icons.close, size: 20,
  //                           color: Colors.white,)),
  //                     onTap: () {
  //                       setState(() {
  //                         _tagsList.remove(i);
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

//   Widget _postView() {
//     return Row(mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         GestureDetector(
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Text('Cancel', style: TextStyle(color: AppTheme.accentColor,
//                 fontSize: 18, fontWeight: FontWeight.w500),),
//           ),
//           onTap: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         Spacer(),
//         GestureDetector(
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 26),
//             decoration: BoxDecoration(
//               color: AppTheme.accentColor,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Text('Post', style: TextStyle(color: Colors.white,
//                 fontSize: 16),),
//           ),
//           onTap: () async {
//             _addFeed();
// //             SharedPreferences _prefs = await SharedPreferences.getInstance();
// //             DateTime now = DateTime.now();
// //             var _today = DateTime(now.year, now.month, now.day);
// //             setState(() {
// //               _postLimitCounter -= 1;
// //             });
// //             _prefs.setInt('postLimit', _postLimitCounter);
//           },
//         ),
//       ],
//     );
//   }

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
      images = <Asset>[];
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
                        width: 300, height: 300),
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
                  width: 300, height: 300),
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

  // _showTagsDialog() {
  //   showDialog(context: context, builder: (c) {
  //     return Dialog(elevation: 0,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       backgroundColor: Colors.white,
  //       child: Container(height: 180,
  //         padding: const EdgeInsets.all(14),
  //         child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: <Widget>[
  //             Text('Enter a Tag', style: TextStyle(color: Colors.black87,
  //               fontWeight: FontWeight.w600, fontSize: 18),),
  //             SizedBox(height: 12,),
  //             Theme(data: ThemeData(primaryColor: Colors.black87),
  //               child: TextField(controller: _tagController,
  //                 style: TextStyle(color: Colors.black87),
  //                 textAlign: TextAlign.center,
  //                 decoration: InputDecoration(hintText: 'Add a Tag',
  //                   hintStyle: TextStyle(color: Colors.black87),
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide: BorderSide(color: Colors.black87),
  //                   ),
  //                   contentPadding: const EdgeInsets.symmetric(vertical: 13,),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16,),
  //             CupertinoButton(color: AppTheme.accentColor,
  //               child: Text('Submit'),
  //               onPressed: () {
  //                 if (_tagController.text.isNotEmpty) {
  //                   setState(() {
  //                     _tagsList.add(_tagController.text);
  //                   });
  //                 }
  //                 _tagController.clear();
  //                 Navigator.of(context).pop();
  //               }),
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  // }

  _showCategoryList(BuildContext context) {
    showModalBottomSheet(context: context,
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


