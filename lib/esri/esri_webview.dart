import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';

class EsriWebview extends StatefulWidget {

  var check, url, extent;

  EsriWebview({this.check, this.url, this.extent});

  @override
  _EsriWebviewState createState() => _EsriWebviewState();
}

class _EsriWebviewState extends State<EsriWebview>
    with SingleTickerProviderStateMixin {

  static const platform = MethodChannel('samples.flutter.dev/battery');
  var mbtilesLayerList = [];
  var urlJson = '';
  WebViewController webController;
  final _key = UniqueKey();

  // var server;

  String statusText = "Start Server";
  startServer() async {
    print('initiated');
    setState(() {
      statusText = "Starting server on Port : 8080";
    });
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    print("Server running on IP : "+server.address.toString()+" On Port : "+server.port.toString());

    setState(() {
      statusText = "Server running on IP : "+server.address.toString()+" On Port : "+server.port.toString();
    });
  }


  addFile() async {
    print("add file entered 1");
    FilePickerResult result = await FilePicker.platform.pickFiles();
    print("add file entered 2");

    if (result != null) {
      print('if entered');
      try {
        print('if entered2');
        var invokeResult = await platform.invokeMethod('addTiles',
            {
              "path": result.files.single.path,
              "key": 'mbtiles${mbtilesLayerList.length}'
            });
        print('here is json');
        print(jsonDecode(invokeResult));

        String fileName = result.files.single.path.split('/').last;
        var tableName = fileName.split('.');
        var obj = jsonDecode(invokeResult);

        mbtilesLayerList.add({
          'key': 'mbtiles${mbtilesLayerList.length}',
          'fileName': fileName,
          'tableName': tableName[0],
          'icon': Icons.remove_red_eye_outlined,
          'obj': obj,
        });

        var list = [];
        //for vector only
        if(obj['format']== 'pbf'){
          try {
            var decodeResult =  jsonDecode(obj['allInfo']['json']);
            for(int i=0; i<decodeResult['vector_layers'].length; i++){
              list.add(decodeResult['vector_layers'][i]['id']);
            }
        } on Exception catch (exception) {
        } catch (error) {
      }
        }

        String layerIds = list.join(',');
        String key = obj['key'];
        String center = obj['center'];
        int maxZoom = obj['maxZoom'];
        String type = obj['format'];

        var url = 'http://localhost:${obj['port']}/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/{z}/{x}/{y}.${obj['format']}';
        urlJson = 'http://localhost:${obj['port']}/getTilesJson/${obj['format'] == 'pbf' ? 2 : 1}/${obj['key']}/${obj['format']}';

        print(layerIds);
        print(key);
        print(center);
        print(maxZoom);
        print(type);
        print(url);

        print("check");

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
    } else {
      // User canceled the picker
    }
  }

  @override
  initState() {
    // print('http://$globalAddress:$globalPort/webviews/angular_arcgis_api_for_js_mapmodule_mobile_optimized/index.html');
    // startServer();
    super.initState();
    // addFile();
  }

  List<String> propList = [];
  @override
  Widget build(BuildContext context) {
    final displayHeight = MediaQuery.of(context).size.height;
    final displayWidth = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Esri Offline"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: WebView(
          key: _key,
          initialUrl:
              'http://$globalAddress:$globalPort/webviews/angular_arcgis_api_for_js_mapmodule_mobile_optimized/index.html',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            webController = webViewController;
            // webViewController.reload();
          },
          onPageFinished: (String _){
            print('page finished called1');

            if(widget.check == 'vector'){
              webController.evaluateJavascript("addVectorLayerOnMap('${widget.url}')");
            }
            else{
              webController.evaluateJavascript("getRasterMap('${widget.url}')");
            }

            webController.evaluateJavascript("zoomToextent('${widget.extent}')");
            // webController.evaluateJavascript("zoomGoToXy('74.307', '31.522')");
            // webController.evaluateJavascript("zoomToXy('74.307', '31.522')");
            // webController.evaluateJavascript("getbaseMap('$urlJson')");
            // webController.evaluateJavascript("addGeoJson('https://mapdata.xyz/test_data/esri_places.geojson')");
            print('page finished called 2');
          },
          onPageStarted: (String _) {
            // add();
            // webController.evaluateJavascript(
            //     "getbaseMap('https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/osm-bright-gl-style/style.json')");
          },
        ),
      ),
    );
  }
}
