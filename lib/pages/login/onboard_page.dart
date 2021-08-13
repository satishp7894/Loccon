import 'package:flutter/material.dart';
import 'package:loccon/main.dart';
import 'package:loccon/utils/apptheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageController _pageController;
  int currentPageValue = 0;
  final List<Widget> _introScreens = <Widget>[
    Container(
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover,
          image: AssetImage('assets/intro1.jpg'),
        ),
      ),
    ),
    Container(
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover,
          image: AssetImage('assets/intro2.jpg'),
        ),
      ),
    ),
    Container(
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover,
          image: AssetImage('assets/intro3.jpg'),
        ),
      ),
    ),
  ];

  getChangedPageAndMoveBar(int page) {
    setState(() {
      currentPageValue = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: _introScreens.length,
            controller: _pageController,
            onPageChanged: (int page) {
              getChangedPageAndMoveBar(page);
            },
            itemBuilder: (c, i) {
              return _introScreens[i];
            }
          ),
        ],
      ),
      bottomSheet: currentPageValue == _introScreens.length - 1 ?
      GestureDetector(
        child: Container(height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
              color:AppTheme.accentColor,
          ),
          alignment: Alignment.center,
          child: Text('Get Started', style: TextStyle(fontSize: 20,
              color: Colors.white),),
        ),
        onTap: () async {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          await _prefs.setBool('onboard', true);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
              Home()), (Route<dynamic> route) => false);
        },
      ) : SizedBox(),
    );
  }
}


class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  PageController _pageController;
  int currentPageValue = 0;
  final List<Widget> _introScreens = <Widget>[
    OnBoardItem(image: 'assets/b1.png',
        backgroundImage: 'assets/splashbg.jpg', title: 'Screen One',
        desc: 'Some Description regarding what is happening on the screen.'),
    OnBoardItem(image: 'assets/b2.jpg',
        backgroundImage: 'assets/splashbg.jpg', title: 'Screen Two',
        desc: 'Some Description regarding what is happening on the screen.'),
    OnBoardItem(image: 'assets/b3.png',
        backgroundImage: 'assets/splashbg.jpg', title: 'Screen Three',
        desc: 'Some Description regarding what is happening on the screen.'),
    OnBoardItem(image: 'assets/b1.png',
        backgroundImage: 'assets/splashbg.jpg', title: 'Screen Four',
        desc: 'Some Description regarding what is happening on the screen.'),
  ];

  getChangedPageAndMoveBar(int page) {
    setState(() {
      currentPageValue = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: _introScreens.length,
            onPageChanged: (int page) {
              getChangedPageAndMoveBar(page);
            },
            controller: _pageController,
            itemBuilder: (c, i) {
              return _introScreens[i];
            }
          ),
          SafeArea(
            child: Stack(alignment: AlignmentDirectional.topStart,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 60),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i=0; i<_introScreens.length; i++)
                        if (i == currentPageValue) ...[circleBar(true)] else
                          circleBar(false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: currentPageValue == _introScreens.length - 1 ?
      GestureDetector(
        child: Container(height: 60,
          width: double.infinity, color: Colors.black87,
          alignment: Alignment.center,
          child: Text('Get Started', style: TextStyle(fontSize: 20,
            color: Colors.white),),
        ),
        onTap: () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
              Home()), (Route<dynamic> route) => false);
        },
      ) : SizedBox(),
    );
  }

  Widget circleBar(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black :
           Colors.black.withOpacity(.5),
        borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }
}


class OnBoardItem extends StatefulWidget {
  final String image, backgroundImage, title, desc;
  OnBoardItem({this.image, this.backgroundImage, this.title, this.desc});

  @override
  _OnBoardItemState createState() => _OnBoardItemState();
}

class _OnBoardItemState extends State<OnBoardItem> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _tweenAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this,
        duration: Duration(seconds: 1));
    _tweenAnimation = Tween(begin: 1.0, end: 0.0,)
        .animate(CurvedAnimation(parent: _animationController,
            curve: Curves.fastOutSlowIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover,
          image: AssetImage('${widget.backgroundImage}'),
        ),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 110),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (c, child) {
            return Transform(
              transform: Matrix4.translationValues(0, _tweenAnimation.value * 35, 0),
              child: FadeTransition(
                opacity: _animationController.drive(CurveTween(curve: Curves.easeInOut)),
                child: Column(
                  children: <Widget>[
                    Container(height: 150, width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(fit: BoxFit.cover,
                          image: AssetImage('${widget.image}'),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text(widget.title, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontSize: 25,
                          fontWeight: FontWeight.w600),),
                    SizedBox(height: 16,),
                    Text(widget.desc, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87,
                          fontSize: 18),),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

