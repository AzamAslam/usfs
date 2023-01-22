import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
class JSonViewr extends StatefulWidget {
  final json;

  const JSonViewr({Key key, this.json}) : super(key: key);

  @override
  _JSonViewrState createState() => _JSonViewrState();
}

class _JSonViewrState extends State<JSonViewr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("JSON Viewer"),),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              child: JsonViewer(widget.json)
          ),
        ],
      ),
    );
  }
}
