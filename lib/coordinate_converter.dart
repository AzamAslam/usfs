import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewjavascript/main.dart';

class CoordinateConverter extends StatefulWidget {
  @override
  _CoordinateConverter createState() => _CoordinateConverter();
}

class _CoordinateConverter extends State<CoordinateConverter> {
  // String address;
  // int port;
  // bool isListening = false;
  // WebViewController controller;

  @override
  initState() {
    // _initServer();
    super.initState();
  }

  // _initServer() async {
  //   var newServer = new LocalAssetsServer(
  //     address: InternetAddress.loopbackIPv4,
  //     assetsBasePath: 'assets/mapbox',
  //     logger: DebugLogger(),
  //   );
  //
  //   var address = await newServer.serve();
  //   setState(() {
  //     this.address = address.address;
  //     port = newServer.boundPort;
  //     isListening = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinate Converter'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: !globalIsListening
            ? Center(child: CircularProgressIndicator())
            : WebView(
                initialUrl:
                    'http://$globalAddress:$globalPort/webviews/coordinate_converter_clientsidejs-master/index.html',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {}),
      ),
    );
  }
}
