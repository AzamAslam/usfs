import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:flutter/material.dart';

import 'catalog_list.dart';
import 'layer_management_list.dart';

class LayerManagement extends StatefulWidget {
  const LayerManagement({Key key}) : super(key: key);

  @override
  _LayerManagementState createState() => _LayerManagementState();
}

class _LayerManagementState extends State<LayerManagement> {
  @override
  Widget build(BuildContext context) {
    var displayHeight = MediaQuery.of(context).size.height;
    var displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        height: displayHeight,
        width: displayWidth,
        padding: EdgeInsets.fromLTRB(displayWidth*0.1, displayHeight*0.12, displayWidth*0.1, displayHeight*0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/icons/layer_logo.png', height: displayHeight*0.1,),
            Text('Layer Management', style: TextStyle(
              fontSize: displayHeight*0.02,
            ),),
            SizedBox(height: displayHeight*0.04,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LayerManagementList(icn: 'assets/icons/GEO_JSON.png', layerName: 'GEOJSON', color: Color.fromRGBO(245,244,249,1),)),
                );
              },
              child: Card(
                child: ListTile(
                leading: Image.asset('assets/icons/GEO_JSON.png', height: displayHeight*0.035,),
                title:  Text('GEOJSON', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
                // trailing: Icon(Icons.add, color: Color.fromRGBO(23,41,158,1), size: displayHeight*0.04,),
                tileColor: Color.fromRGBO(245,244,249,1)
              ),),
            ),
            SizedBox(height: displayHeight*0.04,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LayerManagementList(icn: 'assets/icons/MVT_PBF.png', layerName: 'MVT/PBF', color: Color.fromRGBO(255,242,225,1),)),
                );
              },
              child: Card(child: ListTile(
                leading: Image.asset('assets/icons/MVT_PBF.png', height: displayHeight*0.035,),
                title:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MVT/PBF', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
                    Text('Vector Tiles'),
                  ],
                ),
                // trailing: Icon(Icons.add, color: Color.fromRGBO(23,41,158,1), size: displayHeight*0.04,),
                tileColor: Color.fromRGBO(255,242,225,1),
              ),),
            ),
            SizedBox(height: displayHeight*0.04,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LayerManagementList(icn: 'assets/icons/IMAGE.png', layerName: 'JPG/PNG/WEBP', color: Color.fromRGBO(243,251,238,1),)),
                );
              },
              child: Card(child: ListTile(
                leading: Image.asset('assets/icons/IMAGE.png', height: displayHeight*0.035,),
                title:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('JPG/PNG/WEBP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
                    Text('XYZ Raster'),
                  ],
                ),
                // trailing: Icon(Icons.add, color: Color.fromRGBO(23,41,158,1), size: displayHeight*0.04,),
                tileColor: Color.fromRGBO(243,251,238,1),
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
