import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

import '../../sqliteDataBase/db_provider.dart';
import 'download_folder_data.dart';

class SubFolderDownload extends StatefulWidget {
  var subFolderList;
  var obj;
  SubFolderDownload({Key key, this.subFolderList, this.obj}) : super(key: key);

  @override
  _SubFolderDownloadState createState() => _SubFolderDownloadState();
}

class _SubFolderDownloadState extends State<SubFolderDownload> {

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
        title: Text('Download Pre Staged Folder Data'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: displayHeight*0.9,
          width: displayWidth,
          child: ListView.builder(
              itemCount: widget.subFolderList.length,
              itemBuilder: (BuildContext context,int index){
                return Card(
                  child: ListTile(
                    onTap: () async {

                      var list = [];

                      Database db = await DatabaseHelper.instance.database;
                      int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${widget.subFolderList[index]['name']}'));

                      var obj = widget.subFolderList[index]['list'];
                      print(obj[1]);

                      for(int i=0; i<obj.length; i++){
                        if(count==0){
                          list.add({
                            'name': '${obj[i]['name']}',
                            'url': '${obj[i]['path']}',
                            'icon': '0xf6df',
                            'status': 'Download',
                            'folderName': '${widget.subFolderList[index]['name']}'
                          });
                          int id = await db.rawInsert(
                              'INSERT INTO ${widget.subFolderList[index]['name']}(name, url, icon, status, folderName, path)'
                                  'VALUES(?, ?, ?, ?, ?, ?)',
                              [
                                '${obj[i]['name']}',
                                '${obj[i]['path']}',
                                '0xf6df',
                                'Download',
                                'Nationwide',
                                ''
                              ]);
                        }
                      }

                      if(list.isEmpty && count ==0 ){
                        Fluttertoast.showToast(msg: "Folder is empty");
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
                          '${widget.subFolderList[index]['name']}',
                        );
                        var newList = makeModifiableResults(list);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadFolderData(mbtilesNationwideList: newList,),
                          ),
                        );
                      }

                      // for(int i=0; i<obj[2]['tree'].length; i++){
                      //   if(obj[2]['tree'][i]['name'] == folderName[index]){
                      //     for(int j=0; j<obj[2]['tree'][i]['tree'].length; j++){
                      //       if(obj[2]['tree'][i]['tree'][j]['type'] == 'dir'){
                      //         print('directory');
                      //         subFolderStatus = true;
                      //         var subFolderList = [];
                      //         for(int z=0; z<obj[2]['tree'][i]['tree'][j]['tree'].length; z++){
                      //           subFolderList.add({
                      //             'subFolderName': '${obj[2]['tree'][i]['tree'][j]['tree'][z]['name']}'
                      //           });
                      //         }
                      //         var list = ({'subFolderName': obj[2]['tree'][i]['tree'][j]['tree']});
                      //       }
                      //       else {
                      //         print(obj[2]['tree'][i]['tree'][j]['name']);
                      //         if(count==0){
                      //           list.add({
                      //             'name': '${obj[2]['tree'][i]['tree'][j]['name']}',
                      //             'url': '${obj[2]['tree'][i]['tree'][j]['path']}',
                      //             'icon': '0xf6df',
                      //             'status': 'Download',
                      //             'folderName': '${folderName[index]}'
                      //           });
                      //           int id = await db.rawInsert(
                      //               'INSERT INTO ${folderName[index]}(name, url, icon, status, folderName, path)'
                      //                   'VALUES(?, ?, ?, ?, ?, ?)',
                      //               [
                      //                 '${obj[2]['tree'][i]['tree'][j]['name']}',
                      //                 '${obj[2]['tree'][i]['tree'][j]['path']}',
                      //                 '0xf6df',
                      //                 'Download',
                      //                 'Nationwide',
                      //                 ''
                      //               ]);
                      //         }
                      //       }
                      //     }
                      //   }
                      // }

                      // if(subFolderStatus == true){
                      //   subFolderStatus = false;
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => SubFolderDownload(),
                      //     ),
                      //   );
                      // }
                      // else if(count == 0){
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => DownloadFolderData(mbtilesNationwideList: list,),
                      //     ),
                      //   );
                      // }
                      // else{
                      //   var list = await db.query(
                      //     '${folderName[index]}',
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
                    title: Text(widget.subFolderList[index]['name']),
                  ),
                );
              }
          ),
        ),
      ),
    );
  }
}
