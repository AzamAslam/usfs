// import 'package:flutter/material.dart';
//
// // int id = 3;
//
// class ButtonClass extends StatefulWidget {
//   final Icon icon;
//   final FontWeight fontWeightText;
//   final double fontSizeText;
//   final String title;
//    bool isCheck;
//
//   ButtonClass(this.icon, this.fontSizeText, this.fontWeightText, this.title,
//       this.isCheck);
//
//   @override
//   State<ButtonClass> createState() => _ButtonClassState();
// }
//
// class _ButtonClassState extends State<ButtonClass> {
//   @override
//   Widget build(BuildContext context) {
//     print(widget.isCheck);
//     return widget.isCheck
//         ? Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               CircleAvatar(
//                 backgroundColor: Colors.blue,
//                 child: IconButton(
//                   color: Colors.white,
//                   icon: widget.icon,
//                   onPressed: () {
//                     int index;
//
//                     if (widget.title == 'BaseMap')
//                       index = 1;
//                     else if (widget.title == 'Overlays')
//                       index = 2;
//                     else if (widget.title == 'Coordinate')
//                       index = 3;
//                     else if (widget.title == 'Search') id = 4;
//
//                     setState(() {
//                       id = index;
//                     });
//                   },
//                   splashRadius: 40,
//                 ),
//               ),
//               Text(
//                 widget.title,
//                 style: TextStyle(
//                   fontWeight: widget.fontWeightText,
//                   fontSize: widget.fontSizeText,
//                 ),
//               )
//             ],
//           )
//         : Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               IconButton(
//                 icon: widget.icon, onPressed: () {
//                   int index;
//                 if (widget.title == 'BaseMap')
//                   index = 1;
//                 else if (widget.title == 'Overlays')
//                   index = 2;
//                 else if (widget.title == 'Coordinate')
//                   index = 3;
//                 else if (widget.title == 'Search')
//                   id = 4;
//
//                 setState(() {
//                   // widget.isCheck = true;
//                   id=index;
//                 });
//                   print(id);
//                   print(index);
//               },
//                 splashRadius: 40,
//               ),
//               Text(
//                 widget.title,
//                 style: TextStyle(
//                   fontWeight: widget.fontWeightText,
//                   fontSize: widget.fontSizeText,
//                 ),
//               )
//             ],
//           );
//   }
// }
