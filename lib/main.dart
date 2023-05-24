import 'package:flutter/material.dart';
import 'package:heart_spo2/screen_web.dart';
import 'package:heart_spo2/spo2.dart';
import 'package:heart_spo2/test.dart';

import 'bottom_bar.dart';
import 'chart.dart';
import 'heart_rate.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      home:  HomePage(),
    );
  }
}
