import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeIos extends StatefulWidget {
  const NativeIos({Key key}) : super(key: key);

  @override
  _NativeIosState createState() => _NativeIosState();
}

class _NativeIosState extends State<NativeIos> {

  static const platform = const MethodChannel('flutter.native/helper');
  String _responseFromNativeCode = 'Waiting for Response...';
  Future<void> responseFromNativeCode() async {
    String response = "";
    try {
      final String result = await platform.invokeMethod('helloFromNativeCode');
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _responseFromNativeCode = response;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Native iOS calling'),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            child: Text('Call Native Method'),
            onPressed: responseFromNativeCode,
          ),
          Text(_responseFromNativeCode),
        ],
      ),
    );
  }
}
