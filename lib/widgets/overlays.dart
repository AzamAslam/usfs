import 'package:flutter/material.dart';

class Overlays extends StatefulWidget {
  const Overlays({Key key}) : super(key: key);

  @override
  State<Overlays> createState() => _OverlaysState();
}

class _OverlaysState extends State<Overlays> with SingleTickerProviderStateMixin {

  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: 100,
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Container(
              //   height: MediaQuery.of(context).size.height / 2,
              //   child: Center(
              //     child: Text(
              //       "Tabbar with out Appbar",
              //       style: TextStyle(
              //           color: Colors.white, fontWeight: FontWeight.bold),
              //     ),
              //   ),
              //   color: Colors.blue,
              // ),
              TabBar(
                unselectedLabelColor: Colors.black,
                labelColor: Colors.red,
                tabs: [
                  Tab(
                    text: '1st tab',
                  ),
                  Tab(
                    text: '2 nd tab',
                  )
                ],
                controller: _controller,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Container(child: Center(child: Text('people'))),
                    Text('Person')
                  ],
                  controller: _controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
