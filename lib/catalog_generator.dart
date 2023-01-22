import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const Vector2Raster());
}

class Vector2Raster extends StatefulWidget {
  const Vector2Raster({Key key}) : super(key: key);

  @override
  _Vector2RasterState createState() => _Vector2RasterState();
}

class _Vector2RasterState extends State<Vector2Raster> {
  @override
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useOnDownloadStart: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  // PullToRefreshController pullToRefreshController;
  // String url = "";
  // double progress = 0;
  // final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // pullToRefreshController = PullToRefreshController(
    //   options: PullToRefreshOptions(
    //     color: Colors.blue,
    //   ),
    //   onRefresh: () async {
    //     if (Platform.isAndroid) {
    //       webViewController?.reload();
    //     } else if (Platform.isIOS) {
    //       webViewController?.loadUrl(
    //           urlRequest: URLRequest(url: await webViewController?.getUrl()));
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {webViewController.reload();},
                  child: Icon(
                    Icons.refresh,
                    size: 26.0,
                  ),
                )),
          ],
          title: Text('Catalog Generator'),
          backgroundColor: Colors.blueGrey,
        ),
        body: SafeArea(
          child: Column(children: <Widget>[
            // TextField(
            //   decoration: InputDecoration(
            //       prefixIcon: Icon(Icons.search)
            //   ),
            //   controller: urlController,
            //   keyboardType: TextInputType.url,
            //   onSubmitted: (value) {
            //     var url = Uri.parse(value);
            //     if (url.scheme.isEmpty) {
            //       url = Uri.parse("https://www.google.com/search?q=" + value);
            //     }
            //     webViewController.loadUrl(
            //         urlRequest: URLRequest(url: url));
            //   },
            // ),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                        url: Uri.parse(
                            "https://mapsdata.world/catalog_generator/#1.44/4/-18.7")),

                    initialOptions: options,

                    // pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                      webViewController.reload();
                    },
                    // onLoadStart: (controller, url) {
                    //   setState(() {
                    //     this.url = url.toString();
                    //     urlController.text = this.url;
                    //   });
                    // },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    // shouldOverrideUrlLoading: (controller, navigationAction) async {
                    //   var uri = navigationAction.request.url;

                    // if (![ "http", "https", "file", "chrome",
                    //   "data", "javascript", "about"].contains(uri.scheme)) {
                    //   if (await canLaunch(url)) {
                    //     // Launch the App
                    //     await launch(
                    //       url,
                    //     );
                    //     // and cancel the request
                    //     return NavigationActionPolicy.CANCEL;
                    //   }
                    // }

                    //   return NavigationActionPolicy.ALLOW;
                    // },
                    // onLoadStop: (controller, url) async {
                    //   pullToRefreshController.endRefreshing();
                    //   setState(() {
                    //     this.url = url.toString();
                    //     urlController.text = this.url;
                    //   });
                    // },
                    // onLoadError: (controller, url, code, message) {
                    //   pullToRefreshController.endRefreshing();
                    // },
                    // onProgressChanged: (controller, progress) {
                    //   if (progress == 100) {
                    //     pullToRefreshController.endRefreshing();
                    //   }
                    //   setState(() {
                    //     this.progress = progress / 100;
                    //     urlController.text = this.url;
                    //   });
                    // },
                    // onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    //   setState(() {
                    //     this.url = url.toString();
                    //     urlController.text = this.url;
                    //   });
                    // },
                    // onConsoleMessage: (controller, consoleMessage) {
                    //   print(consoleMessage);
                    // },
                  ),
                  // progress < 1.0
                  //     ? LinearProgressIndicator(value: progress)
                  //     : Container(),
                ],
              ),
            ),
          ]),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     webViewController.reload();
        //   },
        //   child: const Icon(Icons.refresh),
        //   backgroundColor: Colors.lightBlue,
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }
}
