import 'dart:convert';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/material.dart';
import 'package:webviewjavascript/Screens/json_3_form.dart';
import 'package:webviewjavascript/Screens/json_viewer.dart';
import 'package:webviewjavascript/local_assets_server.dart';
import 'package:webviewjavascript/main.dart';
import 'package:webviewjavascript/sample_2_json.dart';
import 'package:webviewjavascript/spatialLite_json.dart';

import '../json_to_form.dart';
List<SelectedListItem> _listOfForests=[];
List<SelectedListItem> _listOfRegions=[];

List<SelectedListItem> _listOfStates=[];
List<SelectedListItem> _listOfDistrict=[];
List<dynamic> items = [];


class JsonFiles extends StatefulWidget {

  @override
  _JsonFilesState createState() => _JsonFilesState();
}

class _JsonFilesState extends State<JsonFiles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample jsons"),
      ),
      body: Column(
        children: [
          ListTile(


            trailing: IconButton(
              onPressed: ()async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                        child:  Container(
                          height: 80.0,

                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  [
                                new CircularProgressIndicator(),
                                new Text("Generating Form from JSON..."),
                              ]
                          ),
                        )
                    );
                  },
                );
                new Future.delayed(new Duration(seconds: 2), () async{
                  Navigator.pop(context); //pop dialog
                  String data = await DefaultAssetBundle.of(context).loadString("assets/simple_form.json");
                  var j = data.toString();
                  print("This is json $j");

                  setState(() {

                  });
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>Register(form:j))
                  // );

                });

              },
              icon: Icon(Icons.arrow_forward_ios_rounded),
            ),
            leading: InkWell(onTap:()async{
              String data = await DefaultAssetBundle.of(context).loadString(
                  "assets/simple_form.json");

              final jsonResult = jsonDecode(data);
              print(jsonResult);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>JSonViewr(json:jsonResult['fields']))
              );
            },child: Icon(Icons.remove_red_eye)),
            title: Text("Sample 1"),
          ),
          ListTile(
            trailing: IconButton(
              onPressed: ()async{
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                        child:  Container(
                          height: 80.0,

                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  [
                                new CircularProgressIndicator(),
                                new Text("Loading JSON..."),
                              ]
                          ),
                        )
                    );
                  },
                );
                new Future.delayed(new Duration(seconds: 2), () async {
                   Navigator.pop(context); //pop dialog
                  //
                  //
                  String data = await DefaultAssetBundle.of(context).loadString(
                      "assets/json_file_two.json");

                 final jsonResult = jsonDecode(data);
                  var  sampleData =jsonResult;
                  print(sampleData);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>SampleTwo(form:sampleData))
                  );

                  // print(jsonResult[0]['NAME']);
                  //
                  //
                  // jsonResult.forEach((s) => items.add({
                  //   'name': s['NAME'],
                  //   'lat': s['yCentroid'],
                  //   'long': s['xCentroid']
                  // }));
                  // print("This is items $items");
                  //
                  //
                  //

                  //
                  // // print("This is items $items");
                  //
                  // // for(int i=0; i<=items.length;i++){
                  // //   _listOfCities.add( SelectedListItem(false, items[i],));
                  // // }
                  // Navigator.of(context).pop();
                });


              },
              icon: Icon(Icons.arrow_forward_ios_rounded),
            ),
            leading: InkWell(
                onTap: ()async{
                  String data = await DefaultAssetBundle.of(context).loadString(
                      "assets/json_file_two.json");

                  final jsonResult = jsonDecode(data);
                  print(jsonResult);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>JSonViewr(json:jsonResult['data']))
                  );
                },
                child: Icon(Icons.remove_red_eye)),
            title: Text("Sample 2"),
          ),
          ListTile(
            trailing: IconButton(
              onPressed: ()async{
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                        child:  Container(
                          height: 80.0,

                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  [
                                new CircularProgressIndicator(),
                                new Text("Loading JSON..."),
                              ]
                          ),
                        )
                    );
                  },
                );
                new Future.delayed(new Duration(seconds: 2), () async {
                  Navigator.pop(context); //pop dialog
                  //
                  //
                  String data = await DefaultAssetBundle.of(context).loadString(
                      "assets/sample_3.json");

                  final jsonResult = jsonDecode(data);
                  var  sampleData =jsonResult;
                  print(sampleData);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>JsonThree(json:sampleData))
                  );

                  // print(jsonResult[0]['NAME']);
                  //
                  //
                  // jsonResult.forEach((s) => items.add({
                  //   'name': s['NAME'],
                  //   'lat': s['yCentroid'],
                  //   'long': s['xCentroid']
                  // }));
                  // print("This is items $items");
                  //
                  //
                  //

                  //
                  // // print("This is items $items");
                  //
                  // // for(int i=0; i<=items.length;i++){
                  // //   _listOfCities.add( SelectedListItem(false, items[i],));
                  // // }
                  // Navigator.of(context).pop();
                });


              },
              icon: Icon(Icons.arrow_forward_ios_rounded),
            ),
            leading: InkWell(
                onTap: ()async{
                  String data = await DefaultAssetBundle.of(context).loadString(
                      "assets/sample_3.json");

                  final jsonResult = jsonDecode(data);
                  print(jsonResult);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>JSonViewr(json:jsonResult['widgets']))
                  );
                },
                child: Icon(Icons.remove_red_eye)),
            title: Text("Sample 3"),
          ),
        ],
      ),
    );
  }
}
