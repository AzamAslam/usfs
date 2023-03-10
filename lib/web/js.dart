import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';

class JSChecking extends StatefulWidget {

  @override
  State<JSChecking> createState() => _JSCheckingState();
}

class _JSCheckingState extends State<JSChecking> {
  String _jsResult = '';

  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();

  String _quickjsVersion;

  Process _process;

  bool _processInitialized = false;

  String evalJS() {
    String jsResult = javascriptRuntime.evaluate("""
            if (typeof MyClass == 'undefined') {
              var MyClass = class  {
                constructor(id) {
                  this.id = id;
                }
                
                getId() { 
                  return this.id;
                }
              }
            }
            var obj = new MyClass(1);
            var jsonStringified = JSON.stringify(obj);
            var value = Math.trunc(Math.random() * 100).toString();
            JSON.stringify({ "object": jsonStringified, "expression": value});
            """).stringResult;
    return jsResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterJS Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'JS Evaluate Result:\n\n$_jsResult\n',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  'Click on the big JS Yellow Button to evaluate the expression bellow using the flutter_js plugin'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Math.trunc(Math.random() * 100).toString();",
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () => Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (ctx) => AjvExample(
            //         //widget.javascriptRuntime,
            //           javascriptRuntime),
            //     ),
            //   ),
            //   child: const Text('See Ajv Example'),
            // ),
            SizedBox.fromSize(size: Size(double.maxFinite, 20)),
            ElevatedButton(
              child: const Text('Fetch Remote Data'),
              onPressed: () async {
                var asyncResult = await javascriptRuntime.evaluateAsync("""
                fetch('https://raw.githubusercontent.com/abner/flutter_js/master/cxx/quickjs/VERSION').then(response => response.text());
              """);
                await javascriptRuntime.executePendingJob();
                final promiseResolved =
                await javascriptRuntime.handlePromise(asyncResult);
                setState(() => _quickjsVersion = promiseResolved.stringResult);
              },
            ),
            Text(
              'QuickJS Version\n${_quickjsVersion == null ? '<NULL>' : _quickjsVersion}',
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        child: Image.asset('assets/js.ico'),
        onPressed: () {
          setState(() {
            // _jsResult = widget.evalJS();
            // Future.delayed(Duration(milliseconds: 599), widget.evalJS);
            _jsResult = evalJS();
            Future.delayed(Duration(milliseconds: 599), evalJS);
          });
        },
      ),
    );
  }
}
