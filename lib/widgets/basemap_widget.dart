import 'package:flutter/material.dart';

class BaseMapLayers extends StatefulWidget {
  String baseMapLayerName;
  String baseMapLayerImage;
  int groupValue = 1 ;
  int indexValue;

  // int groupvalue = 1;

  var baseMapList;

  BaseMapLayers({
    this.baseMapList,
    // this.baseMapLayerName,
    // this.baseMapLayerImage,
    // this.groupValue,
    // this.indexValue,
  });

  @override
  State<BaseMapLayers> createState() => _BaseMapLayersState();
}

class _BaseMapLayersState extends State<BaseMapLayers> {
  @override
  Widget build(BuildContext context) {
    var displayHeight = MediaQuery.of(context).size.height;
    var displayWidth = MediaQuery.of(context).size.width;
    // print(widget.indexValue);
    print(widget.baseMapList[0]['groupValue']);
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.baseMapList.length,
        itemBuilder: (BuildContext context, int i) {
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Radio(
                  value: widget.baseMapList[i]['index'],
                  groupValue: widget.groupValue,
                  onChanged: (value) {
                    setState(() {
                      widget.groupValue = value;
                    });
                  },
                ),
                const Text(
                  'Bright Style',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Container(
                  height: displayHeight * 0.1,
                  width: displayWidth * 0.2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/basemap/1.png'),
                      fit: BoxFit.fill,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}
