import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webviewjavascript/FormsData/read_file.dart';
import 'package:webviewjavascript/open_gpkg_file.dart';

class LoadGPKG extends StatefulWidget {
  var list;

  LoadGPKG({this.list});

  @override
  _LoadGPKGState createState() => _LoadGPKGState();
}

class _LoadGPKGState extends State<LoadGPKG> {

  var listFiles;



  @override
  void initState() {
   // readFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Browse Files'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
          margin: EdgeInsets.all(70.0),

          child: Center(
            child:ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Browse GPKG"),
                  Icon(Icons.upload_sharp),
                ],
              ),
              onPressed: () async{
                FilePickerResult result = await FilePicker.platform.pickFiles();
                String fileName = result.files.single.path;
// pt=fileName;
                print(fileName);
                File jsonFile = await File("$fileName");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OpenGpkg(file: fileName, tableName: "forests",)
                  ),
                );
              },
            ),
          )
      ),);
  }
}
