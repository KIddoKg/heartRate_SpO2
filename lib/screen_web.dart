// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe, unused_import, depend_on_referenced_packages, must_be_immutable, avoid_print, unused_local_variable, unused_field, avoid_unnecessary_containers
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:breathing_collection/breathing_collection.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heart_spo2/presentation/resources/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heart_spo2/pages/background_web.dart';
import 'dart:io' as io;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataModel.dart';
import 'constants/constants.dart';

class ScreenWeb extends StatefulWidget {
  ScreenWeb({Key? key}) : super(key: key);

  @override
  State<ScreenWeb> createState() => _ScreenWebState();
}

class _ScreenWebState extends State<ScreenWeb>
    with SingleTickerProviderStateMixin {
  bool isProcessing = true;
  List<Feed> feeds = [];
  List<Model> feeds2 = [];
  String Rate = "";
  int min = 0;
  int count = 0;

  int max = 0;
  int minSpO2 = 0;
  int maxSpO2 = 0;
  int avg = 0;
  double revert = 0;
  double currentValue = 0;
  double currentValue1 = 0;
  double currentValue2 = 0;
  double currentValue3 = 0;
  double currentValue4 = 0;
  String TextSpO2 = "Your blood oxygen levels are low !!!";
  bool BoolSpO2 = false;

  final AudioCache audioCache = AudioCache();
  Future<void> playDialogSound() async {
    final player = AudioPlayer();

    await player.play(AssetSource('sound.mp3'));
  }

  @override
  void initState() {
    super.initState();
    // fetchData();
    Timer.periodic(Duration(seconds: 10), (timer) {
      fetchData();
      fetchData2();
      CheckDie();
    });
  }

  Future<void> fetchData2() async {
    var url2 = Uri.parse(
        'https://api.thingspeak.com/channels/2160201/feeds.json?api_key=9I0V89SSEQZTLHBZ');

    final response2 = await http.get(url2);

    if (response2.statusCode == 200) {
      final data = json.decode(response2.body);
      List<dynamic> modelData = data['feeds'];
      setState(() {
        feeds2 =
            modelData.map((modelJson) => Model.fromJson(modelJson)).toList();
      });
    }
  }

  Future<void> sendDataToAPI(Map<String, dynamic> data) async {
    https: //api.thingspeak.com/update?api_key=7W4XCY095VFWWG45&field1=0
    String apiUrl = 'https://api.thingspeak.com/update';
    String apiKey = '2R054P0VU6789LGL';
    String apiKey2 = '7W4XCY095VFWWG45';

    int fieldValue1 = data['age']; // Giá trị mới cho trường field1
    int fieldValue2 = data['sex'];
    int fieldValue3 = data['cp'];
    int fieldValue4 = data['trestbps'];
    int fieldValue5 = data['chol'];
    int fieldValue6 = data['fbs'];
    int fieldValue7 = data['restecg'];
    int fieldValue8 = data['exang'];
    int fieldValue9 = data['oldpeak'];
    int fieldValue10 = data['slope'];
    int fieldValue11 = data['ca'];
    int fieldValue12 = data['thal'];
    Random random = Random();
    int randomNumber = random.nextInt(21) + 50;
    int randomNumber2 = random.nextInt(10) + 90;
    String url =
        '$apiUrl?api_key=$apiKey&field1=$fieldValue6&field2=$fieldValue7&field3=$fieldValue8&field4=$fieldValue9&field5=$fieldValue10&field6=$fieldValue11&field7=$fieldValue12';

    String url2 =
        '$apiUrl?api_key=$apiKey2&field1=$randomNumber&field2=$randomNumber2&field3=$fieldValue1&field4=$fieldValue2&field5=$fieldValue3&field6=$fieldValue4&field7=$fieldValue5';
    final response = await http.get(Uri.parse(url));
    final response2 = await http.get(Uri.parse(url2));

    if (response.statusCode == 200) {
      // Cập nhật dữ liệu thành công
      print('Dữ liệu đã được cập nhật thành công');
    } else {
      // Lỗi trong quá trình cập nhật dữ liệu
      print('Lỗi: ${response.statusCode}');
    }
    if (response2.statusCode == 200) {
      // Cập nhật dữ liệu thành công
      print('Dữ liệu đã được cập nhật thành công');
    } else {
      // Lỗi trong quá trình cập nhật dữ liệu
      print('Lỗi: ${response2.statusCode}');
    }
  }

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
      CheckLastID(feeds);
      fakeDataSpO2(feeds);
      fakeData(feeds);
      AvgSpO2();
      convertDouble();
      measurePage();
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setInt('myDataKey', feeds[feeds.length-1].entryId);
    }
  }

  Future<void> CheckDie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int data = prefs.getInt('myDataDie') ?? 0;
    int entryId = 0;
    bool alert = false;
    if (feeds2.length > 1) {
      entryId = feeds2[feeds2.length - 1].entryId;

      if (entryId > data) {
        for (int i = data + 1; i < feeds2[feeds2.length - 1].entryId; i++) {
          String text = "1";

          if (feeds2[i].field1 == text) {
            print("bệnh nà");
            alert = true;
            await prefs.setInt('myDataDie', feeds2[feeds2.length - 1].entryId);
          }
        }
        if(alert == true && isProcessing == false){
          showDieLog();
          alert = false;
        }
      }
    }
  }

  void showDieLog() {
    playDialogSound();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textEditingController = TextEditingController();

        return AlertDialog(
          title: Text('You are at risk of cardiovascular disease'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fakeDataSpO2(List<Feed> feeds) async {
    if (feeds.length > 0) {
      minSpO2 = int.parse(feeds[0].field2!);
      maxSpO2 = int.parse(feeds[0].field2!);

      for (int i = 0; i < feeds.length; i++) {
        int currentValue = int.parse(feeds[i].field2!);
        if (currentValue < minSpO2) {
          minSpO2 = currentValue;
        }
        if (currentValue > maxSpO2) {
          maxSpO2 = currentValue;
        }
      }

      // print('Giá trị SpO2 nhỏ nhất: $minSpO2');
      // print('Giá trị SpO2 lớn nhất: $maxSpO2');
    } else {
      print('Danh sách rỗng ${feeds.length}');
    }
  }

  Future<void> fakeData(List<Feed> feeds) async {
    if (feeds.length > 1) {
      int tests = feeds.length;
      int index = 0;
      min = int.parse(feeds[0].field1);
      max = int.parse(feeds[0].field1);

      for (int i = 0; i < tests; i++) {
        int currentValue = int.parse(feeds[i].field1);
        if (currentValue < min) {
          min = currentValue;
        }
        if (currentValue > max) {
          max = currentValue;
        }
      }

      if (index < tests) {
        int randomInt = Random().nextInt(1);
        if (randomInt == 0) {
          Rate = feeds[feeds.length - 1].field1;
        } else {
          Rate = feeds[feeds.length].field1;
        }
      }
    }
  }

  Future<void> CheckLastID(List<Feed> feeds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? data = prefs.getInt('myDataKey');
    int entryId = 0;

    if (feeds.length > 1) {
      entryId = feeds[feeds.length - 1].entryId;

      if (entryId == data) {
        count++;
        print(count);
        if (count >= 2) {
          String text = "chưa do";
          print(text);
          isProcessing = true;
        }
      } else {
        count = 0;
        isProcessing = false;
        await prefs.setInt('myDataKey', feeds[feeds.length - 1].entryId);
        print(feeds[feeds.length - 1].entryId);
      }
    }
  }

  void AvgSpO2() {
    int currentValue = 0;
    if (feeds.length > 0) {
      // min = int.parse(feeds[0].field2!);
      // max = int.parse(feeds[0].field2!);

      for (int i = 0; i < feeds.length; i++) {
        if (feeds[i].field2 != null) {
          currentValue = currentValue + int.parse(feeds[i].field2!);
        }
      }

      revert = (currentValue / feeds.length) % 10;
      avg = ((currentValue / feeds.length)).toInt();
      // print('Giá trị trung bình: ${avg}');
      if(avg < 95 && isProcessing == false){
        BoolSpO2 = true;
        playDialogSound();
      }
    } else {
      print('Danh sách rỗng ${feeds.length}');
    }
  }

  void convertDouble() {
    // double convertedValues = [];

    if (feeds.length > 0) {
      currentValue = double.parse(feeds[0].field2 ?? '0') % 10;
      currentValue1 = double.parse(feeds[1].field2 ?? '0') % 10;
      currentValue2 = double.parse(feeds[2].field2 ?? '0') % 10;
      currentValue3 = double.parse(feeds[3].field2 ?? '0') % 10;
      currentValue4 = double.parse(feeds[4].field2 ?? '0') % 10;
    } else {
      print('Danh sách rỗng ${feeds.length}');
    }
    print('Danh sách rỗng1 ${currentValue3}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: measurePage(),
    );
  }

  Widget measurePage() {
    return Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  showInformationDialog(context);
                },
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 50, // Adjust width as desired
                    height: 50,
                    child: DemoCircleWave(
                      count: 200,
                      isProcessing: false,
                    ),
                  ),
                  !isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              Rate,
                              style: appText(
                                  color: Colors.black,
                                  isShadow: true,
                                  size: isProcessing ? 20 : 40,
                                  weight: FontWeight.w600),
                            ),
                            Text(
                              isProcessing ? "" : "BPM",
                              style: appText(
                                  color: waveColor,
                                  isShadow: true,
                                  weight: FontWeight.w600),
                            )
                          ],
                        )
                      : Transform.rotate(
                          angle: -0.3,
                          child: LottieBuilder.asset(
                            "assets/heart_bubble.json",
                          )),
                ])),
            Spacer(),
            isProcessing
                ? SizedBox(
                    height: 70,
                    width: 60,
                    child: ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1,
                      ),
                    ),
                  )
                : Text(
                    "Measuring....",
                    style: appText(
                        color: Colors.black,
                        isShadow: true,
                        size: 20,
                        weight: FontWeight.w600),
                  ),
            isProcessing
                ? Container()
                : BoolSpO2
                    ? Text(
                        TextSpO2,
                        style: appText(
                            color: Colors.red,
                            isShadow: true,
                            size: 14,
                            weight: FontWeight.w600),
                      )
                    : Container(),
            SizedBox(
              height: 10,
            ),
            isProcessing
                ? Center(
                    child: Text(
                      "Unmeasured data",
                      style: appText(
                          color: Colors.black,
                          isShadow: true,
                          size: 14,
                          weight: FontWeight.w600),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Stack(children: <Widget>[
                  // Lottie.asset(
                  // 'assets/blue-waves.json',
                  //   height: 300,
                  //   fit: BoxFit.contain,
                  // ),
                  // Card(
                  //   margin: EdgeInsets.only(top: 50, left: 10, right: 10),
                  //   elevation: 4.0,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(2),
                  //   ),
                  //   color: scaffoldColor,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(5.0),
                  //     child: SizedBox(
                  //       width: MediaQuery.of(context).size.width,
                  //       child:Chart(),
                  //     ),
                  //   ),
                  // ),
                  isProcessing
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                                "Please put your finger in the meter to measure"),
                          ),
                        )
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        text: ' BPM',
                                        style: appText(
                                            color: waveColor,
                                            weight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                          text: '\nMAX',
                                          style: appText(
                                              color: Colors.white,
                                              weight: FontWeight.w500)),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                                        text: ' BPM',
                                        style: appText(
                                            color: waveColor,
                                            weight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                          text: '\nMIN',
                                          style: appText(
                                              color: Colors.white,
                                              weight: FontWeight.w500)),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                ]),
              ),
            )
          ],
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Column(children: <Widget>[
                  // !isProcessing ?
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.55, // Adjust width as desired
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Card(
                      // margin: EdgeInsets.only(top: 50, left: 10, right: 10),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: scaffoldColor,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          // width: MediaQuery.of(context).size.width,
                          child: Chart(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                      width: MediaQuery.of(context).size.width *
                          0.55, // Adjust width as desired
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: !isProcessing
                          ? Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: scaffoldColor,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "${maxSpO2}",
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
                                                  text: "${minSpO2}",
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
                              ))
                          : Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: scaffoldColor,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "0",
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "0",
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
                                                  text: "0",
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
                              ))),
                ]),
              ),
            )
          ],
        ),
      ]),
    );
  }

  void showInformationDialog(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController ageController = TextEditingController();
        TextEditingController sexController = TextEditingController();
        TextEditingController cpController = TextEditingController();
        TextEditingController trestbpsController = TextEditingController();
        TextEditingController cholController = TextEditingController();
        TextEditingController fbsController = TextEditingController();
        TextEditingController restecgController = TextEditingController();
        TextEditingController exangController = TextEditingController();
        TextEditingController oldpeakController = TextEditingController();
        TextEditingController slopeController = TextEditingController();
        TextEditingController caController = TextEditingController();
        TextEditingController thalController = TextEditingController();

        return AlertDialog(
          title: Text('Enter Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: ageController,
                        decoration: InputDecoration(labelText: 'Age'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: sexController,
                        decoration: InputDecoration(labelText: 'Sex'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: cpController,
                        decoration: InputDecoration(labelText: 'Cp'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: trestbpsController,
                        decoration: InputDecoration(labelText: 'Trestbps'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: cholController,
                        decoration: InputDecoration(labelText: 'chol'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: fbsController,
                        decoration: InputDecoration(labelText: 'fbs'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: restecgController,
                        decoration: InputDecoration(labelText: 'restecg'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: exangController,
                        decoration: InputDecoration(labelText: 'exang'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: oldpeakController,
                        decoration: InputDecoration(labelText: 'oldpeak'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: slopeController,
                        decoration: InputDecoration(labelText: 'slope'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: caController,
                        decoration: InputDecoration(labelText: 'ca'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: thalController,
                        decoration: InputDecoration(labelText: 'thal'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                int age = int.tryParse(ageController.text) ?? 0;
                int sex = int.tryParse(sexController.text) ?? 0;
                int cp = int.tryParse(cpController.text) ?? 0;
                int trestbps = int.tryParse(trestbpsController.text) ?? 0;
                int chol = int.tryParse(cholController.text) ?? 0;
                int fbs = int.tryParse(fbsController.text) ?? 0;
                int restecg = int.tryParse(restecgController.text) ?? 0;
                int exang = int.tryParse(exangController.text) ?? 0;
                int oldpeak = int.tryParse(oldpeakController.text) ?? 0;
                int slope = int.tryParse(slopeController.text) ?? 0;
                int ca = int.tryParse(caController.text) ?? 0;
                int thal = int.tryParse(thalController.text) ?? 0;

                Map<String, dynamic> data = {
                  'age': age,
                  'sex': sex,
                  'cp': cp,
                  'trestbps': trestbps,
                  'chol': chol,
                  'fbs': fbs,
                  'restecg': restecg,
                  'exang': exang,
                  'oldpeak': oldpeak,
                  'slope': slope,
                  'ca': ca,
                  'thal': thal,
                  // Add other fields to the map
                };

                // Send data to the API
                sendDataToAPI(data);
                // Process the entered data here

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  String test = "Mar";
  bool showAvg = false;

  Widget Chart() {
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
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
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
        text = Text("", style: style);
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
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '90';
        break;
      case 5:
        text = '95';
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
      lineTouchData: LineTouchData(enabled: false),
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
      maxX: 4,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: [
            !isProcessing ? FlSpot(0, currentValue) : FlSpot(0, 0),
            !isProcessing ? FlSpot(1, currentValue1) : FlSpot(1, 0),
            !isProcessing ? FlSpot(2, currentValue2) : FlSpot(2, 0),
            !isProcessing ? FlSpot(3, currentValue3) : FlSpot(3, 0),
            !isProcessing ? FlSpot(4, currentValue4) : FlSpot(4, 0),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
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
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
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
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 4,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: [
            !isProcessing ? FlSpot(0, revert) : FlSpot(0, 0),
            !isProcessing ? FlSpot(1, revert) : FlSpot(1, 0),
            !isProcessing ? FlSpot(2, revert) : FlSpot(2, 0),
            !isProcessing ? FlSpot(3, revert) : FlSpot(3, 0),
            !isProcessing ? FlSpot(4, revert) : FlSpot(4, 0),
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
          dotData: FlDotData(
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
