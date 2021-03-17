import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:satish_play_music/service/audioPlayerTask.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class Songs extends StatefulWidget {
  DatabaseClient db;
  Songs(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _songsState();
  }
}

class _songsState extends State<Songs> with AutomaticKeepAliveClientMixin {
  var songs = <Audio>[];
  var favourites=<String>[];
  bool isloading=true;

  //final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId("music");
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    listensongs();
    listenfavourites();
    super.initState();
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
  listensongs()async{
    final preferences = await StreamingSharedPreferences.instance;
    final refresh=preferences.getInt("refresh",defaultValue: 1);
    refresh.listen((value) async{
      songs = await widget.db.fetchSongs();
      setState(() {
        isloading = false;
      });
    });
  }

  listenfavourites()async{
    final preferences = await StreamingSharedPreferences.instance;
    final favourites=preferences.getStringList("favourites",defaultValue: []);
    favourites.listen((value) {
      this.favourites=value;
      setState(() {

      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(body:Container(
        child: isloading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : Column(children: <Widget>[
          Expanded(
            child: new ListView.builder(
              key: new PageStorageKey('songs'),
              itemCount: songs.length+1,
              itemBuilder: (context, i) {
                if(i==0){
                  return SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 20,
                    child: OutlineButton(
                        child: Text("Shuffle All", style: TextStyle(
                            fontSize: 20,color:  DynamicTheme
                            .of(context)
                            .brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87
                        ),),
                        onPressed: () async{
                          List<Audio> shufflesongs=List.from(songs);
                          shufflesongs.shuffle();
                          playAudioByIndex(shufflesongs,0);
                        },
                        borderSide: BorderSide(
                          color: DynamicTheme
                              .of(context)
                              .brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.black26, //Color of the border
                          style: BorderStyle.solid, //Style of the border
                          width: 1, //width of the border
                        ),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        )),
                  );
                }
                return new Column(
                  children: <Widget>[
                    new Divider(
                      height: 8.0,
                    ),
                    new ListTile(
                      leading:
                    ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(File.fromUri(Uri.parse(songs[i-1].metas.image.path)),height: 50,width: 50,),
                    ),
                      title: new Text(songs[i-1].metas.title,
                          maxLines: 1,
                          style: new TextStyle(fontSize: 17.0,color: DynamicTheme
                              .of(context)
                              .brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87)),
                      subtitle: new Text(
                        songs[i-1].metas.artist,
                        maxLines: 1,
                        style: new TextStyle(
                            fontSize: 12.0, color: DynamicTheme
                            .of(context)
                            .brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black54),
                      ),
                      trailing: new IconButton(icon: favourites.contains(
                          songs[i-1].metas.id) ?Icon( FontAwesomeIcons.solidHeart ,color: Colors.redAccent):Icon(FontAwesomeIcons.heart ,color: DynamicTheme
                          .of(context)
                          .brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54), onPressed: () {
                        UpdateFavourites(songs[i-1].metas.id);
                      }),
                      onTap: () {
                        playAudioByIndex(songs, i-1);
                      },
                      onLongPress: (){
                        opensongoptions(context, songs[i-1]);
                      },
                    ),
                  ],
                );
              }
            ),
          )
        ])
    )
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
