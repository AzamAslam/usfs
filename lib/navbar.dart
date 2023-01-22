import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_manager/file_manager.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_geopackage/flutter_geopackage.dart';
import 'package:webviewjavascript/NativeView/native_view_example.dart';
import 'package:webviewjavascript/Screens/about_app.dart';
import 'package:webviewjavascript/Screens/all_jasons.dart';
import 'package:webviewjavascript/Screens/contact_support.dart';
import 'package:webviewjavascript/Screens/file_manager.dart';
import 'package:webviewjavascript/Screens/json_table.dart';
import 'package:webviewjavascript/coordinate_converter.dart';
import 'package:webviewjavascript/esri/esri_webview.dart';
import 'package:webviewjavascript/esri/online_esri.dart';
import 'package:webviewjavascript/list_files.dart';
import 'package:webviewjavascript/main.dart';
import 'package:webviewjavascript/second_webview.dart';
import 'package:webviewjavascript/select_GPKG.dart';
import 'package:webviewjavascript/spatialLite_json.dart';
import 'package:webviewjavascript/vector_data_converter.dart';
import 'package:webviewjavascript/catalog_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tableview/tableview.dart';
import 'package:geojson/geojson.dart';
import 'package:webviewjavascript/web/js.dart';

import 'package:sqlite3/sqlite3.dart';
import 'package:dart_jts/dart_jts.dart' as JTS;
import 'package:intl/intl.dart';
import 'package:dart_hydrologis_db/dart_hydrologis_db.dart';
import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';
import 'package:pedantic/pedantic.dart';

import 'AngularWebview/angularWebview.dart';
import 'FormsData/show_local_files.dart';
import 'Screens/catalog_list.dart';
import 'Screens/catalog_list_layer_management.dart';
import 'Screens/layer_management_list.dart';
import 'Screens/mbtiles_show.dart';
import 'Screens/open_layer.dart';
import 'Screens/sqlite_viewer.dart';
import 'Screens/table_view.dart';
import 'esri/download_mbtiles/download_data.dart';
import 'feature_server.dart';
import 'jsonToForm/json_to_form.dart';
import 'openlayer_tile_export.dart';

import "dart:convert" as JSON;
import "dart:core";
import 'dart:io';
import "dart:math" as math;
import "dart:typed_data";

import 'package:dart_hydrologis_db/dart_hydrologis_db.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:flutter_geopackage/com/hydrologis/flutter_geopackage/core/queries.dart';
import 'package:intl/intl.dart';
import 'package:proj4dart/proj4dart.dart' as PROJ;

// import 'package:flutter_json_viewer/flutter_json_viewer.dart';

int checkIndex = 0;
var layerList = [];

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  static const platform = MethodChannel('samples.flutter.dev/battery');

  List<JTS.Geometry> countriesGeoms;
  List<LazyGpkgTile> allLazy4326Tiles;
  List<JTS.Geometry> placesGeoms;

  // final job = AssetCopyJob(
  //   assets: [
  //     'testdbs/earth.gpkg',
  //     'testdbs/earthlights.gpkg',
  //   ],
  //   overwrite: false,
  // );

  String statusText = "Start Server";
  startServer() async {
    setState(() {
      statusText = "Starting server on Port : 8080";
    });
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    print("Server running on IP : " +
        server.address.toString() +
        " On Port : " +
        server.port.toString());
    await for (var request in server) {
      var ch = ConnectionsHandler();
      var s = request.requestedUri.path.split("/");

      var earthDb = ch.open('GlobalDatabaseObject.getByKey(s[0])');
      earthDb.forceRasterMobileCompatibility = false;
      var cloudsTileEntry = earthDb.tile(SqlName(s[1]));
      TilesFetcher cloudsFetcher = TilesFetcher(cloudsTileEntry);
      // cloudsFetcher.getLazyTile(earthDb, int.parse(s[2]), int.parse(s[3])).tileImageBytes
      // allLazy4326Tiles = cloudsFetcher.getAllLazyTiles(earthDb);

      request.response
        ..headers.contentType =
        new ContentType("text", "plain", charset: "utf-8")
        ..write('Hello, world')
        ..close();
    }
    setState(() {
      statusText = "Server running on IP : " +
          server.address.toString() +
          " On Port : " +
          server.port.toString();
    });
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/gpkgfiles/ADMIN_Somalia.gpkg');
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    var heightScreen = MediaQuery.of(context).size.height;
    var widthScreen = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          margin: EdgeInsets.only(bottom: heightScreen * 0.06),
          child: Drawer(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 1.5,
                sigmaY: 1.5,
              ),
              child: Container(
                decoration: BoxDecoration(color: Colors.white54),
                child: ListView(
                  children: [
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/LoadCat.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('Load Catalog'),
                    //   onTap: () async {
                    //
                    //     String _batteryLevel = 'Unknown battery level.';
                    //     String batteryLevel;
                    //     try {
                    //
                    //       final int result = await platform.invokeMethod('getBatteryLevel',
                    //           {
                    //             "key": 'hello'
                    //           });
                    //       // final int result = await platform.invokeMethod('getBatteryLevel');
                    //       batteryLevel = 'Battery level at $result % .';
                    //     } on PlatformException catch (e) {
                    //       batteryLevel = "Failed to get battery level: '${e.message}'.";
                    //     }
                    //
                    //     setState(() {
                    //       _batteryLevel = batteryLevel;
                    //     });
                    //
                    //     print('here is battery level');
                    //     print(_batteryLevel);
                    //
                    //     // FilePickerResult result =
                    //     //     await FilePicker.platform.pickFiles();
                    //     //
                    //     // if (result != null) {
                    //     //   File jsonFile = File(result.files.single.path);
                    //     //   print(jsonFile);
                    //     //     var jsonData = jsonFile.readAsStringSync();
                    //     //
                    //     //   webController.evaluateJavascript(
                    //     //       "loadCatalogFlutter($jsonData)");
                    //     // } else {
                    //     //   // User canceled the picker
                    //     // }
                    //   },
                    // ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/AddGeoJSON.png',
                        height: 30,
                      ),
                      title: Text('Add GeoJSON'),
                      onTap: () async {
                        FilePickerResult result = await FilePicker.platform.pickFiles();

                        if (result != null) {
                          var invokeResult = await platform.invokeMethod('addGeoJson', {
                            "path": result.files.single.path,
                            "key": 'geoJson${layerList.length}',
                            "fileName": '',
                          });
                          print('here is json');
                          print(jsonDecode(invokeResult));

                          String fileName =
                              result.files.single.path.split('/').last;
                          var obj = jsonDecode(invokeResult);
                          String url =
                              'http://localhost:${obj['port']}/getGeoJson/geoJson${layerList.length}';
                          var resultGeoJson = jsonDecode(obj['result']);
                          var extent = resultGeoJson['bbox'];

                          layerList.add({
                            'key': 'mbtiles${layerList.length}',
                            'fileName': fileName,
                            'type': 'geoJson',
                            'url': url,
                            'extent': extent
                          });

                          print('geojson bounds here');
                          print(extent);
                          webController.evaluateJavascript("addGeoJson('$url')");
                          webController.evaluateJavascript("zoomToextent('$extent')");
                          Navigator.pop(context);
                        } else {
                          // User canceled the picker
                        }
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('File Manager'),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FileManagerCl()),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/LoadCat.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('Native Module'),
                    //   onTap: () {
                    //     print('Forms');
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => NativeViewExample()
                    //       ),
                    //     );
                    //   },
                    // ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('NRM-Map online'),
                      onTap: () {
                        print('Forms');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OnlineEsri()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('GPKG Layers'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MbtilesShow(
                                  mbtilesLayerList: layerList,
                                )));
                      },
                    ),
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/LoadCat.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('Offline Esri'),
                    //   onTap: () async {
                    //     print('Forms');
                    //
                    //     print("add file entered 1");
                    //     FilePickerResult result = await FilePicker.platform.pickFiles();
                    //     print("add file entered 2");
                    //
                    //     var urlJson = '';
                    //
                    //     if (result != null) {
                    //       print('if entered');
                    //       try {
                    //         print('if entered2');
                    //         var invokeResult = await platform.invokeMethod('addTiles',
                    //             {
                    //               "path": result.files.single.path,
                    //               "key": 'mbtiles${mbtilesLayerList.length}'
                    //             });
                    //         print('here is json');
                    //         print(jsonDecode(invokeResult));
                    //
                    //         String fileName = result.files.single.path.split('/').last;
                    //         var tableName = fileName.split('.');
                    //         var obj = jsonDecode(invokeResult);
                    //
                    //         mbtilesLayerList.add({
                    //           'key': 'mbtiles${mbtilesLayerList.length}',
                    //           'fileName': fileName,
                    //           'tableName': tableName[0],
                    //           'icon': Icons.remove_red_eye_outlined,
                    //           'obj': obj,
                    //         });
                    //
                    //         var list = [];
                    //         //for vector only
                    //         if(obj['format']== 'pbf'){
                    //           try {
                    //             var decodeResult =  jsonDecode(obj['allInfo']['json']);
                    //             for(int i=0; i<decodeResult['vector_layers'].length; i++){
                    //               list.add(decodeResult['vector_layers'][i]['id']);
                    //             }
                    //           } on Exception catch (exception) {
                    //           } catch (error) {
                    //           }
                    //         }
                    //
                    //         String layerIds = list.join(',');
                    //         String key = obj['key'];
                    //         String center = obj['center'];
                    //         int maxZoom = obj['maxZoom'];
                    //         String type = obj['format'];
                    //
                    //         var url = 'http://localhost:${obj['port']}/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/{z}/{x}/{y}.${obj['format']}';
                    //         urlJson = 'http://localhost:${obj['port']}/getTilesJson-layer/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/${obj['format']}';
                    //
                    //         print(layerIds);
                    //         print(key);
                    //         print(center);
                    //         print(maxZoom);
                    //         print(type);
                    //         print(url);
                    //
                    //         print("check");
                    //
                    //         // Step1 openMbtile(key, url, layersIds, center, maxZoom, type)
                    //         // Opacity(key, opacity)
                    //         // visible(key, true/false)
                    //         // zoomToLocation(center)
                    //
                    //         // url, styleJson, overlay geojson
                    //
                    //         // Navigator.push(
                    //         //     context,
                    //         //     MaterialPageRoute(
                    //         //         builder: (context) => MbtilesShow(mbtilesLayerList: mbtilesLayerList,))
                    //         // );
                    //       } on PlatformException catch (e) {
                    //         print('function entered3');
                    //         print(e);
                    //       }
                    //     } else {
                    //       // User canceled the picker
                    //     }
                    //
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => EsriWebview(url: urlJson,)
                    //       ),
                    //     );
                    //   },
                    // ),

                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('Add Mbtiles'),
                      onTap: () async {
                        print('Android');
                        FilePickerResult result = await FilePicker.platform.pickFiles();

                        var urlJson = '';
                        String fileName =
                            result.files.single.path.split('/').last;

                        if (result != null) {
                          print('if entered');
                          try {
                            print('if entered2');
                            var invokeResult;
                            print(layerList.length);
                            // if (Platform.isAndroid) {
                            invokeResult = await platform.invokeMethod('addTiles', {
                              "path": result.files.single.path,
                              "fileName": '',
                              "key": 'mbtiles${layerList.length}'
                            });
                            print('here is json');
                            print(jsonDecode(invokeResult));
                            // }

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

                            var url = 'http://localhost:${obj['port']}/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/{z}/{x}/{y}.${obj['format']}';
                            urlJson = 'http://localhost:${obj['port']}/getTilesJson-layer/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/${obj['format']}';

                            // if(obj['format']== 'pbf'){
                            //   webController.evaluateJavascript("addVectorLayerOnMap('$urlJson')");
                            // }
                            // else{
                            //   webController.evaluateJavascript("getRasterMap('$url')");
                            // }

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
                              webController.evaluateJavascript("addVectorLayerOnMap('$urlJson')");
                              webController.evaluateJavascript("zoomToXy(${centerMap[1]}, ${centerMap[0]}, ${centerMap[2]})");

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
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => EsriWebview(check: 'raster', url: url)
                              //   ),
                              // );
                              // webController.evaluateJavascript("getRasterMap('$url')");
                            }
                            Navigator.pop(context);

                            // Step1 openMbtile(key, url, layersIds, center, maxZoom, type)
                            // Opacity(key, opacity)
                            // visible(key, true/false)
                            // zoomToLocation(center)

                            // url, styleJson, overlay geojson

                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => MbtilesShow(mbtilesLayerList: mbtilesLayerList,))
                            // );
                          } on PlatformException catch (e) {
                            print('function entered3');
                            print(e);
                          }
                        }
                      },
                    ),
                    ListTile(
                        leading: Image.asset(
                          'assets/icons/LoadCat.png',
                          height: 30,
                        ),
                        title: Text('SptialLite'),
                        onTap: () async {
                          // print('GPKG');

                          // var urlJson = '';
                          //
                          // if (result != null) {
                          //   print('if entered');
                          //
                          //   try {
                          //     var invokeResult;
                          //     invokeResult = await platform.invokeMethod(
                          //         'addGpkg', {
                          //       "path": result.files.single.path,
                          //       "key": 'gpkg${layerList.length}'
                          //     });
                          //     print('here is json');
                          //     print(jsonDecode(invokeResult));
                          //
                          //     String fileName =
                          //         result.files.single.path.split('/').last;
                          //     var tableName = fileName.split('.');
                          //     var obj = jsonDecode(invokeResult);
                          //
                          //     var info = obj['info'];
                          //     print(info);
                          //
                          //     layerList.add({
                          //       'key': 'gpkg${layerList.length}',
                          //       'fileName': fileName,
                          //       'type': 'gpkg',
                          //       'table': []
                          //     });
                          //
                          //     int indexValue = 0;
                          //     print('before starting');
                          //     info.forEach((table, content) {
                          //       print('loop in');
                          //       if (table != 'ogr_empty_table') {
                          //         if (content['data_type'] == 'tiles') {
                          //           // 'http://localhost:' + cordovaPort + '/3/' + layer_gp_id+'@'+name + '/{z}/{x}/{y}.png'
                          //           var url =
                          //               'http://localhost:${obj['port']}/3/${obj['key']}@${content['table_name']}/{z}/{x}/{y}.png';
                          //           print('url here');
                          //           print(url);
                          //           var extent =
                          //           obj['detail'][indexValue]['bounds'];
                          //           print('check lat here');
                          //
                          //           print(extent);
                          //
                          //           // webController.evaluateJavascript("getRasterMap('$url', '$fileName')");
                          //           // webController.evaluateJavascript("zoomToextent('$extent')");
                          //           print('hahhahah');
                          //
                          //           layerList[layerList.length - 1]['table'].add({
                          //             'name': '${content['table_name']}',
                          //             'url': url,
                          //             'extent': extent,
                          //             'identifier': '${content['identifier']}',
                          //             'description': '${content['description']}',
                          //             'icon': Icons.visibility_off_outlined
                          //           });
                          //           indexValue++;
                          //           print('indexValue here');
                          //           print(indexValue);
                          //         }
                          //       }
                          //       print('${table}: ${content}');
                          //     });
                          //     print('layer list here');
                          //     print(layerList);
                          // Navigator.pop(context);

                          // mbtilesLayerList.add({
                          //   'key': 'mbtiles${mbtilesLayerList.length}',
                          //   'fileName': fileName,
                          //   'tableName': tableName[0],
                          //   'icon': Icons.remove_red_eye_outlined,
                          //   'obj': obj,
                          // });

                          // var list = [];
                          // //for vector only
                          // if(obj['format']== 'pbf'){
                          //   try {
                          //     var decodeResult =  jsonDecode(obj['allInfo']['json']);
                          //     for(int i=0; i<decodeResult['vector_layers'].length; i++){
                          //       list.add(decodeResult['vector_layers'][i]['id']);
                          //     }
                          //   } on Exception catch (exception) {
                          //   } catch (error) {
                          //   }
                          // }

                          // String layerIds = list.join(',');
                          // String key = obj['key'];
                          // String center = obj['center'];
                          // int maxZoom = obj['maxZoom'];
                          // String type = obj['format'];

                          // var url = 'http://localhost:${obj['port']}/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/{z}/{x}/{y}.${obj['format']}';
                          // urlJson = 'http://localhost:${obj['port']}/getTilesJson-layer/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/${obj['format']}';

                          // if(obj['format']== 'pbf'){
                          //   webController.evaluateJavascript("addVectorLayerOnMap('$urlJson')");
                          // }
                          // else{
                          //   webController.evaluateJavascript("getRasterMap('$url')");
                          // }

                          // print(layerIds);
                          // print(key);
                          // print(center);
                          // print(maxZoom);
                          // print(type);
                          // print(url);
                          // showDialog(
                          //   context: context,
                          //   barrierDismissible: false,
                          //   builder: (BuildContext context) {
                          //     return Dialog(
                          //         child:  Container(
                          //           height: 80.0,
                          //
                          //           child: Column(
                          //               mainAxisAlignment: MainAxisAlignment.center,
                          //               children:  [
                          //                 new CircularProgressIndicator(),
                          //                 new Text("Loading JSON..."),
                          //               ]
                          //           ),
                          //         )
                          //     );
                          //   },
                          // );
                          // new Future.delayed(new Duration(seconds: 5), () async{
                          //   Navigator.pop(context); //pop dialog
                          //   List<SelectedListItem> _listOfCities=[];
                          //
                          //   String data = await DefaultAssetBundle.of(context).loadString("assets/Spatialbookmark.json");
                          //   final jsonResult = jsonDecode(data);
                          //   print(jsonResult[0]['NAME']);
                          //   List<dynamic> items = [];
                          //   jsonResult.forEach((s)=> _listOfCities.add( SelectedListItem(false, s['NAME'],)));
                          //   jsonResult.forEach((s)=> items.add({'name':s['NAME'],'lat':s['yCentroid'],'long':s['xCentroid']}));
                          //   print("This is items $items");
                          //
                          //   print("This is items $items");
                          //
                          //   // for(int i=0; i<=items.length;i++){
                          //   //   _listOfCities.add( SelectedListItem(false, items[i],));
                          //   // }
                          //
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => JSONScreen(listt: _listOfCities,mapList: items,name: "json",))
                          //   );
                          // });
                          Navigator.pop(context);

                          Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>ListFiles())
                                );

                          // DropDown(
                          //   //submitButtonText: kDone,
                          //   submitButtonColor: const Color.fromRGBO(70, 76, 222, 1),
                          //   searchHintText: "Search",
                          //   bottomSheetTitle: "JSON",
                          //   searchBackgroundColor: Colors.black12,
                          //   dataList: items ?? [],
                          //   selectedItems: (List<dynamic> selectedList) {
                          //    // showSnackBar(selectedList.toString());
                          //   },
                          //   selectedItem: (String selected) {
                          //     // showSnackBar(selected);
                          //     // widget.textEditingController.text = selected;
                          //   },
                          //   enableMultipleSelection: false,
                          // //  searchController: _searchTextEditingController,
                          // );// print(url);

                          // webController.evaluateJavascript("getRasterMap('$url')");
                          // }

                          // Step1 openMbtile(key, url, layersIds, center, maxZoom, type)
                          // Opacity(key, opacity)
                          // visible(key, true/false)
                          // zoomToLocation(center)

                          // url, styleJson, overlay geojson
                          //
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => (
                          //
                          //        )));
                          //     } on PlatformException catch (e) {
                          //       print('function entered3');
                          //       print(e);
                          //     }
                          //   } else {
                          //     // User canceled the picker
                          //   }
                        }
                    ),
                    // ListTile(
                    //     leading: Image.asset(
                    //       'assets/icons/LoadCat.png',
                    //       height: 30,
                    //     ),
                    //     title: Text('Json To Form'),
                    //     onTap: () async {
                    //
                    //      // Navigator.pop(context);
                    //
                    //       // DropDown(
                    //       //   //submitButtonText: kDone,
                    //       //   submitButtonColor: const Color.fromRGBO(70, 76, 222, 1),
                    //       //   searchHintText: "Search",
                    //       //   bottomSheetTitle: "JSON",
                    //       //   searchBackgroundColor: Colors.black12,
                    //       //   dataList: items ?? [],
                    //       //   selectedItems: (List<dynamic> selectedList) {
                    //       //    // showSnackBar(selectedList.toString());
                    //       //   },
                    //       //   selectedItem: (String selected) {
                    //       //     // showSnackBar(selected);
                    //       //     // widget.textEditingController.text = selected;
                    //       //   },
                    //       //   enableMultipleSelection: false,
                    //       // //  searchController: _searchTextEditingController,
                    //       // );// print(url);
                    //
                    //       // webController.evaluateJavascript("getRasterMap('$url')");
                    //       // }
                    //
                    //       // Step1 openMbtile(key, url, layersIds, center, maxZoom, type)
                    //       // Opacity(key, opacity)
                    //       // visible(key, true/false)
                    //       // zoomToLocation(center)
                    //
                    //       // url, styleJson, overlay geojson
                    //       //
                    //       // Navigator.push(
                    //       //     context,
                    //       //     MaterialPageRoute(
                    //       //         builder: (context) => (
                    //       //
                    //       //        )));
                    //       //     } on PlatformException catch (e) {
                    //       //       print('function entered3');
                    //       //       print(e);
                    //       //     }
                    //       //   } else {
                    //       //     // User canceled the picker
                    //       //   }
                    //     }
                    // ),
                    ListTile(
                        leading: Image.asset(
                          'assets/icons/LoadCat.png',
                          height: 30,
                        ),
                        title: Text('Json To Forms'),
                        onTap: () async {

                            setState(() {});
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>JsonFiles())
                            );


                         // Navigator.pop(context);

                          // DropDown(
                          //   //submitButtonText: kDone,
                          //   submitButtonColor: const Color.fromRGBO(70, 76, 222, 1),
                          //   searchHintText: "Search",
                          //   bottomSheetTitle: "JSON",
                          //   searchBackgroundColor: Colors.black12,
                          //   dataList: items ?? [],
                          //   selectedItems: (List<dynamic> selectedList) {
                          //    // showSnackBar(selectedList.toString());
                          //   },
                          //   selectedItem: (String selected) {
                          //     // showSnackBar(selected);
                          //     // widget.textEditingController.text = selected;
                          //   },
                          //   enableMultipleSelection: false,
                          // //  searchController: _searchTextEditingController,
                          // );// print(url);

                          // webController.evaluateJavascript("getRasterMap('$url')");
                          // }

                          // Step1 openMbtile(key, url, layersIds, center, maxZoom, type)
                          // Opacity(key, opacity)
                          // visible(key, true/false)
                          // zoomToLocation(center)

                          // url, styleJson, overlay geojson
                          //
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => (
                          //
                          //        )));
                          //     } on PlatformException catch (e) {
                          //       print('function entered3');
                          //       print(e);
                          //     }
                          //   } else {
                          //     // User canceled the picker
                          //   }
                        }
                    ),

                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('Add GPKG'),
                      onTap: () async {
                        print('GPKG');

                        FilePickerResult result =
                        await FilePicker.platform.pickFiles();

                        var urlJson = '';

                        if (result != null) {
                          print('if entered');

                          try {
                            var invokeResult;
                            invokeResult = await platform.invokeMethod(
                                'addGpkg', {
                              "path": result.files.single.path,
                              'name': '',
                              "key": 'gpkg${layerList.length}'
                            });
                            print('here is json');
                            print(jsonDecode(invokeResult));

                            String fileName =
                                result.files.single.path.split('/').last;
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
                                  // 'http://localhost:' + cordovaPort + '/3/' + layer_gp_id+'@'+name + '/{z}/{x}/{y}.png'
                                  var url =
                                      'http://localhost:${obj['port']}/3/${obj['key']}@${content['table_name']}/{z}/{x}/{y}.png';
                                  print('url here');
                                  print(url);
                                  var extent =
                                  obj['detail'][indexValue]['bounds'];
                                  print('check lat here');

                                  print(extent);

                                  // webController.evaluateJavascript("getRasterMap('$url', '$fileName')");
                                  // webController.evaluateJavascript("zoomToextent('$extent')");
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
                            // Navigator.pop(context);

                            // mbtilesLayerList.add({
                            //   'key': 'mbtiles${mbtilesLayerList.length}',
                            //   'fileName': fileName,
                            //   'tableName': tableName[0],
                            //   'icon': Icons.remove_red_eye_outlined,
                            //   'obj': obj,
                            // });

                            // var list = [];
                            // //for vector only
                            // if(obj['format']== 'pbf'){
                            //   try {
                            //     var decodeResult =  jsonDecode(obj['allInfo']['json']);
                            //     for(int i=0; i<decodeResult['vector_layers'].length; i++){
                            //       list.add(decodeResult['vector_layers'][i]['id']);
                            //     }
                            //   } on Exception catch (exception) {
                            //   } catch (error) {
                            //   }
                            // }

                            // String layerIds = list.join(',');
                            // String key = obj['key'];
                            // String center = obj['center'];
                            // int maxZoom = obj['maxZoom'];
                            // String type = obj['format'];

                            // var url = 'http://localhost:${obj['port']}/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/{z}/{x}/{y}.${obj['format']}';
                            // urlJson = 'http://localhost:${obj['port']}/getTilesJson-layer/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/${obj['format']}';

                            // if(obj['format']== 'pbf'){
                            //   webController.evaluateJavascript("addVectorLayerOnMap('$urlJson')");
                            // }
                            // else{
                            //   webController.evaluateJavascript("getRasterMap('$url')");
                            // }

                            // print(layerIds);
                            // print(key);
                            // print(center);
                            // print(maxZoom);
                            // print(type);
                            // print(url);

                            print("check");

                            // if(obj['format']== 'pbf'){
                            print("check url json");
                            print(urlJson);
                            print("check url json");
                            // print(url);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => EsriWebview(check: 'raster', url: 'url')
                            //   ),
                            // );
                            // webController.evaluateJavascript("getRasterMap('$url')");
                            // }

                            // Step1 openMbtile(key, url, layersIds, center, maxZoom, type)
                            // Opacity(key, opacity)
                            // visible(key, true/false)
                            // zoomToLocation(center)

                            // url, styleJson, overlay geojson

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
                        } else {
                          // User canceled the picker
                        }
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('Download PreStaged Data'),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DownloadData()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('GeoSpatial Data Discovery'),
                      onTap: () async {
                        await _launchURL();
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      title: Text('geoJSON Table'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LocalTable()),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/LoadCat.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('Add GPKG'),
                    //   onTap: () async {
                    //
                    //     startServer();
                    //     print('here is server status');
                    //     print(statusText);
                    //
                    //     FilePickerResult result =
                    //     await FilePicker.platform.pickFiles();
                    //
                    //     if (result != null) {
                    //
                    //       print('if entered');
                    //       // File file = File(result.files.single.path);
                    //       var ch = ConnectionsHandler();
                    //
                    //       print('connection established');
                    //       print(result.files.single.path);
                    //
                    //       var earthDb = ch.open(result.files.single.path);
                    //       print('connection established 1st');
                    //       earthDb.forceRasterMobileCompatibility = false;
                    //       print('connection established 1');
                    //
                    //       var cloudsTileEntry = earthDb.tiles();
                    //       for(int i=0; i<cloudsTileEntry.length; i++){
                    //         print(cloudsTileEntry[i].tableName.name);
                    //       }
                    //       var featuresTiles = earthDb.features();
                    //       for(int i=0; i< featuresTiles.length;i++) {
                    //         print(featuresTiles[i].tableName.name);
                    //       }
                    //       // var cloudsTileEntry = earthDb.tile(SqlName("clouds"));
                    //       // TilesFetcher cloudsFetcher = TilesFetcher(cloudsTileEntry);
                    //       // allLazy4326Tiles = cloudsFetcher.getAllLazyTiles(earthDb);
                    //
                    //       // load places
                    //       var dataEnv = JTS.Envelope(-9, 22, 35, 63);
                    //       placesGeoms = earthDb.getGeometriesIn(SqlName("places"),
                    //           userDataField: "name", envelope: dataEnv);
                    //       print('connection established 2');
                    //
                    //       // load countries
                    //       countriesGeoms =
                    //           earthDb.getGeometriesIn(SqlName("countries"), envelope: dataEnv);
                    //       print('connection established 3');
                    //
                    //       print('yes testing');
                    //       ch.closeAll();
                    //       // print(cloudsFetcher);
                    //       //print(allLazy4326Tiles);
                    //       //print(placesGeoms);
                    //       //print(countriesGeoms);
                    //
                    //       // var earthLigthsDb = ch.open(earthLightsPath);
                    //       // earthLigthsDb.forceRasterMobileCompatibility = false;
                    //
                    //       // var jsonData = jsonFile.readAsStringSync();
                    //       //
                    //       // webController.evaluateJavascript(
                    //       //     "loadCatalogFlutter($jsonData)");
                    //     } else {
                    //       // User canceled the picker
                    //     }
                    //   },
                    // ),
                    // Divider(),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/SqlViewer.png',
                        height: 30,
                      ),
                      title: Text('Forms'),
                      onTap: () {
                        print('Forms');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LocalFiles()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/SqlViewer.png',
                        height: 30,
                      ),
                      title: Text('GeoPackage load'),
                      onTap: () {
                        // print('Forms');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoadGPKG()),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/SqlViewer.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('SQLite Viewer'),
                    //   onTap: () {
                    //     print('SQLite viewer');
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => SQLiteViewer()
                    //           ),
                    //     );
                    //   },
                    // ),
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/tableViewer.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('Table Viewer'),
                    //   onTap: () {
                    //     print('Table Viewer');
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => TableViewer()),
                    //     );
                    //   },
                    // ),
                    // Divider(),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/need.png',
                        height: 30,
                      ),
                      title: Text('PWA App'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AngularWebview()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/manual.png',
                        height: 30,
                      ),
                      title: Text('Manual'),
                      onTap: () {
                        print('GeoPackage');
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => SQLiteViewer()),
                        // );
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/LoadCat.png',
                        height: 30,
                      ),
                      trailing: CupertinoSwitch(
                        value: secondWebview,
                        onChanged: (value) {
                          secondWebview = value;
                          setState(() {});
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                              MyApp()), (Route<dynamic> route) => false);
                        },
                      ),
                      title: Text('2nd Webview'),
                    ),
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/AboutApp.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('About App'),
                    //   onTap: () {
                    //     print('About App');
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => AboutApp()),
                    //     );
                    //   },
                    // ),
                    // ListTile(
                    //   leading: Image.asset(
                    //     'assets/icons/Contactsupport.png',
                    //     height: 30,
                    //   ),
                    //   title: Text('Contact Support'),
                    //   onTap: () {
                    //     print('Contactsupport');
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => ContactSupport()),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Container(
        //   padding: data.size.shortestSide < 600
        //       ? EdgeInsets.only(
        //           left: widthScreen * 0.705,
        //           bottom: heightScreen * 0.02,
        //           top: heightScreen * 0.92,
        //           right: widthScreen * 0.14)
        //       : EdgeInsets.only(
        //           left: widthScreen * 0.329,
        //           bottom: heightScreen * 0.02,
        //           top: heightScreen * 0.92,
        //           right: widthScreen * 0.35),
        //   child: Align(
        //     alignment: Alignment.bottomLeft,
        //     child: FloatingActionButton(
        //       backgroundColor: Colors.white,
        //       onPressed: () {},
        //       child: ImageIcon(
        //         AssetImage("assets/icons/ruler.png"),
        //         color: Colors.yellow,
        //         size: 40,
        //       ),
        //     ),
        //   ),
        // ),
        // Container(
        //   padding: data.size.shortestSide < 600
        //       ? EdgeInsets.only(
        //           left: widthScreen * 0.55,
        //           bottom: heightScreen * 0.02,
        //           top: heightScreen * 0.92,
        //           right: widthScreen * 0.28)
        //       : EdgeInsets.only(
        //           left: widthScreen * 0.229,
        //           bottom: heightScreen * 0.02,
        //           top: heightScreen * 0.92,
        //           right: widthScreen * 0.44),
        //   child: Align(
        //     alignment: Alignment.bottomLeft,
        //     child: FloatingActionButton(
        //       backgroundColor: Colors.white,
        //       onPressed: () {},
        //       child: ImageIcon(
        //         AssetImage("assets/icons/draw.png"),
        //         color: Colors.green,
        //         size: 30,
        //       ),
        //     ),
        //   ),
        // ),
        // Container(
        //   padding: data.size.shortestSide < 600
        //       ? EdgeInsets.only(
        //           left: widthScreen * 0.4,
        //           bottom: heightScreen * 0.02,
        //           top: heightScreen * 0.92,
        //           right: widthScreen * 0.46)
        //       : EdgeInsets.only(
        //           left: widthScreen * 0.129,
        //           bottom: heightScreen * 0.02,
        //           top: heightScreen * 0.92,
        //           right: widthScreen * 0.54),
        //   child: Align(
        //     alignment: Alignment.bottomLeft,
        //     child: FloatingActionButton(
        //       onPressed: () {
        //       },
        //       backgroundColor: Colors.white,
        //       child: ImageIcon(
        //         AssetImage("assets/icons/pencil.png"),
        //         color: Colors.blue,
        //         size: 30,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // getOptionForPencil(icon ,text, widthScreen, heightScreen) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 10, right: 10),
  //     child: Container(
  //       height: heightScreen * 0.06,
  //       child: Card(
  //         child: InkWell(
  //           splashColor: Colors.blue.withAlpha(30),
  //           onTap: () {
  //             print('Card tapped.');
  //             Navigator.pop(context);
  //             Navigator.pop(context);
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Row(
  //               children: [
  //                 Image.asset(
  //                   icon,
  //                   height: 20,
  //                 ),
  //                 SizedBox(
  //                   width: widthScreen * 0.04,
  //                 ),
  //                 Text(
  //                   text,
  //                   style: TextStyle(fontSize: 16),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  _launchURL() async {
    const url = 'https://data-usfs.hub.arcgis.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}