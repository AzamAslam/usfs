import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/material.dart';

import 'main.dart';
class JSONScreen extends StatefulWidget {
  final listt;
  final name;
  final mapList;

  const JSONScreen({Key key, this.listt, this.name,this.mapList}) : super(key: key);
  @override
  _JSONScreenState createState() => _JSONScreenState();
}

class _JSONScreenState extends State<JSONScreen> {
  List<SelectedListItem> _listOfCities;
  void initState(){
    super.initState();
    _listOfCities=widget.listt;
  }
  Icon customIcon = const Icon(Icons.search);
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  var names;
  //Widget customSearchBar =  Text('SpatialLite ${widget.name}');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("SpatialLite ${widget.name}"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                print("TAP");
                DropDownState(
                  DropDown(
                    submitButtonText: "kDone",
                    submitButtonColor: const Color.fromRGBO(70, 76, 222, 1),
                    searchHintText: "Search Name",
                    bottomSheetTitle: "SpatialLite ${widget.name}",
                    searchBackgroundColor: Colors.black12,
                    dataList: _listOfCities ?? [],
                    selectedItems: (List<dynamic> selectedList) {
                      var lat,long;
                      names=selectedList.toString();
                      for(int i=0;i<widget.mapList.length;i++){
                        if(widget.mapList[i]['name']=="$names"){
                         // print(widget.mapList.indexOf(widget.mapList[0]['name']));
                          print(widget.mapList[i]['long']);
                          long=widget.mapList[i]['long'];
                          lat=widget.mapList[i]['lat'];

                          // break;
                          //print()
                        }else{
                          print("not found");
                        }

                      }
                      print("here");
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>MyWidget()));

                      webController.evaluateJavascript("zoomToXy('$lat', '$long', '12')");


                      //showSnackBar(selectedList.toString());

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>MyWidget()));

                    },
                    selectedItem: (String selected) {
                    //  showSnackBar(selected);
                      var lat,long;
                      names=selected.toString();
                      for(int i=0;i<widget.mapList.length;i++){
                        if(widget.mapList[i]['name']=="$names"){
                          // print(widget.mapList.indexOf(widget.mapList[0]['name']));
                          print(widget.mapList[i]['long']);
                          long=widget.mapList[i]['long'];
                          lat=widget.mapList[i]['lat'];

                         // break;
                          //print()
                        }else{
                          print("not found");
                        }

                      }
                       print("here");
                      print(lat);
                      print(long);
                      webController.evaluateJavascript("zoomToXy('$lat', '$long', '12')");

                      setState(() {
                       // longg=long;
                      });
                     // Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
                     //  Navigator.pushAndRemoveUntil(
                     //      context,
                     //      MaterialPageRoute(
                     //          builder: (context) => MyApp()
                     //      ),
                     //      ModalRoute.of(context).(route) => MyApp()
                     //  );
                     Navigator.of(context).pop();


print("Navigate");


                    },
                    enableMultipleSelection: false,
                    // searchController: _searchTextEditingController,
                  ),
                ).showModal(context);
                print("TAP h");

              }
          )],


      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (names==null)?Text(""):Text(names,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }
}