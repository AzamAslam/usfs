import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:json_to_form_with_theme/json_to_form_with_theme.dart';
import 'package:json_to_form_with_theme/parsers/widget_parser.dart';
import 'package:json_to_form_with_theme/themes/json_form_theme.dart';
import 'package:webviewjavascript/main.dart';
import 'dart:io';

import '../widget_parse.dart';

class JsonThree extends StatefulWidget {
  JsonThree({Key key,  this.json}) : super(key: key) {}

  final  json;


  @override
  State<JsonThree> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<JsonThree> {
  TextEditingController longController=TextEditingController();
  TextEditingController latController=TextEditingController();
  TextEditingController imController=TextEditingController();
  Stream<Map<String, dynamic>> onValueChangeStream;
  final StreamController<Map<String, dynamic>> _onUserController = StreamController<Map<String, dynamic>>();

  Map<String, WidgetParser> dynamics = {};

  getLAT()async{
    latController.text=latt;
    longController.text=longg;

    setState(() {

    });
  }

  @override
  void initState() {
    getLAT();
    super.initState();
    onValueChangeStream = _onUserController.stream.asBroadcastStream();
  }

  String buildDate(DateTime dateTime) {
    final now = DateTime.now();
    int diff = now.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch;

    if (diff < dayInMilliseconds) {
      return build24String(diff);
    } else if (diff >= dayInMilliseconds && diff < monthInMilliseconds) {
      return buildDaysString(diff);
    } else if (diff >= monthInMilliseconds && diff < yearInMilliseconds) {
      return buildMonthString(dateTime);
    }
    return dateTime.year.toString();
  }

  String buildDaysString(int diff) {
    int days = diff ~/ dayInMilliseconds;
    return "${days}d";
  }

  String buildMonthString(DateTime dateTime) {
    return DateFormat.MMMd().format(dateTime);
  }

  int yearInMilliseconds = 31556952000;
  int monthInMilliseconds = 2629800000;
  int weekInMilliseconds = 604800000;
  int dayInMilliseconds = 86400000;
  int hourInMilliseconds = 3600000;
  int minuteInMilliseconds = 60000;

  String build24String(int diff) {
    int hours = diff ~/ hourInMilliseconds;
    int minutes = (diff - (hours * hourInMilliseconds)) ~/ minuteInMilliseconds;
    return "${hours}h ${minutes}m";
  }

  Widget dateBuilder(int date, String id) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    return Text(buildDate(dateTime));
  }

  List<String> list = ["Medium", "High"];
  List<String> toggleList = ["On", "Off"];

  int counter = 0;
  int toggle = 1;

  bool changeToGoodBad = true;

  Future<dynamic> _refresh() {
    //"chosen_value": "Low-Intermediate"
    if (changeToGoodBad) {
      toggleList = ['Good', "Bad"];
      widget.json['widgets'][1]['values'] = toggleList;
      widget.json['widgets'][1]['chosen_value'] = "Bad";
      widget.json['widgets'][6]['chosen_value'] = "goodReally";
      widget.json['widgets'][8]['chosen_value'] = "Medium";
    } else {
      toggleList = ["On", "Off"];
      widget.json['widgets'][1]['chosen_value'] = "On";
      widget.json['widgets'][1]['values'] = toggleList;
      widget.json['widgets'][6]['chosen_value'] = "bad";
      widget.json['widgets'][8]['chosen_value'] = "High";
    }

    changeToGoodBad = !changeToGoodBad;
    setState(() {});
    return Future.delayed(const Duration(seconds: 0));
  }

  @override
  Widget build(BuildContext context) {

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Sample 3 With Theme'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: longController,
                  decoration: InputDecoration(
                    hintText: 'Long',
                    hintStyle:TextStyle(color: Colors.white) ,

                    prefixIcon: Icon(Icons.location_on_outlined),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    enabledBorder:  OutlineInputBorder(
                      borderRadius:BorderRadius.circular(32.0) ,
                      borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                    ),                  ),

                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: latController,
                  decoration: InputDecoration(
                    hintText: 'Latitude',
                    hintStyle:TextStyle(color: Colors.white) ,

                    prefixIcon: Icon(Icons.location_on_outlined),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    enabledBorder:  OutlineInputBorder(
                      borderRadius:BorderRadius.circular(32.0) ,
                      borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                    ),                  ),

                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(

                  child:TextField(
                    style: TextStyle(color: Colors.white),
                    controller: imController,
                    decoration: InputDecoration(

                      hintText: 'BAse64',
                      hintStyle:TextStyle(color: Colors.white) ,
                      prefixIcon: Icon(Icons.location_on_outlined),
                      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      enabledBorder:  OutlineInputBorder(
                        borderRadius:BorderRadius.circular(32.0) ,
                        borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                      ),
                      //border: OutlineInputBorder(borderSide: BorderSide(width: 2.0,color: Colors.white),borderRadius: BorderRadius.circular(32.0)),
                    ),

                  ),




                ),
                SizedBox(
                  height: 10.0,
                ),
                InkWell(
                    onTap: (){
                      _openCamera(context);
                    },
                    child: Container(
                      color: Colors.white,
                        height: 30.0,
                        width: 130.0,
                        child: Row(
                          children: [
                            Text("Upload Image"),
                            Icon(Icons.upload_sharp),
                          ],
                        ))),
                SizedBox(
                  height: 20.0,
                ),

                Container(
                  height: MediaQuery.of(context).size.height*0.8,
                  width:MediaQuery.of(context).size.width ,
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: JsonFormWithTheme(
                        jsonWidgets: widget.json,
                        dateBuilder: dateBuilder,
                        dynamicFactory: MyWidgetParserFactory(),
                        streamUpdates: onValueChangeStream,
                        onValueChanged: (String d, dynamic s) async {
                          print("Update id $d to value $s");
                          await Future.delayed(const Duration(seconds: 1));
                          return Future.value(true);
                        },
                        theme: const DefaultTheme(
                          linePaDecoration: BoxDecoration(
                              color: Colors.black
                          ) ,
                          linePaDecorationAboveHeader: BoxDecoration(
                              color: Colors.black
                          ) ,
                          nameContainerDecoration:BoxDecoration(
                              color: Colors.black
                          )  ,
                          staticTextStyle: TextStyle(color: Colors.white),
                          staticContainerDecoration:BoxDecoration(
                              color: Colors.black
                          ) ,

                          headerContainerDecoration: BoxDecoration(
                            color: Colors.white
                          )

                        )),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {

              print( currentLocationStored);
              longController.text=longg;
              latController.text=latt;
              setState(() {

              });
              //locationController=currentLocationStored;
              //   print(response['fields'][4]);


              setState(() {

              });


            },
            child: const Icon(Icons.navigation),
            backgroundColor: Colors.green,
          ),
        );

  }
  void _openCamera(BuildContext context)  async{
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    List<int> imageBytes = File(pickedFile.path).readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    print('here is base 64 image');
    print(base64Image);
    // imController.text=base64Image;
    var trimmed = base64Image.substring(0, min(base64Image.length,20));
    print(trimmed);
    setState(() {
      imController.text=trimmed;
      // imageFile = pickedFile!;
    });

    // Navigator.pop(context);
  }


}