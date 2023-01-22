import 'dart:convert';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/material.dart';
import 'package:webviewjavascript/local_assets_server.dart';
import 'package:webviewjavascript/main.dart';
import 'package:webviewjavascript/spatialLite_json.dart';
import 'panelwidget.dart';
List<SelectedListItem> _listOfForests=[];
List<SelectedListItem> _listOfRegions=[];

List<SelectedListItem> _listOfStates=[];
List<SelectedListItem> _listOfDistrict=[];
List<dynamic> items = [];


class ListFiles extends StatefulWidget {

  @override
  _ListFilesState createState() => _ListFilesState();
}

class _ListFilesState extends State<ListFiles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SpatialLite Files"),
      ),
      body: Column(
        children: [
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


                  String data = await DefaultAssetBundle.of(context).loadString(
                      "assets/Spatialbookmark.json");
                  final jsonResult = jsonDecode(data);
                  print(jsonResult[0]['NAME']);


                    jsonResult.forEach((s) => items.add({
                      'name': s['NAME'],
                      'lat': s['yCentroid'],
                      'long': s['xCentroid']
                    }));
                    print("This is items $items");




                    // print("This is items $items");

                    // for(int i=0; i<=items.length;i++){
                    //   _listOfCities.add( SelectedListItem(false, items[i],));
                    // }
               Navigator.of(context).pop();
                });


              },
              icon: Icon(Icons.arrow_forward_ios_rounded),
            ),
            leading: Icon(Icons.description),
            title: Text("SpatialLite JSON"),
          ),
        ],
      ),
    );
  }
}
