// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe, unused_import, depend_on_referenced_packages, must_be_immutable, avoid_print, unused_local_variable, unused_field, avoid_unnecessary_containers
import 'dart:async';
import 'dart:convert';
import 'dart:math';
// import 'package:breathing_collection/breathing_collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:heart_spo2/presentation/resources/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heart_spo2/pages/background.dart';
import 'dart:io' as io;
import 'package:lottie/lottie.dart';

import 'DataModel.dart';
import 'chart.dart';
import 'constants/constants.dart';

class Spo2Screen extends StatefulWidget {
  Spo2Screen({Key? key}) : super(key: key);

  @override
  State<Spo2Screen> createState() => _Spo2ScreenState();
}

class _Spo2ScreenState extends State<Spo2Screen>
    with SingleTickerProviderStateMixin {
  List<Feed> feeds = [];
  int min =0;
  int max =20;
  int avg =0;
  bool isProcessing = true;

  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  String test = "Mar";
  bool showAvg = false;


  Future<void> fetchData() async {
    var url = Uri.parse(
        'https://api.thingspeak.com/channels/2147980/feeds.json?api_key=O2JS76C4MANU1ZZM&results=5');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> feedsData = data['feeds'];
      setState(() {
        feeds = feedsData.map((feedJson) => Feed.fromJson(feedJson)).toList();
      });
print(feeds.length );
      fakeData(feeds);
      AvgSpO2();
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setInt('myDataKey', feeds[feeds.length-1].entryId);
    }
  }

  void AvgSpO2(){
    int currentValue = 0;
    if (feeds.length > 0) {
      // min = int.parse(feeds[0].field2!);
      // max = int.parse(feeds[0].field2!);

      for (int i = 0; i < feeds.length; i++) {
        if (feeds[i].field2 != null) {
          currentValue =  currentValue + int.parse(feeds[i].field2!);
        }
      }
      double revert= (currentValue / feeds.length);
      avg = revert.toInt();
      print('Giá trị trung bình: ${avg}');
    } else {
      print('Danh sách rỗng ${feeds.length }');
    }
  }

  Future<void> fakeData(List<Feed> feeds) async {
    if (feeds.length > 0) {
       min = int.parse(feeds[0].field2!);
       max = int.parse(feeds[0].field2!);

      for (int i = 1; i < feeds.length; i++) {
        int currentValue = 0;
        if (feeds[i].field2 != null) {
          currentValue = int.parse(feeds[i].field2!);
        }

        if (currentValue < min) {
          min = currentValue;
        }
        if (currentValue > max) {
          max = currentValue;
        }
      }

      print('Giá trị nhỏ nhất: $min');
      print('Giá trị lớn nhất: $max');
    } else {
      print('Danh sách rỗng ${feeds.length }');
    }
  }


  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 10), (timer) {
      fetchData();

    });


  }
  @override
  Widget build(BuildContext context) {
    // _controller.forward();
    // List<Widget> pages = [measurePage(), statsPage()];
    List<Widget> pages = [statsPage()];
    return Scaffold(
      backgroundColor: Colors.black,
      body: statsPage(),

    );

  }
  Widget statsPage() {
    return Column(
        children: [
          Card(
            margin: EdgeInsets.only(top: 50, left: 10, right: 10),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            color: scaffoldColor,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child:Chart(),
              ),
            ),
          ),
          Expanded(
              child: Card(
                  margin: EdgeInsets.only(
                      left: 10, right: 10, top: 25, bottom: 20),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  color: scaffoldColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: "${avg}",
                                      style: appText(
                                          size: 23,
                                          color: heartColor,
                                          weight: FontWeight.w500)),
                                  TextSpan(
                                    text: ' SpO2',
                                    style: appText(
                                        color: waveColor,
                                        weight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                      text: '\nAVERAGE',
                                      style: appText(
                                          size: 30,
                                          color: waveColor,
                                          weight: FontWeight.w500)),
                                ],
                              ),
                              textAlign: TextAlign.start,
                            ),
                            Spacer(),
                            LottieBuilder.asset(
                              "assets/heart_rate.json",
                              height:
                              MediaQuery.of(context).size.height * 0.15,
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                        endIndent: 20,
                        indent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 60,
                          right: 60,
                          top: 30,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: "${max}",
                                      style: appText(
                                          size: 23,
                                          color: heartColor,
                                          weight: FontWeight.w500)),
                                  TextSpan(
                                    text: ' SpO2',
                                    style: appText(
                                        color: waveColor,
                                        weight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                      text: '\nMAX',
                                      style: appText(
                                          size: 30,
                                          color: waveColor,
                                          weight: FontWeight.w500)),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Spacer(),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: "${min}",
                                      style: appText(
                                          size: 23,
                                          color: heartColor,
                                          weight: FontWeight.w500)),
                                  TextSpan(
                                    text: ' SpO2',
                                    style: appText(
                                        color: waveColor,
                                        weight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                      text: '\nMIN',
                                      style: appText(
                                          size: 30,
                                          color: waveColor,
                                          weight: FontWeight.w500)),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    ],
                  )))
        ]);
    // )
    //     : Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Padding(
    //         padding:
    //         const EdgeInsets.only(left: 50.0, right: 50, bottom: 20),
    //         child: LottieBuilder.asset("assets/nodata.json"),
    //       ),
    //       Text(
    //         "There is no data to show you \nright now",
    //         textAlign: TextAlign.center,
    //         style: appText(
    //             color: Colors.white,
    //             isShadow: true,
    //             weight: FontWeight.w600,
    //             size: 20),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget Chart(){
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    delay() async {
      await Future.delayed(Duration(seconds: 5));
      setState(() {
        test = "3";
      });

    }
    // delay();
    Widget text;
    switch (value.toInt()) {
      case 2:
        text =  Text("", style: style);
        break;
      case 5:
        text = const Text("", style: style);
        break;
      case 8:
        text = const Text('', style: style);
        break;
      case 11:
        text = const Text('', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 2:
        text = '20';
        break;
      case 4:
        text = '40';
        break;
      case 6:
        text = '60';
        break;
      case 8:
        text = '80';
        break;
      case 10:
        text = '100';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots:  [
            FlSpot(0, 9.5),
            FlSpot(2.6, (max/10) as double),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData:  FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData:  LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return  FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return  FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData:  FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



