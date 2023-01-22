import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_table/json_table.dart';
import 'dart:io';

class LocalTable extends StatefulWidget {
  @override
  _LocalTableState createState() => _LocalTableState();
}

class _LocalTableState extends State<LocalTable> {
  List jsonSample;
var pt;
  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(70.0),

        child: Center(
          child:ElevatedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Add GeoJson"),
                Icon(Icons.upload_sharp),
              ],
            ),
            onPressed: ()async{
              FilePickerResult result = await FilePicker.platform.pickFiles();
              String fileName = result.files.single.path;
             // pt=fileName;
              print(fileName);
              File jsonFile = await File("$fileName");
             // var jsonData = json.decode(jsonFile.readAsStringSync());
             // print(jsonData);
              Map<String, dynamic> map = json.decode(jsonFile.readAsStringSync());
        List<dynamic> data = map["features"];
            //  final list = jsonData.values.toList();

//print("THis is list $list");
              setState(() {

              });
              //pt=jsonData.toString();

              print(pt);
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>JsonFile(path: data,)));

            },
          ),
        )
      ),
    );
  }

  String getPrettyJSONString(jsonObject) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(json.decode(jsonObject));
    return jsonString;
  }

  void _initData() async {
    // try {
    //   final jsonString = await rootBundle.loadString('assets/countries.json');
    //   if (mounted)
    //     setState(() {
    //       jsonSample = jsonDecode(jsonString) as List;
    //     });
    // } catch (e) {
    //   print(e);
    // }
  }
}
class JsonFile extends StatefulWidget {
final path;

  const JsonFile({Key key, this.path}) : super(key: key);

  @override
  _JsonFileState createState() => _JsonFileState();
}

class _JsonFileState extends State<JsonFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          JsonTable(
            widget.path,
            showColumnToggle: true,
            allowRowHighlight: true,
            rowHighlightColor: Colors.yellow[500].withOpacity(0.7),
            paginationRowCount: 20,
            onRowSelect: (index, map) {
              print(index);
              print(map);
            },
          ),
          SizedBox(
            height: 40.0,
          ),

        ],
      ) ,
    );
  }
}
// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:json_table/json_table.dart';
// //
// // class LocalTable extends StatefulWidget {
// //   @override
// //   _LocalTableState createState() => _LocalTableState();
// // }
// //
// // class _LocalTableState extends State<LocalTable> {
// //   List jsonSample;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initData();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         padding: EdgeInsets.all(16.0),
// //         child: Container(
// //           child: jsonSample == null
// //               ? Center(
// //             child: CircularProgressIndicator(),
// //           )
// //               : Column(
// //             children: [
// //               JsonTable(
// //                 jsonSample,
// //                 showColumnToggle: true,
// //                 allowRowHighlight: true,
// //                 rowHighlightColor: Colors.yellow[500].withOpacity(0.7),
// //                 paginationRowCount: 20,
// //                 onRowSelect: (index, map) {
// //                   print(index);
// //                   print(map);
// //                 },
// //               ),
// //               SizedBox(
// //                 height: 40.0,
// //               ),
// //               Text(
// //                   "Simple table which creates table from local json file")
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   String getPrettyJSONString(jsonObject) {
// //     JsonEncoder encoder = new JsonEncoder.withIndent('  ');
// //     String jsonString = encoder.convert(json.decode(jsonObject));
// //     return jsonString;
// //   }
// //
// //   void _initData() async {
// //     try {
// //       final jsonString = await rootBundle.loadString('assets/countries.json');
// //       if (mounted)
// //
// //         setState(() {
// //           Map<String, dynamic> map = json.decode(jsonString);
// //           List<dynamic> data = map["features"];
// //                         // final list = js.values.toList();
// //          // List<Map<String, dynamic>>.from(jsonDecode(jsonString));
// //          print(data);
// //          jsonSample=data;
// //         });
// //       print(jsonSample);
// //     } catch (e) {
// //       print(e);
// //     }
// //   }
// }