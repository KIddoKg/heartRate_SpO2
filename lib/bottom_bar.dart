// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:heart_spo2/spo2.dart';

import 'heart_rate.dart';


class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final items = const [
    Icon(
      Icons.graphic_eq,
      size: 30,
    ),
    Icon(
      Icons.home,
      size: 30,
    ),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(index: index),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: index,

        onTap: (selctedIndex) {
          setState(() {
            index = selctedIndex;
          });
        },
        height: 70,
        // backgroundColor:Color(0xFF212121),
        backgroundColor: getBackgroundColor(index: index),
        animationDuration: const Duration(milliseconds: 300),
        // animationCurve: ,
      ),
      body: Container(
        // color: Color(0xE6FFCD4D),
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: getSelectedWidget(index: index)),
    );
  }

  Widget getSelectedWidget({required int index}) {
    Widget widget;
    switch (index) {
      case 0:
        widget = HeartScreen();
        print(0);
        break;

      default:
        widget =  Spo2Screen();
        print(4);
        break;
    }
    return widget;
  }

  Color getBackgroundColor({required int index}) {
    switch (index) {
      case 0:
        return Color(0xFFCCD6E8);// Màu nền cho case 0
      default:
        return Color(0xFF212121); // Màu nền cho các case còn lại
    }
  }
}
