import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;

import 'package:dart_hydrologis_db/dart_hydrologis_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geopackage/flutter_geopackage.dart';
import 'package:dart_jts/dart_jts.dart' as JTS;
import 'package:sqflite/sqflite.dart';

import 'dart:io' as io;
import 'dart:math';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:webviewjavascript/FormsData/update_form.dart';
import 'package:webviewjavascript/open_database_gpkg.dart';

var databaseName;
var databasePath;
var globalTableName;
var tablesName;
var filterValues = [];
var selectCheckBox = false;
var buttonNameCancel = 'Filter Table';

class OpenGpkg extends StatefulWidget {
  var file;
  var ch;
  var tableName;

  // var buttonNameCancel = 'Filter Table';

  OpenGpkg({Key key, this.file, this.tableName}) : super(key: key);

  @override
  State<OpenGpkg> createState() => _OpenGpkgState();
}

class _OpenGpkgState extends State<OpenGpkg> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DataTableSource _data;

  var forestTabe = ['FORESTNAME', 'ADMINFORESTID', 'FORESTORGCODE'];
  var recreationalGpkgTable = [
    'RECAREANAME',
    'FORESTNAME',
    'RECAREADESCRIPTION'
  ];
  var recreationalMbtilesTable = ['zoom_level', 'tile_column', 'tile_row'];

  var controller1 = TextEditingController();
  var controller2 = TextEditingController();
  var controller3 = TextEditingController();

  @override
  void initState() {
    openDatabase();
    super.initState();
  }

  @protected
  @mustCallSuper
  void dispose() {
    updateStatus = false;
    super.dispose();
  }

  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);

  openDatabase() async {
    if (updateStatus != true) {
      databaseName = widget.file.split('/').last;
      databasePath = widget.file;
      globalTableName = "forests";
    } else {
      setState(() {
        selectCheckBox = false;
        buttonNameCancel = 'Filter Table';
      });
    }

    print("check kro");
    print(getColumnName(widget.tableName, 1));

    await DictionaryDataBaseHelperGPKG(widget.file,widget.tableName).init();

    tablesName = List.generate(
        1,
            (index) => DataColumn(
            label: Text("Table")));

    _data = MyData(_scaffoldKey.currentContext);

    // updateStatus = false;
    setState(() {});
  }

  String getColumnName(String tableN, int indexColumn) {
    if (globalTableName == 'forests') {
      if (indexColumn == 0) {
        return forestTabe[0];
      } else if (indexColumn == 1) {
        return forestTabe[1];
      } else if (indexColumn == 2) {
        return forestTabe[2];
      }
    } else if (globalTableName == 'recreational_opportunities') {
      if (indexColumn == 0) {
        return recreationalGpkgTable[0];
      } else if (indexColumn == 1) {
        return recreationalGpkgTable[1];
      } else if (indexColumn == 2) {
        return recreationalGpkgTable[2];
      }
    } else if (globalTableName == 'tiles') {
      if (indexColumn == 0) {
        return recreationalMbtilesTable[0];
      } else if (indexColumn == 1) {
        return recreationalMbtilesTable[1];
      } else if (indexColumn == 2) {
        return recreationalMbtilesTable[2];
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    var heightScreen = MediaQuery.of(context).size.height;
    var widthScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.tableName),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: (_data == null || (getList.isEmpty))
            ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Center(child: CircularProgressIndicator()))
            : Column(
          children: [
            Container(
              child: Center(
                child: PaginatedDataTable(
                  source: _data,
                  header: Text('$databaseName'),
                  columns: tablesName,
                  // [
                  //   DataColumn(label: Text('fid')),
                  //   DataColumn(label: Text('OBJECTID')),
                  //   DataColumn(label: Text('FORESTID')),
                  // ],
                  columnSpacing: 40,
                  horizontalMargin: 10,
                  rowsPerPage: 8,
                  showCheckboxColumn: selectCheckBox,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: widthScreen * 0.35,
                    height: heightScreen * 0.045,
                    margin: EdgeInsets.all(20),
                    child: TextButton(
                        child: Text(
                          buttonNameCancel,
                          style: TextStyle(fontSize: 16.0),
                        ),

                        onPressed: () {
                          if (buttonNameCancel == 'Cancel') {
                            setState(() {
                              selectCheckBox = false;
                              buttonNameCancel = 'Filter Table';
                            });
                            return;
                          } else
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(20)),
                                  elevation: 16,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: widthScreen * 0.02,
                                        right: widthScreen * 0.02),
                                    height: heightScreen * 0.5,
                                    width: widthScreen * 0.7,
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                            height: heightScreen * 0.03),
                                        Center(
                                            child: Text(
                                              'Filter Table',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )),
                                        SizedBox(height: 20),
                                        getTextFieldForFilter(
                                            getColumnName(
                                                globalTableName, 0),
                                            widthScreen,
                                            heightScreen,
                                            controller1),
                                        getTextFieldForFilter(
                                            getColumnName(
                                                globalTableName, 1),
                                            widthScreen,
                                            heightScreen,
                                            controller2),
                                        getTextFieldForFilter(
                                            getColumnName(
                                                globalTableName, 2),
                                            widthScreen,
                                            heightScreen,
                                            controller3),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          // crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    fontSize:
                                                    heightScreen *
                                                        0.02),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                "Filter",
                                                style: TextStyle(
                                                    fontSize:
                                                    heightScreen *
                                                        0.02),
                                              ),
                                              onPressed: () async {
                                                print('yha dekh lo');
                                                print(getColumnName(
                                                    globalTableName, 1));
                                                print(globalTableName);
                                                print(controller1.text);
                                                if ((controller1.text == '' || controller1.text == null || controller1.text.isEmpty) &&
                                                    (controller2.text ==
                                                        '' ||
                                                        controller2.text == null ||
                                                        controller2.text.isEmpty) &&
                                                    (controller3.text == '' ||
                                                        controller3.text ==null ||
                                                        controller3.text.isEmpty)) {
                                                  Navigator.pop(context);
                                                  return;
                                                }
                                                filterValues = [
                                                  {
                                                    'columnName':
                                                    getColumnName(
                                                        widget
                                                            .tableName,
                                                        0),
                                                    'filterValue':
                                                    controller1.text
                                                        .isNotEmpty
                                                        ? controller1
                                                        .text
                                                        : '%'
                                                  },
                                                  {
                                                    'columnName':
                                                    getColumnName(
                                                        widget
                                                            .tableName,
                                                        1),
                                                    'filterValue':
                                                    controller2.text
                                                        .isNotEmpty
                                                        ? controller2
                                                        .text
                                                        : '%'
                                                  },
                                                  {
                                                    'columnName':
                                                    getColumnName(
                                                        widget
                                                            .tableName,
                                                        2),
                                                    'filterValue':
                                                    controller3.text
                                                        .isNotEmpty
                                                        ? controller3
                                                        .text
                                                        : '%'
                                                  },
                                                ];

                                                await DictionaryDataBaseHelperGPKG(widget.file,widget.tableName)
                                                    .init();

                                                tablesName = List.generate(
                                                    tableNamesFromDb
                                                        .length,
                                                        (index) => DataColumn(
                                                        label: Text(tableNamesFromDb[
                                                        index]
                                                        ['name']
                                                            .toString())));

                                                _data = MyData(
                                                    _scaffoldKey
                                                        .currentContext);

                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                        }),
                  ),
                  Container(
                    width: widthScreen * 0.37,
                    height: heightScreen * 0.045,
                    margin: EdgeInsets.all(20),
                    child: TextButton(
                      child: Text(
                        'Update Table',
                        style: TextStyle(fontSize: 16.0),
                      ),

                      onPressed: () {
                        setState(() {
                          selectCheckBox = true;
                          buttonNameCancel = 'Cancel';
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  getTextFieldForFilter(text, widthScreen, heightScreen, controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
              labelText: text.toString(),
            ),
          ),
        ),
      ],
    );
  }
}

class MyData extends DataTableSource {
  final List<dynamic> _data = getList;

  int selectedIndex = -1;

  final BuildContext context;

  MyData(this.context);

  String truncate(String text, {length: 25, omission: '...'}) {
    if (length >= text.length) {
      return text;
    }
    return text.replaceRange(length, text.length, omission);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(
        selected: index == selectedIndex,
        onSelectChanged: (val) {
          if (selectCheckBox == true) {
            print('yha pe');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateForm(
                    row: _data[index],
                  )),
            );
          }
          selectedIndex = index;
        },
        cells: [
          for (int j = 0; j < tableNamesFromDb.length; j++)
            DataCell(Text(truncate(
                _data[index][tableNamesFromDb[j]['name']].toString(),
                length: 25))),
        ]);
  }
}
