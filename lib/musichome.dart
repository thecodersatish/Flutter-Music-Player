import 'dart:async';
import 'dart:convert';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:satish_play_music/pages/about_new.dart';
import 'package:satish_play_music/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:satish_play_music/views/album.dart';
import 'package:satish_play_music/views/songs.dart';
import 'package:satish_play_music/views/artists.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:satish_play_music/views/miniPlayer.dart';
import 'package:satish_play_music/pages/material_search.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:satish_play_music/views/playlists.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:move_to_background/move_to_background.dart';


class MusicHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _musicState();
  }
}

class _musicState extends State<MusicHome>with SingleTickerProviderStateMixin<MusicHome> {
  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Albums'),
    Tab(text: 'Songs'),
    Tab(text: 'Artists'),
    Tab(text: 'PlayLists'),
  ];
  ScrollController _scrollViewController;
  TabController _tabController;
  DatabaseClient db;
  String title = "Music player";
  bool isLoading = true;
  List<Audio>fetchedAudios;
  @override
  void initState() {
    super.initState();
    _scrollViewController = new ScrollController();
    _tabController = new TabController(vsync: this, length: 4);
    getLast();
  }

  void getLast() async {
    db = new DatabaseClient();
    await db.create();
    fetchedAudios=await db.fetchSongs();
    final preferences = await StreamingSharedPreferences.instance;
    final playlist=preferences.getStringList("playingList",defaultValue: []);
    final index=preferences.getInt("index", defaultValue: 0);
    final duration=preferences.getInt("duration", defaultValue: 0);
    int i=index.getValue(),dur=duration.getValue();
    List<Audio> songs=[];
    List<String> savedplaylist=playlist.getValue();
    savedplaylist.forEach((element) {
      Map<String,dynamic>temp=json.decode(element);
      Audio a=Audio.file(
        temp["uri"],
        metas: Metas(
          id:temp["id"],
          artist: temp["artist"],
          album: temp["album"],
          title: temp["title"],
          image: MetasImage.file(temp["albumArt"]),
          extra: {"duration":new Duration(milliseconds: temp["duration"]),"albumId":temp["albumId"],"filePath":temp["filePath"]}
        )
      );
      songs.add(a);
    });
    if(savedplaylist.length!=0){
      AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
      await _assetsAudioPlayer.open(
        Playlist(audios: songs, startIndex: i),
        autoStart: false,
        showNotification: true,
        playInBackground: PlayInBackground.enabled,
        audioFocusStrategy: AudioFocusStrategy.request(
            resumeAfterInterruption: true, resumeOthersPlayersAfterDone: true),
        headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
        notificationSettings: NotificationSettings(
            stopEnabled: false
        ),
      );
      _assetsAudioPlayer.seek(new Duration(milliseconds: dur));
    }
    setState(() {
      isLoading = false;
    });
    listensavings();
  }



  void listensavings()async{
    final preferences = await StreamingSharedPreferences.instance;
    _assetsAudioPlayer.current.listen((event) {
      if(event!=null) {
        preferences.setInt("index", event.index);
        db.updateSong(int.parse(event.audio.audio.metas.id));
      }
    });
    _assetsAudioPlayer.currentPosition.listen((event) {
      preferences.setInt("duration", event.inMilliseconds);
      _assetsAudioPlayer.playlistAudioFinished.listen((event1) {
        if(event1.index==_assetsAudioPlayer.playlist.audios.length-1 && event.inMilliseconds==event1.audio.duration.inMilliseconds-2){
          _assetsAudioPlayer.pause();
          _assetsAudioPlayer.seek(Duration.zero);
        }
      });
    });
  }

  @override
  void dispose() async {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  // getSharedData() async {
  //   const platform = const MethodChannel('app.channel.shared.data');
  //   Map sharedData = await platform.invokeMethod("getSharedData");
  //   if (sharedData != null) {
  //     if (sharedData["albumArt"] == "null") {
  //       sharedData["albumArt"] = null;
  //     }
  //     Song song = new Song(
  //         9999 /*random*/,
  //         sharedData["artist"],
  //         sharedData["title"],
  //         sharedData["album"],
  //         null,
  //         int.parse(sharedData["duration"]),
  //         sharedData["uri"],
  //         sharedData["albumArt"]);
  //     List<Song> list = new List();
  //     list.add((song));
  //     MyQueue.songs = list;
  //     Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
  //       return new NowPlaying(null, list, 0, 0);
  //     }));
  //   }
  // }


 Future<void> _refresh()async{
    Map<String,int> songids={};
    Map<String,int> dbsongids={};
    final audioquery=new FlutterAudioQuery();
    final songs1 = await audioquery.getSongs();
    songs1.forEach((element) {
      songids[element.id]=1;
    });
    final songs = await db.fetchSongs();
    songs.forEach((element) {
      if(!songids.containsKey(element.metas.id)){
        db.remove(int.parse(element.metas.id));
      }
      else{
        dbsongids[element.metas.id]=1;
      }
    });
    songs1.forEach((element) {
      if(!dbsongids.containsKey(element.id)){
        db.insertOrUpdateSong(element);
      }
    });
    print("hi");
    final preferences = await StreamingSharedPreferences.instance;
    preferences.setInt("refresh", new DateTime.now().millisecondsSinceEpoch);
  }

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(child: new Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: DynamicTheme.of(context).brightness==Brightness.dark?Colors.black87:Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text('Satish Play Music',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
                currentAccountPicture: Image.asset("assets/images/logo.png"),
                decoration: BoxDecoration(color: DynamicTheme.of(context).brightness==Brightness.dark?Colors.black26:Colors.white60,),
              ),
              ListTile(
                leading: Text('Settings',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>Settings(db)));
                },
              ),
              new Divider(
                height: 8.0,
              ),
              ListTile(
                leading: Text('About',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>AboutNew()));
                },
              ),
              new Divider(
                height: 8.0,
              ),
              ListTile(
                leading: Text('Close',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              new Divider(
                height: 8.0,
              ),
            ],
          ),
        ),
      ),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.alignLeft,size: 20,),
              onPressed:(){ _scaffoldKey.currentState.openDrawer(); },
            ),
            title: new Text("Play Music",),
            // Display a placeholder widget to visualize the shrinking size.
            elevation: 10.0,
            actions: <Widget>[
              new IconButton(
                  icon: Icon(FontAwesomeIcons.search,size: 20,),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchSong(db)));
                  }),
            ],
            bottom: new TabBar(
              indicatorWeight: 3.0,
              tabs: myTabs,
              indicatorColor: Theme.of(context).accentColor,
              controller: _tabController,
              indicatorPadding: EdgeInsets.only(top: 40),
            ),
          ),
      body: isLoading?new Center(child: CircularProgressIndicator(),):new TabBarView(
          children: <Widget>[
            Album(db),
            Songs(db),
            Artists(db),
            PlayList(db)
          ],
          controller: _tabController,
        ),
      bottomNavigationBar: isLoading?null:MiniPlayer(db),
    ),
    onWillPop: _onwillpop,
    );
  }

  Future<bool> _onwillpop()async{
    MoveToBackground.moveTaskToBack();
    return false;
  }

  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}



class Constants{
  static const String Setting = 'Settings';
  static const String About = 'About';
  static const String Close = 'Close';

  static const List<String> choices = <String>[
    Setting,
    About,
    Close
  ];
}
