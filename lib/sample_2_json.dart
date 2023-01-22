import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_form_builder/formbuilder.dart';
import 'package:simple_form_builder/global/checklistModel.dart';
import 'dart:io';

import 'Utility.dart';
import 'main.dart';
class SampleTwo extends StatefulWidget {
  final form;

  const SampleTwo({Key key, this.form}) : super(key: key);

  @override
  _SampleTwoState createState() => _SampleTwoState();
}

class _SampleTwoState extends State<SampleTwo> {
  TextEditingController longController=TextEditingController();
  TextEditingController latController=TextEditingController();
  TextEditingController imController=TextEditingController();
  getLAT()async{
    latController.text=latt;
    longController.text=longg;

    setState(() {

    });
  }
  @override
  void initState() {
    getLAT();
    super.initState();
    //onValueChangeStream = _onUserController.stream.asBroadcastStream();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Json To Form"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: longController,
              decoration: InputDecoration(
                hintText: 'Long',
                prefixIcon: Icon(Icons.location_on_outlined),
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),

            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              controller: latController,
              decoration: InputDecoration(
                hintText: 'Latitude',
                prefixIcon: Icon(Icons.location_on_outlined),
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),

            ),
            SizedBox(
              height: 20.0,
            ),
            Container(

              child:TextField(
                controller: imController,
                decoration: InputDecoration(
                  hintText: 'BAse64',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),

              ),




            ),
            InkWell(
                onTap: (){
                  _openCamera(context);
                },
                child: Container(
                    height: 50.0,
                    width: 130.0,
                    child: Row(
                      children: [
                        Text("Upload Image"),
                        Icon(Icons.upload_sharp),
                      ],
                    ))),


            Container(
              height: MediaQuery.of(context).size.height*0.7,
              width:MediaQuery.of(context).size.width ,
              child: FormBuilder(
                initialData: widget.form,
                title: "",
                titleStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                description: "",
                widgetCrossAxisAlignment: CrossAxisAlignment.center,
                index: 0,
                onUpload:'',
                showIndex: false,
                descriptionTextDecoration: TextStyle(color: Colors.red),
                submitButtonWidth: 1,
                submitButtonDecoration: BoxDecoration(
                  color: Colors.blue,
                ),
                showIcon: false,
                onSubmit: (ChecklistModel val) {
                  if (val == null) {
                    print("no data");
                  } else {
                    // var json = jsonEncode(val.toJson());
                    // print(json);
                  }
                },
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          print( currentLocationStored);
          longController.text=longg;
          latController.text=latt;
          setState(() {

          });
          //locationController=currentLocationStored;
          //   print(response['fields'][4]);


          setState(() {

          });


        },
        child: const Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
    );
  }
  var _image;

  var pic;

  var picc;

  var imgO;

  void _openCamera(BuildContext context)  async{
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    List<int> imageBytes = File(pickedFile.path).readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    print('here is base 64 image');
    print(base64Image);
    // imController.text=base64Image;
    var trimmed = base64Image.substring(0, min(base64Image.length,20));
    print(trimmed);
    setState(() {
      imController.text=trimmed;
      // imageFile = pickedFile!;
    });

    // Navigator.pop(context);
  }

}
