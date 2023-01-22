// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// import 'main.dart';
// class Register extends StatefulWidget {
// final form;
//
//   const Register({Key key, this.form}) : super(key: key);
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   @override
//   _Register createState() => new _Register();
// }
//
// class _Register extends State<Register> {
//   TextEditingController longController=TextEditingController();
//   TextEditingController latController=TextEditingController();
//   TextEditingController imController=TextEditingController();
//   Map keyboardTypes = {
//     "number": TextInputType.number,
//   };
//
//  // String form= json.encode({
//  //  'fields': [
//  //  {
//  //  'key': 'name',
//  //  'type': 'Input',
//  //  'label': 'Name',
//  //  'placeholder': "Enter Your Name",
//  //  'required': true,
//  //  },
//  //  {
//  //  'key': 'username',
//  //  'type': 'Input',
//  //  'label': 'Username',
//  //  'placeholder': "Enter Your Username",
//  //  'required': true,
//  //  'hiddenLabel': true,
//  //  },
//  //  {'key': 'email', 'type': 'Email', 'label': 'email', 'required': true},
//  //  {
//  //  'key': 'password1',
//  //  'type': 'Password',
//  //  'label': 'Password',
//  //  'required': true
//  //  },
//  //  {'key': 'number', 'type': 'Input', 'label': 'number', 'required': true},
//  //  ]
//  //  });
//  // String form=widget.form;
//   dynamic response;
//
//   Map decorations = {
//     'email': InputDecoration(
//       hintText: 'Email',
//       prefixIcon: Icon(Icons.email),
//       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
//     ),
//     'username': InputDecoration(
//       labelText: "Enter your email",
//       prefixIcon: Icon(Icons.account_box),
//       border: OutlineInputBorder(),
//     ),
//     'password1': InputDecoration(
//         prefixIcon: Icon(Icons.security), border: OutlineInputBorder()),
//   };
//
//   // dynamic response;
//   //
//   // Map decorations = {
//   //   'email': InputDecoration(
//   //     hintText: 'Email',
//   //     prefixIcon: Icon(Icons.email),
//   //     contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//   //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
//   //   ),
//   //   'username': InputDecoration(
//   //     labelText: "Enter your email",
//   //     prefixIcon: Icon(Icons.account_box),
//   //     border: OutlineInputBorder(),
//   //   ),
//   //   'password1': InputDecoration(
//   //       prefixIcon: Icon(Icons.security), border: OutlineInputBorder()),
//   // };
//   void getJson()async{
//
//   }
//   getLAT()async{
//     latController.text=latt;
//     longController.text=longg;
//
//     setState(() {
//
//     });
//   }
// @override
// void initState(){
//     getLAT();
//   getJson();
//   super.initState();
// }
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return new Scaffold(
//       appBar: new AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: new Text("Json to Form"),
//       ),
//       body:  SingleChildScrollView(
//         child:  Center(
//           // Center is a layout widget. It takes a single child and positions it
//           // in the middle of the parent.
//           child: new Column(children: <Widget>[
//             new Container(
//               child: new Text(
//                 " Form",
//                 style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
//               ),
//               margin: EdgeInsets.only(top: 10.0),
//             ),
//             SizedBox(
//               height: 10.0,
//             ),
//             TextField(
//               controller: longController,
//               decoration: InputDecoration(
//                 hintText: 'Long',
//                 prefixIcon: Icon(Icons.location_on_outlined),
//                 contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
//               ),
//
//             ),
//             SizedBox(
//               height: 20.0,
//             ),
//             TextField(
//               controller: latController,
//               decoration: InputDecoration(
//                 hintText: 'Latitude',
//                 prefixIcon: Icon(Icons.location_on_outlined),
//                 contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
//               ),
//
//             ),
//             SizedBox(
//               height: 20.0,
//             ),
//             Container(
//
//               child:TextField(
//                 controller: imController,
//                 decoration: InputDecoration(
//                   hintText: 'BAse64',
//                   prefixIcon: Icon(Icons.location_on_outlined),
//                   contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
//                 ),
//
//               ),
//
//
//
//
//             ),
//             InkWell(
//                 onTap: (){
//                   _openCamera(context);
//                 },
//                 child: Container(
//                     height: 50.0,
//                     width: 130.0,
//                     child: Row(
//                       children: [
//                         Text("Upload Image"),
//                         Icon(Icons.upload_sharp),
//                       ],
//                     ))),
//
//
//             Container(
//               height: MediaQuery.of(context).size.height*0.8,
//               width:MediaQuery.of(context).size.width ,
//               child: JsonSchema(
//                 decorations: decorations,
//                 //keyboardTypes: keyboardTypes,
//                 form: widget.form,
//                 onChanged: (dynamic response) {
//                   print(jsonEncode(response));
//                   this.response = response;
//                 },
//                 actionSave: (data) {
//                   print(data);
//                 },
//                 buttonSave: new Container(
//                   height: 40.0,
//                   color: Colors.blueAccent,
//                   child: Center(
//                     child: Text("Sumbit",
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
//   void _openCamera(BuildContext context)  async{
//     final pickedFile = await ImagePicker().getImage(
//       source: ImageSource.camera,
//     );
//     List<int> imageBytes = File(pickedFile.path).readAsBytesSync();
//     String base64Image = base64Encode(imageBytes);
//
//     print('here is base 64 image');
//     print(base64Image);
//     // imController.text=base64Image;
//     var trimmed = base64Image.substring(0, min(base64Image.length,20));
//     print(trimmed);
//     setState(() {
//       imController.text=trimmed;
//       // imageFile = pickedFile!;
//     });
//
//     // Navigator.pop(context);
//   }
// }