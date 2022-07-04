import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:practical/Bottom.dart';
import 'package:practical/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  var data;
  void initState() {
    getEmail().whenComplete(() => Timer(
          Duration(seconds: 3),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => data == null ? Profile() : Bottom(),
            ),
          ),
        ));

    super.initState();
  }

  Future getEmail() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var results = _prefs.get("email");
    setState(() {
      data = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity / 2,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff61CEFFBD),
                Color(0xffFFFFFF),
                Color(0xffFFFFFF),
                Color(0xffFFFFFF),
                Color(0xff61CEFFBD)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset("assets/spalshIcon.png",
                height: height * 0.07, width: height * 0.07)
          ]),
        ),
      ),
    );
  }
}
