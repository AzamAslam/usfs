import 'package:flutter/material.dart';
import 'package:tableview/tableview.dart';

class TableViewer extends StatefulWidget {
  const TableViewer({Key key}) : super(key: key);

  @override
  _TableViewerState createState() => _TableViewerState();
}

class _TableViewerState extends State<TableViewer> {

  static List<String> headerList = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
  // 设置tableView的数据源，如果需要显示section，数据源就是二位数据
  static List<List<String>> rowList = [
    ["Ahmar"],
    ["Bilal","Brown","Blue","Biscuits"],
    ["Camal","Cat"],
    ["qweqw","etrte","xcvx","xcvx","mnmvfv","nbnnb"],
    ["bbvvb","bbvvb","cvvcv"],
    ["vcvcv","xzxzxz"],
    ["assasa","dsa","qqqww","weqe","eret"],
    ["rtrtrt","tytyty","uyyuy"],
    ["ioioi"],
    ["opopop","popopo","zxzz","zxczxc"],
    ["xccxc","cvcvcv","vbvbv","bnnb","bnnbn","mnm"],
    ["zxcz","zxczx"],
    ["zxczx"],
    ["zxczx"],
    ["zxczx","zxczxc","zxczxc"],
    ["zxczx","zxczxc","cvcvb","vbbvb"],
    ["vbvb","vcvc","fghfghfghfghf"],
    ["hjgjgj"],
    ["kjkjkj","klklkl","ukuiku"],
    ["csdsdc"],
    ["zxczx","zxczxc","zxczxc"],
  ["zxczx","zxczxc","cvcvb","vbbvb"],
  ["vbvb","vcvc","fghfghfghfghf"],
  ["hjgjgj"],
  ["kjkjkj","klklkl","ukuiku"],
  ["csdsdc"]
  ];
  int choseSection = 0;
  String title = "";

  double btnWidth = 60;
  int num = 5;
  double space = 10;

  @override
  void initState() {

    super.initState();

  }


// tableview的代理，用于设置tableview的section个数，cell个数，section(header)高度，cell高度,每个cell和section的样式
  var delegate = TableViewDelegate(

      numberOfSectionsInTableView: (){return headerList.length;},
      numberOfRowsInSection: (int section){ return rowList[section].length;},
      heightForHeaderInSection: (int section) { return 20;},
      heightForRowAtIndexPath: (IndexPath indexPath) { return 40;},
      viewForHeaderInSection: (BuildContext context, int section){
        return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 10),
          color: Color.fromRGBO(220, 220, 220, 1),
          height: 20,
          child: Text(headerList[section]),
        );
      },
      cellForRowAtIndexPath: (BuildContext context, IndexPath indexPath) {
        return InkWell(
          onTap: (){
            Navigator.of(context).pop(rowList[indexPath.section][indexPath.row]);
          },
          child: Container(
            color: Colors.white,
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child:Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      rowList[indexPath.section][indexPath.row],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Divider(indent: 10,endIndent: 10,height: 1,),
              ],
            ),
          ),
        );
      }
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table View'),
        backgroundColor: Colors.blueGrey,
      ),
      body: NotificationListener<TableViewNotifier> (
        onNotification: (notification) {

          choseSection = notification.scrollSection;
          setState(() {

          });
          return true;
        },
        child: TableView(
          delegate: delegate,
          // scrollbar的样式，可通过 implements TableViewScrollBar 自定义，如果同时设置startAlignment和endAlignment会有滑动效果，如效果2所示
          scrollbar: TableViewHeaderScrollBar(
            headerTitleList: headerList,
            itemHeight: 20,
            startAlignment: Alignment.centerRight,
            choseSection: choseSection,
            indexChanged: (index) {
              title = headerList[index];
              choseSection = index;
              setState(() {

              });
            },
            gestureFinished: (){
              title = "";
              setState(() {

              });
            },
          ),
          // scrollBar点击中间提示的Widget，可通过implement TableViewCenterTip自定义，无设置则无提示效果
          centerTip: TableViewCenterTitle(
            alignment: Alignment.center,
            title: title,
          ),
        ),
      ),
    );
  }
}
