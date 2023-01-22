import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewjavascript/navbar.dart';

import 'main.dart';

class SecondWebview extends StatefulWidget {
  const SecondWebview({Key key}) : super(key: key);

  @override
  _SecondWebviewState createState() => _SecondWebviewState();
}

class _SecondWebviewState extends State<SecondWebview> {

  String mapCenter = '';

  WebViewController secondWebController;

  @override
  Widget build(BuildContext context) {
    final displayHeight = MediaQuery.of(context).size.height;
    final displayWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(mapCenter == '' ? "Second Webview": mapCenter),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: WebView(
          // key: _key,
          initialUrl:'http://$globalAddress:$globalPort/webviews/angular_arcgis_api_for_js_mapmodule_mobile_optimized/webview2.html',
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: Set.from([
            JavascriptChannel(
                name: 'messageHandler',
                onMessageReceived: (JavascriptMessage message) async {
                  if(message.message == 'mapCenter'){
                    mapCenter = await webController.evaluateJavascript("returnLatLonCenter()");
                    var center = mapCenter.split('"');
                    var newCenter = center[1].split(',');
                    print(newCenter[0]);
                    print(newCenter[1]);
                    setState(() {});
                  }
                  else if(message.message == 'distance'){
                    Navigator.pop(context);
                    Navigator.pop(context);
                    mapCenter = await webController.evaluateJavascript("callDistanceFunction()");
                    setState(() {});
                  }
                  else if(message.message == 'area'){
                    Navigator.pop(context);
                    Navigator.pop(context);
                    mapCenter = await webController.evaluateJavascript("callAreaFunction()");
                    setState(() {});
                  }
                  else if(message.message == 'fl'){
                    Navigator.pop(context);
                    Navigator.pop(context);
                    mapCenter = await webController.evaluateJavascript("addFeatureSrvice()");
                    setState(() {});
                  }
                })
          ]),
            onWebViewCreated: (WebViewController webViewController) {
              secondWebController = webViewController;
              // webViewController.reload();
            },
        // onPageFinished: (String _) async {
        //   for(int i=0; i<layerList.length; i++){
        //     if(layerList[i]['type'] == 'geoJson'){
        //       secondWebController.evaluateJavascript("addGeoJson('${layerList[i]['url']}')");
        //       secondWebController.evaluateJavascript("zoomToextent('${layerList[i]['extent']}')");
        //     }
        //     else if(layerList[i]['type'] == 'vectorLayer'){
        //       secondWebController.evaluateJavascript("addVectorLayerOnMap('${layerList[i]['url']}')");
        //       secondWebController.evaluateJavascript("zoomToXy(${layerList[i]['center1']}, ${layerList[i]['center0']}, ${layerList[i]['center2']})");
        //     }
        //     else if(layerList[i]['type'] == 'rasterLayer'){
        //       secondWebController.evaluateJavascript("getRasterMap('${layerList[i]['url']}', '${layerList[i]['fileName']}')");
        //       secondWebController.evaluateJavascript("zoomToXy(${layerList[i]['center1']}, ${layerList[i]['center0']}, 12)");
        //     }
        //     else if(layerList[i]['type'] == 'gpkg'){
        //       secondWebController.evaluateJavascript("getRasterMap('${layerList[i]['url']}', '${layerList[i]['fileName']}')");
        //       secondWebController.evaluateJavascript("zoomToextent('${layerList[i]['extent']}')");
        //     }
        //   }
        // }
        ),
      ),
    );
  }
}
