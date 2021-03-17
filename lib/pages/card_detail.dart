import 'dart:io';
import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:satish_play_music/service/audioPlayerTask.dart';
import 'package:satish_play_music/views/miniPlayer.dart';

class CardDetail extends StatefulWidget {
  int mode;
  DatabaseClient db;
  Audio song;
  CardDetail(this.mode,this.db,this.song);
  @override
  State<StatefulWidget> createState() {
    return new stateCardDetail();
  }
}

class stateCardDetail extends State<CardDetail> {
  List<Audio> songs;
  bool isLoading = true;
  var image;
  @override
  void initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    if (widget.mode == 0) {
      songs=await widget.db.fetchSongsFromAlbum(widget.song.metas.extra["albumId"]);
    }
    else {
      songs=await widget.db.fetchSongsByArtist(widget.song.metas.artist);
    }
    image=File.fromUri(Uri.parse(songs[0].metas.image.path));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return new Scaffold(
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new CustomScrollView(
              slivers: <Widget>[
                new SliverAppBar(
                  expandedHeight:
                      orientation == Orientation.portrait ? 350.0 : 200.0,
                  floating: false,
                  pinned: true,
                  title: widget.mode==0?Text(widget.song.metas.album):Text(widget.song.metas.artist),
                  flexibleSpace: new FlexibleSpaceBar(
                    background: new Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        image != null
                              ? new Image.file(
                                  image,
                                  fit: BoxFit.cover,
                                )
                              : new Image.asset("assets/images/album.jpg",
                                  fit: BoxFit.cover),
                      ],
                    ),
                  ),
                ),
                new SliverList(
                  delegate: new SliverChildListDelegate(<Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: new Text(
                        widget.mode == 0
                            ? widget.song.metas.album
                            : widget.song.metas.artist,
                        style: new TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold,color:Theme.of(context).accentColor),
                        maxLines: 1,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 10.0, bottom: 10.0),
                      child: new Text(songs.length.toString() + " song(s)",style: TextStyle(color:Theme.of(context).accentColor),),
                    ),
                    new Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: new Text("Songs",
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ))),
                  ]),
                ),
                new SliverList(
                  delegate: new SliverChildBuilderDelegate((builder, i) {
                    return new Column(
                      children: [
                        new Divider(
                          height: 7.0,
                        ),
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(height: 50,width: 50,child: Center(
                              child: Text("-",style: TextStyle(color:Theme.of(context).accentColor,fontSize: 25),),))),
                          title: new Text(songs[i].metas.title,
                              maxLines: 1, style: new TextStyle(fontSize: 18.0,color:Theme.of(context).accentColor)),
                          subtitle: new Text(
                            songs[i].metas.artist,
                            maxLines: 1,
                            style:
                            new TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                          ),
                          trailing: new Text(
                              songs[i].metas.extra["duration"]
                                  .toString()
                                  .split('.')
                                  .first,
                              style: new TextStyle(
                                  fontSize: 12.0, color:Theme.of(context).accentColor)),
                          onTap: () {
                            playAudioByIndex(songs,i);
                          },
                        )
                      ],
                    );
                  }, childCount: songs.length),
                ),
              ],
            ),
      bottomNavigationBar: MiniPlayer(widget.db),
    );
  }
}
