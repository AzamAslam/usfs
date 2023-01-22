// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;
// String formString;
// void loadJson() {
//   rootBundle.loadString('assets/simple.json').then((jsonString){
//     List<dynamic> jsonObj = json.decode(jsonString) ?? '';
//     List<Map<String, dynamic>> rawJson = listOfDynamicToMap(jsonObj) ?? [];
//
//
//   });
// }
//
// List<Map<String, dynamic>> listOfDynamicToMap(List<dynamic> list) {
//   List<Map<String,dynamic>> listOfMap = [];
//   list.forEach((element) {
//     if(element is Map<String, dynamic>) {
//       listOfMap.add(element);
//     }
//   });
//   return listOfMap;
// }