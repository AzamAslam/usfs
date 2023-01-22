import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:developer' as developer;
import 'package:local_assets_server/local_assets_server.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:webviewjavascript/panelwidget.dart';
import 'package:share/share.dart';
import 'package:webviewjavascript/sqliteDataBase/db_provider.dart';

import 'navbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
var currentLocation, currentLocationStored;
int indexGeoJSON = 0;
var longg;
var latt;

bool checkPlacemark = false;
bool secondWebview = false;

String globalAddress;
int globalPort;
bool globalIsListening = false;

//For radio button use in bottom navigation bar
int groupOverlaysWeatherValue = -1;
int groupOverlaysREFValue = -1;
int groupBaseValue = -1;

WebViewController webController;
WebViewController webControllerSecond;
var globalLongitude, globalLatitude;
// InAppWebViewController webViewController;

double positionPanel = 0;
bool _switchGeoLocation = true;
var serverOne;

var getCenter = [
  {'long': '-74.5'},
  {'lat': '40'}
];
var getZoom = 16.0000;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  await Permission.storage.request();
  // await Permission.camera.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) =>
      MaterialApp(debugShowCheckedModeBanner: false, home: MyWidget());
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {


  var longitude;
  var latitude;

  final _key = UniqueKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _bottomBarController = BottomBarWithSheetController(initialIndex: 0);
  final panelController = new PanelController();
  TabController _tabController;

  static const double febHeightClosed = 116.0;
  double febHeight = febHeightClosed;

  String address;
  int port;
  bool isListening = false;

  // WebViewController webController;

  int _currentIndex = 0;
  var getLocation, getLocate;

  var mapCenter = '';

  var server;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }


  startServer() async {
    print('initiated');
    serverOne = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    print("Server running on IP : "+serverOne.address.toString()+" On Port : "+serverOne.port.toString());
  }

  setGeoLocation() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error(
            'Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error(
              'Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      getLocation = await Geolocator.getCurrentPosition();

      getLocate = await Geolocator.getCurrentPosition();
      var position = (getLocate.toString()).split(',');
      var latPoint = position[0].split(' ');
      var longPoint = position[1].split(' ');
      longitude = double.parse(longPoint[2]);
      latitude = double.parse(latPoint[1]);
      var lat =
          (double.parse(latPoint[1]).toStringAsFixed(3));
      var long =
          (double.parse(longPoint[2]).toStringAsFixed(3));
      print(longitude);
      print(latitude);
      webController.evaluateJavascript(
          "setCenter($longitude, $latitude)");
      setState(() {
        longg=long;
        latt=lat;
        currentLocation = 'Lat: ' + lat + ', Long: ' + long;
        currentLocationStored = 'Lat: ' + lat + ', Long: ' + long;
        getLocate = 'Lat: ' + lat + ', Long: ' + long;
      });

      print(await Geolocator.getCurrentPosition());
  }

  @override
  initState() {
    setGeoLocation();
    startServer();
    _initServer();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _tabController = new TabController(length: 1, vsync: this);
  }

  // InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
  //     crossPlatform: InAppWebViewOptions(
  //       useOnDownloadStart: true,
  //       useShouldOverrideUrlLoading: true,
  //       mediaPlaybackRequiresUserGesture: false,
  //     ),
  //     android: AndroidInAppWebViewOptions(
  //       useHybridComposition: true,
  //     ),
  //     ios: IOSInAppWebViewOptions(
  //       allowsInlineMediaPlayback: true,
  //     ));

  // void _incrementCounter() {
  //   controller?.evaluateJavascript('window.increment()');
  // }

  _initServer() async {
    var server = new LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/mapbox',
    );

    var address = await server.serve();

    setState(() {
      this.server = server;
      this.address = address.address;
      port = server.boundPort;
      isListening = true;
    });

    globalAddress = this.address;
    globalPort = this.port;
    globalIsListening = this.isListening;
    setState(() {});
  }

  List<String> propList = [];
  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.10;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.6;

    final displayHeight = MediaQuery.of(context).size.height;
    final displayWidth = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: Container(
          width: MediaQuery.of(context).size.height * 0.7, child: NavBar()),
      appBar: AppBar(
        centerTitle: true,
        // toolbarHeight: MediaQuery.of(context).size.height * 0.12,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
                onTap: (){
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                  webController.reload();
                },
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                _connectionStatus == ConnectivityResult.none ? Icon(Icons.wifi_off_sharp): _connectionStatus == ConnectivityResult.wifi ? Icon(Icons.wifi):Icon(Icons.signal_cellular_alt_outlined)
                  ],
                )),
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Transform.scale(
          //       scale: 0.8,
          //       child: CupertinoSwitch(
          //               value: _switchGeoLocation,
          //               onChanged: (value) {
          //                 setState(() {
          //                   // if(value== false)
          //                   //   currentLocation = null;
          //                   // else{
          //                   //   currentLocation = currentLocationStored;
          //                   //   webController.evaluateJavascript("setCenter($longitude, $latitude)");
          //                   // }
          //                   _switchGeoLocation = value;
          //                 });
          //               },
          //             ),
          //     ),
          //     Text('2nd Webview', style: TextStyle(
          //       fontSize: MediaQuery.of(context).size.height * 0.014
          //     ),)
          //   ],
          // ),
        ],
        title:
        Column(
          children: [

            mapCenter == ''
                ? Text('USFS') :
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Share.share(getLocate.toString()),
              child: SelectableText.rich(
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Share.share(getLocate.toString());
                    },
                  text: "Map Center: (" + mapCenter.toString() + ")",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.011),
                ),
              ),
            ),
        // SizedBox(
        //   height: 3,
        // ),
        currentLocation == null
            ? SizedBox()
            : GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Share.share(currentLocation.toString()),
          child: SelectableText.rich(
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Share.share(currentLocation.toString());
                },
              text: 'Location: ($currentLocation)',
              style: TextStyle(
                  fontSize:
                  MediaQuery.of(context).size.height * 0.011),
            ),
          ),
        ),
        // currentLocation == null
        //     ? SizedBox()
        //     : Text(
        //         'Location: ($currentLocation)',
        //         style: TextStyle(
        //             fontSize: MediaQuery.of(context).size.height * 0.012),
        //       ),
        // SizedBox(
        //   height: 7,
        // ),
        // Text(
        //   ' Zoom Level: $getZoom',
        //   style: TextStyle(
        //       fontSize: MediaQuery.of(context).size.height * 0.011),
        // ),
          ],
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          SlidingUpPanel(
            controller: panelController,
            minHeight: panelHeightClosed,
            maxHeight: panelHeightOpen,
            panelBuilder: (controller) => PanelWidget(
              webViewController: webController,
              tabController: _tabController,
              controller: controller,
              panelController: panelController,
            ),
            onPanelSlide: (position) => setState(() {
              final panelMaxScrollExtent = panelHeightOpen - panelHeightClosed;
              febHeight = position * panelMaxScrollExtent + febHeightClosed;
              positionPanel = position;
            }),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              // onTapDown: (TapDownDetails details) => onTapDown(context, details),
              // onTapUp: (TapUpDetails details) => onTapUp(context, details),
              child: Container(
                padding: EdgeInsets.only(bottom: displayHeight * 0.18),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: !isListening
                    ? Center(child: CircularProgressIndicator())
                    : secondWebview == true ? ResizableWidget(
                  isHorizontalSeparator: true,
                  isDisabledSmartHide: false,
                  separatorColor: Colors.grey,
                  separatorSize: 4,
                  onResized: _printResizeInfo,
                      children: [
                        WebView(
                          key: _scaffoldKey,
                          initialUrl: 'http://$globalAddress:$globalPort/webviews/angular_arcgis_api_for_js_mapmodule_mobile_optimized/webview2.html',
                          javascriptMode: JavascriptMode.unrestricted,
                          javascriptChannels: Set.from([
                            JavascriptChannel(
                                name: 'messageHandler',
                                onMessageReceived: (JavascriptMessage message) async {
                                  if(message.message == 'mapCenter'){
                                    mapCenter = await webController.evaluateJavascript("returnLatLonCenter()");
                                    var center = mapCenter.split('"');
                                    var newCenter = center[0].split(',');
                                    var lats = double.parse(newCenter[0]).toStringAsFixed(3);
                                    var longs = double.parse(newCenter[1]).toStringAsFixed(3);
                                    mapCenter = 'Lat: ' + lats + ', Long: ' + longs;
                                    print(newCenter[0]);
                                    print(newCenter[1]);
                                    print(mapCenter);
                                    setState(() {});
                                  }
                                  else if(message.message == 'distance'){
                                    await webController.evaluateJavascript("callDistanceFunction()");
                                    setState(() {});
                                  }
                                  else if(message.message == 'area'){
                                    await webController.evaluateJavascript("callAreaFunction()");
                                    setState(() {});
                                  }
                                  else if(message.message == 'fl'){
                                    await webController.evaluateJavascript("addFeatureSrvice()");
                                    setState(() {});
                                  }
                                })
                          ]),
                          onWebViewCreated: (WebViewController webViewController) {
                            webControllerSecond = webViewController;
                            // webViewController.reload();
                          },
                        ),
                        WebView(
                          key: _key,
                          initialUrl: 'http://$globalAddress:$globalPort/webviews/existing_webmappingapplication_nrm-map/index.html',
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated: (WebViewController webViewController) {
                            webController = webViewController;
                            // webViewController.reload();
                          },
                          onPageFinished: (String _) async {
                            bool serviceEnabled;
                            LocationPermission permission;

                            // Test if location services are enabled.
                            serviceEnabled = await Geolocator.isLocationServiceEnabled();
                            if (!serviceEnabled) {
                              // Location services are not enabled don't continue
                              // accessing the position and request users of the
                              // App to enable the location services.
                              return Future.error('Location services are disabled.');
                            }

                            permission = await Geolocator.checkPermission();
                            if (permission == LocationPermission.denied) {
                              permission = await Geolocator.requestPermission();
                              if (permission == LocationPermission.denied) {
                                // Permissions are denied, next time you could try
                                // requesting permissions again (this is also where
                                // Android's shouldShowRequestPermissionRationale
                                // returned true. According to Android guidelines
                                // your App should show an explanatory UI now.
                                return Future.error('Location permissions are denied');
                              }
                            }

                            if (permission == LocationPermission.deniedForever) {
                              // Permissions are denied forever, handle appropriately.
                              return Future.error(
                                  'Location permissions are permanently denied, we cannot request permissions.');
                            }

                            // When we reach here, permissions are granted and we can
                            // continue accessing the position of the device.
                            getLocation = await Geolocator.getCurrentPosition();

                            getLocate = await Geolocator.getCurrentPosition();
                            var position = (getLocate.toString()).split(',');
                            var latPoint = position[0].split(' ');
                            var longPoint = position[1].split(' ');
                            var longitude = double.parse(longPoint[2]);
                            var latitude = double.parse(latPoint[1]);
                            var lat = (double.parse(latPoint[1]).toStringAsFixed(3));
                            var long = (double.parse(longPoint[2]).toStringAsFixed(3));
                            globalLongitude = longitude;
                            globalLatitude = latitude;
                            print(longitude);
                            print(latitude);
                            webController.evaluateJavascript("zoomToXy('$latitude', '$longitude', '12')");
                            setState(() {
                              currentLocation = 'Lat: ' + lat + ', Long: ' + long;
                              currentLocationStored = 'Lat: ' + lat + ', Long: ' + long;
                              _switchGeoLocation = true;
                              getLocate = 'Lat: ' + lat + ', Long: ' + long;
                              getZoom = 16.0000;
                            });

                            print(await Geolocator.getCurrentPosition());
                            // print('page finished called1');
                            //
                            // if(widget.check == 'vector'){
                            //   webController.evaluateJavascript("addVectorLayerOnMap('${widget.url}')");
                            // }
                            // else{

                            //   webController.evaluateJavascript("getRasterMap('${widget.url}')");
                            // }
                            // // webController.evaluateJavascript("getbaseMap('$urlJson')");
                            // // webController.evaluateJavascript("addGeoJson('https://mapdata.xyz/test_data/esri_places.geojson')");
                            // print('page finished called 2');
                          },
                        ),
                      ],
                    )
                    :
                // _connectionStatus == ConnectivityResult.none ?
                WebView(
                  key: _key,
                  // initialUrl:
                  // 'http://$globalAddress:$globalPort/webviews/angular_arcgis_api_for_js_mapmodule_mobile_optimized/index.html',
                  // initialUrl: 'http://$globalAddress:$globalPort/webviews/dist/heroku-test/index.html',
                  initialUrl: 'http://$globalAddress:$globalPort/webviews/existing_webmappingapplication_nrm-map/index.html',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    webController = webViewController;
                  },
                  onPageFinished: (String _) async {
                    bool serviceEnabled;
                    LocationPermission permission;
                    serviceEnabled = await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      return Future.error('Location services are disabled.');
                    }

                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        return Future.error('Location permissions are denied');
                      }
                    }

                    if (permission == LocationPermission.deniedForever) {
                      return Future.error(
                          'Location permissions are permanently denied, we cannot request permissions.');
                    }
                    getLocation = await Geolocator.getCurrentPosition();

                    getLocate = await Geolocator.getCurrentPosition();
                    var position = (getLocate.toString()).split(',');
                    var latPoint = position[0].split(' ');
                    var longPoint = position[1].split(' ');
                    var longitude = double.parse(longPoint[2]);
                    var latitude = double.parse(latPoint[1]);
                    var lat = (double.parse(latPoint[1]).toStringAsFixed(3));
                    var long = (double.parse(longPoint[2]).toStringAsFixed(3));
                    print(longitude);
                    print(latitude);
                    globalLongitude = longitude;
                    globalLatitude = latitude;
                    webController.evaluateJavascript("zoomToXy('$latitude', '$longitude', '12')");
                    setState(() {
                      currentLocation = 'Lat: ' + lat + ', Long: ' + long;
                      currentLocationStored = 'Lat: ' + lat + ', Long: ' + long;
                      _switchGeoLocation = true;
                      getLocate = 'Lat: ' + lat + ', Long: ' + long;
                      getZoom = 16.0000;
                    });

                    print(await Geolocator.getCurrentPosition());
                  },
                )
                //       : (_connectionStatus == ConnectivityResult.wifi || _connectionStatus == ConnectivityResult.mobile) ? WebView(
                //   key: _key,
                //   initialUrl: 'http://$globalAddress:$globalPort/webviews/dist/heroku-test/index.html',
                //   // initialUrl: 'http://$globalAddress:$globalPort/webviews/existing_webmappingapplication_nrm-map/index.html',
                //   javascriptMode: JavascriptMode.unrestricted,
                //   onWebViewCreated: (WebViewController webViewController) {
                //     webController = webViewController;
                //   },
                // )
                //     : WebView(
                //   key: _key,
                //   // initialUrl:
                //   // 'http://$globalAddress:$globalPort/webviews/angular_arcgis_api_for_js_mapmodule_mobile_optimized/index.html',
                //   // initialUrl: 'http://$globalAddress:$globalPort/webviews/dist/heroku-test/index.html',
                //   initialUrl: 'http://$globalAddress:$globalPort/webviews/existing_webmappingapplication_nrm-map/index.html',
                //   javascriptMode: JavascriptMode.unrestricted,
                //   onWebViewCreated: (WebViewController webViewController) {
                //     webController = webViewController;
                //   },
                //   onPageFinished: (String _) async {
                //     bool serviceEnabled;
                //     LocationPermission permission;
                //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
                //     if (!serviceEnabled) {
                //       return Future.error('Location services are disabled.');
                //     }
                //
                //     permission = await Geolocator.checkPermission();
                //     if (permission == LocationPermission.denied) {
                //       permission = await Geolocator.requestPermission();
                //       if (permission == LocationPermission.denied) {
                //         return Future.error('Location permissions are denied');
                //       }
                //     }
                //
                //     if (permission == LocationPermission.deniedForever) {
                //       return Future.error(
                //           'Location permissions are permanently denied, we cannot request permissions.');
                //     }
                //     getLocation = await Geolocator.getCurrentPosition();
                //
                //     getLocate = await Geolocator.getCurrentPosition();
                //     var position = (getLocate.toString()).split(',');
                //     var latPoint = position[0].split(' ');
                //     var longPoint = position[1].split(' ');
                //     var longitude = double.parse(longPoint[2]);
                //     var latitude = double.parse(latPoint[1]);
                //     var lat = (double.parse(latPoint[1]).toStringAsFixed(3));
                //     var long = (double.parse(longPoint[2]).toStringAsFixed(3));
                //     print(longitude);
                //     print(latitude);
                //     webController.evaluateJavascript("zoomToXy('$latitude', '$longitude', '12')");
                //     setState(() {
                //       currentLocation = 'Lat: ' + lat + ', Long: ' + long;
                //       currentLocationStored = 'Lat: ' + lat + ', Long: ' + long;
                //       _switchGeoLocation = true;
                //       getLocate = 'Lat: ' + lat + ', Long: ' + long;
                //       getZoom = 16.0000;
                //     });
                //
                //     print(await Geolocator.getCurrentPosition());
                //   },
                // ),
              ),
            ),
          ),
          // Positioned.fill(
          //   child: Align(
          //     alignment: Alignment.center,
          //     child: Icon(
          //       Icons.add,
          //       size: 20,
          //       color: Colors.grey,
          //     ),
          //   ),
          // ),
          Positioned(
            right: 20,
            bottom: febHeight,
            child: buildFAB(context),
            // child: SizedBox(),
          ),
        ],
      ),
    );
  }

  void _printResizeInfo(List<WidgetSizeInfo> dataList) {
    // ignore: avoid_print
    print(dataList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
  }

  void _openCamera(BuildContext context)  async{
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    List<int> imageBytes = File(pickedFile.path).readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    print('here is base 64 image');
    print(base64Image);
    setState(() {
      // imageFile = pickedFile!;
    });
    Navigator.pop(context);
  }

  void _openGallery(BuildContext context) async{
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    List<int> imageBytes = File(pickedFile.path).readAsBytesSync();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);

    print('here is base 64 image');
    print(base64Image);
    setState(() {
      // imageFile = pickedFile!;
    });

    Navigator.pop(context);
  }

  Future<void> _showChoiceDialog(BuildContext context)
  {
    return showDialog(context: context,builder: (BuildContext context){

      return AlertDialog(
        title: Text("Choose option",style: TextStyle(color: Colors.blue),),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Divider(height: 1,color: Colors.blue,),
              ListTile(
                onTap: (){
                  _openGallery(context);
                },
                title: Text("Gallery"),
                leading: Icon(Icons.account_box,color: Colors.blue,),
              ),

              Divider(height: 1,color: Colors.blue,),
              ListTile(
                onTap: (){
                  _openCamera(context);
                },
                title: Text("Camera"),
                leading: Icon(Icons.camera,color: Colors.blue,),
              ),
            ],
          ),
        ),);
    });
  }

  buildFAB(BuildContext context) => Column(
    children: [
      FloatingActionButton(
        onPressed: () async {
          _showChoiceDialog(context);
        },
        child: Icon(Icons.camera_alt_outlined),
        backgroundColor: Colors.blueGrey,
      ),
      SizedBox(height: 10,),
      FloatingActionButton(
        onPressed: () async {
          bool serviceEnabled;
          LocationPermission permission;

          // Test if location services are enabled.
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            // Location services are not enabled don't continue
            // accessing the position and request users of the
            // App to enable the location services.
            return Future.error('Location services are disabled.');
          }

          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              // Permissions are denied, next time you could try
              // requesting permissions again (this is also where
              // Android's shouldShowRequestPermissionRationale
              // returned true. According to Android guidelines
              // your App should show an explanatory UI now.
              return Future.error('Location permissions are denied');
            }
          }

          if (permission == LocationPermission.deniedForever) {
            // Permissions are denied forever, handle appropriately.
            return Future.error(
                'Location permissions are permanently denied, we cannot request permissions.');
          }

          // When we reach here, permissions are granted and we can
          // continue accessing the position of the device.
          getLocation = await Geolocator.getCurrentPosition();

          getLocate = await Geolocator.getCurrentPosition();
          var position = (getLocate.toString()).split(',');
          var latPoint = position[0].split(' ');
          var longPoint = position[1].split(' ');
          var longitude = double.parse(longPoint[2]);
          var latitude = double.parse(latPoint[1]);
          var lat = (double.parse(latPoint[1]).toStringAsFixed(3));
          var long = (double.parse(longPoint[2]).toStringAsFixed(3));
          print(longitude);
          print(latitude);
          webController.evaluateJavascript("zoomToXy('$latitude', '$longitude', '12')");
          setState(() {
            currentLocation = 'Lat: ' + lat + ', Long: ' + long;
            currentLocationStored = 'Lat: ' + lat + ', Long: ' + long;
            _switchGeoLocation = true;
            getLocate = 'Lat: ' + lat + ', Long: ' + long;
            getZoom = 16.0000;
          });

          print(await Geolocator.getCurrentPosition());

          // print(getLocation);
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.blueGrey,
      ),
    ],
  );

  onTapUp(BuildContext context, TapUpDetails details) async {
    var getMapZoom =
        await webController.evaluateJavascript("GL.map.getZoom();");
    var getMapCenter =
        await webController.evaluateJavascript("GL.map.getCenter();");
    var lats;
    var longs;
    var getLatLong;
    if (Platform.isIOS) {
      getLatLong = getMapCenter.split('"');
      print(getLatLong[1] + ' yes');
      print(getLatLong[3] + ' yes1');
      lats = (double.parse(getLatLong[1]).toStringAsFixed(3));
      longs = (double.parse(getLatLong[3]).toStringAsFixed(3));
    } else if (Platform.isAndroid) {
      getLatLong = getMapCenter.split('":');
      var getlats = getLatLong[1].split(',');
      var getlongs = getLatLong[2].split('}');
      lats = (double.parse(getlats[0]).toStringAsFixed(3));
      longs = (double.parse(getlongs[0]).toStringAsFixed(3));
    }
    setState(() {
      getLocate = 'Lat: ' + lats + ', Long: ' + longs;
      getZoom = double.parse((double.parse(getMapZoom)).toStringAsFixed(4));
    });
    print(getZoom);
    print(getCenter);
    print('Gesture detector working onTapUp');
    var displayWidth = MediaQuery.of(context).size.width;
    var displayHeight = MediaQuery.of(context).size.height;
    if (checkPlacemark == true) {
      String coordinatesFromMap =
          await webController.evaluateJavascript("GL.getClickedPoint();");
      print(coordinatesFromMap);
      var placeName = TextEditingController();
      var notes = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 16,
              child: Container(
                padding: EdgeInsets.only(
                    left: displayWidth * 0.02, right: displayWidth * 0.02),
                height: displayHeight * 0.6,
                width: displayWidth * 0.7,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: displayHeight * 0.04),
                    Center(
                        child: Text(
                      'Add Plaace',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                    SizedBox(height: 20),
                    getTextFieldForPlacemark('PLACE NAME', displayWidth,
                        displayHeight, 1, 1, placeName),
                    getTextFieldForPlacemark(
                        'NOTES', displayWidth, displayHeight, 3, 5, notes),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: displayHeight * 0.02),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text(
                            "Save",
                            style: TextStyle(fontSize: displayHeight * 0.02),
                          ),
                          onPressed: () async {
                            var lats;
                            var longs;
                            var getLatLong;
                            if (Platform.isIOS) {
                              getLatLong = coordinatesFromMap.split('"');
                              lats = getLatLong[1];
                              longs = getLatLong[3];
                            } else if (Platform.isAndroid) {
                              getLatLong = coordinatesFromMap.split('":');
                              var getlats = getLatLong[1].split(',');
                              var getlongs = getLatLong[2].split('}');
                              lats = getlats[0];
                              longs = getlongs[0];
                            }
                            print(lats);
                            print(longs + 'long is not defined');

                            //Add data in sqflite Database
                            Database db =
                                await DatabaseHelper.instance.database;
                            int id = await db.rawInsert(
                                'INSERT INTO Placemarks (name, notes, lat, long,) '
                                'VALUES(?, ?, ?, ?,)',
                                [
                                  placeName.text,
                                  notes.text,
                                  getLatLong[1],
                                  getLatLong[3]
                                ]);
                            //Data Added successfully
                            print(id);

                            final List<Map<String, dynamic>> mapsImpact =
                                await db.query('Placemarks');
                            print(mapsImpact);

                            setState(() {
                              placemarksList.add({
                                'name': placeName.text,
                                'notes': notes.text,
                                'lat': getLatLong[1],
                                'long': getLatLong[3]
                              });
                              Navigator.pop(context);
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
      checkPlacemark = false;
    } else if (checkPlaceMarkDetails == true &&
        checkPlaceMarksDetailsIndex != -1) {
      print(checkPlaceMarksDetailsIndex.toString() + ' else if enetered');
      print(placemarksList[checkPlaceMarksDetailsIndex]['name']);
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 16,
            child: Container(
              padding: EdgeInsets.only(
                  left: displayWidth * 0.02, right: displayWidth * 0.02),
              height: displayHeight * 0.5,
              width: displayWidth * 0.5,
              child: Column(
                children: <Widget>[
                  SizedBox(height: displayHeight * 0.04),
                  Center(
                      child: Text(
                    'Information Box',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )),
                  SizedBox(height: displayHeight * 0.04),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              placemarksList[checkPlaceMarksDetailsIndex]
                                  ['name'],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.03,
                  ),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(placemarksList[checkPlaceMarksDetailsIndex]
                                ['notes']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.03,
                  ),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Longitude',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(placemarksList[checkPlaceMarksDetailsIndex]
                                ['long']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.03,
                  ),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Latitude',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(placemarksList[checkPlaceMarksDetailsIndex]
                                ['lat']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          "Close",
                          style: TextStyle(fontSize: displayHeight * 0.02),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
      // checkPlaceMarksDetailsIndex = -1;
      checkPlaceMarkDetails = false;
    }

    checkPlacemark = false;
  }

  onTapDown(BuildContext context, TapDownDetails details) async {
    var getMapZoom =
        await webController.evaluateJavascript("GL.map.getZoom();");
    var getMapCenter =
        await webController.evaluateJavascript("GL.map.getCenter();");
    var lats;
    var longs;
    var getLatLong;
    if (Platform.isIOS) {
      getLatLong = getMapCenter.split('"');
      print(getLatLong[1] + ' yes');
      print(getLatLong[3] + ' yes1');
      lats = (double.parse(getLatLong[1]).toStringAsFixed(3));
      longs = (double.parse(getLatLong[3]).toStringAsFixed(3));
    } else if (Platform.isAndroid) {
      getLatLong = getMapCenter.split('":');
      var getlats = getLatLong[1].split(',');
      var getlongs = getLatLong[2].split('}');
      lats = (double.parse(getlats[0]).toStringAsFixed(3));
      longs = (double.parse(getlongs[0]).toStringAsFixed(3));
    }
    setState(() {
      getLocate = 'Lat: ' + lats + ', Long: ' + longs;
      getZoom = double.parse((double.parse(getMapZoom)).toStringAsFixed(4));
    });
    print(getZoom);
    print(getCenter);
    print('Gesture detector working onTapDown');
    var displayWidth = MediaQuery.of(context).size.width;
    var displayHeight = MediaQuery.of(context).size.height;
    if (checkPlacemark == true) {
      String coordinatesFromMap =
          await webController.evaluateJavascript("GL.getClickedPoint();");
      print(coordinatesFromMap + 'here is coordinates');
      var placeName = TextEditingController();
      var notes = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 16,
              child: Container(
                padding: EdgeInsets.only(
                    left: displayWidth * 0.02, right: displayWidth * 0.02),
                height: displayHeight * 0.6,
                width: displayWidth * 0.7,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: displayHeight * 0.04),
                    Center(
                        child: Text(
                      'Add Place',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                    SizedBox(height: 20),
                    getTextFieldForPlacemark('PLACE NAME', displayWidth,
                        displayHeight, 1, 1, placeName),
                    getTextFieldForPlacemark(
                        'NOTES', displayWidth, displayHeight, 3, 5, notes),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: displayHeight * 0.02),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text(
                            "Save",
                            style: TextStyle(fontSize: displayHeight * 0.02),
                          ),
                          onPressed: () async {
                            var lats;
                            var longs;
                            var getLatLong;
                            if (Platform.isIOS) {
                              getLatLong = coordinatesFromMap.split('"');
                              lats = getLatLong[1];
                              longs = getLatLong[3];
                            } else if (Platform.isAndroid) {
                              getLatLong = coordinatesFromMap.split('":');
                              var getlats = getLatLong[1].split(',');
                              var getlongs = getLatLong[2].split('}');
                              lats = getlats[0];
                              longs = getlongs[0];
                            }
                            print(lats);
                            print(longs + 'long is not defined');

                            //Add data in sqflite Database
                            Database db =
                                await DatabaseHelper.instance.database;
                            int id = await db.rawInsert(
                                'INSERT INTO Placemarks (name, notes, lat, long) '
                                'VALUES(?, ?, ?, ?)',
                                [
                                  placeName.text,
                                  notes.text,
                                  lats,
                                  longs
                                  // getLatLong[1],
                                  // getLatLong[3]
                                ]);
                            //Data Added successfully
                            print(id);

                            final List<Map<String, dynamic>> mapsImpact =
                                await db.query('Placemarks');
                            print(mapsImpact);

                            setState(() {
                              placemarksList.add({
                                'name': placeName.text,
                                'notes': notes.text,
                                'lat': lats,
                                'long': longs
                              });
                              Navigator.pop(context);
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
      checkPlacemark = false;
    } else if (checkPlaceMarkDetails == true &&
        checkPlaceMarksDetailsIndex != -1) {
      print('Hello is it entered');
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 16,
            child: Container(
              padding: EdgeInsets.only(
                  left: displayWidth * 0.02, right: displayWidth * 0.02),
              height: displayHeight * 0.5,
              width: displayWidth * 0.5,
              child: Column(
                children: <Widget>[
                  SizedBox(height: displayHeight * 0.04),
                  Center(
                      child: Text(
                    'Information Box',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )),
                  SizedBox(height: displayHeight * 0.04),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              placemarksList[checkPlaceMarksDetailsIndex]
                                  ['name'],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.03,
                  ),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(placemarksList[checkPlaceMarksDetailsIndex]
                                ['notes']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.03,
                  ),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Longitude',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(placemarksList[checkPlaceMarksDetailsIndex]
                                ['long']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.03,
                  ),
                  SizedBox(
                    height: displayHeight * 0.05,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth * 0.01,
                            right: displayWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Latitude',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(placemarksList[checkPlaceMarksDetailsIndex]
                                ['lat']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          "Close",
                          style: TextStyle(fontSize: displayHeight * 0.02),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
      // checkPlaceMarksDetailsIndex = -1;
      checkPlaceMarkDetails = false;
    }
    checkPlacemark = false;
  }

  getTextFieldForPlacemark(text, widthScreen, heightScreen, min, max, controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            controller: controller,
            maxLines: max,
            minLines: min,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  new EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
              border: UnderlineInputBorder(),
              labelText: text.toString(),
            ),
          ),
        ),
      ],
    );
  }
}
