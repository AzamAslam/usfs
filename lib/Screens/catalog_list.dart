import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class CatalogList extends StatefulWidget {
  var list;

  CatalogList({this.list});

  @override
  _CatalogListState createState() => _CatalogListState();
}

class _CatalogListState extends State<CatalogList> {
  var files;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/catalog.json');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      print(int.parse(contents));

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  void getFiles() async {
    readCounter();


    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    print('start get files');
    // List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    print('1');
    // var root = storageInfo[0]
    //     .rootDir; //storageInfo[1] for SD card, geting the root directory
    // var fm = FileManager(root: Directory(root)); //
    // files = await fm.filesTree(
    //     excludedPaths: ["/storage/emulated/0/Android"],
    //     extensions: ["json"] //optional, to filter files, list only pdf files
    //     );
    // setState(() {
    //   files;
    // }); //update the UI
    print('end get files');
  }

  @override
  void initState() {
    getFiles(); //call getFiles() function on initial state.
    super.initState();
  }

  Future<void> deleteFile(File file) async {
    print('deleteFile entered');
    try {
      if (await file.exists()) {
        print('Yes entered');
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  @override
  Widget build(BuildContext context) {
    var displayWidth = MediaQuery.of(context).size.width;
    var displayHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Catalog Builder'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: files == null
              ? Text("Searching Files")
              : ReorderableListView.builder(
        onReorder: (int start, int current) {
      // dragging from top to bottom
      if (start < current) {
        int end = current - 1;
        var startItem = files[start];
        int i = 0;
        int local = start;
        do {
          files[local] = files[++local];
          i++;
        } while (i < end - start);
        files[end] = startItem;
      }
      // dragging from bottom to top
      else if (start > current) {
        var startItem = files[start];
        for (int i = start; i > current; i--) {
          files[i] = files[i - 1];
        }
        files[current] = startItem;
      }
      setState(() {});
    },

                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: files?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    print(files[0]);
                    final item = index.toString();
                    return Dismissible(
                        key: Key(item),
                        onDismissed: (direction) async {
                          // Remove the item from the data source.
                          deleteFile(files[index]);
                          setState(() {
                            files.removeAt(index);
                          });

                          // Then show a snackbar.
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Catalog Deleted')));
                        },
                        child: files[index]
                                .path
                                .split('/')
                                .last
                                .contains('Catalog')
                            ? Card(
                                child: ListTile(
                                title: Text(files[index].path.split('/').last),
                                leading: Image.asset(
                                  'assets/icons/LoadCat.png',
                                  height: 30,
                                ),
                                // trailing: Icon(Icons.delete, color: Colors.redAccent,),
                                onTap: () {
                                  var jsonData =
                                      files[index].readAsStringSync();
                                  print(jsonData);

                                  webController.evaluateJavascript(
                                      "loadCatalogFlutter($jsonData)");
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                              ))
                            : SizedBox());
                    //   InkWell(
                    //   onTap: () async {
                    //     String data = await DefaultAssetBundle.of(context).loadString("assets/mapbox/catalogs/"+widget.list[index]+".json");
                    //     final jsonResult = data.toString();
                    //     webController.evaluateJavascript("loadCatalogFlutter($jsonResult)");
                    //     Navigator.of(context).popUntil((route) => route.isFirst);
                    //     // print(widget.list[index]);
                    //   },
                    //   child: Container(
                    //     height: MediaQuery.of(context).size.height*0.08,
                    //     child: Card(
                    //       color: Colors.white,
                    //       child: Padding(
                    //         padding: EdgeInsets.only(left: 10 ,top: displayHeight*0.02, bottom: displayHeight*0.02),
                    //         child: Text((index+1).toString()+".\t "+widget.list[index],
                    //         style: TextStyle(
                    //           fontSize: 16
                    //         ),),
                    //       ),
                    //     ),
                    //   ),
                    // );
                  }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: displayHeight * 0.07,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: ElevatedButton(
              onPressed: () {
                launch(
                    'https://mapsdata.world/catalog_generator/#1.44/4/-18.7');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Vector2Raster()),
                // );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Add New Item', style: TextStyle(fontSize: 18)),
                ],
              ),

            ),
          ),
        )
      ]),
    );
  }
}
