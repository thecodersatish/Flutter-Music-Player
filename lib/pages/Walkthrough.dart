import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:satish_play_music/musichome.dart';
import 'package:satish_play_music/pages/NoMusicFound.dart';

class SplashScreen extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return new SplashState();
  }
}

class SplashState extends State<SplashScreen> {
  var db;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        body: SafeArea(
          child: new Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/images/ic_splash.png",height: 100,),
                Center(
                    child: Container(),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 5),
                  child: Text(
                    "Satish Play Music",
                    style: TextStyle(color:Theme.of(context).accentColor,fontSize: 25),
                  ),
                ),
                Text("Setting up...",
                    style: TextStyle(color:Theme.of(context).accentColor, fontSize: 20))
              ],
            ),
          ),
        ));
  }

  loadSongs() async {
    setState(() {
      isLoading = true;
    });
    var db = new DatabaseClient();
    await db.create();
    if (await db.alreadyLoaded()) {
     // Navigator.of(context).pop();
      await Future.delayed(const Duration(seconds: 2), () => "3");
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) {
        return new MusicHome();
      }));
    } else {
      var songs;
      try {
        final audioquery=new FlutterAudioQuery();
        songs = await audioquery.getSongs();
        List<SongInfo> list = new List.from(songs);
        if (list == null || list.length == 0) {
          print("List-> $list");
          Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) {
            return new NoMusicFound();
          }));
        }
        else {
          for (SongInfo song in list) {
            db.insertOrUpdateSong(song);
          }
          if (!mounted) {
            return;
          }
          new Future.delayed(const Duration(seconds: 100), () => "5");
          Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) {
            return new MusicHome();
          }));
        }
      } catch (e) {
        print("failed to get songs");
      }
    }
  }

}
 