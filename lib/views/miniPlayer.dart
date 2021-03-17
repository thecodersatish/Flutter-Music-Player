import 'dart:async';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:satish_play_music/views/nowPlaying.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class MiniPlayer extends StatefulWidget {
  DatabaseClient db;
  MiniPlayer(this.db);
  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Future<SharedPreferences> sharedPreferences;
  StreamSubscription notificationClickSubscription;
  bool pageOpened = false;
  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId("music");
  @override
  void initState() {
    super.initState();
    sharedPreferences = SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    notificationClickSubscription?.cancel();
    super.dispose();
  }

  void _openNowPlaying() async {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>NowPlaying(widget.db)));
    // Navigate to now playing page.
  }

  @override
  Widget build(BuildContext context) {
    return _assetsAudioPlayer.builderCurrent(
      builder: (BuildContext context, Playing playing) {
        if (playing != null) {
          return InkWell(
           child: Container(
              height: 65,
              color: DynamicTheme.of(context).brightness==Brightness.dark?Colors.grey[900]:Colors.white60,
              width: MediaQuery.of(context).size.width,
            child:Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(7),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(File.fromUri(Uri.parse(playing.audio.audio.metas.image.path))),
                    ),
                  ),),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          playing.audio.audio.metas.title,
                          maxLines: 1,
                          style: TextStyle(fontSize: 18,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),
                        ),
                        Text(
                          playing.audio.audio.metas.album,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                        children: [
                          IconButton(icon: Icon(
                            Icons.skip_previous,
                            size: 32,
                              color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white
                          ), onPressed: () {
                            _assetsAudioPlayer.previous();
                          }),
                          Padding(padding: EdgeInsets.only(left: 5)),
                          _assetsAudioPlayer.builderLoopMode(
                              builder: (context, loopMode) {
                                return PlayerBuilder.isPlaying(
                                    player: _assetsAudioPlayer,
                                    builder: (context, isPlaying) {
                                      return IconButton(icon: Icon(
                                        isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                                          size: 23,
                                          color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white
                                      ), onPressed: () {
                                        _assetsAudioPlayer.playOrPause();
                                      });
                                    }
                                );
                              }
                          ),
                          IconButton(icon: Icon(
                            Icons.skip_next,
                            size: 32,
                              color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white
                          ), onPressed: () {
                            _assetsAudioPlayer.next();
                          })
                        ],
                      ),
              ]
            )
          ),
            onTap: _openNowPlaying,
          );
        }
            return Container(
              height: 65,
              color: DynamicTheme.of(context).brightness==Brightness.dark?Colors.grey[900]:Colors.white54,
              width: MediaQuery.of(context).size.width,
              child: ListTile(
                isThreeLine: true,
                leading: Image.asset("assets/images/logo.png",height: 40,),
                title: Text('Not Playing',style: TextStyle(color:Theme.of(context).accentColor),),
                subtitle: Text('Tap on a song from the list.',style: TextStyle(color:Theme.of(context).accentColor),),
              ),
            );
          },
        );
  }
}
