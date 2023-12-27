import 'dart:async';
import 'dart:developer';

import 'package:enamduatekno/business/MySearchDelegant.dart';
import 'package:enamduatekno/business/businessDetailPage.dart';
import 'package:enamduatekno/business/businessNearbyPage.dart';
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


class businessPage extends StatefulWidget {
  const businessPage({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;
  @override
  _businessPageState createState() => _businessPageState();
}

class _businessPageState extends State<businessPage>{
  List<BusinessData> businessListData = BusinessData.businessList;
  late SharedPreferences pref;
  late List<String> categoriesList = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  final ScrollController scrollController = ScrollController();
  var MainUrl = Api.ApiUrl;
  var AuthKey = Api.ApiKey;


  late Future? futureBusiness;
  Animation<double>? animation;
  var _isVisible;
  int lioffset = 20;
  int totaldata = 0;
  var categories = null;
  final List<String> getcategorieslist = [];
  var searchlocation;
  var searchlatitude;
  var searchlongitude;
  var sortby;
  var searchdistance;
  var opennow;
  var searchprices;
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
    pref = await SharedPreferences.getInstance();
    pref.setString('searchlocation', "");
    pref.setString('searchlatitude', "");
    pref.setString('searchlongitude', "");
    pref.setString('sortby', "");
    pref.setString('searchdistance', "");
    pref.setString('opennow', "");
    pref.setString('searchprices', "");
    setState(() {
      futureBusiness = getBusiness();
    });
  }

  Future getLoadMore(int offset) async {
    searchlocation = !pref.getString('searchlocation').toString().isEmpty?pref.getString('searchlocation'):"NYC";
    searchlatitude = pref.getString('searchlatitude')!=null?pref.getString('searchlatitude'):"";
    searchlongitude = pref.getString('searchlongitude')!=null?pref.getString('searchlongitude'):"";
    sortby = pref.getString('sortby')!=null?pref.getString('sortby'):"";
    searchdistance = pref.getString('searchdistance')!=null?pref.getString('searchdistance'):"";
    opennow = pref.getString('opennow')!=null?pref.getString('opennow'):"false";
    searchprices = pref.getString('searchprices')!=null?pref.getString('searchprices'):"";
    categoriesList = pref.getStringList("searchcategory") ?? [];
    var latlong="";
    if(searchlatitude!="" && searchlatitude!=""){
      latlong = '&latitude='+searchlatitude.toString()+'&longitude='+searchlatitude;
    }
    var sortbyshow="";
    if(sortby!=""){
      sortbyshow = '&sortby='+sortby;
    }
    var searchdistanceshow="";
    if(sortby!=""){
      int dbDistance = int.parse(searchdistance);
      searchdistanceshow = '&radius='+dbDistance.toString();
    }
    var opennowshow="";
    if(opennow!=""){
      opennowshow = '&open_now='+opennow;
    }
    var searchpricesshow="";
    if(searchprices!=""){
      searchpricesshow = '&price='+searchprices;
    }
    var categoriesshow="";
    if(categoriesList.length!=0){
      for (var data in categoriesList) {
        categoriesshow +='&categories='+data.toString();
      }
    }
    var url;
    url = '${MainUrl}search?location='+searchlocation+latlong+sortbyshow+searchdistanceshow+opennowshow+searchpricesshow+categoriesshow+'&offset=${offset}';
    //url = '${MainUrl}search?location=NYC&offset=${offset}';

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
          price: data['price']==null?"":data['price'],
        ),
      );
    }

    return responceData['businesses'];

  }
  Future getBusiness() async {
    searchlocation = !pref.getString('searchlocation').toString().isEmpty?pref.getString('searchlocation'):"NYC";
    searchlatitude = pref.getString('searchlatitude')!=null?pref.getString('searchlatitude'):"";
    searchlongitude = pref.getString('searchlongitude')!=null?pref.getString('searchlongitude'):"";
    sortby = pref.getString('sortby')!=null?pref.getString('sortby'):"";
    searchdistance = pref.getString('searchdistance')!=null?pref.getString('searchdistance'):"";
    opennow = pref.getString('opennow')!=null?pref.getString('opennow'):"false";
    searchprices = pref.getString('searchprices')!=null?pref.getString('searchprices'):"";
    categoriesList = pref.getStringList("searchcategory") ?? [];
    var latlong="";
    if(searchlatitude!="" && searchlatitude!=""){
      latlong = '&latitude='+searchlatitude.toString()+'&longitude='+searchlatitude;
    }
    var sortbyshow="";
    if(sortby!=""){
      sortbyshow = '&sortby='+sortby;
    }
    var searchdistanceshow="";
    if(sortby!=""){
      int dbDistance = int.parse(searchdistance);
      searchdistanceshow = '&radius='+dbDistance.toString();
    }
    var opennowshow="";
    if(opennow!=""){
      opennowshow = '&open_now='+opennow;
    }
    var searchpricesshow="";
    if(searchprices!=""){
      searchpricesshow = '&price='+searchprices;
    }
    var categoriesshow="";
    if(categoriesList.length!=0){
      for (var data in categoriesList) {
        categoriesshow +='&categories='+data.toString();
      }

    }
    var url;
    url = '${MainUrl}search?location='+searchlocation+latlong+sortbyshow+searchdistanceshow+opennowshow+searchpricesshow+categoriesshow;
    //url = '${MainUrl}search?location=NYC';

    print('url'+url);
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

  Widget getFilterBarUI() {
    return Stack(
      children: <Widget>[
        Container(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.nearlyWhite,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16.0),
                      ),
                      border: Border.all(
                          color: AppTheme.grey
                              .withOpacity(0.2)),
                    ),
                    child: InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.grey.withOpacity(0.2),
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => FiltersScreen(),
                              fullscreenDialog: true),
                        );
                      },
                      child: Icon(Icons.sort,
                          color: AppTheme.mainColor),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24.0),
                      bottomRight: Radius.circular(24.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0,8.0,0.0,8.0),
                                child: CircleAvatar(
                                  child: Image.asset('assets/images/ic_launcher_circle.png'),
                                )
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0,8.0,0.0,8.0),
                                child: Text(
                                  'BUSINESS 62',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: AppTheme.mainColor,
                                  ),
                                ),
                              ),
                            ),
                            _filter(),

                            _searchAppbar(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _searchAppbar() {
    return
      IconButton(icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate:MySearchDelegant ());
          });
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
                                              //getSearchBarUI(),
                                              //getTimeDateUI(),
                                              //getFilterBarUI(),
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
                                            'Businesses',
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
                  floatingActionButton: AnimatedOpacity(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FloatingActionButton(
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          ),
                          tooltip: 'Nearby',
                          onPressed: (){
                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: businessNearbyPage(animationController: widget.animationController))).then(onGoBack);
                          },
                          child: IconTheme(
                            data: IconThemeData(
                                color: Colors.white),
                            child: Icon(Icons.near_me),
                          ),
                          backgroundColor: AppTheme.mainColor,
                        )
                      ],
                    ),
                    duration: Duration(milliseconds: 100),
                    opacity: _isVisible? 1 : 0,
                  )

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
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0.0,90,0.0,0.0),
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
    print("fkajfa");
    setState(() {
      futureBusiness = getBusiness();
    });

    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    lioffset = lioffset+20;
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      futureBusiness = getLoadMore(lioffset);
    });

    _refreshController.loadComplete();
  }

  onGoBack(dynamic value) {
    print(value);
    print("gobackkhgakhg");
    if(value=="load_data"){
      setState(() {
        futureBusiness = getBusiness();
      });
    }
  }
  Widget _filter() {
    return
      IconButton(icon: Icon(Icons.sort),
          onPressed: () {

            Route route = MaterialPageRoute<void>(
              builder: (BuildContext context) => FiltersScreen(),
              fullscreenDialog: true,
            );
            Navigator.push(context, route).then(onGoBack);
            //_openFilter();
            //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: notifikasiPage()));
          });
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



class FilterDialog extends StatefulWidget {
  FilterDialog({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;


  @override
  _filterState createState() => _filterState();
}

class _filterState  extends State<FilterDialog>  {
  TextEditingController _textTanggaMulai = TextEditingController();
  TextEditingController _textTanggaBerakhir = TextEditingController();
  TextEditingController _textSearch = TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var _idprovinsi;
  var _idkabupaten;
  var _idkabupatendapil;
  var _idkecamatan;
  var MainUrl = Api.ApiUrl;
  var AuthKey = Api.ApiKey;
  late List _dataProvince;
  late List _dataKabupaten;
  late List _dataKabupatenperdapil;
  late List _dataKecamatan;
  List<String> jenis_dugaan_pelanggaran = [];
  var input_jenis_dugaan_pelanggaran='';
  var userLogin;
  var idlevel ;
  var userProvinsi ;
  var userKabKota ;
  late SharedPreferences preff;

  static var tglstart;
  static var tglend;
  static var idprov;
  static var idkab;
  var kabpref;
  var kacpref;

  var _isLogin;
  var _group;
  var _userId;
  var _IdLevel;
  var _userEmail;
  var _nohp;
  var _NamaLengkap;
  var _Password;
  var _provinsi;
  var _namaprovinsi;
  var _kabupaten;
  var _namakabupaten;
  var _kecamatan;
  var _namakecamatan;
  var _kelurahan;
  var _caleg;
  var _partai;
  var _dapil;
  var _status;
  var _photo;
  var _aktif;
  var _verify;
  var textpencarian;

  var _iddapil;
  late List _dataDapil;


  static String get tgllaporanstart {
    return tglstart;
  }

  static String get tgllaporanend {
    return tglend;
  }

  static String get provinsi {
    return idprov;
  }

  static String get kabupaten {
    return idkab;
  }

  void getProvince() async {
    final Uri url = Uri.parse(MainUrl+ "provinsi");
    final respose = await http.get(url,
        headers: {
          "Auth": '${AuthKey}'
        }
    );
    var listData = jsonDecode(respose.body);
    setState(() {
      _dataProvince = listData['data'];
    });
  }

  void getKabupatenDapil(idprovinsi, dapil) async {
    final Uri url = Uri.parse(MainUrl+ "dapil/dprri_detail?id_provinsi="+idprovinsi+"&dapil="+dapil);
    final respose = await http.get(url,
        headers: {
          "Auth": '${AuthKey}'
        }
    );
    var listData = jsonDecode(respose.body);
    setState(() {
      _dataKabupatenperdapil = listData['data'];
    });

    print("_dataKabupatenperdapil"+_dataKabupatenperdapil.toString());
    print("url:"+url.toString());
  }

  void getKecamatan(idkabupaten) async {
    final Uri url = Uri.parse(MainUrl+ "kecamatan?kabupaten_id="+idkabupaten);
    final respose = await http.get(url,
        headers: {
          "Auth": '${AuthKey}'
        }
    );
    var listData = jsonDecode(respose.body);
    setState(() {
      _dataKecamatan = listData['data'];
    });
  }

  void getDapilDPRRI(var idprov) async {
    final Uri url = Uri.parse(MainUrl+ "dapil/dprri?id_provinsi="+idprov);
    final respose = await http.get(url,
        headers: {
          "Auth": '${AuthKey}'
        }
    );
    var listData = jsonDecode(respose.body);
    setState(() {
      _dataDapil = listData['data'];
    });

    print("_dataDapil"+_dataDapil.toString());
    print("url:"+url.toString());
  }

  void getDapilDPRDPROV(var idprov) async {
    final Uri url = Uri.parse(MainUrl+ "dapil/dprd_prov?id_provinsi="+idprov);
    final respose = await http.get(url,
        headers: {
          "Auth": '${AuthKey}'
        }
    );
    var listData = jsonDecode(respose.body);
    setState(() {
      _dataDapil = listData['data'];
    });

    print("_dataDapil"+_dataDapil.toString());
    print("url:"+url.toString());
  }

  void getDapilDPRDKAB(var idprov, var idkab) async {
    final Uri url = Uri.parse(MainUrl+ "dapil/dprd_kab?id_provinsi="+idprov+"&id_kabupaten="+idkab);
    final respose = await http.get(url,
        headers: {
          "Auth": '${AuthKey}'
        }
    );
    var listData = jsonDecode(respose.body);
    setState(() {
      _dataDapil = listData['data'];
    });

    print("_dataDapil"+_dataDapil.toString());
    print("url:"+url.toString());
  }

  void initial() async {
    preff = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _dataProvince=[];
    getProvince();
    _dataKabupaten=[];
    _dataKabupatenperdapil=[];
    _dataKecamatan=[];
    _dataDapil=[];
    initial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Filter'),
      ),
      body: Center(
        child: Container(
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },

                  child: Column(
                    children: <Widget>[
                      Form(
                          key: _formKey,
                          child:Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child:
                              new Container(
                                  color: AppTheme.white,
                                  child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child:Align(
                                            alignment: Alignment.centerLeft,
                                            child: RichText(
                                              text: new TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(text: 'Cari',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14)),

                                                ],
                                              ),
                                            ),
                                          ),

                                        ),
                                        Column(
                                            crossAxisAlignment : CrossAxisAlignment.start,
                                            children: <Widget> [
                                              TextFormField(
                                                controller: _textSearch,
                                                decoration: InputDecoration(
                                                  labelText: 'Cari nik,nama',
                                                  border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                                                      borderRadius: BorderRadius.circular(25.0)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: new BorderSide(color: AppTheme.grey),
                                                      borderRadius: BorderRadius.circular(25.0)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: new BorderSide(color: AppTheme.mainColor),
                                                      borderRadius: BorderRadius.circular(25.0)),
                                                  suffixIcon: Icon(
                                                    Icons.search,
                                                  ),
                                                ),
                                              ),
                                            ]
                                        ),
                                        SizedBox(height: 15.0),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child:Align(
                                            alignment: Alignment.centerLeft,
                                            child: RichText(
                                              text: new TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(text: 'Provinsi',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14)),

                                                ],
                                              ),
                                            ),
                                          ),

                                        ),
                                        Column(
                                            crossAxisAlignment : CrossAxisAlignment.start,
                                            children: <Widget> [
                                              DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField(
                                                  decoration: InputDecoration(
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: new BorderSide(color: AppTheme.grey),
                                                        borderRadius: BorderRadius.circular(24.0)),
                                                    border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                                                        borderRadius: BorderRadius.circular(24.0)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: new BorderSide(color: AppTheme.mainColor),
                                                        borderRadius: BorderRadius.circular(24.0)),
                                                  ),
                                                  hint: Text("Pilih Provinsi"),
                                                  value: _idprovinsi,
                                                  isDense: true,

                                                  isExpanded: true,
                                                  items: _dataProvince.map((item) {
                                                    return DropdownMenuItem(
                                                      child: Text(item['provinsi']),
                                                      value: item['id'],
                                                    );
                                                  }).toList(),

                                                  onChanged: null,
                                                ),
                                              ),
                                            ]
                                        ),
                                        if(_caleg=="3")
                                          getDataKabupatenDPRKAB(),


                                        SizedBox(height: 15.0),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child:Align(
                                            alignment: Alignment.centerLeft,
                                            child: RichText(
                                              text: new TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(text: 'Dapil',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14)),

                                                ],
                                              ),
                                            ),
                                          ),

                                        ),
                                        Column(
                                            crossAxisAlignment : CrossAxisAlignment.start,
                                            children: <Widget> [
                                              DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField(
                                                  decoration: InputDecoration(
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: new BorderSide(color: AppTheme.grey),
                                                        borderRadius: BorderRadius.circular(25.0)),
                                                    border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                                                        borderRadius: BorderRadius.circular(25.0)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: new BorderSide(color: AppTheme.mainColor),
                                                        borderRadius: BorderRadius.circular(25.0)),
                                                  ),
                                                  hint: Text("Pilih Dapil"),
                                                  value: _iddapil,
                                                  isDense: true,
                                                  isExpanded: true,
                                                  items: _dataDapil.map((item) {
                                                    return DropdownMenuItem(
                                                      child: Text(item['DAPIL']),
                                                      value: item['DAPIL'],
                                                    );
                                                  }).toList(),
                                                  validator: (value) {
                                                    if (value == null)
                                                      return "Silakan pilih Dapil";
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _iddapil = value;

                                                      if(_caleg=="1" || _caleg=="2"){
                                                        _idkabupatendapil = null;
                                                        getKabupatenDapil(_idprovinsi,_iddapil);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ]
                                        ),
                                        if(_caleg=="1" || _caleg=="2")
                                          getDataKabupaten(),
                                        SizedBox(height: 15.0),


                                        SizedBox(height: 20.0),
                                        InkWell(
                                          onTap: () {
                                            print("fakjfk:" +_textTanggaMulai.text);
                                            if (!_formKey.currentState!.validate()) {

                                              return;
                                            }
                                            _formKey.currentState!.save();
                                            var prov;
                                            var kab;
                                            var kec;
                                            if(_idprovinsi==null){
                                              prov = '';
                                            }else{
                                              prov = _idprovinsi;
                                            }
                                            if(_idkabupaten==null){
                                              kab = '';
                                            }else{
                                              kab = _idkabupaten;
                                            }
                                            if(_idkecamatan==null){
                                              kec = '';
                                            }else{
                                              kec = _idkecamatan;
                                            }
                                            if(_iddapil==null){
                                              _iddapil = '';
                                            }else{
                                              _iddapil = _iddapil;
                                            }

                                            if(_textSearch.text==null){
                                              textpencarian = '';
                                            }else{
                                              textpencarian = _textSearch.text;
                                            }


                                            var namaprovinsi = "";
                                            for (var i = 0; i < _dataProvince.length; i++) {

                                              // Checking for largest value in the list
                                              if (_dataProvince[i]['id'] == _idprovinsi) {
                                                namaprovinsi = _dataProvince[i]['provinsi'];
                                              }

                                            }
                                            var namakabupaten = "";
                                            for (var i = 0; i < _dataKabupaten.length; i++) {

                                              // Checking for largest value in the list
                                              if (_dataKabupaten[i]['id'] == _idkabupaten) {
                                                namakabupaten = _dataKabupaten[i]['kabupaten'];
                                              }

                                            }
                                            for (var i = 0; i < _dataKabupatenperdapil.length; i++) {
                                              // Checking for largest value in the list
                                              if (_dataKabupatenperdapil[i]['ID_KABUPATEN'] == _idkabupatendapil) {
                                                namakabupaten = _dataKabupatenperdapil[i]['KABUPATEN'];
                                              }

                                            }
                                            var namakecamatan = "";
                                            for (var i = 0; i < _dataKecamatan.length; i++) {

                                              // Checking for largest value in the list
                                              if (_dataKecamatan[i]['id'] == _idkecamatan) {
                                                namakecamatan = _dataKecamatan[i]['kecamatan'];
                                              }

                                            }
                                            if(_idkabupatendapil!=""){
                                              _idkabupaten = _idkabupatendapil;
                                            }
                                            preff.setString('prov', _idprovinsi);
                                            preff.setString('namaprov', namaprovinsi);
                                            preff.setString('dapil', _iddapil);
                                            preff.setString('kab', _idkabupaten);
                                            preff.setString('namakab', namakabupaten);
                                            preff.setString('kec', _idkecamatan);
                                            preff.setString('namakec', namakecamatan);

                                            if (_formKey.currentState!.validate()) {
                                              setState(() {

                                                //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: konstituenSearchPage(search: textpencarian,prov: prov,kab: kab, kec: kec, dapil: _iddapil, animationController: widget.animationController )));

                                              });
                                            }


                                            //Provider.of<Person>(context, listen: false).increaseAge();
                                            //Provider.of<Jumlah_Laporan>(context, listen: false).load(context,_textTanggaMulai.text,_textTanggaBerakhir.text,_idprovinsi,_idkabupaten);

                                            /*Navigator
                                                      .of(context)
                                                      .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => NavigationHomeScreen(screenset:  NewHomePage())));*/

                                          },
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(16.0)),
                                          highlightColor: Colors.transparent,

                                          child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: EdgeInsets.symmetric(vertical: 15),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                        color: Colors.grey.shade200,
                                                        offset: Offset(2, 4),
                                                        blurRadius: 5,
                                                        spreadRadius: 2)
                                                  ],
                                                  gradient: LinearGradient(
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight,
                                                      colors: [Color(0xfff77b00), Color(0xfff7892b)])),
                                              child: Text("Terapkan", style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
                                          ),
                                        )

                                      ])
                                  )
                              ),
                            ),
                          )
                      )

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getDataKabupaten() {
    return Column(children: [
      SizedBox(height: 10.0),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child:Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                new TextSpan(text: 'Kabupaten',style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
              ],
            ),
          ),
        ),

      ),
      Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: <Widget> [
            DropdownButtonHideUnderline(
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: AppTheme.grey),
                      borderRadius: BorderRadius.circular(25.0)),
                  border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                      borderRadius: BorderRadius.circular(25.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: AppTheme.mainColor),
                      borderRadius: BorderRadius.circular(25.0)),
                ),
                hint: Text("Pilih Kabupaten"),
                value: _idkabupatendapil,
                isDense: true,
                isExpanded: true,
                items: _dataKabupatenperdapil.map((item) {
                  return DropdownMenuItem(
                    child: Text(item['KABUPATEN']),
                    value: item['ID_KABUPATEN'],
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _idkabupatendapil = value;

                  });
                },
              ),
            ),
          ]
      ),


    ]);
  }

  Widget getDataKabupatenDPRKAB() {
    return Column(children: [
      SizedBox(height: 10.0),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child:Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                new TextSpan(text: 'Kabupaten',style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
                new TextSpan(text: ' *', style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
              ],
            ),
          ),
        ),

      ),
      Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: <Widget> [
            DropdownButtonHideUnderline(
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: AppTheme.grey),
                      borderRadius: BorderRadius.circular(25.0)),
                  border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                      borderRadius: BorderRadius.circular(25.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: AppTheme.mainColor),
                      borderRadius: BorderRadius.circular(25.0)),
                ),
                hint: Text("Pilih Kabupaten"),
                value: _idkabupaten,
                isDense: true,
                isExpanded: true,
                items: _dataKabupaten.map((item) {
                  return DropdownMenuItem(
                    child: Text(item['kabupaten']),
                    value: item['id'],
                  );
                }).toList(),
                validator: (value) {
                  if (value == null)
                    return "Silakan pilih Kabupaten";
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _idkabupaten = value;

                  });
                },
              ),
            ),
          ]
      ),


    ]);
  }

}