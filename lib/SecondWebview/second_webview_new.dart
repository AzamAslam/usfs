import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewjavascript/navbar.dart';

import '../main.dart';


class SecondWebviewNew extends StatefulWidget {
  const SecondWebviewNew({Key key}) : super(key: key);

  @override
  _SecondWebviewNewState createState() => _SecondWebviewNewState();
}

class _SecondWebviewNewState extends State<SecondWebviewNew> {
  WebViewController secondWebController;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Second Webview New"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: WebView(
          // key: _key,
            initialUrl:
            'http://$globalAddress:$globalPort/webviews/angular_arcgis_api_for_js_mapmodule_mobile_optimized/index.html',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              secondWebController = webViewController;
            },
            onPageFinished: (String _) async {
              for (int i = 0; i < layerList.length; i++) {
                if (layerList[i]['type'] == 'geoJson') {
                  secondWebController.evaluateJavascript(
                      "addGeoJson('${layerList[i]['url']}')");
                  secondWebController.evaluateJavascript(
                      "zoomToextent('${layerList[i]['extent']}')");
                } else if (layerList[i]['type'] == 'vectorLayer') {
                  secondWebController.evaluateJavascript(
                      "addVectorLayerOnMap('${layerList[i]['url']}')");
                  secondWebController.evaluateJavascript(
                      "zoomToXy(${layerList[i]['center1']}, ${layerList[i]['center0']}, ${layerList[i]['center2']})");
                } else if (layerList[i]['type'] == 'rasterLayer') {
                  secondWebController.evaluateJavascript(
                      "getRasterMap('${layerList[i]['url']}', '${layerList[i]['fileName']}')");
                  secondWebController.evaluateJavascript(
                      "zoomToXy(${layerList[i]['center1']}, ${layerList[i]['center0']}, 12)");
                } else if (layerList[i]['type'] == 'gpkg') {
                  secondWebController.evaluateJavascript(
                      "getRasterMap('${layerList[i]['url']}', '${layerList[i]['fileName']}')");
                  secondWebController.evaluateJavascript(
                      "zoomToextent('${layerList[i]['extent']}')");
                }
              }
            }),
      ),
    );
  }
}
