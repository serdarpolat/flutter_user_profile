import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_app1/user_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(backgroundColor: Colors.white, fontFamily: 'Josefin'),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final List<CardModel> userList = cards;
  double percentSlide = 1.0;

  int cardIndex = 0;

  double scrollPercent = 0.0;
  double cardPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double singleCardStart;
  double singleCardEnd;
  AnimationController singleCardFinish,
      followCtrl,
      scaleCtrl,
      openUserCtrl,
      userInfoCtrl,
      zoomCtrl;
  Animation followAnim, scaleAnim, openUserAnim, userInfoAnim, zoomAnim;

  @override
  void initState() {
    super.initState();
    singleCardFinish = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    )..addListener(() {
        setState(() {
          scrollPercent = lerpDouble(
              singleCardStart, singleCardEnd, singleCardFinish.value);
        });
      });

    followCtrl = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );

    followAnim = Tween(begin: 46.0, end: 100.0).animate(followCtrl)
      ..addListener(() {
        setState(() {});
      });

    scaleCtrl = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );

    scaleAnim = Tween(begin: 1.0, end: 0.0).animate(scaleCtrl)
      ..addListener(() {
        setState(() {});
      });

    userInfoCtrl = AnimationController(
      duration: Duration(milliseconds: 280),
      vsync: this,
    );

    userInfoAnim = Tween(begin: 0.0, end: 1.0).animate(userInfoCtrl)
      ..addListener(() {
        setState(() {});
      });

    zoomCtrl = AnimationController(
      duration: Duration(milliseconds: 280),
      vsync: this,
    );

    zoomAnim = Tween(begin: 1.1, end: 1.0).animate(zoomCtrl)
      ..addListener(() {
        setState(() {});
      });

    openUserCtrl = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    openUserAnim = Tween(begin: 290.0, end: 540.0).animate(openUserCtrl)
      ..addListener(() {
        setState(() {});
      });

    followCtrl.forward();
    scaleCtrl.forward();
    openUserCtrl.forward();
  }

  @override
  void dispose() {
    singleCardFinish.dispose();
    followCtrl.dispose();
    scaleCtrl.dispose();
    openUserCtrl.dispose();
    super.dispose();
  }

  void _hDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _hDragUpdate(DragUpdateDetails details) {
    final cardDrag = (details.globalPosition.dx - startDrag.dx) / context.size.width;

    setState(() {
      scrollPercent =
          (startDragPercentScroll + (-cardDrag / userList.length))
              .clamp(0.0, 1.0 - (1 / userList.length));
      cardPercent = cardDrag;
      if (cardPercent < 0) {
        percentSlide = -cardPercent;
      } else {
        percentSlide = cardPercent;
      }
    });
  }

  void _hDragEnd(DragEndDetails details) {
    singleCardStart = scrollPercent;
    singleCardEnd =
        (scrollPercent * userList.length).round() / userList.length;

    singleCardFinish.forward(from: 0.0);
    setState(() {
      if (cardPercent < -0.5 && cardIndex < (userList.length - 1))
        cardIndex++;
      else if (cardPercent > 0.5 && cardIndex > 0) cardIndex--;

      percentSlide = 1.0;
    });
  }

  List<Widget> _buildCards() {
    return [
      _buildCard(0, 6, scrollPercent, userList[0].imagePath, false),
      _buildCard(1, 6, scrollPercent, userList[1].imagePath, false),
      _buildCard(2, 6, scrollPercent, userList[2].imagePath, true),
      _buildCard(3, 6, scrollPercent, userList[3].imagePath, false),
      _buildCard(4, 6, scrollPercent, userList[4].imagePath, true),
      _buildCard(5, 6, scrollPercent, userList[5].imagePath, false),
    ];
  }

  Widget _buildCard(int cardId, int cardCount, double scrollPercent,
      String imgPath, bool isFollow) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    return FractionalTranslation(
      translation: Offset(cardId - cardScrollPercent,
          0.0), //MediaQuery.of(context).size.width * cardId
      child: Transform(
        transform: Matrix4.translationValues(0.0, 0.0, 0.0)..scale(zoomAnim.value),
        child: Card(
          imgPath: imgPath,
          isFollow: isFollow,
        ),
      ),
    );
  }

  Color _color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onHorizontalDragStart: _hDragStart,
            onHorizontalDragUpdate: _hDragUpdate,
            onHorizontalDragEnd: _hDragEnd,
            child: Stack(
              overflow: Overflow.clip,
              children: _buildCards(),
            ),
          ),
          Transform(
            transform: Matrix4.translationValues(0.0, openUserAnim.value, 0.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                  child: Opacity(
                    opacity: percentSlide,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 44.0 * (1.0 - percentSlide), 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  userList[cardIndex].followers,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Text(
                                'followers',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  userList[cardIndex].posts,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Text(
                                'posts',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  userList[cardIndex].following,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Text(
                                'following',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 400.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 30.0),
                        child: Opacity(
                          opacity: percentSlide,
                          child: Transform(
                            transform: Matrix4.translationValues(
                                0.0, 44.0 * (1.0 - percentSlide), 0.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    if (openUserCtrl.status ==
                                        AnimationStatus.completed) {
                                      openUserCtrl.reverse();
                                    } else {
                                      openUserCtrl.forward();
                                    }

                                    if (userInfoCtrl.status ==
                                        AnimationStatus.completed) {
                                      userInfoCtrl.reverse();
                                    } else {
                                      userInfoCtrl.forward();
                                    }

                                    if (zoomCtrl.status ==
                                        AnimationStatus.completed) {
                                      zoomCtrl.reverse();
                                    } else {
                                      zoomCtrl.forward();
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        userList[cardIndex].name,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      Text(
                                        userList[cardIndex].location,
                                      ),
                                    ],
                                  ),
                                ),
                                FlatButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: () {
                                    if (userList[cardIndex].isFollow == false) {
                                      followCtrl.reverse();
                                      scaleCtrl.reverse();
                                      userList[cardIndex].isFollow = true;
                                    } else {
                                      followCtrl.forward();
                                      scaleCtrl.forward();
                                      userList[cardIndex].isFollow = false;
                                    }

                                    // if (followCtrl.status ==
                                    //     AnimationStatus.completed) {
                                    //   followCtrl.reverse();
                                    // } else {
                                    //   followCtrl.forward();
                                    // }

                                    // if (scaleCtrl.status ==
                                    //     AnimationStatus.completed) {
                                    //   scaleCtrl.reverse();
                                    // } else {
                                    //   scaleCtrl.forward();
                                    // }

                                    _color == Colors.white
                                        ? _color = Color(0xFFE63426)
                                        : _color = Colors.white;
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: followAnim.value,
                                    height: 46.0,
                                    decoration: BoxDecoration(
                                        color: _color,
                                        border: Border.all(
                                          color: Color(0xFFE63426),
                                          width: 3.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4
                                                .translationValues(
                                                    0.0, 0.0, 0.0)
                                              ..scale(1.0 - scaleAnim.value),
                                            child: Opacity(
                                              opacity: 1.0 - scaleAnim.value,
                                              child: Text(
                                                'FOLLOW',
                                                style: TextStyle(
                                                  color: Color(0xFFE63426),
                                                  letterSpacing: 1.0,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Transform(
                                            alignment: Alignment.center,
                                            transform:
                                                Matrix4.translationValues(
                                                    0.0, 0.0, 0.0)
                                                  ..scale(scaleAnim.value),
                                            child: Opacity(
                                              opacity: scaleAnim.value,
                                              child: Icon(Icons.person_outline,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: userInfoAnim.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Text(
                                'The widget has a very nifty feature which allows a Floating Action Button to be docked in it. Adding BottomAppBar in Scaffold.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30.0,
                                vertical: 30.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: Text(
                                      'Photos',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Container(
                                            width: 160.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              image: DecorationImage(
                                                image:
                                                    AssetImage('images/p1.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Container(
                                            width: 160.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              image: DecorationImage(
                                                image:
                                                    AssetImage('images/p2.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Container(
                                            width: 160.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              image: DecorationImage(
                                                image:
                                                    AssetImage('images/p3.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Container(
                                            width: 160.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              image: DecorationImage(
                                                image:
                                                    AssetImage('images/p4.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Container(
                                            width: 160.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              image: DecorationImage(
                                                image:
                                                    AssetImage('images/p5.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30.0,
        fixedColor: Color(0xFFE63426),
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text(''),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE63426),
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

class Card extends StatelessWidget {
  final String imgPath;
  final bool isFollow;

  Card({this.imgPath, this.isFollow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imgPath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black26, BlendMode.multiply),
        ),
      ),
    );
  }
}
