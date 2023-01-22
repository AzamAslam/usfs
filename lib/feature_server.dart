import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewjavascript/main.dart';
import 'package:flutter_downloader/flutter_downloader.dart';


// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   if (Platform.isAndroid) {
//     await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
//   }
//
//   runApp(const Vector2Raster());
// }

class FeatureServer extends StatefulWidget {
  const FeatureServer({Key key}) : super(key: key);

  @override
  _FeatureServerState createState() => _FeatureServerState();
}

class _FeatureServerState extends State<FeatureServer> {



  @override
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        cacheEnabled: true,
        useOnDownloadStart: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        allowContentAccess: true,
        builtInZoomControls: true,
        thirdPartyCookiesEnabled: true,
        allowFileAccess: true,
        geolocationEnabled: true,
        supportMultipleWindows: true,
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  // PullToRefreshController pullToRefreshController;
  // String url = "";
  // double progress = 0;
  // final urlController = TextEditingController();

  ReceivePort _port = ReceivePort();

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    checkPlatform();
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);

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

  void checkPlatform() async {
    WidgetsFlutterBinding.ensureInitialized();
    // await Permission.camera.request();
    // await Permission.microphone.request();
    // await Permission.storage.request();

    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
        AndroidServiceWorkerController.instance();

        serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            print(request);
            return null;
          },
        );
      }
    }
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
          title: Text('Feature Server'),
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
                            'http://ovh.net/files/',
                          // 'http://$globalAddress:$globalPort/webviews/featureserver_downloader_webview/build/index.html'
                        )),

                    initialOptions: options,

                    onDownloadStart: (controller, url) async {
                      print('hahahha entered');
                      print("onDownload $url");
                      Directory tempDir = await getExternalStorageDirectory();
                      await FlutterDownloader.enqueue(
                        url: "$url",
                        savedDir: tempDir.path,
                        showNotification: true,
                        openFileFromNotification: true,
                        saveInPublicStorage: true,
                      );
                    },

                    // pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) async {
                      webViewController = controller;
                      webViewController.reload();
                      await controller.webStorage.localStorage;
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
                    //   await controller.evaluateJavascript(source: "window.localStorage");
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



