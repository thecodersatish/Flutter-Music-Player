import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.transparent, //No more green
        elevation: 0.0, //Shadow gone
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Container(
                  child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: AssetImage("assets/images/developer.jpg"),
                              radius: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "Navya S/W Solutions",
                                style: TextStyle(
                                    fontSize: 20, color: Theme.of(context).accentColor),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.facebook,
                                  color: Theme.of(context).accentColor,
                                  size: 25,
                                ),
                                onPressed: () =>
                                    launchUrl("https://www.facebook.com/satish.naidu.5203577")),
                            IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.linkedin,
                                  color: Theme.of(context).accentColor,
                                  size: 25,
                                ),
                                onPressed: () =>
                                    launchUrl("https://www.linkedin.com/in/satish-adabala/")),
                            IconButton(
                                icon: Icon(
                                  Icons.mail,
                                  color: Theme.of(context).accentColor,
                                  size: 25,
                                ),
                                onPressed: () =>
                                    launchUrl("mailto:thecodersatish@gmail.com")),
                          ],
                        ),
                      ],
                    ),
                ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                    children: <Widget>[
                      Text("Developed by:",
                       style: TextStyle(fontSize: 20,color: Theme.of(context).accentColor),),
                      SizedBox(height: 10,),
                      Text(
                        "Satish Adabala",
                        style: TextStyle(fontSize: 30,color: Theme.of(context).accentColor),
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(
                                Icons.mail,
                                color: Theme.of(context).accentColor,
                                size: 25,
                              ),
                              onPressed: () =>
                                  launchUrl("mailto:thecodersatish@gmail.com")),
                          IconButton(
                              icon: Icon(
                                FontAwesomeIcons.facebook,
                                color: Theme.of(context).accentColor,
                                size: 25,
                              ),
                              onPressed: () => launchUrl(
                                  "https://www.facebook.com/satish.naidu.5203577")),
                          new IconButton(
                            icon: new Icon(FontAwesomeIcons.githubSquare,
                                color: Theme.of(context).accentColor, size: 25),
                            onPressed: () => launchUrl(
                                "https://github.com/thecodersatish"),
                          )
                        ],
                      ),
                    ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}
