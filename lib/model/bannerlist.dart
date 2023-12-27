import 'package:flutter/widgets.dart';

class BannerList {
  BannerList({
    this.navigateScreen,
    this.id = '',
    this.imagePath = '',
    this.link = '',
    this.create_date = '',
  });

  Widget? navigateScreen;
  String id;
  String imagePath;
  String link;
  String create_date;

  static List<BannerList> bannerList = [

  ];
}
