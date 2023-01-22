import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'dart:convert';

class OpenLayer extends StatelessWidget {
  // const OpenLayer({Key key}) : super(key: key);

  final JavascriptRuntime jsRunTime = getJavascriptRuntime();

  TextEditingController bbox = TextEditingController();
  TextEditingController zoom = TextEditingController();
  TextEditingController style = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var displayHeight = MediaQuery.of(context).size.height;
    var displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Open Layer Tile Export'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: displayWidth*0.04, right: displayWidth*0.04),
            child: Column(
              children: [
                // Text('Enter Parameters', style: TextStyle(
                //   fontSize: 20,
                // ),),
                SizedBox(height: displayHeight*0.03,),
                Row(
                  children: [
                    Text('Enter bbox:   ', style: TextStyle(
                        fontSize: 16
                    ),),
                    Container(
                      height: displayHeight*0.07,
                      width: displayWidth*0.6,
                      child: TextFormField(
                        controller: bbox,
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9-., ]')),],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'bbox',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          hintStyle: const TextStyle(color: Colors.black),
                        ),

                      ),
                    ),

                  ],
                ),
                SizedBox(height: displayHeight*0.02,),
                Row(
                  children: [
                    Text('Enter zoom:  ', style: TextStyle(
                        fontSize: 16
                    ),),
                    Container(
                      height: displayHeight*0.07,
                      width: displayWidth*0.6,
                      child: TextFormField(
                        controller: zoom,
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Zoom',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          hintStyle: const TextStyle(color: Colors.black),
                        ),

                      ),
                    ),
                  ],
                ),
                SizedBox(height: displayHeight*0.02,),
                Row(
                  children: [
                    Text('Enter Style:    ', style: TextStyle(
                        fontSize: 16
                    ),),
                    Container(
                      height: displayHeight*0.07,
                      width: displayWidth*0.6,
                      child: TextFormField(
                        controller: style,
                        keyboardType: TextInputType.text,
                        // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Style Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          hintStyle: const TextStyle(color: Colors.black),
                        ),

                      ),
                    ),
                  ],
                ),
                SizedBox(height: displayHeight*0.04,),
                Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  width: displayWidth*0.5,
                  height: displayHeight*0.07,
                  decoration: BoxDecoration(
                    // color: Color.fromRGBO(205,201,51,1),
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(
                    //     color: Color.fromRGBO(205,201,51,1,)
                    //   // width: 5,
                    // )
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      var list = {"bbox": bbox.text,
                      "zoom": bbox.text,
                      "stylename": style.text};
                      var newJson = json.encode(list);
                      // print(newJson);
                      passJson(jsRunTime, newJson, bbox.text, zoom.text, style.text);
                      // var encodeJSONEx = json.decode(newJson);
                      // print(newJson);
                      // print(encodeJSONEx);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const Accessories()),
                      // );
                    },
                    color: Colors.blueGrey,
                    child: const Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 20,
                        color:  Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<int> passJson(JavascriptRuntime jsRunTime, jsonFile, bbox, zoom, style) async {
  String blocJs = await rootBundle.loadString('assets/mapbox/webviews/openlayers_tile_export_backgroundprocess-master/src/js/index.js');
  print(jsonFile);
  final resutl = jsRunTime.evaluate(blocJs+ '''downloadthis('$bbox', '$zoom', '$style')''');
  final jsStringResult = resutl.stringResult;
  // print(jsStringResult);
}

