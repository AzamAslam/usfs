import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../main.dart';

class MbtilesShow extends StatefulWidget {
  var mbtilesLayerList;
  MbtilesShow({Key key, this.mbtilesLayerList}) : super(key: key);

  @override
  _MbtilesShowState createState() => _MbtilesShowState();
}

class _MbtilesShowState extends State<MbtilesShow> {
  var _value = [];
  bool isChecked = false;
  var icons = [];

  initializeOpacity(){
    if(widget.mbtilesLayerList != null){
      for(int i=0; i<widget.mbtilesLayerList.length; i++){
        _value.add(1);
      }
    }
  }

  @override
  initState() {
    initializeOpacity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var heightScreen = MediaQuery.of(context).size.height;
    var widthScreen = MediaQuery.of(context).size.width;
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Select Layer'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: heightScreen * 0.9,
          child:  widget.mbtilesLayerList != null ?
          ListView.builder(
            itemCount: widget.mbtilesLayerList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20),
                    child: Text(widget.mbtilesLayerList[index]['fileName']),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      for(int i = 0; i < widget.mbtilesLayerList[index]['table'].length; i++)
                      SizedBox(
                        height: heightScreen * 0.16,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text('Table Name: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                      Text(widget.mbtilesLayerList[index]['table'][i]['name']),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: (){
                                      if(widget.mbtilesLayerList[index]['table'][i]['icon'] == Icons.remove_red_eye_outlined){
                                        widget.mbtilesLayerList[index]['table'][i]['icon'] = Icons.visibility_off_outlined;
                                      }
                                      else if(widget.mbtilesLayerList[index]['table'][i]['icon'] == Icons.visibility_off_outlined){
                                        widget.mbtilesLayerList[index]['table'][i]['icon'] = Icons.remove_red_eye_outlined;
                                        webController.evaluateJavascript("getRasterMap('${widget.mbtilesLayerList[index]['table'][i]['url']}', '${widget.mbtilesLayerList[index]['table'][i]['name']}')");
                                        webController.evaluateJavascript("zoomToextent('${widget.mbtilesLayerList[index]['table'][i]['extent']}')");
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      }
                                      setState(() {});
                                      },
                                      child: Icon(widget.mbtilesLayerList[index]['table'][i]['icon']))
                                ],
                                  ),
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Description: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                    Expanded(child: Text(widget.mbtilesLayerList[index]['table'][i]['description'])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ): Center(child: Text('No GPKG added yet')),
        ),
      ),
    );
  }
}
