import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupport extends StatelessWidget {
  const ContactSupport({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    var displayWidth = MediaQuery.of(context).size.width;
    var displayHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Contact Support'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo/logo.png'),
              SizedBox(height: 40,),
              data.size.shortestSide < 600 ? getMobile(displayWidth, displayHeight, 'Contact', 'https://techmaven.net/home/contact/'):
                  getTab(displayWidth, displayHeight, 'Contact: ', 'https://techmaven.net/home/contact/'),
              SizedBox(height: 40,),
              data.size.shortestSide < 600 ? getMobile(displayWidth, displayHeight, 'Support', 'http://support.techmaven.net/'):
              getTab(displayWidth, displayHeight, 'Support: ', 'http://support.techmaven.net/'),
              SizedBox(height: 40,),
              data.size.shortestSide < 600 ? getMobile(displayWidth, displayHeight, 'Website', 'https://mapexplorer.techmaven.net/'):
              getTab(displayWidth, displayHeight, 'Website: ', 'https://mapexplorer.techmaven.net/'),
            ],
          ),
        ),
      ),
    );
  }

  getTab(displayWidth, displayHeight, text, link) => Row(
    children: [
      Text(text, style: TextStyle(
          fontSize: displayHeight*0.02
      ),),
      InkWell(
          child: new Text(link, style: TextStyle(
              fontSize: displayHeight*0.02,
            color: Colors.blue
          ),),
          onTap: () => launch(link)
      ),
    ],
  );

  getMobile(displayWidht, displayHeight, text, link) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text, style: TextStyle(
          fontSize: displayHeight*0.03,
      ),),
      InkWell(
          child: new Text(link, style: TextStyle(
              fontSize: displayHeight*0.02,
            color: Colors.blue
          ),),
          onTap: () => launch(link)
      ),
    ],
  );

}
