import 'package:flutter/material.dart';
import 'package:practical/Fav.dart';
import 'package:practical/Notification.dart';
import 'package:practical/bookmark.dart';
import 'package:practical/update.dart';

import 'Home.dart';

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  var bottomSelected = 0;
  var screen = [
    Home(),
    Fav(),
    BookMark(),
    Noti(),
    Update(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[bottomSelected],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomSelected,
          onTap: (value) {
            setState(
              () {
                bottomSelected = value;
              },
            );
          },
          selectedItemColor: Color(0xff03CDCD),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorite",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: "Bookmark",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notification_important_rounded),
              label: "Notification",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ]),
    );
  }
}
