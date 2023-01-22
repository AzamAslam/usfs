import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webviewjavascript/esri/download_mbtiles/download_folder_data.dart';
import 'package:webviewjavascript/esri/download_mbtiles/sub_folder_download.dart';
import 'package:webviewjavascript/sqliteDataBase/db_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DownloadData extends StatefulWidget {
  const DownloadData({Key key}) : super(key: key);

  @override
  _DownloadDataState createState() => _DownloadDataState();
}

class _DownloadDataState extends State<DownloadData> {

  var mbtilesTestDataList = [
    {'name': 'basemap_vectortiles_esri.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/district_basemap/basemap_vectortiles_esri.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'TestData'
    },
    {'name': 'contourlines_vectortiles_esri.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/district_basemap/contourlines_vectortiles_esri.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'TestData'
    },
    {'name': 'hillshade_rastertiles_esri.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/district_basemap/hillshade_rastertiles_esri.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'TestData'
    },
  ];

  var mbtilesNationwideList = [
    {'name': 'Corner.mbtiles',
    'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/Corner.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'developed_site.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/developed_site.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'Forest_Administrative_Boundaries.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/Forest_Administrative_Boundaries.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'Forest_Service_Regional_Boundaries.mbtiles',
    'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/Forest_Service_Regional_Boundaries.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'FSTopo_PBS_Reference_Quadrangle.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/FSTopo_PBS_Reference_Quadrangle.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'Healthy_Forest_Restoration_Act_Activities.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/Healthy_Forest_Restoration_Act_Activities.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'LandUtilizationProject.mbtiles',
    'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/LandUtilizationProject.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'LMPU_.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/LMPU_.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'Monument.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/Monument.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'National_Forest_System_Roads.mbtiles',
    'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/National_Forest_System_Roads.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'National_Forest_System_Trails.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/National_Forest_System_Trails.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'National_Grassland_Units.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/National_Grassland_Units.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'National_USFS_Fire_Occurrence_Point.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/National_USFS_Fire_Occurrence_Point.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'National_Wilderness_Areas.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/National_Wilderness_Areas.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'National_Wild_and_Scenic_Rivers%3A_Legal_Status.mbtiles',
    'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/National_Wild_and_Scenic_Rivers%3A_Legal_Status.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'NFS_landUnit.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/NFS_landUnit.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'PADUS_FS_Managed_Surface_Ownership_Parcels.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/PADUS_FS_Managed_Surface_Ownership_Parcels.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'ProclaimedForest_Grassland.mbtiles',
    'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/ProclaimedForest_Grassland.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'Recreation_Area_Activities.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/Recreation_Area_Activities.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
    {'name': 'withdrawal.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/MBTILES_Nationwide_Dataset/withdrawal.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Nationwide'
    },
  ];

  var mbtilesForestList = [
    {'name': 'hillshade_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/deschutes/hillshade_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'reference_labels_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/deschutes/reference_labels_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'reference_lines_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/deschutes/reference_lines_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'satellite_esri_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/deschutes/satellite_esri_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'stamen_terrain_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/deschutes/stamen_terrain_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'thunderforest_outdoors_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/deschutes/thunderforest_outdoors_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'hillshade_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/gifford_pinchot/hillshade_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'reference_labels_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/gifford_pinchot/reference_labels_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'reference_lines_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/gifford_pinchot/reference_lines_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'satellite_esri_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/gifford_pinchot/satellite_esri_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'stamen_terrain_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/gifford_pinchot/stamen_terrain_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
    {'name': 'thunderforest_outdoors_rastertiles.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/forests/gifford_pinchot/thunderforest_outdoors_rastertiles.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Forests'
    },
  ];
  var mbtilesRegionsList = [
    {'name': 'alaska/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/alaska/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
    {'name': 'eastern/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/eastern/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
    {'name': 'intermountain/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/intermountain/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
    {'name': 'northern/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/northern/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
    {'name': 'pacificnorthwest/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/pacificnorthwest/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
    {'name': 'rockymountain/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/rockymountain/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
    {'name': 'southeastern/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/southeastern/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
    {'name': 'southwestern/esri_vectortiles_basemap.mbtiles',
      'url': 'https://techmavengeo.cloud/test/usfs/regional_basemap/southwestern/esri_vectortiles_basemap.mbtiles',
      'icon': '0xf6df',
      'status': 'Download',
      'folderName': 'Regions'
    },
  ];

  var folderName = [];
  var obj;

  void getJsonFromUrl() async{

    final url = Uri.parse('https://techmavengeo.cloud/get_usfs.php');
    http.Response response = await http.get(url, headers: {
      'Accept': 'application/json',
    });

    obj = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      print('successfully loaded json');
      for(int i=0; i<obj.length; i++){
        if(obj[i]['name'] == 'usfs'){
          for(int j=0; j<obj[i]['tree'].length; j++){
            folderName.add(obj[i]['tree'][j]['name']);
          }
        }
      }
    }
    setState(() {});
    print(folderName);
  }

  @override
  void initState() {
    super.initState();
    getJsonFromUrl();
  }

  List<Map<String, dynamic>> makeModifiableResults(
      List<Map<String, dynamic>> results) {
    // Generate modifiable
    return List<Map<String, dynamic>>.generate(
        results.length, (index) => Map<String, dynamic>.from(results[index]),
        growable: true);
  }

  @override
  Widget build(BuildContext context) {
    final displayHeight = MediaQuery.of(context).size.height;
    final displayWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Pre Staged Data'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: displayHeight*0.9,
          width: displayWidth,
          child: folderName.isNotEmpty ? ListView.builder(
            itemCount: folderName.length,
          itemBuilder: (BuildContext context,int index){
            return Card(
              child: ListTile(
                onTap: () async {
                  var list = [];
                  var subFolderList = [];

                  Database db = await DatabaseHelper.instance.database;
                  int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${folderName[index]}'));

                  var subFolderStatus = false;

                  for(int i=0; i<obj[2]['tree'].length; i++){
                    if(obj[2]['tree'][i]['name'] == folderName[index]){
                      for(int j=0; j<obj[2]['tree'][i]['tree'].length; j++){
                        if(obj[2]['tree'][i]['tree'][j]['type'] == 'dir'){
                          print('directory');
                          subFolderStatus = true;
                          // for(int z=0; z<obj[2]['tree'][i]['tree'][j]['tree'].length; z++){
                            subFolderList.add(
                                {
                                  'name': '${obj[2]['tree'][i]['tree'][j]['name']}',
                                  'list': obj[2]['tree'][i]['tree'][j]['tree']
                                  });
                          // }
                        }
                        else {
                          print(obj[2]['tree'][i]['tree'][j]['name']);
                          if(count==0){
                            list.add({
                              'name': '${obj[2]['tree'][i]['tree'][j]['name']}',
                              'url': '${obj[2]['tree'][i]['tree'][j]['path']}',
                              'icon': '0xf6df',
                              'status': 'Download',
                              'folderName': '${folderName[index]}'
                            });
                                int id = await db.rawInsert(
                                    'INSERT INTO ${folderName[index]}(name, url, icon, status, folderName, path)'
                                        'VALUES(?, ?, ?, ?, ?, ?)',
                                    [
                                      '${obj[2]['tree'][i]['tree'][j]['name']}',
                                      '${obj[2]['tree'][i]['tree'][j]['path']}',
                                      '0xf6df',
                                      'Download',
                                      'Nationwide',
                                      ''
                                    ]);
                          }
                        }
                      }
                    }
                  }

                  if(subFolderStatus == true){
                    subFolderStatus = false;
                    print(subFolderList);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubFolderDownload(subFolderList: subFolderList,),
                      ),
                    );
                  }
                  else if(count == 0){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadFolderData(mbtilesNationwideList: list,),
                      ),
                    );
                  }
                  else{
                    var list = await db.query(
                      '${folderName[index]}',
                    );
                    var newList = makeModifiableResults(list);
                    print('else part');
                    print(newList);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadFolderData(mbtilesNationwideList: newList,),
                      ),
                    );
                  }

                  //
                  // if(count==0){
                  //   for(int i=0; i<mbtilesNationwideList.length; i++){
                  //     int id = await db.rawInsert(
                  //         'INSERT INTO ${folderName[index]}(name, url, icon, status, folderName, path)'
                  //             'VALUES(?, ?, ?, ?, ?, ?)',
                  //         [
                  //           mbtilesNationwideList[i]['name'],
                  //           mbtilesNationwideList[i]['url'],
                  //           '0xf6df',
                  //           'Download',
                  //           'Nationwide',
                  //           ''
                  //         ]);
                  //   }
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => DownloadFolderData(mbtilesNationwideList: mbtilesNationwideList,),
                  //     ),
                  //   );
                  // }
                  // else{
                  //   mbtilesNationwideList = [];
                  //   var list = await db.query(
                  //     'Nationwide',
                  //   );
                  //   var newList = makeModifiableResults(list);
                  //   print('else part');
                  //   print(newList);
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => DownloadFolderData(mbtilesNationwideList: newList,),
                  //     ),
                  //   );
                  // }
                },
                leading: Icon(Icons.folder),
                // trailing: Icon(Icons.download_rounded),
                title: Text(folderName[index]),
              ),
            );
          }
          ): SizedBox(
              height: displayHeight*0.9,
              child: Center(child: CircularProgressIndicator())),
        ),
      ),
    );
  }
}
