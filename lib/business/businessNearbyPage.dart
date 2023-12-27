import 'dart:async';
import 'dart:developer';

import 'package:enamduatekno/business/businessDetailPage.dart';
import 'package:enamduatekno/view/filters_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:enamduatekno/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:enamduatekno/model/business_list_data.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:enamduatekno/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cupertino_tabbar/cupertino_tabbar.dart' as CupertinoTabBar;
import 'package:geolocator/geolocator.dart';

class businessNearbyPage extends StatefulWidget {
  const businessNearbyPage({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;
  @override
  _businessNearbyPageState createState() => _businessNearbyPageState();
}

class _businessNearbyPageState extends State<businessNearbyPage>{
  List<BusinessData> businessListData = BusinessData.businessList;
  late SharedPreferences pref;

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Animation<double>? topBarAnimation;
  double topBarOpacity = 1.0;
  final ScrollController scrollController = ScrollController();
  var MainUrl = Api.ApiUrl;
  var AuthKey = Api.ApiKey;


  late Future? futureBusiness;
  Animation<double>? animation;
  var _isVisible;
  int lioffset = 20;
  int totaldata = 0;
  var categories = null;
  late var latitude;
  var longitude;
  final List<String> getcategorieslist = [];

  @override
  void initState() {
    _isVisible = true;
    scrollController.addListener(() {
      if(scrollController.position.userScrollDirection == ScrollDirection.reverse){
        print("**** ${_isVisible} up");
        if(_isVisible == true) {
          /* only set when the previous state is false
             * Less widget rebuilds
             */
          //Move IO away from setState
          setState((){
            _isVisible = false;
          });
        }
      } else {
        if(scrollController.position.userScrollDirection == ScrollDirection.forward){
          print("**** ${_isVisible} down");
          if(_isVisible == false) {
            /* only set when the previous state is false
               * Less widget rebuilds
               */
            //Move IO away from setState
            setState((){
              _isVisible = true;
            });
          }
        }
      }
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
            _isVisible = false;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });

    super.initState();
    initial();
  }

  void initial() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(Exception('Location permissions are permanently denied.'));
      }

      if (permission == LocationPermission.denied) {
        return Future.error(Exception('Location permissions are denied.'));
      }
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    print(position.latitude);
    print(position.longitude);
    latitude = position.latitude;
    longitude = position.longitude;
    print(position.latitude);
    print(position.longitude);
    setState(() {
      futureBusiness = getBusiness(latitude.toString(),longitude.toString());
    });

  }
  Future getLoadMore(String lat,String long,int offset) async {
    var url;
    url = '${MainUrl}search?latitude='+lat+'&longitude='+long+'&offset=${offset}';

    print(url);
    final responce = await http.get(Uri.parse(url),
        headers: {
          "Authorization": 'Bearer ${AuthKey}'
        }
    );
    print(responce.body);
    final responceData = json.decode(responce.body);

    var jsonData = responceData['businesses'];
    for (var data in jsonData){
      totaldata = responceData['total'];

      for (var catdata in data['categories']){
        getcategorieslist.add(catdata['title']);
      }
      var getcategories = getcategorieslist.toString().replaceAll('[','');
      getcategories = getcategories.replaceAll(']','');
      businessListData.add(
        BusinessData(
          id: data['id'],
          alias: data['alias'],
          name: data['name'],
          image_url: data['image_url'],
          url: data['url'],
          review_count: data['review_count']==null?"0":data['review_count'],
          categories: getcategories==null?"-":getcategories,
          rating: data['rating']==null?"0.0":data['rating'],
          price: data['price']==null?"0":data['price'],
        ),
      );
    }

    return responceData['businesses'];

  }
  Future getBusiness(String lat,String long) async {
    var url;
    url = '${MainUrl}search?latitude='+lat+'&longitude='+long;

    print(url);
    final responce = await http.get(Uri.parse(url),
        headers: {
          "Authorization": 'Bearer ${AuthKey}'
        }
    );
    print(responce.body);
    final responceData = json.decode(responce.body);

    var jsonData = responceData['businesses'];
    businessListData.clear();
    for (var data in jsonData){
      totaldata = responceData['total'];

      for (var catdata in data['categories']){
        getcategorieslist.add(catdata['title']);
      }
      var getcategories = getcategorieslist.toString().replaceAll('[','');
      getcategories = getcategories.replaceAll(']','');
      businessListData.add(
        BusinessData(
          id: data['id'],
          alias: data['alias'],
          name: data['name'],
          image_url: data['image_url'],
          url: data['url'],
          review_count: data['review_count']==null?"0":data['review_count'],
          categories: getcategories==null?"-":getcategories,
          rating: data['rating']==null?"0.0":data['rating'],
          price: data['price']==null?"0":data['price'],
        ),
      );
    }

    return responceData['businesses'];
  }
  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Nearby $latitude, $longitude',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: futureBusiness,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Theme(
            data: AppTheme.buildLightTheme(),
            child: Container(
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: <Widget>[

                    Column(
                      children: <Widget>[
                        getAppBarUI(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0.0,0,0.0,0.0),
                            child: NestedScrollView(

                              headerSliverBuilder:
                                  (BuildContext context, bool innerBoxIsScrolled) {
                                return <Widget>[
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                          return Column(
                                            children: <Widget>[
                                            ],
                                          );
                                        }, childCount: 1),
                                  ),

                                ];
                              },
                              body: businessListData.length!=0?
                              SmartRefresher(
                                enablePullDown: true,
                                enablePullUp: true,
                                header: WaterDropHeader(),
                                controller: _refreshController,
                                onRefresh: _onRefresh,
                                onLoading: _onLoading,
                                child: ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.only(
                                      top: 4, bottom: 0, right: 16, left: 16),
                                  itemCount: businessListData.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (BuildContext context, int index) {
                                    final int count =
                                    businessListData.length > 10 ? 10 : businessListData.length;
                                    final Animation<double> animation =
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                        CurvedAnimation(
                                            parent: widget.animationController!,
                                            curve: Interval((1 / count) * index, 1.0,
                                                curve: Curves.fastOutSlowIn)));
                                    widget.animationController?.forward();

                                    return BusinessView(
                                      BusinessListData: businessListData[index],
                                      animation: animation,
                                      animationController: widget.animationController!,
                                    );
                                  },
                                ),
                              )
                                  :

                              Container(
                                color: AppTheme.nearlyWhite,

                                child: SafeArea(
                                  top: false,
                                  child: Scaffold(
                                    backgroundColor: AppTheme.nearlyWhite,

                                    body: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context).padding.top,
                                              left: 16,
                                              right: 16),
                                          child:  Icon(FontAwesomeIcons.newspaper,
                                              size: 80,
                                              color: AppTheme.grey),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            'Business',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(top: 16),
                                          child:Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: const Text(
                                                'Business not found',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  ),
                                ),
                              ),



                            ),
                            // this doesn't work for top and bottom
                          ),
                        ),

                      ],
                    ),

                  ],
                ),


              ),
            ),
          );
        }

        return Theme(
          data: AppTheme.buildLightTheme(),
          child: Container(
            child: Scaffold(
              body: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      getAppBarUI(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0.0,0,0.0,0.0),
                          child: NestedScrollView(
                            controller: scrollController,
                            headerSliverBuilder:
                                (BuildContext context, bool innerBoxIsScrolled) {
                              return <Widget>[
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                        return Column(
                                          children: <Widget>[

                                          ],
                                        );
                                      }, childCount: 1),
                                )

                              ];
                            },
                            body: Container(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                    top: 0, bottom: 0, right: 0, left: 0),
                                itemCount: 3,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    width: 300,
                                    child: Stack(
                                      children: <Widget>[
                                        AnimatedBuilder(
                                          animation: widget.animationController!,
                                          builder: (BuildContext context, Widget? child) {

                                            return FadeTransition(
                                              opacity: animation!,
                                              child: new Transform(
                                                transform: new Matrix4.translationValues(
                                                    0.0, 30 * (1.0 - animation!.value), 0.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 24, right: 24, top: 16, bottom: 16),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.white,
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(8.0),
                                                          bottomLeft: Radius.circular(8.0),
                                                          bottomRight: Radius.circular(8.0),
                                                          topRight: Radius.circular(8.0)),
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                            color: AppTheme.grey.withOpacity(0.2),
                                                            offset: Offset(1.1, 1.1),
                                                            blurRadius: 10.0),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                            width: MediaQuery.of(context).size.width,
                                                            height: 200.0,
                                                            child: Shimmer.fromColors(
                                                              child: Card(
                                                                color: Colors.grey,
                                                              ),
                                                              baseColor: Colors.grey.shade300,
                                                              highlightColor: Colors.grey,
                                                              direction: ShimmerDirection.ltr,
                                                            )
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(
                                                              left: 24, right: 24, top: 16, bottom: 16),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context).size.width,
                                                                      height: 25.0,
                                                                      child: Shimmer.fromColors(
                                                                        child: Card(
                                                                          color: Colors.grey,
                                                                        ),
                                                                        baseColor: Colors.grey.shade300,
                                                                        highlightColor: Colors.grey,
                                                                        direction: ShimmerDirection.ltr,
                                                                      ),
                                                                    ),

                                                                    Row(
                                                                        children: <Widget>[
                                                                          Container(
                                                                            width: MediaQuery.of(context).size.width / 3.5,

                                                                            child:Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  SizedBox(
                                                                                    width: 90.0,
                                                                                    height: 20.0,
                                                                                    child: Shimmer.fromColors(
                                                                                      child: Card(
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                      baseColor: Colors.grey.shade300,
                                                                                      highlightColor: Colors.grey,
                                                                                      direction: ShimmerDirection.ltr,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 110.0,
                                                                                    height: 25.0,
                                                                                    child: Shimmer.fromColors(
                                                                                      child: Card(
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                      baseColor: Colors.grey.shade300,
                                                                                      highlightColor: Colors.grey,
                                                                                      direction: ShimmerDirection.ltr,
                                                                                    ),
                                                                                  ),
                                                                                ]
                                                                            ),
                                                                          ),


                                                                        ]
                                                                    ),

                                                                  ],
                                                                ),
                                                              ),


                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),



                          ),
                          // this doesn't work for top and bottom
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ),
          ),
        );


      },

    );

  }

  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      futureBusiness = getBusiness(latitude,longitude);
    });

    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    lioffset = lioffset+20;
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      futureBusiness = getLoadMore(latitude.toString(),longitude.toString(),lioffset);
    });

    _refreshController.loadComplete();
  }
}

class BusinessView extends StatelessWidget {
  const BusinessView(
      {Key? key, this.BusinessListData, this.animationController, this.animation})
      : super(key: key);

  final BusinessData? BusinessListData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 16, left: 0, right: 5, bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    offset: const Offset(4, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: BusinessDetailPage(initialid: BusinessListData!.id)));
                      },
                      child: Column(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 2,
                            child: Image.network(
                              BusinessListData!.image_url,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            color: AppTheme.buildLightTheme()
                                .backgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child:Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16,right: 16, top: 8, bottom: 8),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            BusinessListData!.name,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Row(
                                            children: <Widget>[
                                              RatingBar(
                                                initialRating:
                                                BusinessListData!.rating,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 24,
                                                ratingWidget: RatingWidget(
                                                  full: Icon(
                                                    Icons.star_rate_rounded,
                                                    color: AppTheme.mainColor,
                                                  ),
                                                  half: Icon(
                                                    Icons.star_half_rounded,
                                                    color: AppTheme.mainColor,
                                                  ),
                                                  empty: Icon(
                                                    Icons
                                                        .star_border_rounded,
                                                    color: AppTheme.mainColor,
                                                  ),
                                                ),
                                                itemPadding:
                                                EdgeInsets.zero,
                                                onRatingUpdate: (rating) {
                                                  print(rating);
                                                },
                                              ),
                                              Text(
                                                ' ${BusinessListData!.review_count} Reviews',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey
                                                        .withOpacity(0.8)),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 8, bottom: 8),
                                            child: RichText(
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                  text: "${BusinessListData!.price}",
                                                  style:TextStyle(
                                                      color: AppTheme.mainColor,
                                                      fontSize: 22
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                        text:" • ",
                                                        style: TextStyle(
                                                            color: AppTheme.darkGray,
                                                            fontSize: 16
                                                        )
                                                    ),
                                                    TextSpan(
                                                        text:"${BusinessListData!.categories}",
                                                        style: TextStyle(
                                                            color: AppTheme.nearlyDarkBlue,
                                                            fontSize: 16
                                                        )
                                                    )
                                                  ]
                                              ),
                                            ),
                                          )
                                        ],
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
            ),
          ),
        ],
      ),
    );
  }
}

class ContestTabHeader extends SliverPersistentHeaderDelegate {
  ContestTabHeader(
      this.searchUI,
      );
  final Widget searchUI;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return searchUI;
  }

  @override
  double get maxExtent => 52.0;

  @override
  double get minExtent => 52.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}