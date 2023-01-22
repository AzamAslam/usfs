import 'dart:io' show Directory;
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;


class DatabaseHelper {
  static final _databaseName = "tet.db";
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory.path);
    print(_databaseName);
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create  database table
  Future _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE IF NOT EXISTS MBTILES_Nationwide_Dataset(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS district_basmap(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS forests(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS placemarks(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS recreational(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS regional_basemap(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS styles(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS test_data(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS topo(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");

    await db.execute(
        "CREATE TABLE IF NOT EXISTS deschutes(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS gifford_pinchot(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");

    await db.execute(
        "CREATE TABLE IF NOT EXISTS alaska(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS eastern(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS intermountain(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS northern(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS pacificnorthwest(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS rockymountain(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS southeastern(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS southwestern(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");



    await db.execute(
        "CREATE TABLE IF NOT EXISTS Nationwide(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Regions(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Forests(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS TestData(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, folderName TEXT, path TEXT, url TEXT, icon TEXT, status TEXT );");

    await db.execute(
        "CREATE TABLE IF NOT EXISTS jsonToForm(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , name TEXT, userName TEXT, email TEXT, password TEXT, number TEXT, longitude TEXT, latitude TEXT);");

    await db.execute(
        "CREATE TABLE IF NOT EXISTS Placemarks(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,name TEXT, notes TEXT, lat TEXT, long TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Geojson(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,url TEXT, name TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Mvtpbf(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,url TEXT, name TEXT );");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Jpgpng(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,url TEXT, name TEXT );");
  }

}