import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webviewjavascript/FormsData/read_file.dart';

class LocalFiles extends StatefulWidget {
  var list;

  LocalFiles({this.list});

  @override
  _LocalFilesState createState() => _LocalFilesState();
}

class _LocalFilesState extends State<LocalFiles> {

  var listFiles;

  void readFiles() async {
    var assetsFile = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(assetsFile);
    List<String> listGpkg =
    manifestMap.keys.where((String key) => key.contains('.gpkg')).toList();
    List<String> listMbtiles =
    manifestMap.keys.where((String key) => key.contains('.mbtiles')).toList();

    // final files = File(listGpkg[0]);
    // var usForestMbtiles = File(listMbtiles[0]);
    // var usForestGpkg = files;

    setState(() {
      listFiles = [
        {'dbName': listGpkg[0], 'tableName': 'forests'},
        {'dbName': listGpkg[1], 'tableName': 'recreational_opportunities'},
        {'dbName': listMbtiles[0], 'tableName': 'tiles'}];
    });
  }

  @override
  void initState() {
    readFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Local Files'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: listFiles?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      child: ListTile(
                        title: Text(listFiles[index]['dbName'].split('/').last),
                        leading: Image.asset(
                          'assets/icons/LoadCat.png',
                          height: 30,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReadFile(file: listFiles[index]['dbName'], tableName: listFiles[index]['tableName'],)
                            ),
                          );
                        },
                      ));
                }),
            SizedBox(height: MediaQuery.of(context).size.height*0.06,),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.8,
              child: Card(
                color: Colors.blueGrey,
                  child: ListTile(
                    title: Center(child: Text('Import from local storage', style: TextStyle(color: Colors.white),)),
                    onTap: () async {
                      FilePickerResult result = await FilePicker.platform.pickFiles();
                      String fileName = result.files.single.path.split('/').last;

                      if (result != null){
                        print(fileName);
                        print(result.files.single.path);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReadFile(file: result.files.single.path, tableName: fileName,)
                          ),
                        );

                      }
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}
