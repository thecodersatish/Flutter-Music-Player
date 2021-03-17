import 'dart:async';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:satish_play_music/pages/list_songs.dart';
import 'package:satish_play_music/pages/card_detail.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:satish_play_music/service/audioPlayerTask.dart';


class NowPlaying extends StatefulWidget {
  DatabaseClient db;
  NowPlaying(this.db);
  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  static const platform = const MethodChannel('ringtone');
  Future<SharedPreferences> sharedPreferences;
  //final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId("music");
  List<String> favourites=[];

  @override
  void initState() {
    super.initState();
    sharedPreferences = SharedPreferences.getInstance();
    listenfavourites();
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Now Playing"),
        actions: [
          IconButton(icon: Icon(
              Icons.playlist_play,
              size: 32,
              color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white
          ), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ListSongs(widget.db,4,[])));
          }),
          _assetsAudioPlayer.builderCurrent(
              builder: (context, playing) {
                if (playing != null) {
                  return PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),
                    onSelected: (choice)async{
                      if(choice == Constants.Album){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CardDetail(0,widget.db,playing.audio.audio)));
                      }else if(choice == Constants.Artist){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CardDetail(1,widget.db,playing.audio.audio)));
                      }else if(choice == Constants.Favourite){
                        UpdateFavourites(_assetsAudioPlayer.current.value.audio.audio.metas.id);
                      }
                      else if(choice == Constants.RingTone){
                        try {
                          final String temp = await platform.invokeMethod(
                              'setringtone', {
                            "arg": _assetsAudioPlayer.current.value.audio
                                .audio.path
                          });
                          print(temp);
                        }on PlatformException catch (e) {
                          print(e);
                        }
                      }else if(choice == Constants.Share){
                        await FlutterShare.shareFile(
                          title: "Share Music File",
                          text: _assetsAudioPlayer.current.value.audio.audio.metas.title,
                          filePath: _assetsAudioPlayer.current.value.audio.audio.metas.extra["filePath"],
                        );
                      }
                      else if(choice == Constants.Details){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return new SimpleDialog(
                                backgroundColor: Theme.of(context).accentColor,
                                title: Text("Music Details"),
                                children: [
                                  Text("Filepath:  "+_assetsAudioPlayer.current.value.audio.audio.metas.extra["filePath"]),
                                  Text("Title:     "+_assetsAudioPlayer.current.value.audio.audio.metas.title),
                                  Text("Album:     "+_assetsAudioPlayer.current.value.audio.audio.metas.album),
                                  Text("Artist:    "+_assetsAudioPlayer.current.value.audio.audio.metas.artist),
                                ],
                              );
                            });
                      }
                      else{
                        print('Close');
                      }
                    },
                    itemBuilder: (BuildContext context){
                      return Constants.choices.map((String choice){
                        if(choice=="favourites") {
                          if(favourites.contains(_assetsAudioPlayer.current.value.audio.audio.metas.id)){
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text("Remove Favourites"),
                            );
                          }
                          else{
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text("Add to Favourites"),
                            );
                          }
                        }else{
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }
                      }).toList();
                    },
                  );
                }
                return Container();
              }
          )
        ],
      ),
        body:Center(
        child: _assetsAudioPlayer.builderCurrent(
        builder: (context, playing) {
      if (playing == null) {
        return FutureBuilder<SharedPreferences>(
          future: sharedPreferences,
          builder: (context, prefSnapshot) {
            if (prefSnapshot.hasData) {
              final prefs = prefSnapshot.data;
              if (prefs.containsKey('id')) {
                final audio = Audio(
                    prefs.getString('source'),
                  metas: Metas(
                    artist: prefs.getString('artist'),
                    album: prefs.getString('album'),
                    title: prefs.getString('title'),
                  ),
                );
                return nowPlayingScreen(
                    audio: audio, loadFromPrefs: prefs);
              }
            }
            return Center(
              child: Text('Not Playing: Go back to home page.'),
            );
          },
        );
      }
         return nowPlayingScreen(audio: playing.audio.audio);
          },
        ),
        ),
      );
  }
  Widget nowPlayingScreen(
      {Audio audio, SharedPreferences loadFromPrefs}) {
    return ListView(
      children: <Widget>[
        SizedBox(height: 10.0),
        Container(height: MediaQuery.of(context).size.height*0.50,
          width: MediaQuery.of(context).size.height*0.50,
          color: Colors.transparent,
          child:Image.file(
            File.fromUri(Uri.parse(audio.metas.image.path)),
            fit: BoxFit.fitHeight,
          ),
        ),
        SizedBox(height: 5.0),
        Column(
            children: <Widget>[
              _assetsAudioPlayer.builderRealtimePlayingInfos(
                  builder: (context, infos) {
                    if (infos == null) {
                      return SizedBox();
                    }
                    //print("infos: $infos");
                    return PositionSeekWidget(
                      currentPosition: infos.currentPosition,
                      duration: infos.duration,
                      seekTo: (to) {
                        _assetsAudioPlayer.seek(to);
                      },
                    );
                  }
              ),
              SizedBox(height: 10,),
              musicDetails(audio),
              SizedBox(height: 10,),
              _assetsAudioPlayer.builderLoopMode(
                builder: (context, loopMode) {
                  return PlayerBuilder.isPlaying(
                      player: _assetsAudioPlayer,
                      builder: (context, isPlaying) {
                        return PlayingControls(
                          loopMode: loopMode,
                          isPlaying: isPlaying,
                          isPlaylist: true,
                          onshuffle: () {
                            _assetsAudioPlayer.toggleShuffle();
                          },
                          toggleLoop: () {
                            _assetsAudioPlayer.toggleLoop();
                          },
                          onPlay: () {
                            _assetsAudioPlayer.playOrPause();
                          },
                          onNext: () {
                            //_assetsAudioPlayer.forward(Duration(seconds: 10));
                            _assetsAudioPlayer.next(
                                keepLoopMode: true
                              /*keepLoopMode: false*/);
                          },
                          onPrevious: () {
                            _assetsAudioPlayer.previous(
                              /*keepLoopMode: false*/);
                          },
                        );
                      });
                },
              ),
            ]
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget musicDetails(Audio audio) {
    return Column(
      children: <Widget>[
        Text(
          audio.metas.title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24.0,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white, fontWeight: FontWeight.bold),
          maxLines: 1,
        ),
        SizedBox(height: 10.0),
        Text('${audio.metas.album}',
    maxLines: 1,
    style: TextStyle(fontSize: 20.0,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),),
      ],
    );
  }

}



class PlayingControls extends StatelessWidget {
  final bool isPlaying;
  final LoopMode loopMode;
  final bool isPlaylist;
  final Function() onPrevious;
  final Function() onPlay;
  final Function() onNext;
  final Function() toggleLoop;
  final Function() onshuffle;

  PlayingControls({
    @required this.isPlaying,
    this.isPlaylist = false,
    this.loopMode,
    this.toggleLoop,
    this.onPrevious,
    @required this.onPlay,
    this.onNext,
    this.onshuffle,
  });
  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId("music");
  Widget _loopIcon(BuildContext context) {
    final iconSize = 34.0;
    if (loopMode == LoopMode.none) {
      return Icon(
        Icons.loop,
        size: iconSize,
        color: Colors.grey,
      );
    } else if (loopMode == LoopMode.playlist) {
      return Icon(
        Icons.loop,
        size: iconSize,
        color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white,
      );
    } else {
      //single
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.loop,
            size: iconSize
            ,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white,
          ),
          Center(
            child: Text("1", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            toggleLoop();
          },
          child: _loopIcon(context),
        ),
        IconButton(
          onPressed: isPlaylist ? this.onPrevious : null,
          icon: Icon(Icons.skip_previous,size: 32,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),
        ),
        ClipOval(
          child: Material(
            color: Colors.blue, // button color
            child: InkWell(
              child: SizedBox(width: 56, height: 56, child: Icon(
                  isPlaying?Icons.pause : Icons.play_arrow_sharp,
                  size: 32,
                  color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white
              ),),
              onTap: this.onPlay,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.skip_next,size: 32,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),
          onPressed: isPlaylist ? this.onNext : null,
        ),
        StreamBuilder(builder: (context,snapshot){
          return IconButton(
            onPressed: this.onshuffle,
            icon: Icon(
              Icons.shuffle,
              size: 32,
              color: _assetsAudioPlayer.isShuffling.value?DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white:Colors.grey,
            ),
          );
        },
          stream: _assetsAudioPlayer.isShuffling,),
      ],
    );
  }
}


class PositionSeekWidget extends StatefulWidget {
  final Duration currentPosition;
  final Duration duration;
  final Function(Duration) seekTo;

  const PositionSeekWidget({
    @required this.currentPosition,
    @required this.duration,
    @required this.seekTo,
  });

  @override
  _PositionSeekWidgetState createState() => _PositionSeekWidgetState();
}

class _PositionSeekWidgetState extends State<PositionSeekWidget> {
  Duration _visibleValue;
  bool listenOnlyUserInterraction = false;
  double get percent => widget.duration.inMilliseconds == 0
      ? 0
      : _visibleValue.inMilliseconds / widget.duration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInterraction) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Slider(
            activeColor:  DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white,
            inactiveColor:  DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black54:Colors.white60,
            min: 0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: percent * widget.duration.inMilliseconds.toDouble(),
            onChangeEnd: (newValue) {
              setState(() {
                listenOnlyUserInterraction = false;
                widget.seekTo(_visibleValue);
              });
            },
            onChangeStart: (_) {
              setState(() {
                listenOnlyUserInterraction = true;
              });
            },
            onChanged: (newValue) {
              setState(() {
                final to = Duration(milliseconds: newValue.floor());
                _visibleValue = to;
              });
            },
          ),
          Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 20)),
              Text(durationToString(widget.currentPosition),style: TextStyle(color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),),
              Spacer(),
              Text(durationToString(widget.duration),style: TextStyle(color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.black87:Colors.white),),
    Padding(padding: EdgeInsets.only(left: 20)),
            ],
          )
        ],
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes =
  twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  String twoDigitSeconds =
  twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return "$twoDigitMinutes:$twoDigitSeconds";
}


class Constants{
  static const String Album = 'Go to Album';
  static const String Artist = 'Go to Artist';
  static const String Close = 'Close';
  static const String Favourite = 'favourites';
  static const String Share = 'Share';
  static const String RingTone = 'Set as Ringtone';
  static const String Details = 'Show Details';

  static const List<String> choices = <String>[
    Album,
    Artist,
    Favourite,
    Share,
    RingTone,
    Details,
    Close
  ];
}

