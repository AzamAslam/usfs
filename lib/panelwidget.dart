import 'dart:convert';
import 'dart:io';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewjavascript/main.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webviewjavascript/sqliteDataBase/db_provider.dart';
import 'list_files.dart';

import 'list_files.dart';

bool checkSearch = false;
List<SelectedListItem> _listOfRegionss=[];
List<SelectedListItem> _listOfForests=[];

List<SelectedListItem> _listOfStates=[];
List<SelectedListItem> _listOfDistrict=[];

bool checkPlaceMarkDetails = false;
int checkPlaceMarksDetailsIndex = -1;

var placemarksList = [
  {'id':'0', 'name' :'Add New Placemark', 'notes': '', 'lat': '', 'long': ''},
];

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;
  final TabController tabController;
  final WebViewController webViewController;
  // int groupOverlaysWeatherValue;
  // int groupOverlaysREFValue;
  // int groupBaseValue;

  // int index;

  PanelWidget({
    this.controller,
    this.panelController,
    this.tabController,
    this.webViewController,
  });

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget>
    with SingleTickerProviderStateMixin {
  int id = 1;
  // int _groupOverlaysWeatherValue = 1;
  // int _groupOverlaysREFValue = 1;
  // int _groupBaseValue = 1;
  // int indexValue = 1;

  final _formKey = GlobalKey<FormState>();
  // final _formKey = GlobalKey<FormState>();

  var longController = TextEditingController();
  var latController = TextEditingController();

  TabController _controller;

  bool _switchValue1 = false;
  bool _switchValue2 = false;
  bool _switchValue3 = false;
  bool _switchValue4 = false;

  var ovarlaysWEATHERList = [
    {
      'index': 1,
      'textName': 'Clouds',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 2,
      'textName': 'Precipitation',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 3,
      'textName': 'Pressure',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 4,
      'textName': 'Wind',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 5,
      'textName': 'Tempature',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 6,
      'textName': 'Accumulated Snow',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 7,
      'textName': 'Depth of snow',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 8,
      'textName': 'Wind - speed,direction',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 9,
      'textName': 'Temperature',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 10,
      'textName': 'Soil temperature 0-10 сm',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 11,
      'textName': 'Soil temperature >10 сm',
      'imageName': 'basemap-bright.png',
    },
    {
      'index': 12,
      'textName': 'Relative humidity',
      'imageName': 'basemap-bright.png',
    },
  ];

  var overlaysREFList = [
    {
      'index': 1,
      'isChecked': false,
      'id': 'mgrs',
      'textName': 'MGRS',
      'imageName': 'basemap-bright.png',
      'type': 'pbf',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/reference_layers/mgrs.json',
    },
    {
      'index': 2,
      'isChecked': false,
      'id': 'gars30',
      'textName': 'Gars 30',
      'imageName': 'basemap-bright.png',
      'type': 'pbf',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/reference_layers/gars_30min.json',
    },
    {
      'index': 3,
      'isChecked': false,
      'id': 'gars30Centroid',
      'textName': 'Gars 30 Centroid',
      'imageName': 'basemap-bright.png',
      'type': 'pbf',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/reference_layers/gars_30_centroid.json',
    },
    {
      'index': 4,
      'isChecked': false,
      'id': 'timeZones',
      'textName': 'Time Zones',
      'imageName': 'basemap-bright.png',
      'type': 'pbf',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/reference_layers/timezones.json',
    },
    // {
    //   'index': 5,
    //   'isChecked': false,
    //   'id': 'osmStates',
    //   'textName': 'OSM States',
    //   'imageName': 'basemap-bright.png',
    //   'type': 'pbf',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/reference_layers/osm_states_and_major_places.json',
    // },
  ];

  // var overlaysREFList = [
  //   {
  //     'index': 1,
  //     'id': 'mgrs',
  //     'textName': 'MGRS',
  //     'imageName': 'basemap-bright.png',
  //     'type': 'pbf',
  //     'url':
  //     'http://maptileserver.xyz:8000/services/reference_layers/mgrs_grid_vectortiles',
  //   },
  //   {
  //     'index': 2,
  //     'id': 'gars30',
  //     'textName': 'Gars 30',
  //     'imageName': 'basemap-bright.png',
  //     'type': 'pbf',
  //     'url':
  //     'http://maptileserver.xyz:8000/services/reference_layers/gars_30min',
  //   },
  //   {
  //     'index': 3,
  //     'id': 'gars30Centroid',
  //     'textName': 'Gars 30 Centroid',
  //     'imageName': 'basemap-bright.png',
  //     'type': 'pbf',
  //     'url':
  //     'http://maptileserver.xyz:8000/services/reference_layers/gars30mingridcentroids_0-5',
  //   },
  //   {
  //     'index': 4,
  //     'id': 'timeZones',
  //     'textName': 'Time Zones',
  //     'imageName': 'basemap-bright.png',
  //     'type': 'pbf',
  //     'url':
  //     'http://maptileserver.xyz:8000/services/reference_layers/overlay_timezones',
  //   },
  //   {
  //     'index': 5,
  //     'id': 'osmStates',
  //     'textName': 'OSM States',
  //     'imageName': 'basemap-bright.png',
  //     'type': 'pbf',
  //     'url':
  //     'http://maptileserver.xyz:8000/services/reference_layers/usa/state_borders_line',
  //   },
  // ];

  var baseMapList = [
    {
      'index': 1,
      'textName': 'Navigation',
      'imageName': 'navigation.png',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/osm-bright-gl-style/style.json',
    },
    {
      'index': 2,
      'textName': 'Dark Gray Canvas',
      'imageName': 'darkGreyCanvas.png',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/toner-gl-style/style.json',
    },
    {
      'index': 3,
      'textName': 'Ligth Gray Canvas',
      'imageName': 'lightGreyCanvas.png',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/positron-gl-style/style.json',
    },
    {
      'index': 4,
      'textName': 'Nova',
      'imageName': 'Nova.png',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/dark-matter-gl-style/style.json',
    },
    {
      'index': 5,
      'textName': 'World Street Night',
      'imageName': 'worldStreetNigth.png',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/klokantech-basic-gl-style/style.json',
    },
    {
      'index': 6,
      'textName': 'Water Color',
      'imageName': 'waterColor.png',
      'url':
          'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/klokantech-3D/style.json',
    },
    // {
    //   'index': 7,
    //   'textName': 'Bright Opac',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/osm-bright-gl-style/style_opac.json',
    // },
    // {
    //   'index': 8,
    //   'textName': 'DarkMatter Opac',
    //   'imageName': 'basemap-darkmap-opak.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/dark-matter-gl-style/style_opac.json',
    // },
    // {
    //   'index': 9,
    //   'textName': 'Klokan Tech Opac',
    //   'imageName': 'basemap-klokantech-opak.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/klokantech-terrain-gl-style/style_opac.json',
    // },
    // {
    //   'index': 10,
    //   'textName': 'Liberty',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/osm-liberty-gl-style/style.json',
    // },
    // {
    //   'index': 11,
    //   'textName': 'Esri Satellite Hybrid',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/esri_satellite_hybrid_stylesheet.json',
    // },
    // {
    //   'index': 12,
    //   'textName': 'Here Satellite Hybrid',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/here_satellite_hybrid_stylesheet.json',
    // },
    // {
    //   'index': 13,
    //   'textName': 'Satellite Hybrid',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/esri_satellite_hybrid_stylesheet_with_hillshade_contourlines.json',
    // },
    // {
    //   'index': 14,
    //   'textName': 'Esri Satellite Hybrid 2',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/esri_satellite_hybrid_stylesheet_with_hillshade_contourlines.json',
    // },
    // {
    //   'index': 15,
    //   'textName': 'Here Satellite Hybrid 2',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/here_satellite_hybrid_stylesheet_with_hillshade_contours.json',
    // },
    // {
    //   'index': 16,
    //   'textName': 'Klokan Tech Terrain',
    //   'imageName': 'basemap-bright.png',
    //   'url':
    //       'https://techmavengeo.cloud/vectortile_stylesheets/openmaptiles/klokantech-terrain-gl-style/style.json',
    // },
  ];
void getData()async{


  String data = await DefaultAssetBundle.of(context).loadString("assets/Spatialbookmark.json");
  final jsonResult = jsonDecode(data);
  print(jsonResult[0]['NAME']);



  jsonResult.forEach((s) => items.add({
    'name': s['NAME'],
    'lat': s['yCentroid'],
    'long': s['xCentroid']
  }));
  print("This is items $items");




  // print("This is items $items");

  // for(int i=0; i<=items.length;i++){
  //   _listOfCities.add( SelectedListItem(false, items[i],));
  // }
  //Navigator.of(context).pop();
  jsonResult.forEach((s) {

    if (s['TYPE']=="Region") {
      _listOfRegionss.add( SelectedListItem(false, s['NAME'],));
      setState(() {

      });
    }
  });
  jsonResult.forEach((s) {

    if (s['TYPE']=="Forest") {
      _listOfForests.add( SelectedListItem(false, s['NAME'],));
    }
  });
  jsonResult.forEach((s) {

    if (s['TYPE']=="States") {
      _listOfStates.add( SelectedListItem(false, s['NAME'],));
    }
  });
  jsonResult.forEach((s) {

    if (s['TYPE']=="District") {
      _listOfDistrict.add( SelectedListItem(false, s['NAME'],));
    }
  });




}
  @override
  void initState() {
  getData();
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    // getPlacemarksFromDatabase();
  }

  getPlacemarksFromDatabase() async {
    print('entered yes');
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> mapsImpact = await db.query('Placemarks');
    for(int i=0; i<mapsImpact.length; i++){
      placemarksList.add({
        'id': mapsImpact[i]['id'].toString(),
        'name': mapsImpact[i]['name'],
        'notes': mapsImpact[i]['notes'],
        'lat': mapsImpact[i]['lat'],
        'long': mapsImpact[i]['long']
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var displayHeight = MediaQuery.of(context).size.height;
    var displayWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: EdgeInsets.zero,
      controller: widget.controller,
      children: [
        Container(
          padding: EdgeInsets.only(
              top: displayHeight * 0.008,
              // bottom: displayHeight * 0.4,
              left: displayWidth * 0.04,
              right: displayWidth * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.lightBlue,
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () {
                  // webController.evaluateJavascript("GL.addURLGeoJSON('https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson');");
                  // webController.evaluateJavascript("GL.measureRemove();");
                  // var urlOverlays =
                  //     'http://maptileserver.xyz:8000/services/reference_layers/mgrs_grid_vectortiles';
                  // widget.webViewController.reload();
                  widget.webViewController
                      .evaluateJavascript(
                          "GL.removeLayer('2');");
                  // widget.webViewController.evaluateJavascript("addJPGPNGWEBPLayer('https://techmavengeo.cloud/vectortile_stylesheets/reference_layers/mgrs.json, 2asa, asasas')");
                  // widget.webViewController.evaluateJavascript("setOverlays('http://maptileserver.xyz:8000/services/reference_layers/gars30mingridcentroids_0-5')");
                  // widget.webViewController.evaluateJavascript("GL.add3DTerrain();");
                  if (positionPanel == 0) {
                    widget.panelController.open();
                    print('Was open');
                  } else if (positionPanel == 1) {
                    widget.panelController.close();
                    print('was close');
                  }
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: id == 1 ? Colors.blue : Colors.transparent,
                    child: IconButton(
                      color: id == 1 ? Colors.white : Colors.grey,
                      icon: ImageIcon(AssetImage("assets/icons/Basemap.png"),),
                      onPressed: () {
                        int index = 1;

                        setState(() {
                          id = index;
                        });
                      },
                      splashRadius: 40,
                    ),
                  ),
                  Text(
                    'BaseMap',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: id == 2 ? Colors.blue : Colors.transparent,
                    child: IconButton(
                      color: id == 2 ? Colors.white : Colors.grey,
                      icon: ImageIcon(AssetImage("assets/icons/Overlays-1.png"),),
                      onPressed: () {
                        int index = 2;

                        setState(() {
                          id = index;
                        });
                      },
                      splashRadius: 40,
                    ),
                  ),
                  Text(
                    'Overlays',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: id == 5 ? Colors.blue : Colors.transparent,
                    child: IconButton(
                      color: id == 5 ? Colors.white : Colors.grey,
                      icon: ImageIcon(AssetImage("assets/icons/Placemark.png"),),
                      onPressed: () {
                        int index = 5;

                        setState(() {
                          id = index;
                        });
                      },
                      splashRadius: 40,
                    ),
                  ),
                  Text(
                    'Placemarks',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: id == 3 ? Colors.blue : Colors.transparent,
                    child: IconButton(
                      color: id == 3 ? Colors.white : Colors.grey,
                      icon: ImageIcon(AssetImage("assets/icons/Coordinate.png"),),
                      onPressed: () {
                        int index = 3;

                        setState(() {
                          id = index;
                        });
                      },
                      splashRadius: 40,
                    ),
                  ),
                  Text(
                    'Coordinate',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: <Widget>[
              //     CircleAvatar(
              //       backgroundColor: id == 4 ? Colors.blue : Colors.transparent,
              //       child: IconButton(
              //         color: id == 4 ? Colors.white : Colors.grey,
              //         icon: ImageIcon(AssetImage("assets/icons/tools.png"),),
              //         onPressed: () {
              //           int index = 4;
              //
              //           setState(() {
              //             id = index;
              //           });
              //         },
              //         splashRadius: 40,
              //       ),
              //     ),
              //     Text(
              //       'Tools',
              //       style: TextStyle(
              //         fontWeight: FontWeight.normal,
              //         fontSize: 10,
              //       ),
              //     )
              //   ],
              // ),
            ],
          ),
        ),
        SizedBox(
          height: displayHeight * 0.03,
        ),
        id == 1
            ? getBaseMap(displayWidth, displayHeight)
            : id == 2
                ? getOverlays(displayWidth, displayHeight)
                : id == 3
                    ? setCoordinate(displayWidth, displayHeight)
                    : id == 4
                        ? getTools(displayWidth, displayHeight)
                        : id == 5
                            ? getPlacemarks(displayWidth, displayHeight)
                            : Center(
                                child: Text('Nothis is here to display'),
                              ),
      ],
    );
  }

  getPlacemarks(displayWidth, displayHeight) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Container(
        height: displayHeight *0.5,
        padding: EdgeInsets.all(10),
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: placemarksList.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onTap: () async {

                    // if(placemarksList[index]['name']=='Add New Placemark'){
                    //   Text("jdkad");
                    // setState(() {
                    //   checkPlacemark = true;
                    // });
                    // widget.panelController.close();
                    // }

                    // String coordinatesFromMap = await webController.evaluateJavascript("GL.getClickedPoint();");
                    // String coordinatesFromMap = 'hello';
                    // print(coordinatesFromMap);
                    // if(coordinatesFromMap!=null && coordinatesFromMap !='' && placemarksList[index]['name']=='Add New Placemark'){
                    //   var placeName = TextEditingController();
                    //   var notes = TextEditingController();
                    //   showDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return Dialog(
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(20)),
                    //         elevation: 16,
                    //         child: Container(
                    //           padding: EdgeInsets.only(left: displayWidth*0.02, right: displayWidth*0.02),
                    //           height: displayHeight * 0.5,
                    //           width: displayWidth * 0.7,
                    //           child: Column(
                    //             children: <Widget>[
                    //               SizedBox(height: displayHeight*0.06),
                    //               Center(
                    //                   child: Text(
                    //                     'Add Place',
                    //                     style: TextStyle(
                    //                         fontWeight: FontWeight.bold, fontSize: 20),
                    //                   )),
                    //               SizedBox(height: 20),
                    //               getTextFieldForPlacemark('PLACE NAME', displayWidth, displayHeight, 1, 1, placeName),
                    //               getTextFieldForPlacemark('NOTES', displayWidth, displayHeight, 3, 5, notes),
                    //               SizedBox(
                    //                 height: 10,
                    //               ),
                    //
                    //               Row(
                    //                 // crossAxisAlignment: CrossAxisAlignment.end,
                    //                 mainAxisAlignment: MainAxisAlignment.end,
                    //                 children: [
                    //                   TextButton(
                    //                     child: Text("Cancel", style: TextStyle(
                    //                         fontSize: displayHeight*0.02
                    //                     ),),
                    //                     onPressed:  () {
                    //                       Navigator.pop(context);
                    //                     },
                    //                   ),
                    //                   TextButton(
                    //                     child: Text("Save", style: TextStyle(
                    //                         fontSize: displayHeight*0.02
                    //                     ),),
                    //                     onPressed:  () {
                    //                       setState(() {
                    //                         placemarksList.add({'name':placeName.text,'notes': notes.text});
                    //                         Navigator.pop(context);
                    //                       });
                    //                     },
                    //                   )
                    //                 ],
                    //               )
                    //             ],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   );
                    // }
                    // if(placemarksList[index]['name']!='Add New Placemark')
                    // else{
                    //   String name = placemarksList[index]['name'];
                    //   var passLong = placemarksList[index]['long'];
                    //   var passLat = placemarksList[index]['lat'];
                    //   print(name);
                    //   print(passLong+'Hello long');
                    //   print(passLat+'Hello lat');
                    //   webController.evaluateJavascript(
                    //       "setPlacemark('$name', $passLong, $passLat)");
                    //   checkPlaceMarkDetails = true;
                    //   checkPlaceMarksDetailsIndex = index;
                    //   widget.panelController.close();
                    // }

                    // webController.evaluateJavascript('getClickedMethod()');
                    // widget.panelController.close();
                  },
                  child: Dismissible(
                    key: Key(placemarksList[index]['name']),
                    onDismissed: (direction) async {

                      print(placemarksList[index]['id']);
                      //Remove row from database
                      Database db = await DatabaseHelper.instance.database;
                      db.delete("Placemarks", where: "id = ?", whereArgs: [placemarksList[index]['id']]);

                      setState(() {
                        if(placemarksList[index]['name']!='Add New Placemark'){
                          placemarksList.removeAt(index);
                        }
                      });

                      Fluttertoast.showToast(
                          msg: "Placemark deleted",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                      );
                      // Then show a snackbar.
                      // ScaffoldMessenger.of(context)
                      //     .showSnackBar(SnackBar(content: Text('$placemarksList[$index][name] dismissed')));
                    },
                    child:Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           getCircle("Forests"),

                           getCircle("US States"),
                           getCircle("Regions"),
                           getCircle("Districts"),

                           // getPlacemarkListName(placemarksList[index]['name'], displayWidth, displayHeight),

                          ],
                        ),

                      ],
                    )

                  ),
              );
            }),
      ),
    );
  }
Widget getCircle(name){
    return  InkWell(
      onTap: ()async{
        DropDownState(
          DropDown(
            submitButtonText: "kDone",
            submitButtonColor: const Color.fromRGBO(70, 76, 222, 1),
            searchHintText: "Search Name",
            bottomSheetTitle: "",
            searchBackgroundColor: Colors.black12,
            dataList:(name=="Forests")?_listOfForests:(name=="Regions")?_listOfRegionss:(name=="US States")?_listOfStates:(name=="Districts")?_listOfDistrict:[] ,
            selectedItems: (List<dynamic> selectedList) {
              var lat,long;
              var  names=selectedList.toString();
              for(int i=0;i<items.length;i++){
                if(items[i]['name']=="$names"){
                  // print(widget.mapList.indexOf(widget.mapList[0]['name']));
                  print(items[i]['long']);
                  long=items[i]['long'];
                  lat=items[i]['lat'];

                  // break;
                  //print()
                }else{
                  print("not found");
                }

              }
              print("here");
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyWidget()));

              webController.evaluateJavascript("zoomToXy('$lat', '$long', '12')");


              //showSnackBar(selectedList.toString());

              //Navigator.push(context, MaterialPageRoute(builder: (context)=>MyWidget()));

            },
            selectedItem: (String selected) {
              //  showSnackBar(selected);
              var lat,long;
              //  names=selected.toString();
              for(int i=0;i<items.length;i++){
                if(items[i]['name']=="$selected"){
                  // print(widget.mapList.indexOf(widget.mapList[0]['name']));
                  print(items[i]['long']);
                  long=items[i]['long'];
                  lat=items[i]['lat'];

                  // break;
                  //print()
                }else{
                  print("not found");
                }

              }
              print("here");
              print(lat);
              print(long);
              webController.evaluateJavascript("zoomToXy('$lat', '$long', '12')");

              setState(() {
                // longg=long;
              });

             ///Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));


              print("Navigate");


            },
            enableMultipleSelection: false,
            // searchController: _searchTextEditingController,
          ),
        ).showModal(context);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage:
            AssetImage('assets/map.png'),
            backgroundColor: Colors.transparent,
          ),
          Text("$name"),
        ],
      ),
    );
}
  // getPlacemarkInformationBox( displayWidth, displayHeight) => InkWell(
  //   onTap: () async {
  //     // String html = await webController.evaluateJavascript("window.document.getElementsByTagName('html')[0].outerHTML;");
  //     String coordinatesFromMap = await webController.evaluateJavascript("myFunction()");
  //     if(coordinatesFromMap!=null && coordinatesFromMap !=''){
  //
  //     }
  //     print(coordinatesFromMap);
  //     // webController.evaluateJavascript('getClickedMethod()');
  //     // widget.panelController.close();
  //   },
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Divider(),
  //       Text(
  //         text,
  //         style: TextStyle(fontSize: 18),
  //       ),
  //       Divider(),
  //     ],
  //   ),
  // );

  getPlacemarkListName(text, displayWidth, displayHeight) => InkWell(

    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            Text(
              text,
              style: TextStyle(fontSize: 18),
            ),
            Divider(),
          ],
        ),
  );

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
              contentPadding: new EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
              border: UnderlineInputBorder(),
              labelText: text.toString(),
            ),
          ),
        ),
      ],
    );
  }



  getTools(displayWidth, displayHeight) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          // Container(
          //   height: displayHeight * 0.1,
          //   child: Card(
          //     child: InkWell(
          //       splashColor: Colors.blue.withAlpha(30),
          //       onTap: () {
          //         print('Draw Tools');
          //       },
          //       child: Row(
          //         children: [
          //           ImageIcon(
          //             AssetImage("assets/icons/draw.png"),
          //             color: Colors.green,
          //             size: 50,
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Text(
          //             'Draw Tools',
          //             style: TextStyle(fontSize: 16),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Container(
          //   height: displayHeight * 0.1,
          //   child: Card(
          //     child: InkWell(
          //       splashColor: Colors.blue.withAlpha(30),
          //       onTap: () {
          //         showDialog(
          //           context: context,
          //           builder: (context) {
          //             return Dialog(
          //               shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(20)),
          //               elevation: 16,
          //               child: Container(
          //                 height: displayHeight * 0.3,
          //                 width: displayWidth * 0.04,
          //                 child: Column(
          //                   children: <Widget>[
          //                     SizedBox(height: 20),
          //                     Center(
          //                         child: Text(
          //                       'Select Pencil Style',
          //                       style: TextStyle(
          //                           fontWeight: FontWeight.bold, fontSize: 20),
          //                     )),
          //                     SizedBox(height: 20),
          //                     getOptionForPencil(
          //                         'assets/icons/point_style.png',
          //                         'Point',
          //                         displayWidth,
          //                         displayHeight,
          //                         'point'),
          //                     getOptionForPencil(
          //                         'assets/icons/line_style.png',
          //                         'Line',
          //                         displayWidth,
          //                         displayHeight,
          //                         'line'),
          //                     getOptionForPencil(
          //                         'assets/icons/polygon_style.png',
          //                         'Polygone',
          //                         displayWidth,
          //                         displayHeight,
          //                         'polygone'),
          //                     SizedBox(
          //                       height: 10,
          //                     )
          //                   ],
          //                 ),
          //               ),
          //             );
          //           },
          //         );
          //       },
          //       child: Row(
          //         children: [
          //           ImageIcon(
          //             AssetImage("assets/icons/pencil.png"),
          //             color: Colors.blue,
          //             size: 50,
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Text(
          //             'Linear',
          //             style: TextStyle(fontSize: 16),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Container(
            height: displayHeight * 0.1,
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  webController.evaluateJavascript(
                      "GL.startLineMeasure();");
                  // webController.evaluateJavascript("GL.startAreaMeasure();");
                  widget.panelController.close();
                  print('Line Measure');
                },
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage("assets/icons/line_style.png"),
                      color: Colors.blue,
                      size: 50,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Line Measure',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: displayHeight * 0.1,
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  webController.evaluateJavascript("GL.startAreaMeasure();");
                  widget.panelController.close();
                  print('Area Measure');
                },
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage("assets/icons/ruler.png"),
                      color: Colors.yellow,
                      size: 50,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Area Measure',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: displayHeight * 0.1,
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  webController.evaluateJavascript("GL.measureRemove();");
                  widget.panelController.close();
                  print('Remove measurments');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      color: Colors.grey,
                      size: 50,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Remove Measurements',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  setCoordinate(displayWidth, displayHeight) => Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            width: displayWidth,
            height: displayHeight * 0.5,
            padding: EdgeInsets.only(
                top: displayHeight * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Enter Coordinate',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: displayHeight * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Longitude: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Container(
                      height: displayHeight * 0.05,
                      width: displayWidth * 0.5,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Longitude';
                          }
                          return null;
                        },
                        controller: longController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9-.,]')),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Longitude',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          hintStyle: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: displayHeight * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Latitude:    ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Container(
                      height: displayHeight * 0.05,
                      width: displayWidth * 0.5,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Latitude';
                          }
                          return null;
                        },
                        controller: latController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Latitude',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          hintStyle: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: displayHeight * 0.02,
                ),
                Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  width: displayWidth * 0.3,
                  height: displayHeight * 0.05,
                  decoration: BoxDecoration(
                    // color: Color.fromRGBO(205,201,51,1),
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(
                    //     color: Color.fromRGBO(205,201,51,1,)
                    //   // width: 5,
                    // )
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text('Processing Data')),
                        // );
                      }
                      // if (longController.text.isEmpty) {
                      //   Fluttertoast.showToast(msg: "Enter Longitude");
                      //   return;
                      // }
                      var long = longController.text;
                      if (longController.text == null) {
                        return;
                        // Navigator.pop(context, longController.text);
                      }
                      var lat = latController.text;
                      webController
                          .evaluateJavascript("setCenter($long, $lat)");
                      widget.panelController.close();
                      // Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const Accessories()),
                      // );
                    },
                    color: Colors.blue,
                    child: const Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  getBaseMap(displayWidth, displayHeight) => SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                // physics: AlwaysScrollableScrollPhysics(),
                // scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: baseMapList.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Radio(
                          // value: baseMapList[i]['index'],
                          value: i + 1,
                          groupValue: groupBaseValue,
                          onChanged: (value) {
                            setState(() {
                              print('Set State working now');
                              print(value);
                              groupBaseValue = value;
                              print(groupBaseValue);
                              print('Set State working after');
                            });
                            String url = baseMapList[i]['url'];
                            widget.webViewController
                                .evaluateJavascript("setBasemap('$url')");
                            webController.evaluateJavascript("GL.add3DTerrain();");
                            print(i + 1);
                            print(groupBaseValue);
                          },
                        ),
                        Text(
                          baseMapList[i]['textName'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          height: displayHeight * 0.1,
                          width: displayWidth * 0.2,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.black38,
                            ),
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/img/' + baseMapList[i]['imageName'],
                              ),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      );

  getOverlays(displayWidth, displayHeight) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: displayHeight * 0.03,
              child: TabBar(
                controller: widget.tabController,
                isScrollable: true,
                labelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  new Container(
                    height: displayHeight * 1.58,
                    width: displayWidth * 0.1,
                    child: new Tab(text: 'REF'),
                  ),
                  // new Container(
                  //   width: displayWidth * 0.18,
                  //   child: new Tab(text: 'WEATHER'),
                  // ),
                  // new Container(
                  //   width: displayWidth * 0.12,
                  //   child: new Tab(text: 'GRIDS'),
                  // ),
                ],
              ),
            ),
            Container(
              height: widget.tabController.index == 0 ? displayHeight * 0.53 : widget.tabController.index == 1 ? displayHeight * 1.56 : displayHeight * 0.525,
              decoration: BoxDecoration(color: Colors.grey),
              child: new TabBarView(
                controller: widget.tabController,
                children: <Widget>[
                  Container(
                    height: displayHeight * 0.6,
                    child: Column(
                      children: [
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            // physics: AlwaysScrollableScrollPhysics(),
                            // scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: overlaysREFList.length,
                            itemBuilder: (context, i) {
                              return Container(
                                padding: EdgeInsets.only(
                                  top: displayHeight * 0.02,
                                  left: displayWidth * 0.04,
                                  right: displayWidth * 0.04,
                                ),
                                child: Material(
                                  color: Colors.white,
                                  child: ListTile(
                                    tileColor: Colors.white,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Radio(
                                        //   value: overlaysREFList[i]['index'],
                                        //   groupValue: groupOverlaysREFValue,
                                        //   onChanged: (value) {
                                        //     var idOverlay =
                                        //         overlaysREFList[i]['id'];
                                        //     var nameOverlay =
                                        //         overlaysREFList[i]['textName'];
                                        //     var urlOverlay =
                                        //         overlaysREFList[i]['url'];
                                        //     print(
                                        //         "setOverlays('$urlOverlay.$runtimeType, $idOverlay, $nameOverlay')");
                                        //     // widget.webViewController
                                        //     //     .evaluateJavascript(
                                        //     //         "setOverlays('$urlOverlay', '$idOverlay', '$nameOverlay',)");
                                        //     widget.webViewController
                                        //         .evaluateJavascript("setBasemap('$urlOverlay')");
                                        //     setState(() {
                                        //       groupOverlaysREFValue = value;
                                        //     });
                                        //     print(overlaysREFList[i]['index']);
                                        //     print(groupOverlaysREFValue);
                                        //   },
                                        // ),
                                      Checkbox(
                                      value: overlaysREFList[i]['isChecked'],
                                      onChanged: (bool value) {
                                        var idOverlay =
                                        overlaysREFList[i]['id'];
                                        var nameOverlay =
                                        overlaysREFList[i]['textName'];
                                        var urlOverlay =
                                        overlaysREFList[i]['url'];
                                        // widget.webViewController
                                        //     .evaluateJavascript("setBasemap('$urlOverlay')");
                                        print(overlaysREFList[i]['index']);
                                        print(groupOverlaysREFValue);
                                        setState(() {
                                          if(value == true)
                                          widget.webViewController
                                              .evaluateJavascript(
                                              "setOverlays('$urlOverlay', '$idOverlay', '$nameOverlay',)");
                                          else
                                            webController.evaluateJavascript("GL.removeOverlays('$idOverlay');");
                                          overlaysREFList[i]['isChecked'] = value;
                                        });
                                      },
                                    ),
                                        Text(
                                          overlaysREFList[i]['textName'],
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Container(
                                          height: displayHeight * 0.1,
                                          width: displayWidth * 0.2,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.black38,
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                'assets/img/' +
                                                    overlaysREFList[i]
                                                        ['imageName'],
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                  // Container(
                  //   child: Column(
                  //     children: [
                  //       ListView.builder(
                  //           physics: NeverScrollableScrollPhysics(),
                  //           // physics: AlwaysScrollableScrollPhysics(),
                  //           // scrollDirection: Axis.vertical,
                  //           shrinkWrap: true,
                  //           itemCount: ovarlaysWEATHERList.length,
                  //           itemBuilder: (context, i) {
                  //             return Container(
                  //               padding: EdgeInsets.only(
                  //                 top: displayHeight * 0.02,
                  //                 left: displayWidth * 0.04,
                  //                 right: displayWidth * 0.04,
                  //               ),
                  //               child: Material(
                  //                 color: Colors.white,
                  //                 child: ListTile(
                  //                   tileColor: Colors.white,
                  //                   title: Row(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.spaceBetween,
                  //                     children: [
                  //                       Radio(
                  //                         value: ovarlaysWEATHERList[i]
                  //                             ['index'],
                  //                         groupValue: groupOverlaysWeatherValue,
                  //                         onChanged: (value) {
                  //                           setState(() {
                  //                             groupOverlaysWeatherValue = value;
                  //                           });
                  //                         },
                  //                       ),
                  //                       Text(
                  //                         ovarlaysWEATHERList[i]['textName'],
                  //                         style: TextStyle(
                  //                           fontSize: 20,
                  //                         ),
                  //                       ),
                  //                       Container(
                  //                         height: displayHeight * 0.1,
                  //                         width: displayWidth * 0.2,
                  //                         decoration: BoxDecoration(
                  //                           border: Border.all(
                  //                             width: 2,
                  //                             color: Colors.black38,
                  //                           ),
                  //                           image: DecorationImage(
                  //                             image: AssetImage(
                  //                               'assets/img/' +
                  //                                   ovarlaysWEATHERList[i]
                  //                                       ['imageName'],
                  //                             ),
                  //                             fit: BoxFit.fill,
                  //                           ),
                  //                           shape: BoxShape.circle,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ),
                  //             );
                  //             SizedBox(
                  //               height: 20,
                  //             );
                  //           }),
                  //     ],
                  //   ),
                  // ),
                  //'http://$globalAddress:$globalPort/webviews/vector_gis_data_convert_to_geojson_webpage_clientsidejs-master/index.html'
                  // new Card(
                  //   child: Column(
                  //     children: [
                  //       new ListTile(
                  //         tileColor: Colors.grey,
                  //         leading: CupertinoSwitch(
                  //           value: _switchValue1,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _switchValue1 = value;
                  //             });
                  //           },
                  //         ),
                  //         title: new Text(
                  //           'pluscode',
                  //           style: TextStyle(
                  //             fontSize: 20,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: displayHeight * 0.01),
                  //       new ListTile(
                  //         tileColor: Colors.grey,
                  //         leading: CupertinoSwitch(
                  //           value: _switchValue2,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _switchValue2 = value;
                  //             });
                  //           },
                  //         ),
                  //         title: new Text(
                  //           'gars',
                  //           style: TextStyle(
                  //             fontSize: 20,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: displayHeight * 0.01),
                  //       new ListTile(
                  //         tileColor: Colors.grey,
                  //         leading: CupertinoSwitch(
                  //           value: _switchValue3,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _switchValue3 = value;
                  //             });
                  //           },
                  //         ),
                  //         title: new Text(
                  //           'what3words',
                  //           style: TextStyle(
                  //             fontSize: 20,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: displayHeight * 0.01),
                  //       new ListTile(
                  //         tileColor: Colors.grey,
                  //         leading: CupertinoSwitch(
                  //           value: _switchValue4,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _switchValue4 = value;
                  //             });
                  //           },
                  //         ),
                  //         title: new Text(
                  //           'mgrs',
                  //           style: TextStyle(
                  //             fontSize: 20,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      );

// child: Column(
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             // FlatButton(
//             //   height: 50,
//             //   child: Text('All Posts'),
//             //   shape: Border(
//             //       bottom: BorderSide(color: Colors.black, width: 3)
//             //   ),
//             //   onPressed: (){
//             //     print('You selected all posts');
//             //   },
//             // ),
//             // TextButton(child: Text('REF', )),
//             // SizedBox(width: displayWidth*0.01,),
//             // ElevatedButton(child: Text('WEATHER')),
//             // ElevatedButton(child: Text('GRIDS')),
//           ],
//         ),
//         ListTile(
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('new Overlays here'),
//               Container(
//                 height: displayHeight * 0.1,
//                 width: displayWidth * 0.8,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/basemap/4.jpeg'),
//                     fit: BoxFit.fill,
//                   ),
//                   shape: BoxShape.rectangle,
//                 ),
//               ),
//             ],
//           ),
//           leading: Radio(
//             value: 1,
//             groupValue: _groupValue,
//             onChanged: (value) {
//               setState(() {
//                 _groupValue = value;
//               });
//             },
//           ),
//         ),
//         ListTile(
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('new Overlays here'),
//               Container(
//                 height: displayHeight * 0.1,
//                 width: displayWidth * 0.8,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/basemap/3.jpeg'),
//                     fit: BoxFit.fill,
//                   ),
//                   shape: BoxShape.rectangle,
//                 ),
//               ),
//             ],
//           ),
//           leading: Radio(
//             value: 2,
//             groupValue: _groupValue,
//             onChanged: (value) {
//               setState(() {
//                 _groupValue = value;
//               });
//             },
//           ),
//         ),
//         ListTile(
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('new Overlays here'),
//               Container(
//                 height: displayHeight * 0.1,
//                 width: displayWidth * 0.8,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/basemap/2.png'),
//                     fit: BoxFit.fill,
//                   ),
//                   shape: BoxShape.rectangle,
//                 ),
//               ),
//             ],
//           ),
//           leading: Radio(
//             value: 3,
//             groupValue: _groupValue,
//             onChanged: (value) {
//               setState(() {
//                 _groupValue = value;
//               });
//             },
//           ),
//         ),
//       ],
//     ),

  // Container(
  // padding: EdgeInsets.only(
  // top: displayHeight * 0.02,
  // left: displayWidth * 0.04,
  // right: displayWidth * 0.04),
  // // height: displayHeight * 0.62,
  // child: ,
  // ),
  // new Card(
  // color: Colors.grey,
  // child: Column(
  // children: [
  // new ListTile(
  // tileColor: Colors.white,
  // title: Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // children: [
  // Radio(
  // value: 1,
  // groupValue: _groupValue,
  // onChanged: (value) {
  // setState(() {
  // _groupValue = value;
  // });
  // },
  // ),
  // Column(
  // children: [
  // Text(
  // 'MGRS',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.02,
  // ),
  // Text(
  // 'Mbtile Layer',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // ],
  // ),
  // Container(
  // height: displayHeight * 0.1,
  // width: displayWidth * 0.2,
  // decoration: BoxDecoration(
  // border: Border.all(
  // width: 2,
  // color: Colors.black38,
  // ),
  // image: DecorationImage(
  // image: AssetImage(
  // 'assets/img/basemap-bright.png',
  // ),
  // fit: BoxFit.fill,
  // ),
  // shape: BoxShape.circle,
  // ),
  // ),
  // ],
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.01,
  // ),
  // ListTile(
  // tileColor: Colors.white,
  // title: Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // children: [
  // Radio(
  // value: 2,
  // groupValue: _groupValue,
  // onChanged: (value) {
  // setState(() {
  // _groupValue = value;
  // });
  // },
  // ),
  // Column(
  // children: [
  // Text(
  // 'Gars 30',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.02,
  // ),
  // Text(
  // 'Mbtile Layer',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // ],
  // ),
  // Container(
  // height: displayHeight * 0.1,
  // width: displayWidth * 0.2,
  // decoration: BoxDecoration(
  // border: Border.all(
  // width: 2,
  // color: Colors.black38,
  // ),
  // image: DecorationImage(
  // image: AssetImage(
  // 'assets/img/basemap-bright.png',
  // ),
  // fit: BoxFit.fill,
  // ),
  // shape: BoxShape.circle,
  // ),
  // ),
  // ],
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.01,
  // ),
  // ListTile(
  // tileColor: Colors.white,
  // title: Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // children: [
  // Radio(
  // value: 3,
  // groupValue: _groupValue,
  // onChanged: (value) {
  // setState(() {
  // _groupValue = value;
  // });
  // },
  // ),
  // Column(
  // children: [
  // Text(
  // 'Gars 30 Centroid',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.02,
  // ),
  // Text(
  // 'Mbtile Layer',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // ],
  // ),
  // Container(
  // height: displayHeight * 0.1,
  // width: displayWidth * 0.2,
  // decoration: BoxDecoration(
  // border: Border.all(
  // width: 2,
  // color: Colors.black38,
  // ),
  // image: DecorationImage(
  // image: AssetImage(
  // 'assets/img/basemap-bright.png',
  // ),
  // fit: BoxFit.fill,
  // ),
  // shape: BoxShape.circle,
  // ),
  // ),
  // ],
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.01,
  // ),
  // ListTile(
  // tileColor: Colors.white,
  // title: Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // children: [
  // Radio(
  // value: 4,
  // groupValue: _groupValue,
  // onChanged: (value) {
  // setState(() {
  // _groupValue = value;
  // });
  // },
  // ),
  // Column(
  // children: [
  // Text(
  // 'Time Zones',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.02,
  // ),
  // Text(
  // 'Mbtile Layer',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // ],
  // ),
  // Container(
  // height: displayHeight * 0.1,
  // width: displayWidth * 0.2,
  // decoration: BoxDecoration(
  // border: Border.all(
  // width: 2,
  // color: Colors.black38,
  // ),
  // image: DecorationImage(
  // image: AssetImage(
  // 'assets/img/basemap-bright.png',
  // ),
  // fit: BoxFit.fill,
  // ),
  // shape: BoxShape.circle,
  // ),
  // ),
  // ],
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.01,
  // ),
  // ListTile(
  // tileColor: Colors.white,
  // title: Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // children: [
  // Radio(
  // value: 5,
  // groupValue: _groupValue,
  // onChanged: (value) {
  // setState(() {
  // _groupValue = value;
  // });
  // },
  // ),
  // Column(
  // children: [
  // Text(
  // 'OSM States',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // SizedBox(
  // height: displayHeight * 0.02,
  // ),
  // Text(
  // 'Mbtile Layer',
  // style: TextStyle(
  // fontSize: 20,
  // ),
  // ),
  // ],
  // ),
  // Container(
  // height: displayHeight * 0.1,
  // width: displayWidth * 0.2,
  // decoration: BoxDecoration(
  // border: Border.all(
  // width: 2,
  // color: Colors.black38,
  // ),
  // image: DecorationImage(
  // image: AssetImage(
  // 'assets/img/basemap-bright.png',
  // ),
  // fit: BoxFit.fill,
  // ),
  // shape: BoxShape.circle,
  // ),
  // ),
  // ],
  // ),
  // ),
  // ],
  // ),
  // )

  getOptionForPencil(icon, text, widthScreen, heightScreen, string) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        height: heightScreen * 0.06,
        child: Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              if(string == 'point')
              webController.evaluateJavascript(
                  "GL.drawLine();");
              else if(string == 'line')
                webController.evaluateJavascript(
                    "GL.startLineMeasure();");
              else if(string == 'polygone')
                webController.evaluateJavascript(
                    "GL.drawPolygon();");
              Navigator.pop(context);
              widget.panelController.close();
              print(string);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.asset(
                    icon,
                    height: 20,
                  ),
                  SizedBox(
                    width: widthScreen * 0.04,
                  ),
                  Text(
                    text,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
