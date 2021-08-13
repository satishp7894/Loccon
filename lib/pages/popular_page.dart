import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loccon/pages/details_page.dart';
import 'package:loccon/utils/apptheme.dart';

class PopularPage extends StatefulWidget {
  @override
  _PopularPageState createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  List<String> _images = ['b1.png', 'b2.jpg', 'b3.png', 'b1.png', 'b2.jpg', 'b3.png'];
  List<String> _imagesList = ['b1.png', 'b2.jpg', 'b3.png'];
  List<String> _time = ['Anytime', 'Today', 'Tomorrow', 'This Week', 'This Month'];
  int _selectedTime = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1,
        centerTitle: true,
        title: Text('POPULAR', style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w600),),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 16,),
          Container(height: 50,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 10, top: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _time.length,
              itemBuilder: (c, i) {
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _selectedTime == i ?
                      Column(mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('${_time[i]}', style: TextStyle(fontSize: 18,
                            color: Colors.black87, fontWeight: FontWeight.w700),),
                          SizedBox(height: 4,),
                          Container(height: 5, width: 5,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ) : Text('${_time[i]}', style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w600, color: Colors.grey),),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedTime = i;
                    });
                  },
                );
              }),
          ),
          _eventsListView(),
          SizedBox(height: 12,),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Trending', style: TextStyle(color: Colors.black87,
                    fontSize: 24, fontWeight: FontWeight.w600),),
                SizedBox(height: 4,),
                Text('Suggested Events', style: TextStyle(color: Colors.grey,
                  fontSize: 18,),),
              ],
            ),
          ),
          _homeList(),
        ],
      ),
    );
  }

  Widget _eventsListView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 8,),
        Padding(padding: const EdgeInsets.only(left: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Popular', style: TextStyle(color: Colors.black87,
                fontSize: 24, fontWeight: FontWeight.w600),),
              SizedBox(height: 4,),
              Text('Nearby Events', style: TextStyle(color: Colors.grey,
                fontSize: 18,),),
            ],
          ),
        ),
        Container(height: 360,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _imagesList.length,
            itemBuilder: (c, i) {
              return _eventsListItem(i);
            }),
        ),
      ],
    );
  }


  Widget _eventsListItem(int i) {
    return GestureDetector(
      child: Container(width: 300,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(
            color: Colors.black87.withOpacity(.08),
            blurRadius: 16, offset: Offset(6, 6),
          )],
        ),
        child: Column(
          children: <Widget>[
            Hero(tag: _imagesList[i],
              child: Container(height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  image: DecorationImage(fit: BoxFit.cover,
                    image: AssetImage('assets/${_imagesList[i]}'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('SAT, JUN 27 - JUN 28', style: TextStyle(
                      color: AppTheme.accentColor, fontSize: 15),),
                  SizedBox(height: 4,),
                  Text('The Salad Revolution - Free Event', style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600,
                    fontSize: 18),),
                  SizedBox(height: 4,),
                  Text('Vapi, Gujarat', style: TextStyle(
                    color: Colors.grey, fontSize: 16.5),),
                  SizedBox(height: 16,),
                  Row(
                    children: <Widget>[
                      Flexible(flex: 8,
                        child: Container(height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.star, size: 20,),
                              SizedBox(width: 4,),
                              Text('Interested', style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w500),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Flexible(flex: 2,
                        child: Container(height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Transform(
                            alignment: Alignment.center,
                            transform:Matrix4.rotationY(pi),
                            child: Icon(Icons.reply)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) =>
          DetailsPage(image: _images[i],)));
      },
    );
  }

  Widget _homeList() {
    return ListView.builder(shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: _images.length,
      itemBuilder: (c, i) {
        return _homeListItem(i);
      });
  }

  Widget _homeListItem(int i) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
          color: Colors.black87.withOpacity(.08),
          blurRadius: 16, offset: Offset(6, 6),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(fit: BoxFit.cover,
                image: AssetImage('assets/${_images[i]}',),
              ),
            ),
          ),
          SizedBox(height: 14,),
          Row(mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.8, color: Colors.grey),
                ),
                child: Text('10', style: TextStyle(fontWeight: FontWeight.w600),),
              ),
              SizedBox(width: 10,),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Monday', style: TextStyle(fontWeight: FontWeight.w700),),
                  SizedBox(height: 3,),
                  Text('December, 2019', style: TextStyle(color: Colors.grey),),
                ],
              ),
              Spacer(),
              Icon(Icons.more_vert,
                color: Colors.grey,),
            ],
          ),
          SizedBox(height: 16,),
          Text('Fashion Meetup', style: TextStyle(fontSize: 16.5,
            fontWeight: FontWeight.w600),),
          SizedBox(height: 4,),
          Text('Starts at 9:00am in Mumbai',
            style: TextStyle(color: Colors.grey),),
          SizedBox(height: 14,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Interested', style: TextStyle(color: Colors.white),),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Share', style: TextStyle(fontSize: 17,
                      fontWeight: FontWeight.w600),),
                  SizedBox(width: 3,),
                  Transform(
                    alignment: Alignment.center,
                    transform:Matrix4.rotationY(pi),
                    child: Icon(Icons.reply)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


}
