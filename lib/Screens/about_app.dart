import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    var displayWidth = MediaQuery.of(context).size.width;
    var displayHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('About App'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Center(
                child: Text('Map Data Explorer Cross Platform Mapping App', style: TextStyle(
                  fontSize: displayHeight*0.02,
                  fontWeight: FontWeight.bold
                ),),
              ),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Map Data Explorer is a mapping app powered by vector tile basemaps (MapTiler Data and MapBox) with configurable stylesheets', style: TextStyle(
                    fontSize: displayHeight*0.015
                  ),),
                  Text('Supports user loaded device GeoJSON', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  SizedBox(height: 10,),
                  Text('Supports user loaded Map Catalog (JSON) of internet mapping content', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      getBullet(),
                      SizedBox(width: 10,),
                      Text('XYZ PNG/JPG Raster Tiles', style: TextStyle(
                          fontSize: displayHeight*0.015
                      ),),
                    ],
                  ),
                  Row(
                    children: [
                      getBullet(),
                      SizedBox(width: 10,),
                      Text('PBF Vector Tiles', style: TextStyle(
                          fontSize: displayHeight*0.015
                      ),),
                    ],
                  ),
                  Row(
                    children: [
                      getBullet(),
                      SizedBox(width: 10,),
                      Text('GeoJSON', style: TextStyle(
                          fontSize: displayHeight*0.015
                      ),),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('Includes additional layers users can enable:vector overlays (Reference Grids, TimeZones and US State Boundaries)', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  Text('Weather Overlays from OpenWeatherMap', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  SizedBox(height: 10,),
                  Text('Map Supports Tilting to display 3D terrain and 3D Buildings', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  SizedBox(height: 10,),
                  Text('Map includes Search - Search for Address, Place name using Mapbox', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  SizedBox(height: 10,),
                  Text('Map Includes Go to Coordinate', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  SizedBox(height: 10,),
                  Text('Includes an in-app vector converter to convert GIS data (Shapefiles, GPKG, GPX, KML, CSV, WKT to GeoJSON) must be 4326', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),
                  SizedBox(height: 10,),
                  Text('Includes in-app coordinate converter to convert to /from different coordinate systems and GRIDS (MGRS,GARS, etc)', style: TextStyle(
                      fontSize: displayHeight*0.015
                  ),),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
  
  getBullet() => Container(
    height: 10.0,
    width: 10.0,
    decoration: new BoxDecoration(
      color: Colors.black,
      shape: BoxShape.circle,
    ),
  );


  getTab(displayWidth, displayHeight, text, link) => Row(
    children: [
      Text(text, style: TextStyle(
          fontSize: displayHeight*0.015
      ),),
      InkWell(
          child: new Text(link, style: TextStyle(
              fontSize: displayHeight*0.015,
              color: Colors.blue
          ),),
          onTap: () => launch(link)
      ),
    ],
  );

  getMobile(displayWidht, displayHeight, text, link) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text, style: TextStyle(
        fontSize: displayHeight*0.015,
      ),),
      InkWell(
          child: new Text(link, style: TextStyle(
              fontSize: displayHeight*0.015,
              color: Colors.blue
          ),),
          onTap: () => launch(link)
      ),
    ],
  );
  
}
