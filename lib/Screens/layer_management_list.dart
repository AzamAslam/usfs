import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:webviewjavascript/sqliteDataBase/db_provider.dart';

// GL.map.resize();


import '../main.dart';

var geojsonList = [];

var removeIdLayer = [];

class LayerManagementList extends StatefulWidget {

  var icn, layerName, color;

  LayerManagementList({this.icn, this.layerName, this.color});

  @override
  _LayerManagementListState createState() => _LayerManagementListState();
}


class _LayerManagementListState extends State<LayerManagementList> {
  var files = [];

  var geojsonListClass = [];
  var removeIdLayerPbf = [];
  var removeIdLayerJpg = [];
  var mvtPbfList = [];
  var jpgPngWebpList = [];

  getCatalogsFromDatabase() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> mapsImpact = await db.query('Geojson');
    for(int i=0; i<mapsImpact.length; i++){
      geojsonListClass.add({
        'id': mapsImpact[i]['id'].toString(),
        'name': mapsImpact[i]['name'],
        'url': mapsImpact[i]['url']
      });
    }
    final List<Map<String, dynamic>> mapsImpact1 = await db.query('Mvtpbf');
    for(int i=0; i<mapsImpact1.length; i++){
      mvtPbfList.add({
        'id': mapsImpact1[i]['id'].toString(),
        'name': mapsImpact1[i]['name'],
        'url': mapsImpact1[i]['url']
      });
    }
    final List<Map<String, dynamic>> mapsImpact2 = await db.query('Jpgpng');
    for(int i=0; i<mapsImpact2.length; i++){
      jpgPngWebpList.add({
        'id': mapsImpact2[i]['id'].toString(),
        'name': mapsImpact2[i]['name'],
        'url': mapsImpact2[i]['url']
      });
    }

    if(widget.layerName == 'GEOJSON'){
      files = geojsonListClass = geojsonList;
    }
    else if(widget.layerName == 'MVT/PBF')
      files = mvtPbfList;
    else if(widget.layerName == 'JPG/PNG/WEBP')
      files = jpgPngWebpList;

    setState(() {

    });
  }

  @override
  void initState() {
    // getFiles(); //call getFiles() function on initial state.
    super.initState();
    getCatalogsFromDatabase();
  }

  Future<void> deleteFile(File file) async {
    print('deleteFile entered');
    try {
      if (await file.exists()) {
        print('Yes entered');
        await file.delete();
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    var displayWidth = MediaQuery.of(context).size.width;
    var displayHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // title: Text('Catalog Builder'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(children: [
        SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(displayHeight*0.02, displayHeight*0.02, displayHeight*0.02, displayHeight*0.1),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/icons/layer_logo.png', height: displayHeight*0.06,),
                          SizedBox(width: displayWidth*0.03,),
                          Text('Layer Management', style: TextStyle(fontWeight: FontWeight.w400, fontSize: displayHeight*0.02),),
                        ],
                      ),
                      Row(
                        children: [
                          Text(widget.layerName, style: TextStyle(fontWeight: FontWeight.w400, fontSize: displayHeight*0.02),),
                          SizedBox(width: displayWidth*0.03,),
                          Image.asset(widget.icn, height: displayHeight*0.03,),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: displayHeight*0.02,),
                Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: displayWidth*0.04, right: displayWidth*0.01),
                      // leading: Text('', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
                      title:  Text(widget.layerName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
                      // trailing: Icon(Icons.add, color: Color.fromRGBO(23,41,158,1), size: displayHeight*0.03,),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Delete or Re-order'),
                          SizedBox(width: displayWidth*0.01,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_drop_up, color: Color.fromRGBO(23,41,158,1), size: displayHeight*0.024,),
                              Icon(Icons.arrow_drop_down, color: Color.fromRGBO(23,41,158,1), size: displayHeight*0.024,),
                            ],
                          ),
                        ],
                      ),
                      tileColor: widget.color
                  ),
                ),
                files == null
                    ? Text('No files there', style: TextStyle(fontSize: displayHeight*0.04),)
                    : ReorderableListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    onReorder: (int start, int current) {
                      // dragging from top to bottom
                      if (start < current) {
                        int end = current - 1;
                        var startItem = files[start];
                        int i = 0;
                        int local = start;
                        do {
                          files[local] = files[++local];
                          i++;
                        } while (i < end - start);
                        files[end] = startItem;
                      }
                      // dragging from bottom to top
                      else if (start > current) {
                        var startItem = files[start];
                        for (int i = start; i > current; i--) {
                          files[i] = files[i - 1];
                        }
                        files[current] = startItem;
                      }
                      setState(() {});
                    },

                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int index) {
                      // final item = index.toString();
                      final item = files[index]['id'];
                      return Dismissible(
                          key: Key(item),
                          onDismissed: (direction) async {
                            var removeId;
                            if(widget.layerName == 'GEOJSON'){
                              for(int i=0; i<removeIdLayer.length; i++){
                                if(files[index]['name'] == removeIdLayer[i]['name']){
                                  removeId = removeIdLayer[i]['id'];
                                  removeIdLayer[i]['name'] = 'null';
                                  print('yes enetere');
                                }
                              }
                            }
                            else if(widget.layerName == 'MVT/PBF'){
                              for(int i=0; i<removeIdLayerPbf.length; i++){
                                if(files[index]['name'] == removeIdLayer[i]['name']){
                                  removeId = removeIdLayerPbf[i]['id'];
                                  removeIdLayerPbf[i]['name'] = 'null';
                                }
                              }
                            }
                            else if(widget.layerName == 'JPG/PNG/WEBP'){
                              for(int i=0; i<removeIdLayerJpg.length; i++){
                                if(files[index]['name'] == removeIdLayerJpg[i]['name']){
                                  removeId = removeIdLayerJpg[i]['id'];
                                  removeIdLayerJpg[i]['name'] = 'null';
                                }
                              }
                            }

                            print(removeId);
                            webController.evaluateJavascript("GL.removeLayer('${removeId}');");
                            //Remove row from database
                            Database db = await DatabaseHelper.instance.database;
                            if(widget.layerName == 'GEOJSON')
                              db.delete("Geojson", where: "id = ?", whereArgs: [files[index]['id']]);
                            else if(widget.layerName == 'MVT/PBF')
                              db.delete("Mvtpbf", where: "id = ?", whereArgs: [files[index]['id']]);
                            else if(widget.layerName == 'JPG/PNG/WEBP')
                              db.delete("Jpgpng", where: "id = ?", whereArgs: [files[index]['id']]);

                            setState(() {
                              files.removeAt(index);
                            });

                            // Then show a snackbar.
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Layer Deleted')));
                          },
                          child: files[index] != null
                              ? Card(
                              child: ListTile(
                                title: Text(files[index]['name']),
                                leading: Image.asset(
                                  widget.icn,
                                  height: 30,
                                ),
                                // trailing: Icon(Icons.delete, color: Colors.redAccent,),
                                onTap: () {
                                  var rng = new Random();
                                  var name = 'random';
                                  if(widget.layerName == 'GEOJSON'){
                                    name = (rng.nextInt(100)).toString()+'geojson';
                                    String id = geojsonList.length.toString();
                                    for(int i=0; i<removeIdLayer.length; i++){
                                      if(files[index]['name'] == removeIdLayer[i]['name']){
                                        webController.evaluateJavascript("addGEOJSONLayer('${files[index]['url']}', '${removeIdLayer[i]['id']}', '$name');");
                                      }
                                    }
                                  }
                                  else if(widget.layerName == 'MVT/PBF'){
                                    name = (rng.nextInt(100)).toString()+'pbf';
                                    String id = mvtPbfList.length.toString();
                                    webController.evaluateJavascript("addMVTPBFLayer('${files[index]['url']}', '$id', '$name');");
                                  }
                                  else if(widget.layerName == 'JPG/PNG/WEBP'){
                                    name = (rng.nextInt(100)).toString()+'xyz';
                                    String id = jpgPngWebpList.length.toString();
                                    webController.evaluateJavascript("addJPGPNGWEBPLayer('${files[index]['url']}', '$id', '$name');");
                                  }

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                              ))
                              : SizedBox());
                    }),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: displayHeight * 0.07,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  var webController = TextEditingController();
                  var nameController = TextEditingController();
                  // launch(
                  //     'https://mapsdata.world/catalog_generator/#1.44/4/-18.7');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => Vector2Raster()),
                  // );
                  showDialog(
                    barrierDismissible: false,
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
                            height: displayHeight * 0.7,
                            width: displayWidth * 0.8,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: displayHeight * 0.04),
                                Image.asset('assets/icons/layer_logo.png', height: displayHeight*0.1,),
                                Text('Layer Management', style: TextStyle(
                                  fontSize: displayHeight*0.02,
                                ),),
                                SizedBox(height: displayHeight*0.1,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Add Name'
                                        ),
                                        SizedBox(height: 6,),
                                        SizedBox(
                                          height: displayHeight*0.07,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter Name';
                                              }
                                              return null;
                                            },
                                            controller: nameController,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              // contentPadding: EdgeInsets.only(top: 20),
                                              isDense: true,
                                              // prefixIcon: Icon(Icons.arrow_drop_up),
                                              prefixIcon: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Image.asset(
                                                  'assets/icons/globe.png',
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: 'Enter Name',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25.0),
                                              ),
                                              hintStyle: const TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: displayHeight*0.02,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add Web Service'
                                        ),
                                        SizedBox(height: 6,),
                                        SizedBox(
                                          height: displayHeight*0.07,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter Url';
                                              }
                                              return null;
                                            },
                                            controller: webController,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              // contentPadding: EdgeInsets.only(top: 20),
                                              isDense: true,
                                              // prefixIcon: Icon(Icons.arrow_drop_up),
                                              prefixIcon: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Image.asset(
                                                  'assets/icons/globe.png',
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: 'Enter url',
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
                                      height: displayHeight*0.04,
                                    ),
                                    Container(
                                      height: displayHeight * 0.06,
                                      width: displayWidth*0.5,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if(webController.text==null || webController.text=='' || nameController.text==null || nameController.text=='' ){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Please enter about text fields')));
                                            return;
                                          }
                                          var tableName = widget.layerName;
                                          if(widget.layerName == 'GEOJSON'){
                                            tableName = 'Geojson';
                                          }
                                          else if(widget.layerName == 'MVT/PBF'){
                                            tableName = 'Mvtpbf';
                                          }
                                          else if(widget.layerName == 'JPG/PNG/WEBP'){
                                            tableName = 'Jpgpng';
                                          }

                                          Database db =
                                              await DatabaseHelper.instance.database;
                                          int id = await db.rawInsert(
                                              'INSERT INTO $tableName (url, name) '
                                                  'VALUES(?, ?)',
                                              [
                                                webController.text,
                                                nameController.text
                                              ]);
                                          //Data Added successfully
                                          print(id);

                                          final List<Map<String, dynamic>> mapsImpact =
                                              await db.query(tableName);
                                          if(widget.layerName == 'GEOJSON'){
                                            String geojsonId = geojsonList.length.toString();
                                            geojsonList.add({
                                              'id': geojsonId.toString(),
                                              'name': mapsImpact[mapsImpact.length-1]['name'],
                                              'url': mapsImpact[mapsImpact.length-1]['url']
                                            });
                                            print(geojsonId.toString());
                                            print('hahahahhah');
                                            removeIdLayer.add({
                                              'id': geojsonId.toString(),
                                              'name': mapsImpact[mapsImpact.length-1]['name'],
                                            });
                                          }
                                          else if(widget.layerName == 'MVT/PBF'){
                                            String mvtPbfId = mvtPbfList.length.toString();
                                            mvtPbfList.add({
                                              'id': mvtPbfId,
                                              'name': mapsImpact[mapsImpact.length-1]['name'],
                                              'url': mapsImpact[mapsImpact.length-1]['url']
                                            });
                                            removeIdLayerPbf.add({
                                              'id': mvtPbfId,
                                              'name': mapsImpact[mapsImpact.length-1]['name'],
                                            });
                                          }
                                          else if(widget.layerName == 'JPG/PNG/WEBP'){
                                            String jpgPngWebpId = jpgPngWebpList.length.toString();
                                            jpgPngWebpList.add({
                                              'id': jpgPngWebpId,
                                              'name': mapsImpact[mapsImpact.length-1]['name'],
                                              'url': mapsImpact[mapsImpact.length-1]['url']
                                            });
                                            removeIdLayerJpg.add({
                                              'id': jpgPngWebpId,
                                              'name': mapsImpact[mapsImpact.length-1]['name'],
                                            });
                                          }
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text('Add URL', style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:widget.color ,

                                        ),


                                      ),
                                    ),
                                    SizedBox(height: displayHeight*0.04,),
                                    TextButton(
                                      child: Text(
                                        "Cancel",
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
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Add New Item', style: TextStyle(fontSize: 18)),
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor:widget.color ,

                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
