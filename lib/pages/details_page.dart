import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loccon/utils/apptheme.dart';


class DetailsPage extends StatefulWidget {
  final String image;
  DetailsPage({this.image});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<String> _images = ['b1.png', 'b2.jpg', 'b3.png', 'b1.png', 'b2.jpg', 'b3.png'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(centerTitle: true,
            expandedHeight: 220, elevation: 1,
            floating: true, pinned: true, snap: true,
            stretch: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [
                StretchMode.zoomBackground,
              ],
              background: Hero(tag: widget.image,
                child: Image.asset(
                  'assets/${widget.image}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate([
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 12,),
                  Text('SAT, JUN 27 - JUN 28', style: TextStyle(
                      color: AppTheme.accentColor, fontSize: 15),),
                  SizedBox(height: 4,),
                  Text('The Salad Revolution - Free Event', style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600,
                      fontSize: 18),),
                  SizedBox(height: 4,),
                  Text('Online Event', style: TextStyle(
                      color: Colors.grey, fontSize: 16.5),),
                  SizedBox(height: 15,),
                  Row(
                    children: <Widget>[
                      Flexible(flex: 6,
                        child: Container(height: 40,
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
                        child: Container(height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.star_border),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Flexible(flex: 2,
                        child: Container(height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.more_horiz),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    children: <Widget>[
                      Icon(Icons.person,
                        color: Colors.grey,),
                      SizedBox(width: 8,),
                      Text('15 Interested',
                        style: TextStyle(fontSize: 16),),
                    ],
                  ),
                  SizedBox(height: 12,),
                  Row(
                    children: <Widget>[
                      Icon(Icons.filter_tilt_shift,
                        color: Colors.grey,),
                      SizedBox(width: 8,),
                      Text('Public, Hosted by Vapi, Gujarat',
                        style: TextStyle(fontSize: 16),),
                    ],
                  ),
                  SizedBox(height: 12,),
                  Row(
                    children: <Widget>[
                      Icon(Icons.location_on,
                        color: Colors.grey,),
                      SizedBox(width: 8,),
                      Text('Online Event',
                        style: TextStyle(fontSize: 16),),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Text('Description', style: TextStyle(fontWeight: FontWeight.w600,
                      color: Colors.black87, fontSize: 18),),
                  SizedBox(height: 10,),
                  Text('This is a rather very long descriptive information about the product or '
                    'service shown as above. This is more description about the product or service'
                    ' and here is some more description'
                   '\n\n This is a rather very long descriptive information about the product or '
                    'service shown as above. This is more description about the product or service'
                    ' and here is some more description',
                    style: TextStyle(color: Colors.grey, fontSize: 15.6),
                    maxLines: null, textAlign: TextAlign.justify,),
                  SizedBox(height: 25,),
                  _eventsListView(),
                  SizedBox(height: 40,),
                ],
              ),
            ),
          ])),
        ],
      ),
    );
  }

  Widget _eventsListView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 8,),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Similar', style: TextStyle(color: Colors.black87,
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
              itemCount: _images.length,
              itemBuilder: (c, i) {
                return _eventsListItem(i);
              }),
        ),
      ],
    );
  }

  Widget _eventsListItem(int i) {
    return Container(width: 300,
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
          Container(height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              image: DecorationImage(fit: BoxFit.cover,
                image: AssetImage('assets/${_images[i]}'),
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
                                fontWeight: FontWeight.w500),)
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
    );
  }

}
