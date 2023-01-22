import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main.dart';

class OpenLayerTileExport extends StatelessWidget {
  const OpenLayerTileExport({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Layer Tile Export'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: !globalIsListening
            ? Center(child: CircularProgressIndicator())
            : WebView(
            initialUrl:
            'http://$globalAddress:$globalPort/webviews/openlayers_tile_export_backgroundprocess-master/index.html',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {}),
      ),
    );
  }
}
