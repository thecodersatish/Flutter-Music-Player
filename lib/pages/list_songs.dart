import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:satish_play_music/service/audioPlayerTask.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'dart:io';
import 'package:satish_play_music/views/miniPlayer.dart';

class ListSongs extends StatefulWidget {
  DatabaseClient db;
  int mode;
  List<Audio> allsongs;
  // mode =1=>recent, 2=>top, 3=>fav, 4+>current Playlist
  ListSongs(this.db,this.mode,this.allsongs);
  @override
  State<StatefulWidget> createState() {
    return new _listSong();
  }
}

class _listSong extends State<ListSongs> {
  List<Audio> songs=[];
  bool isLoading = true;
  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId("music");
  @override
  void initState() {
    super.initState();
    initSongs();
  }

  void initSongs() async {
    final preferences = await StreamingSharedPreferences.instance;
    switch (widget.mode) {
      case 1:
        {
          songs=await widget.db.fetchRecentSong();
          break;
        }
      case 2:
        {
          songs=await widget.db.fetchTopSong();
          break;
        }
      case 3:
        {
          final favourites=preferences.getStringList("favourites", defaultValue: []);
          for(int i=0;i<widget.allsongs.length;i++){
            if(favourites.getValue().contains(widget.allsongs[i].metas.id)){
              songs.add(widget.allsongs[i]);
            }
          }
          break;
        }
      case 4:
        {
          songs=_assetsAudioPlayer.playlist.audios;
          break;
        }
      default:
        break;
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget getTitle(int mode) {
    switch (mode) {
      case 1:
        return new Text("Recently played");
        break;
      case 2:
        return new Text("Top tracks");
        break;
      case 3:
        return new Text("Favourites");
        break;
      case 4:
        return new Text("Current PlayList");
        break;
      default:
        return null;
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Add songs"),
          content: new Text(
              "To add songs to favourite, press on Like Icon right on songs tab."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Got it"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // appBar: widget.orientation == Orientation.portrait
      //     ? new AppBar(
      //         title: getTitle(widget.mode),
      //       )
      //     : null,
        appBar: new AppBar(
                title: getTitle(widget.mode),
          actions: <Widget>[
            widget.mode == 3 ? IconButton(
              icon: Icon(Icons.add,), onPressed: () {
              _showDialog();
            },) : Container()
          ],
        ),

        body: new Container(
          child: isLoading
              ? new Center(
                  child: new CircularProgressIndicator(),
                )
              : new ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, i) => Column(
              children: <Widget>[
                new Divider(
                  height: 8.0,
                ),
                new ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child:Container(height: 50,width: 50,child: songs[i].metas.image.path!=null?
                    Image.file(File.fromUri(Uri.parse(songs[i].metas.image.path))):
                    Image.asset("assets/images/download.png"),),),
                  title: new Text(songs[i].metas.title,
                      maxLines: 1,
                      style: new TextStyle(fontSize: 18.0,color:Theme.of(context).accentColor)),
                  subtitle: new Text(
                    songs[i].metas.artist,
                    maxLines: 1,
                    style: new TextStyle(
                        fontSize: 12.0, color: Colors.grey),
                  ),
                  trailing: widget.mode == 4?PlayerBuilder.isPlaying(
                      player: _assetsAudioPlayer,
                      builder: (context, isPlaying) {
                        if(isPlaying != null){
                          if(_assetsAudioPlayer.current.valueWrapper.value.audio.audio.metas.id==songs[i].metas.id){
                            if(_assetsAudioPlayer.isPlaying.valueWrapper.value)
                            return Image.asset("assets/images/playing.gif",height: 40,width: 40,);
                            else
                            return Image.asset("assets/images/pausing.gif",height: 40,width: 40,);
                          }
                          return Container(height: 0,width: 0,);
                        }
                        return Container(height: 0,width: 0,);
                      }):widget.mode == 2
                      ? new Text(
                    (i + 1).toString(),
                    style: new TextStyle(
                        fontSize: 12.0, color: Colors.grey),
                  )
                      : new Text(songs[i].metas.extra["duration"]
                      .toString()
                      .split('.')
                      .first,
                      style: new TextStyle(
                          fontSize: 12.0, color: Colors.grey)),
                  onTap: () {
                    if(widget.mode==4) {
                      _assetsAudioPlayer.playlistPlayAtIndex(i);
                    }
                    else{
                      playAudioByIndex(songs, i);
                    }
                  },
                  onLongPress: () {
                    if (widget.mode == 3) {
                      showDialog(
                        context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text(
                              'Are you sure want remove this from favourites?'),
                          content: new Text(songs[i].metas.title),
                          actions: <Widget>[
                            new FlatButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: new Text(
                                'No',
                              ),
                            ),
                            new TextButton(
                              onPressed: () async {
                                UpdateFavourites(songs[i].metas.id);
                                setState(() {
                                  songs.removeAt(i);
                                });
                                Navigator.of(context).pop();
                              },
                              child: new Text('Yes'),
                            ),
                          ],
                        );
                      }
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      bottomNavigationBar:  MiniPlayer(widget.db),
    );
  }
}
