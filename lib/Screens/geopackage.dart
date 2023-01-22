import 'package:flutter/material.dart';
// import 'geopackage_test_view.dart';

class GeoPackage extends StatefulWidget {
  const GeoPackage({Key key}) : super(key: key);

  @override
  _GeoPackageState createState() => _GeoPackageState();
}

class _GeoPackageState extends State<GeoPackage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Geopackage",
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      // home: GeopackageTestView(),
    );
  }
}
