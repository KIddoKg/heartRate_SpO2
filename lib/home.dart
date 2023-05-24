import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heart_spo2/screen_web.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'DataModel.dart';
import 'heart_rate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context , constraints ) {
      if(constraints.maxWidth < 600){
        return HeartScreen();
      }else {
        return ScreenWeb();
      }
    },


    );

  }
}
