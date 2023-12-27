import 'dart:convert';
import 'dart:ui';
import 'package:enamduatekno/model/bannerlist.dart';
import 'package:enamduatekno/model/business_reviews_list_data.dart';
import 'package:enamduatekno/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enamduatekno/app_theme.dart';
import 'package:http/http.dart' as http;
import '../utils/text_style.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cupertino_tabbar/cupertino_tabbar.dart' as CupertinoTabBar;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BusinessDetailPage extends StatefulWidget {
  const BusinessDetailPage({Key? key, required this.initialid}) : super(key: key);
  final String initialid;
  @override
  _BusinessDetailPageState createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> with TickerProviderStateMixin {
  late String idbusiness;
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  late AnimationController controller;
  late AnimationController bodyScrollAnimationController;
  late ScrollController scrollController;
  late Animation<double> scale;
  late Animation<double> appBarSlide;
  double headerImageSize = 0;
  bool isFavorite = false;

  var getid;
  var getnama="";
  var getrating=0.0;
  var latitude=0.0;
  var longitude=0.0;
  var getprice="";
  final List<String> getcategorieslist = [];
  late var getcategories="";
  var geturl="";
  var getdisplay_phone="";
  var gettransactions="";
  var getlocation="";
  var getreview_count="";
  var getopenstart="";
  var getopenend="";
  bool getgetisopen= false;
  var getdetail;
  var getinputtgl;
  var getphoto;
  Future? futureProgramDetail;
  late AnimationController animationController;
  bool loadEdit = false;

  var MainUrl = Api.ApiUrl;
  var AuthKey = Api.ApiKey;
  final List<String> imgList = [];
  final double infoHeight = 364.0;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  Animation<double>? animation;

  late Future? futureBusinessReviews;
  List<BusinessReviewsData> businessReviewsListData = BusinessReviewsData.businessReviewsList;

  late int lioffsetreviews =3;
  var gettotalrating="";
  @override
  void initState() {
    idbusiness = widget.initialid;
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    bodyScrollAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController.offset >= headerImageSize / 2) {
          if (!bodyScrollAnimationController.isCompleted) bodyScrollAnimationController.forward();
        } else {
          if (bodyScrollAnimationController.isCompleted) bodyScrollAnimationController.reverse();
        }
      });

    appBarSlide = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: bodyScrollAnimationController,
    ));

    scale = Tween(begin: 1.0, end: 0.5).animate(CurvedAnimation(
      curve: Curves.linear,
      parent: controller,
    ));

    futureProgramDetail = getApiProgramDetail();
    futureBusinessReviews = getBusinessReviews();
    setData();

    super.initState();
  }
  Future<void> setData() async {
    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    bodyScrollAnimationController.dispose();
    super.dispose();
  }

  Future getApiProgramDetail() async {
    final Uri url = Uri.parse('${MainUrl+idbusiness}');
    print('url:'+url.toString());
    final responce = await http.get(url,
        headers: {
          "Authorization": 'Bearer ${AuthKey}'
        }
    );

    final responceData = json.decode(responce.body);
    /*if (responceData['status'] != true) {
      final snackBar = SnackBar(
        content: Text(responceData['message']),
        backgroundColor: Colors.black,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }*/
    getid = responceData['id'];
    getnama = responceData['name'];
    getrating = responceData['rating'];
    getprice = responceData['price']==null?"0":responceData['price'];
    getdetail = responceData['alias'];
    getinputtgl = responceData['display_phone'];
    getphoto = responceData['image_url']!=null?responceData['image_url']:"";
    for (var urlfoto in responceData['photos']){
      setState(() {
        imgList.add(urlfoto);
      });
    }
    var jsonData = responceData['categories'];

    for (var data in jsonData){
      getcategorieslist.add(data['title']);
    }
    getcategories = getcategorieslist.toString().replaceAll('[','');
    getcategories = getcategories.replaceAll(']','');
    setState(() {
      latitude = responceData['coordinates']['latitude'];
      longitude = responceData['coordinates']['longitude'];
    });
    geturl = responceData['url'];
    getdisplay_phone = responceData['display_phone'];
    getdisplay_phone = responceData['display_phone'];
    for (var datatran in responceData['transactions']){
      setState(() {
        gettransactions = datatran;
        if(gettransactions=='delivery'){
          cupertinoTransaction =0;
        }else if(gettransactions=='pickup'){
          cupertinoTransaction =1;
        }
      });
    }
    getlocation = responceData['location']['address1']+" "+responceData['location']['city']+" "+responceData['location']['state']+" "+responceData['location']['zip_code'];

    getreview_count = NumberFormat("#,##0").format(responceData['review_count']);
    for (var dataopen in responceData['hours']){
      setState(() {
        getgetisopen = dataopen['is_open_now'];
        for (var opensche in dataopen['open']){
          getopenstart = opensche['start'];
          getopenend = opensche['end'];
        }
      });
    }
    return responceData['name'];

  }

  Future getBusinessReviews() async {
    var url;
    url = '${MainUrl+idbusiness}/reviews';

    print(url);
    final responce = await http.get(Uri.parse(url),
        headers: {
          "Authorization": 'Bearer ${AuthKey}'
        }
    );
    print(responce.body);
    final responceData = json.decode(responce.body);

    /*if (responceData['status'] != true) {
      final snackBar = SnackBar(
        content: Text(responceData['message']),
        backgroundColor: Colors.black,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }*/
    var jsonData = responceData['reviews'];
    gettotalrating = NumberFormat("#,##0").format(responceData['total']);
    businessReviewsListData.clear();
    for (var data in jsonData){
      businessReviewsListData.add(
        BusinessReviewsData(
          id: data['id'],
          url: data['url'],
          text: data['text'],
          rating: data['rating'],
          time_created: data['time_created'],
          user_id: data['user']['id'],
          user_profile_url: data['user']['profile_url']==null?"":data['user']['profile_url'],
          user_image_url: data['user']['image_url']==null?"":data['user']['image_url'],
          user_name: data['user']['name']
        ),
      );
    }
    print("businessReviewsListData:"+businessReviewsListData.length.toString());
    return responceData['reviews'];
  }


  int cupertinoTransaction = 0;
  int cupertinoTransactionGetter() => cupertinoTransaction;

  @override
  Widget build(BuildContext context) {
    headerImageSize = MediaQuery.of(context).size.height / 1.5;
    final double tempHeight = MediaQuery.of(context).size.height;
    final double tempWidth = MediaQuery.of(context).size.width;
    print('headerImageSize:'+headerImageSize.toString());
    print('tempWidth:'+tempWidth.toString());
    return FutureBuilder(
      future: futureProgramDetail,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(loadEdit){
            loadEdit =false;
          }
          return ScaleTransition(
            scale: scale,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Scaffold(
                body: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                        controller: scrollController,
                        child:Stack(
                          children: <Widget>[

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 1.2,
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                        reverse: false,
                                        autoPlay: true,
                                        height: 600,
                                        viewportFraction: 1.0,
                                        autoPlayInterval: Duration(seconds: 3),
                                        autoPlayAnimationDuration: Duration(milliseconds: 800)
                                    ),
                                    items: imgList.map((item) => ClipRRect(
                                        child: Image.network(item, fit: BoxFit.cover,width: 1000)),
                                    ).toList(),
                                  ),
                                ),

                                Container(
                                  transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                                  decoration: BoxDecoration(
                                    color: AppTheme.nearlyWhite,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(32.0),
                                        topRight: Radius.circular(32.0)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: AppTheme.grey.withOpacity(0.2),
                                          offset: const Offset(1.1, 1.1),
                                          blurRadius: 10.0),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8, right: 8),
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[

                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 32.0, left: 16, right: 16),
                                            child:

                                            Text(
                                              '$getnama',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                                letterSpacing: 0.27,
                                                color: AppTheme.dark,
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16, bottom: 0, top: 0),
                                            child: Row(
                                              children: <Widget>[
                                                RatingBar(
                                                  initialRating:
                                                  getrating,
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
                                                RichText(
                                                  text: TextSpan(
                                                      text: "$getrating",
                                                      style:TextStyle(
                                                          color: AppTheme.dark,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                            text:" ($getreview_count Reviews) ",
                                                            style: TextStyle(
                                                                color: AppTheme.gray.withOpacity(0.8),
                                                                fontSize: 16
                                                            )
                                                        ),
                                                      ]
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16, bottom: 8, top: 16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                RichText(
                                                  text: TextSpan(
                                                      text: "$getprice",
                                                      style:TextStyle(
                                                          color: AppTheme.mainColor,
                                                          fontSize: 16
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
                                                            text:"$getcategories",
                                                            style: TextStyle(
                                                                color: AppTheme.nearlyDarkBlue,
                                                                fontSize: 16
                                                            )
                                                        )
                                                      ]
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          AnimatedOpacity(
                                            duration: const Duration(milliseconds: 500),
                                            opacity: opacity1,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.nearlyWhite,
                                                        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                              color: AppTheme.grey.withOpacity(0.2),
                                                              offset: const Offset(1.1, 1.1),
                                                              blurRadius: 8.0),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(
                                                            left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            getgetisopen?
                                                            RichText(
                                                              text: TextSpan(
                                                                  text: "Open",
                                                                  style:TextStyle(
                                                                      color: AppTheme.teal,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 16
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                        text:" • ",
                                                                        style: TextStyle(
                                                                            color: AppTheme.gray.withOpacity(0.8),
                                                                            fontSize: 16
                                                                        )
                                                                    ),
                                                                    TextSpan(
                                                                        text:"$getopenstart - ",
                                                                        style: TextStyle(
                                                                            color: AppTheme.gray.withOpacity(0.8),
                                                                            fontSize: 16
                                                                        )
                                                                    ),
                                                                    TextSpan(
                                                                        text:"$getopenend",
                                                                        style: TextStyle(
                                                                            color: AppTheme.gray.withOpacity(0.8),
                                                                            fontSize: 16
                                                                        )
                                                                    ),
                                                                  ]
                                                              ),
                                                            ):
                                                            Text(
                                                              'Close',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                letterSpacing: 0.27,
                                                                color: AppTheme.danger,
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
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 18, bottom: 16),
                                            child: Row(
                                              children: <Widget>[

                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          'Address',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.grey.withOpacity(0.8)),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          getlocation,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8),
                                                  child: Container(
                                                    width: 1,
                                                    height: 42,
                                                    color: Colors.grey.withOpacity(0.8),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 8, right: 8, top: 4, bottom: 4),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          'Phone',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.grey.withOpacity(0.8)),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          '$getdisplay_phone',
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child:Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 16, right: 16, top: 8, bottom: 8),
                                                    child:Row(
                                                      children: <Widget>[
                                                        CupertinoTabBar.CupertinoTabBar(
                                                          AppTheme.gray,
                                                          AppTheme.dark,
                                                          [
                                                            const Text(
                                                              "Delivery",
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                            const Text(
                                                              "Pickup",
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ],
                                                          cupertinoTransactionGetter,
                                                              (int index) {
                                                            setState(() {
                                                              cupertinoTransaction = index;
                                                            });
                                                          },
                                                          borderRadius: const BorderRadius.all(const Radius.circular(24.0)),
                                                          useSeparators: false,
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _startActivityInNewTask(geturl);
                                                  },
                                                  child:Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.nearlyWhite,
                                                        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                              color: AppTheme.grey.withOpacity(0.2),
                                                              offset: const Offset(1.1, 1.1),
                                                              blurRadius: 8.0),
                                                        ],
                                                      ),
                                                      child: Container(
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
                                                          child: Icon(
                                                            Icons.link,
                                                            color: AppTheme.mainColor,
                                                            size: 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )


                                              ]
                                          )

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                                  decoration: BoxDecoration(
                                    color: AppTheme.nearlyWhite,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: AppTheme.grey.withOpacity(0.2),
                                          offset: const Offset(1.1, 1.1),
                                          blurRadius: 10.0),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8, right: 8),
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[

                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16, top: 8),
                                            child: Text(
                                              'Rating & Review',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                                letterSpacing: 0.27,
                                                color: AppTheme.dark,
                                              ),
                                            ),
                                          ),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            left: 16, right: 16, top: 8, bottom: 0),
                                                        child: Text(
                                                          '$getrating',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 59,
                                                            color: AppTheme.dark,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            left: 16, right: 16, top: 0, bottom: 0),
                                                        child: Text(
                                                          '$gettotalrating Ratings',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(color: AppTheme.gray.withOpacity(0.8),
                                                              fontSize: 16
                                                          ),
                                                        ),
                                                      ),

                                                    ]
                                                ),
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      RatingBar(
                                                        initialRating:
                                                        5,
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
                                                      RatingBar(
                                                        initialRating:
                                                        4,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 4,
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
                                                      RatingBar(
                                                        initialRating:
                                                        3,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 3,
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
                                                      RatingBar(
                                                        initialRating:
                                                        2,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 2,
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
                                                      RatingBar(
                                                        initialRating:
                                                        1,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 1,
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
                                                    ]
                                                ),

                                              ]
                                          ),

                                          FutureBuilder(
                                            future: futureBusinessReviews,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return ListView.builder(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  controller: scrollController,
                                                  padding: const EdgeInsets.only(
                                                      top: 4, bottom: 0, right: 16, left: 16),
                                                  itemCount: businessReviewsListData.length,
                                                  scrollDirection: Axis.vertical,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    final int count =
                                                    businessReviewsListData.length > 10 ? 10 : businessReviewsListData.length;
                                                    final Animation<double> animation =
                                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                                        CurvedAnimation(
                                                            parent: animationController!,
                                                            curve: Interval((1 / count) * index, 1.0,
                                                                curve: Curves.fastOutSlowIn)));
                                                    animationController?.forward();

                                                    return BusinessReviewsView(
                                                      BusinessReviewsListData: businessReviewsListData[index],
                                                      animation: animation,
                                                      animationController: animationController!,
                                                    );
                                                  },
                                                );
                                              }
                                              return SizedBox( height: 10.0);


                                            },

                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                            Container (
                              transform: Matrix4.translationValues(290.0, 270.0, 0.0),
                              child: Card(
                                color: AppTheme.mainColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                elevation: 10.0,
                                child: InkWell(
                                  onTap: () {
                                    _startActivityInNewTask("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.map,
                                        color: AppTheme.nearlyWhite,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            buildHeaderButton(),
                          ],
                        )
                    ),

                    AnimatedBuilder(
                      animation: appBarSlide,
                      builder: (context, snapshot) {
                        return Transform.translate(
                          offset: Offset(0.0, -1000 * (1 - appBarSlide.value)),
                          child: Material(
                            elevation: 2,
                            color: AppTheme.nearlyWhite,
                            child: buildHeaderButton(hasTitle: true),
                          ),
                        );
                      },
                    )
                  ],
                )




              ),
            ),
          );

        }else{
          print("fhahfhkaf"+snapshot.hasData.toString());
          return Theme(
            data: AppTheme.buildLightTheme(),
            child: ScaleTransition(
              scale: scale,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Scaffold(
                    body: Stack(
                      children: <Widget>[
                        SingleChildScrollView(
                            controller: scrollController,
                            child:Stack(
                              children: <Widget>[

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: 1.2,
                                      child: Shimmer.fromColors(
                                        child: Card(
                                          color: Colors.grey,
                                        ),
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey,
                                        direction: ShimmerDirection.ltr,
                                      ),
                                    ),

                                    Container(
                                      transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                                      decoration: BoxDecoration(
                                        color: AppTheme.nearlyWhite,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(32.0),
                                            topRight: Radius.circular(32.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: AppTheme.grey.withOpacity(0.2),
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 10.0),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 32.0, left: 16, right: 16),
                                                child:

                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width-150,
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
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0, left: 16, right: 16),
                                                child:

                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width-100,
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
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0, left: 16, right: 16),
                                                child:

                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width-300,
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
                                              ),
                                              AnimatedOpacity(
                                                duration: const Duration(milliseconds: 500),
                                                opacity: opacity1,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                                            boxShadow: <BoxShadow>[
                                                              BoxShadow(
                                                                  color: AppTheme.grey.withOpacity(0.2),
                                                                  offset: const Offset(1.1, 1.1),
                                                                  blurRadius: 8.0),
                                                            ],
                                                          ),
                                                          child: SizedBox(
                                                            width: MediaQuery.of(context).size.width-250,
                                                            height: 45.0,
                                                            child: Shimmer.fromColors(
                                                              child: Card(
                                                                color: Colors.grey,
                                                              ),
                                                              baseColor: Colors.grey.shade300,
                                                              highlightColor: Colors.grey,
                                                              direction: ShimmerDirection.ltr,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 18, bottom: 16),
                                                child: Row(
                                                  children: <Widget>[
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        focusColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        hoverColor: Colors.transparent,
                                                        splashColor: Colors.grey.withOpacity(0.2),
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(4.0),
                                                        ),
                                                        onTap: () {
                                                          FocusScope.of(context).requestFocus(FocusNode());

                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              left: 8, right: 8, top: 4, bottom: 4),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: MediaQuery.of(context).size.width-350,
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
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(context).size.width-250,
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
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 8),
                                                      child: Container(
                                                        width: 1,
                                                        height: 42,
                                                        color: Colors.grey.withOpacity(0.8),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        children: <Widget>[
                                                          Material(
                                                            color: Colors.transparent,
                                                            child: InkWell(
                                                              focusColor: Colors.transparent,
                                                              highlightColor: Colors.transparent,
                                                              hoverColor: Colors.transparent,
                                                              splashColor: Colors.grey.withOpacity(0.2),
                                                              borderRadius: const BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              onTap: () {
                                                                FocusScope.of(context).requestFocus(FocusNode());
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(
                                                                    left: 8, right: 8, top: 4, bottom: 4),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context).size.width-350,
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
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context).size.width-250,
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
                                              Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child:Padding(
                                                        padding: const EdgeInsets.only(
                                                            left: 16, right: 16, top: 8, bottom: 8),
                                                        child:Row(
                                                          children: <Widget>[
                                                            SizedBox(
                                                              width: MediaQuery.of(context).size.width-250,
                                                              height: 45.0,
                                                              child: Shimmer.fromColors(
                                                                child: Card(
                                                                  color: Colors.grey,
                                                                ),
                                                                baseColor: Colors.grey.shade300,
                                                                highlightColor: Colors.grey,
                                                                direction: ShimmerDirection.ltr,
                                                              ),
                                                            )

                                                          ],
                                                        ),
                                                      ),

                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        _startActivityInNewTask(geturl);
                                                      },
                                                      child:Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: AppTheme.nearlyWhite,
                                                            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                                            boxShadow: <BoxShadow>[
                                                              BoxShadow(
                                                                  color: AppTheme.grey.withOpacity(0.2),
                                                                  offset: const Offset(1.1, 1.1),
                                                                  blurRadius: 8.0),
                                                            ],
                                                          ),
                                                          child: Container(
                                                            width: 48,
                                                            height: 48,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey.shade300,
                                                                borderRadius: const BorderRadius.all(
                                                                  Radius.circular(16.0),
                                                                ),
                                                                border: Border.all(
                                                                    color: AppTheme.grey
                                                                        .withOpacity(0.2)),
                                                              ),
                                                              child: Icon(
                                                                Icons.link,
                                                                color: Colors.grey.shade300,
                                                                size: 28,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )


                                                  ]
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                                      decoration: BoxDecoration(
                                        color: AppTheme.nearlyWhite,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: AppTheme.grey.withOpacity(0.2),
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 10.0),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16, right: 16, top: 8, bottom: 8),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width-250,
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
                                              ),
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                left: 16, right: 16, top: 8, bottom: 0),
                                                            child: Text(
                                                              '0.0',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 59,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                left: 16, right: 16, top: 0, bottom: 0),
                                                            child: Text(
                                                              '0 Ratings',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(color: Colors.grey.shade300,
                                                                  fontSize: 16
                                                              ),
                                                            ),
                                                          ),

                                                        ]
                                                    ),
                                                    Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          RatingBar(
                                                            initialRating:
                                                            5,
                                                            direction: Axis.horizontal,
                                                            allowHalfRating: true,
                                                            itemCount: 5,
                                                            itemSize: 24,
                                                            ratingWidget: RatingWidget(
                                                              full: Icon(
                                                                Icons.star_rate_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              half: Icon(
                                                                Icons.star_half_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              empty: Icon(
                                                                Icons
                                                                    .star_border_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                            ),
                                                            itemPadding:
                                                            EdgeInsets.zero,
                                                            onRatingUpdate: (rating) {
                                                              print(rating);
                                                            },
                                                          ),
                                                          RatingBar(
                                                            initialRating:
                                                            4,
                                                            direction: Axis.horizontal,
                                                            allowHalfRating: true,
                                                            itemCount: 4,
                                                            itemSize: 24,
                                                            ratingWidget: RatingWidget(
                                                              full: Icon(
                                                                Icons.star_rate_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              half: Icon(
                                                                Icons.star_half_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              empty: Icon(
                                                                Icons
                                                                    .star_border_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                            ),
                                                            itemPadding:
                                                            EdgeInsets.zero,
                                                            onRatingUpdate: (rating) {
                                                              print(rating);
                                                            },
                                                          ),
                                                          RatingBar(
                                                            initialRating:
                                                            3,
                                                            direction: Axis.horizontal,
                                                            allowHalfRating: true,
                                                            itemCount: 3,
                                                            itemSize: 24,
                                                            ratingWidget: RatingWidget(
                                                              full: Icon(
                                                                Icons.star_rate_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              half: Icon(
                                                                Icons.star_half_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              empty: Icon(
                                                                Icons
                                                                    .star_border_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                            ),
                                                            itemPadding:
                                                            EdgeInsets.zero,
                                                            onRatingUpdate: (rating) {
                                                              print(rating);
                                                            },
                                                          ),
                                                          RatingBar(
                                                            initialRating:
                                                            2,
                                                            direction: Axis.horizontal,
                                                            allowHalfRating: true,
                                                            itemCount: 2,
                                                            itemSize: 24,
                                                            ratingWidget: RatingWidget(
                                                              full: Icon(
                                                                Icons.star_rate_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              half: Icon(
                                                                Icons.star_half_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              empty: Icon(
                                                                Icons
                                                                    .star_border_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                            ),
                                                            itemPadding:
                                                            EdgeInsets.zero,
                                                            onRatingUpdate: (rating) {
                                                              print(rating);
                                                            },
                                                          ),
                                                          RatingBar(
                                                            initialRating:
                                                            1,
                                                            direction: Axis.horizontal,
                                                            allowHalfRating: true,
                                                            itemCount: 1,
                                                            itemSize: 24,
                                                            ratingWidget: RatingWidget(
                                                              full: Icon(
                                                                Icons.star_rate_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              half: Icon(
                                                                Icons.star_half_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                              empty: Icon(
                                                                Icons
                                                                    .star_border_rounded,
                                                                color: Colors.grey.shade300,
                                                              ),
                                                            ),
                                                            itemPadding:
                                                            EdgeInsets.zero,
                                                            onRatingUpdate: (rating) {
                                                              print(rating);
                                                            },
                                                          ),
                                                        ]
                                                    ),

                                                  ]
                                              ),



                                              FutureBuilder(
                                                future: futureBusinessReviews,
                                                builder: (context, snapshot) {
                                                  return ListView.builder(
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    controller: scrollController,
                                                    padding: const EdgeInsets.only(
                                                        top: 4, bottom: 0, right: 16, left: 16),
                                                    itemCount: businessReviewsListData.length,
                                                    scrollDirection: Axis.vertical,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      final int count =
                                                      businessReviewsListData.length > 10 ? 10 : businessReviewsListData.length;
                                                      final Animation<double> animation =
                                                      Tween<double>(begin: 0.0, end: 1.0).animate(
                                                          CurvedAnimation(
                                                              parent: animationController!,
                                                              curve: Interval((1 / count) * index, 1.0,
                                                                  curve: Curves.fastOutSlowIn)));
                                                      animationController?.forward();

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

                                                                        },
                                                                        child: Column(
                                                                          children: <Widget>[
                                                                            Container(
                                                                              color: AppTheme.buildLightTheme()
                                                                                  .backgroundColor,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                                                            Row(
                                                                                              children: <Widget>[
                                                                                                Container(
                                                                                                  padding: EdgeInsets.all(2),
                                                                                                  decoration: BoxDecoration(
                                                                                                    shape: BoxShape.circle,
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(width: 10),
                                                                                                Column(

                                                                                                  mainAxisAlignment:
                                                                                                  MainAxisAlignment.start,
                                                                                                  crossAxisAlignment:
                                                                                                  CrossAxisAlignment.start,
                                                                                                  children: <Widget>[
                                                                                                    SizedBox(
                                                                                                      width: MediaQuery.of(context).size.width-250,
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

                                                                                                    RatingBar(
                                                                                                      initialRating:
                                                                                                      5,
                                                                                                      direction: Axis.horizontal,
                                                                                                      allowHalfRating: true,
                                                                                                      itemCount: 5,
                                                                                                      itemSize: 14,
                                                                                                      ratingWidget: RatingWidget(
                                                                                                        full: Icon(
                                                                                                          Icons.star_rate_rounded,
                                                                                                          color: Colors.grey.shade300,
                                                                                                        ),
                                                                                                        half: Icon(
                                                                                                          Icons.star_half_rounded,
                                                                                                          color: Colors.grey.shade300,
                                                                                                        ),
                                                                                                        empty: Icon(
                                                                                                          Icons
                                                                                                              .star_border_rounded,
                                                                                                          color: Colors.grey.shade300,
                                                                                                        ),
                                                                                                      ),
                                                                                                      itemPadding:
                                                                                                      EdgeInsets.zero,
                                                                                                      onRatingUpdate: (rating) {
                                                                                                        print(rating);
                                                                                                      },
                                                                                                    ),
                                                                                                  ],
                                                                                                ),

                                                                                              ],
                                                                                            ),

                                                                                            SizedBox(height: 10),
                                                                                            SizedBox(
                                                                                              width: MediaQuery.of(context).size.width-250,
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
                                                                                            SizedBox(
                                                                                              width: MediaQuery.of(context).size.width-150,
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
                                                                                            SizedBox(
                                                                                              width: MediaQuery.of(context).size.width-50,
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
                                                                                            SizedBox(height: 10),
                                                                                            SizedBox(
                                                                                              width: MediaQuery.of(context).size.width-250,
                                                                                              height: 25.0,
                                                                                              child: Shimmer.fromColors(
                                                                                                child: Card(
                                                                                                  color: Colors.grey,
                                                                                                ),
                                                                                                baseColor: Colors.grey.shade300,
                                                                                                highlightColor: Colors.grey,
                                                                                                direction: ShimmerDirection.ltr,
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
                                                    },
                                                  );


                                                },

                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),


                                  ],
                                ),
                                Container (
                                  transform: Matrix4.translationValues(290.0, 270.0, 0.0),
                                  child: Card(
                                    color: Colors.grey.shade300,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50.0)),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      child: Center(
                                        child: Icon(
                                          CupertinoIcons.map,
                                          color: Colors.grey.shade300,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                buildHeaderButton(),
                              ],
                            )
                        ),

                        AnimatedBuilder(
                          animation: appBarSlide,
                          builder: (context, snapshot) {
                            return Transform.translate(
                              offset: Offset(0.0, -1000 * (1 - appBarSlide.value)),
                              child: Material(
                                elevation: 2,
                                color: AppTheme.nearlyWhite,
                                child: buildHeaderButton(hasTitle: true),
                              ),
                            );
                          },
                        )
                      ],
                    )




                ),
              ),
            )

          );
        }
      },
    );

  }
  Widget buildHeaderImage() {
    double maxHeight = MediaQuery.of(context).size.height;
    double minimumScale = 0.8;
    return GestureDetector(
      onVerticalDragUpdate: (detail) {
        controller.value += detail.primaryDelta! / maxHeight * 2;
      },
      onVerticalDragEnd: (detail) {
        if (scale.value > minimumScale) {
          controller.reverse();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: <Widget>[
            Theme(
            data: AppTheme.buildLightTheme(),
            child: Stack(
              children: <Widget>[
                imgList.length ==0 ?
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: headerImageSize,
                  child: Hero(
                    tag: getphoto,
                    child: ClipRRect(
                      child: Image.network(
                        getphoto,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ):
                Container(
                    child: CarouselSlider(
                      options: CarouselOptions(
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(milliseconds: 800)
                      ),
                      items: imgList.map((item) => Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.all(5),
                        child: Center(
                          child:ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(item, fit: BoxFit.cover, width: 1000)),
                        ),

                      )).toList(),
                    )
                ),
              ],
            ),
          ),
          buildHeaderButton(),
        ],
      ),
    );
  }


  Widget buildHeaderButton({bool hasTitle = false}) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 0,
              margin: const EdgeInsets.all(0),
              child: InkWell(
                onTap: () {
                  if (bodyScrollAnimationController.isCompleted) bodyScrollAnimationController.reverse();
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    color: hasTitle ? Colors.white : Colors.black,
                  ),
                ),
              ),
              color: hasTitle ? Theme.of(context).primaryColor : Colors.white,
            ),
            if (hasTitle) Text("$getnama", style: titleStyle.copyWith(color: Colors.white)),

          ],
        ),
      ),
    );
  }


  void _startActivityInNewTask(url) {
    final intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull(url),
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }


}

class BannerListView extends StatelessWidget {
  const BannerListView(
      {Key? key,
        this.listData,
        this.callBack,
        this.animationController,
        this.animation})
      : super(key: key);

  final BannerList? listData;
  final VoidCallback? callBack;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Positioned.fill(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(listData!.imagePath, fit: BoxFit.cover))
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.grey.withOpacity(0.2),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


}

Widget getTimeBoxUI(String text1) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.nearlyWhite,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.grey.withOpacity(0.2),
              offset: const Offset(1.1, 1.1),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              text1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.27,
                color: AppTheme.mainColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _startActivityInNewTask(url) {
  final intent = AndroidIntent(
    action: 'action_view',
    data: Uri.encodeFull(url),
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  intent.launch();
}

class BusinessReviewsView extends StatelessWidget {
  const BusinessReviewsView(
      {Key? key, this.BusinessReviewsListData, this.animationController, this.animation})
      : super(key: key);

  final BusinessReviewsData? BusinessReviewsListData;
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
    var rating = double.parse(BusinessReviewsListData!.rating.toString());
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

                      },
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: AppTheme.buildLightTheme()
                                .backgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: BusinessReviewsListData!.user_image_url != ""? CircleAvatar(
                                                    radius: 25,
                                                    backgroundImage:
                                                    NetworkImage(BusinessReviewsListData!.user_image_url),
                                                    backgroundColor: Colors.transparent)
                                                    :
                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundImage: AssetImage("assets/images/nopicprof.png"),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Column(

                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    BusinessReviewsListData!.user_name,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),

                                                  RatingBar(
                                                    initialRating:
                                                    rating,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 14,
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
                                                ],
                                              ),

                                            ],
                                          ),

                                          SizedBox(height: 10),
                                          Text(
                                            BusinessReviewsListData!.text,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            BusinessReviewsListData!.time_created,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey
                                                    .withOpacity(0.8)),
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