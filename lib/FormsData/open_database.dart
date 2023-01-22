import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'package:webviewjavascript/FormsData/read_file.dart';
import 'package:webviewjavascript/FormsData/update_form.dart';

var getList = [];
var tableNamesFromDb;

class DictionaryDataBaseHelper {

  Database _db;
  static final _databaseVersion = 1;

  Future<void> init() async {
    io.Directory applicationDirectory = await getApplicationDocumentsDirectory();

    String dbPathEnglish = path.join(databasePath);

    bool dbExistsEnglish = await io.File(dbPathEnglish).exists();

    print('dbExistsEnglish');
    print(dbExistsEnglish);

    if (!dbExistsEnglish) {
      print('dbExistsEnglish function entered');
      String dbPathEnglishAssets = path.join(applicationDirectory.path, databaseName);
      // Copy from asset
      ByteData data = await rootBundle.load(path.join("assets/formsData", databaseName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await io.File(dbPathEnglishAssets).writeAsBytes(bytes, flush: true);
    }

    this._db = await openDatabase(dbPathEnglish, version: _databaseVersion);

    if (_db == null) {
      throw "bd is not initiated, initiate using [init(db)] function";
    }

    // List<Map> words;

    await _db.transaction((txn) async {
      if (filterValues.isNotEmpty) {
        print('filters start');
        getList = await txn.query(
          '$globalTableName WHERE ${filterValues[0]['columnName']} like \'${filterValues[0]['filterValue']}\' OR ${filterValues[1]['columnName']} like \'${filterValues[1]['filterValue']}\' OR ${filterValues[2]['columnName']} like \'${filterValues[2]['filterValue']}\'',
        );
      } else if (updateValues.isNotEmpty) {
        print('update values here');
        print(updateValues);
        for (int i = 1; i < tableNamesFromDb.length; i++) {
          await txn.update(globalTableName, {'${updateValues[i]['columnName']}': '${updateValues[i]['updateValue']}'}, where: '${updateValues[0]['columnName']} = ?', whereArgs: ['${updateValues[0]['updateValue']}'] );
        }

      } else {
        // final tables = await txn.rawQuery('SELECT * FROM forests');
        if(databaseName.contains('.gpkg')){
          final tables = await txn.rawQuery('SELECT table_name FROM gpkg_contents');
          for(int i = 0; i<tables.length; i++ ){
            if(tables[i]['table_name'] != 'ogr_empty_table' && tables[i]['table_name'] != 'nooa-rnc'){
              tableNamesFromDb = await txn.query(
                'pragma_table_info(\'${tables[i]['table_name']}\')',
                columns: [
                  "name",
                ],
              );
              getList = await txn.query(
                '${tables[i]['table_name']}',
              );
              globalTableName = '${tables[i]['table_name']}';
            }
          }
        }
        else{
          globalTableName = 'tiles';
          tableNamesFromDb = await txn.query(
            'pragma_table_info(\'$globalTableName\')',
            columns: [
              "name",
            ],
          );
          getList = await txn.query(
            'tiles',
          );
        }
      }
    });

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
      );
    });

    print(words[1]['fid']);

    return words.toList();
  }

  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);

  @override
  void dispose() {
    // TODO: implement dispose
    _db.close();
  }
}
