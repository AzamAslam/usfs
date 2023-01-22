import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnlineEsri extends StatefulWidget {
  const OnlineEsri({Key key}) : super(key: key);

  @override
  _OnlineEsriState createState() => _OnlineEsriState();
}

class _OnlineEsriState extends State<OnlineEsri> {
  @override
  Widget build(BuildContext context) {
    final displayHeight = MediaQuery.of(context).size.height;
    final displayWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Esri Online"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      child: WebView(
        // key: _key,
          initialUrl:'https://mapdata.xyz/nrm_app/NRM-MAP/nrm_js_map/ts/dist/',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    ),
    );
  }
}
