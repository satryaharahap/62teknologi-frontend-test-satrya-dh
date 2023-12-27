import 'dart:io';
import 'package:enamduatekno/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SplashPageState createState() => _SplashPageState();


}

class _SplashPageState extends State<SplashPage> {
  late SharedPreferences pref;


  @override
  void initState() {
    super.initState();
  }
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: AppTheme.mainColor,
        ),
        Center(
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top),
            child: Image.asset(
                "assets/images/splash_bg.png"
            ),
          ),
        ),
      ],
    );

  }

}