import 'package:flutter/material.dart';
import 'package:loccon/utils/apptheme.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<String> _images = ['b1.png', 'b2.jpg', 'b3.png', 'b1.png', 'b2.jpg', 'b3.png'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1,
        centerTitle: true,
        title: Text('OFFERS', style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w600),),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 12,),
          Padding(padding: const EdgeInsets.only(left: 10),
            child: Text('Most Recommended', style: TextStyle(color: Colors.black87,
              fontSize: 24, fontWeight: FontWeight.w600),),
          ),
          Container(height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: _images.length,
              itemBuilder: (c, i) {
                return _moreListItem(i);
              },
            ),
          ),
          SizedBox(height: 18,),
          Padding(padding: const EdgeInsets.only(left: 10),
            child: Text('Most Recommended', style: TextStyle(color: Colors.black87,
                fontSize: 24, fontWeight: FontWeight.w600),),
          ),
          SizedBox(height: 12,),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _images.length,
            itemBuilder: (c, i) {
              return Container(height: 90,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: <Widget>[
                    Container(width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(fit: BoxFit.cover,
                          image: AssetImage('assets/${_images[i]}'),
                        ),
                      ),
                    ),
                    SizedBox(width: 14,),
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('The Salad Revolution - Free Event', style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w600,
                            fontSize: 18),),
                          SizedBox(height: 8,),
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
                              Text('12/06/20', style: TextStyle(color: Colors.grey,
                                  fontWeight: FontWeight.w600),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _moreListItem(int i) {
    return Container(width: 330,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(alignment: Alignment.bottomLeft,
        children: <Widget>[
          Align(alignment: Alignment.topCenter,
            child: Container(height: 200,
              margin: const EdgeInsets.only(top: 10, left: 10,
                  right: 10, bottom: 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(fit: BoxFit.cover,
                  image: AssetImage('assets/${_images[i]}',),
                ),
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter,
            child: Container(height: 165,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(left: 10, right: 30),
              decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(
                  color: Colors.black87.withOpacity(.08),
                  blurRadius: 16, offset: Offset(6, 6),
                )],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                      Text('12/06/20', style: TextStyle(color: Colors.grey,
                          fontWeight: FontWeight.w600),),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('The Salad Revolution - Free Event', style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600,
                    fontSize: 18),),
                  SizedBox(height: 4,),
                  Text('This is a rather very long descriptive information about the service or product',
                    style: TextStyle(color: Colors.grey,
                      fontSize: 15), textAlign: TextAlign.justify,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
