import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'package:webviewjavascript/FormsData/read_file.dart';
import 'package:webviewjavascript/FormsData/update_form.dart';

List<dynamic> getList = [];
var tableNamesFromDb;

class DictionaryDataBaseHelperGPKG {

  Database _db;
  final path;
  final name;

  DictionaryDataBaseHelperGPKG(this.path, this.name);

  Future<void> init() async {
    io.Directory applicationDirectory =
    await getApplicationDocumentsDirectory();

   String dbPathEnglish =path;

    print(dbPathEnglish);

    bool dbExistsEnglish = await io.File(path).exists();

    print(dbExistsEnglish);

    if (!dbExistsEnglish) {
      print('hahha');
      // Copy from asset
      ByteData data = await rootBundle.load(path);
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await io.File(dbPathEnglish).writeAsBytes(bytes, flush: true);
    }

    this._db = await openDatabase(dbPathEnglish);

    if (_db == null) {
      throw "bd is not initiated, initiate using [init(db)] function";
    }

    // List<Map> words;

    await _db.transaction((txn) async {
      if (filterValues.isNotEmpty) {
        getList = await txn.query(
          '$globalTableName WHERE ${filterValues[0]['columnName']} like \'${filterValues[0]['filterValue']}\' OR ${filterValues[1]['columnName']} like \'${filterValues[1]['filterValue']}\' OR ${filterValues[2]['columnName']} like \'${filterValues[2]['filterValue']}\'',
        );
      } else if (updateValues.isNotEmpty) {
        for (int i = 1; i < tableNamesFromDb.length; i++) {
          await txn.update(globalTableName, {'${updateValues[i]['columnName']}': '${updateValues[i]['updateValue']}'}, where: '${updateValues[0]['columnName']} = ?', whereArgs: ['${updateValues[0]['updateValue']}'] );
        }

      } else {
        tableNamesFromDb = await txn.query(
          'pragma_table_info(\'$globalTableName\')',
          columns: [
            "name",
          ],
        );
        getList = await txn.query(
          globalTableName,
        );
      }
    });

    // print(getList[1]['fid']);

    // getAllTheWordsEnglish();

    filterValues = [];
    updateValues = [];

    print('init end');
  }

  Future<List> getAllTheWordsEnglish() async {
    print('getWords enetered');
    if (_db == null) {
      throw "bd is not initiated, initiate using [init(db)] function";
    }
    List<Map> words;

    await _db.transaction((txn) async {
      words = await txn.query(
        globalTableName,
        // columns: [
        //   "fid",
        //   // "REGION",
        // ],
      );
    });

    print(words[1]['fid']);

    return words.toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _db.close();
  }
}

// import 'dart:io' show Directory;
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' show join;
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart'
//     show getApplicationDocumentsDirectory;
// import 'package:webviewjavascript/FormsData/read_file.dart';
//
// // var data;
//
// class DatabaseHelperRead {
//   static final _databaseName = databaseName;
//   static final _databaseVersion = 1;
//
//   // make this a singleton class
//   DatabaseHelperRead._privateConstructor();
//
//   static final DatabaseHelperRead instance = DatabaseHelperRead._privateConstructor();
//
//   // only have a single app-wide reference to the database
//   static Database _database;
//
//   Future<bool> databaseExists(String path) =>
//       databaseFactory.databaseExists(path);
//
//   Future<Database> get database async {
//     print('yes');
//     // var value = await databaseExists(databasePath);
//     // print(value);
//     if (_database != null) return _database;
//     _database = await _initDatabase();
//     return _database;
//   }
//
//   _initDatabase() async {
//     print('initDatabase entered');
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     print(documentsDirectory.path);
//     String path = join(documentsDirectory.path, _databaseName);
//     return await openDatabase(path,
//         version: _databaseVersion);
//   }
//
//   // SQL code to create  database table
//   Future _onCreate(Database db, int version) async {
//     await db.execute(
//         "CREATE TABLE IF NOT EXISTS Placemarks(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,name TEXT, notes TEXT, lat TEXT, long TEXT );");
//     await db.execute(
//         "CREATE TABLE IF NOT EXISTS Geojson(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,url TEXT, name TEXT );");
//     await db.execute(
//         "CREATE TABLE IF NOT EXISTS Mvtpbf(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,url TEXT, name TEXT );");
//     await db.execute(
//         "CREATE TABLE IF NOT EXISTS Jpgpng(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,url TEXT, name TEXT );");
//   }
//
// }
