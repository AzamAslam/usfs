import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webviewjavascript/sqliteDataBase/db_provider.dart';
import 'dart:io';

import '../../Screens/mbtiles_show.dart';
import '../../main.dart';
import '../../navbar.dart';

class DownloadFolderData extends StatefulWidget {
  var mbtilesNationwideList ;
  DownloadFolderData({Key key, this.mbtilesNationwideList}) : super(key: key);

  @override
  _DownloadFolderDataState createState() => _DownloadFolderDataState();
}

class _DownloadFolderDataState extends State<DownloadFolderData> {

  static const platform = MethodChannel('samples.flutter.dev/battery');

  var downloadingStatus = false;
  @override
  void dispose(){
    if(downloadingStatus == true){
      Fluttertoast.showToast(msg: 'Downloading cancelled because you cancel the screen');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayHeight = MediaQuery.of(context).size.height;
    final displayWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Pre Staged Folder Data'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
              itemCount: widget.mbtilesNationwideList.length,
            itemBuilder: (BuildContext context,int index){
              return InkWell(
                onTap: (){},
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.folder),
                    trailing: InkWell(
                        onTap: () async {
                          if(widget.mbtilesNationwideList[index]['icon'] == '0xe1f6'){

                            if(widget.mbtilesNationwideList[index]['name'].contains('gpkg')){
                              print('yes this is gpkg');
                              // return;

                              var urlJson = '';

                              if (widget.mbtilesNationwideList[index]['path'] != null) {
                                print('if entered');

                                try {
                                  var invokeResult;
                                  invokeResult = await platform.invokeMethod(
                                      'addGpkg', {
                                    "path": widget.mbtilesNationwideList[index]['path'],
                                    'name': '',
                                    "key": 'gpkg${layerList.length}'
                                  });
                                  print('here is json');
                                  print(jsonDecode(invokeResult));

                                  String fileName = widget.mbtilesNationwideList[index]['path'].split('/').last;
                                  var tableName = fileName.split('.');
                                  var obj = jsonDecode(invokeResult);

                                  var info = obj['info'];
                                  print(info);

                                  layerList.add({
                                    'key': 'gpkg${layerList.length}',
                                    'fileName': fileName,
                                    'type': 'gpkg',
                                    'table': []
                                  });

                                  int indexValue = 0;
                                  print('before starting');
                                  info.forEach((table, content) {
                                    print('loop in');
                                    if (table != 'ogr_empty_table') {
                                      if (content['data_type'] == 'tiles') {
                                        var url =
                                            'http://localhost:${obj['port']}/3/${obj['key']}@${content['table_name']}/{z}/{x}/{y}.png';
                                        print('url here');
                                        print(url);
                                        var extent =
                                        obj['detail'][indexValue]['bounds'];
                                        print('check lat here');

                                        print(extent);

                                        print('hahhahah');

                                        layerList[layerList.length - 1]['table'].add({
                                          'name': '${content['table_name']}',
                                          'url': url,
                                          'extent': extent,
                                          'identifier': '${content['identifier']}',
                                          'description': '${content['description']}',
                                          'icon': Icons.visibility_off_outlined
                                        });
                                        indexValue++;
                                        print('indexValue here');
                                        print(indexValue);
                                      }
                                    }
                                    print('${table}: ${content}');
                                  });
                                  print('layer list here');
                                  print(layerList);

                                  print("check");
                                  print("check url json");
                                  print(urlJson);
                                  print("check url json");

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MbtilesShow(
                                            mbtilesLayerList: layerList,
                                          )));
                                } on PlatformException catch (e) {
                                  print('function entered3');
                                  print(e);
                                }
                              }
                            }
                            else{
                              var urlJson = '';
                              String fileName = widget.mbtilesNationwideList[index]['path'].split('/').last;
                              print('path here');
                              print(widget.mbtilesNationwideList[index]['path']);

                              if (widget.mbtilesNationwideList[index]['path'] != null) {
                                print('if entered');
                                try {
                                  print('if entered2');
                                  var invokeResult;
                                  if (Platform.isAndroid) {
                                    invokeResult = await platform.invokeMethod(
                                        'addTiles', {
                                      "path": widget.mbtilesNationwideList[index]['path'],
                                      "fileName": fileName,
                                      "key": 'mbtiles${layerList.length}'
                                    });
                                    print('here is json');
                                    print(jsonDecode(invokeResult));
                                  }

                                  var tableName = fileName.split('.');
                                  var obj = jsonDecode(invokeResult);

                                  var list = [];
                                  //for vector only
                                  if (obj['format'] == 'pbf') {
                                    try {
                                      var decodeResult =
                                      jsonDecode(obj['allInfo']['json']);
                                      for (int i = 0;
                                      i < decodeResult['vector_layers'].length;
                                      i++) {
                                        list.add(
                                            decodeResult['vector_layers'][i]['id']);
                                      }
                                    } on Exception catch (exception) {
                                    } catch (error) {}
                                  }

                                  String layerIds = list.join(',');
                                  String key = obj['key'];
                                  String center = obj['center'];
                                  int maxZoom = obj['maxZoom'];
                                  String type = obj['format'];

                                  var url =
                                      'http://localhost:${obj['port']}/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/{z}/{x}/{y}.${obj['format']}';
                                  urlJson =
                                  'http://localhost:${obj['port']}/getTilesJson-layer/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/${obj['format']}';

                                  print(layerIds);
                                  print(key);
                                  print(center);
                                  print(maxZoom);
                                  print(type);
                                  print(url);

                                  var centerMap = center.split(',');

                                  print("check");

                                  if (obj['format'] == 'pbf') {
                                    print("check url json");
                                    print(urlJson);
                                    webController.evaluateJavascript(
                                        "addVectorLayerOnMap('$urlJson')");
                                    webController.evaluateJavascript(
                                        "zoomToXy(${centerMap[1]}, ${centerMap[0]}, ${centerMap[2]})");

                                    layerList.add({
                                      'key': 'mbtiles${layerList.length}',
                                      'fileName': fileName,
                                      'type': 'vectorLayer',
                                      'url': urlJson,
                                      'center1': centerMap[1],
                                      'center0': centerMap[0],
                                      'center2': centerMap[2],
                                    });
                                  } else {
                                    print("check url json");
                                    print(url);
                                    webController.evaluateJavascript(
                                        "getRasterMap('$url', '$fileName')");
                                    webController.evaluateJavascript(
                                        "zoomToXy(${centerMap[1]}, ${centerMap[0]}, 12)");

                                    layerList.add({
                                      'key': 'mbtiles${layerList.length}',
                                      'fileName': fileName,
                                      'type': 'rasterLayer',
                                      'url': url,
                                      'center1': centerMap[1],
                                      'center0': centerMap[0],
                                    });
                                  }
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } on PlatformException catch (e) {
                                  print('function entered3');
                                  print(e);
                                }
                              }
                            }
                          }
                          else{

                            String path;
                            bool downloading = false;
                            var progressString = "";
                            Dio dio = Dio();
                            var dir = await getApplicationDocumentsDirectory();

                            print('path here else');
                            print('${dir.path}/${widget.mbtilesNationwideList[index]['name']}.mbtiles');

                            try {
                              widget.mbtilesNationwideList[index]['icon'] = '';
                              downloadingStatus = true;
                              await dio.download(
                                  widget.mbtilesNationwideList[index]['url'],
                                  "${dir.path}/${widget.mbtilesNationwideList[index]['name']}.mbtiles",
                                  onReceiveProgress: (rec, total) {
                                    print("Rec: $rec , Total: $total");
                                    setState(() {
                                      downloading = true;
                                      progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
                                    });
                                  });
                              print("Download completed");
                              setState(() {});
                            } catch (e) {
                              Fluttertoast.showToast(msg: 'File not download. There is some issue with it');
                              downloadingStatus = false;
                              print(e);
                              return;
                            }
                            setState(() {
                              downloading = false;
                              progressString = "Completed";
                              downloadingStatus = false;
                            });
                            Database db = await DatabaseHelper.instance.database;

                            final res = await db.rawUpdate(
                                'UPDATE ${widget.mbtilesNationwideList[index]['folderName']} SET icon = ?, path = ? WHERE name = ?',
                                [
                                  '0xe1f6',
                                  '${dir.path}/${widget.mbtilesNationwideList[index]['name']}.mbtiles',
                                  widget.mbtilesNationwideList[index]['name'],
                                ]);
                            widget.mbtilesNationwideList[index]['icon'] = '0xe1f6';
                            widget.mbtilesNationwideList[index]['path'] = '${dir.path}/${widget.mbtilesNationwideList[index]['name']}.mbtiles';
                            setState(() {});
                            Fluttertoast.showToast(msg: 'File downloaded');
                          }
                        },
                        child: widget.mbtilesNationwideList[index]['icon'] == '' ? CircularProgressIndicator(): Icon(
                            IconData(int.parse(widget.mbtilesNationwideList[index]['icon']), fontFamily: 'MaterialIcons'))),
                    title: Text(widget.mbtilesNationwideList[index]['name']),
                  ),
                ),
              );
            }
            ),
          ],
        ),
      ),
    );
  }
}
