import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:satish_play_music/database/database_client.dart';
import 'package:satish_play_music/service/audioPlayerTask.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:satish_play_music/pages/card_detail.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class Album extends StatefulWidget {
  DatabaseClient db;
  Album(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _stateAlbum();
  }
}

class _stateAlbum extends State<Album> with AutomaticKeepAliveClientMixin{
  var albums=<Audio>[];
  var f;
  bool isLoading = true;
  @override
  initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    // songs=await widget.db.fetchSongs();
    final preferences = await StreamingSharedPreferences.instance;
    final refresh=preferences.getInt("refresh",defaultValue: 1);
    refresh.listen((value) async{
      albums=await widget.db.fetchAlbum();
      setState(() {
        isLoading = false;
      });
    });
  }

  List<Card> _buildGridCards(BuildContext context) {
    return albums.map((album) {
      return Card(
        elevation: 3.0,
        color: DynamicTheme.of(context).brightness==Brightness.dark?Colors.blueGrey:Colors.white,
        child: new InkResponse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                   AspectRatio(
                      aspectRatio: 1.0,
                      child: album.metas.image.path != null
                          ? new Image.file(
                        File.fromUri(Uri.parse(album.metas.image.path)),
                        height: 150.0,
                        fit: BoxFit.fill,
                      )
                          : new Image.asset(
                        "assets/images/album.jpg",
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10,top: 5),
                    child: Row(
                      children: [
                        Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 5,),
                                Container(
                                  width: MediaQuery.of(context).size.width*0.30,
                                  child: Text(
                                    album.metas.album,
                                    style: new TextStyle(fontSize: 17.0),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),),
                                Container(
                                  width: MediaQuery.of(context).size.width*0.30,
                                child:Text(
                                  album.metas.extra["count"],
                                  style: new TextStyle(fontSize: 15.0,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.blueGrey:Colors.white54),
                                  maxLines: 1,
                                ),
                                )
                              ],
                            ),
                        Spacer(),
                        IconButton(icon: Icon(Icons.more_vert,color: DynamicTheme.of(context).brightness==Brightness.light?Colors.blueGrey:Colors.white54,),iconSize: 24,onPressed: ()async{
                          print(int.parse(album.metas.id));
                          final songs = await widget.db.fetchSongsFromAlbum(int.parse(album.metas.id));
                          openbottomsheet(context, songs);
                        },)
                      ],
                    )
                ),
              ),
            ],
          ),
          onTap: () {
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: isLoading
            ? new Center(
          child: new CircularProgressIndicator(),
        )
            : Column(children: <Widget>[
          Expanded(
            child: new ListView.builder(
              key: new PageStorageKey('artists'),
              itemCount: albums.length,
              itemBuilder: (context, i) =>
              new Column(
                children: <Widget>[
                  new Divider(
                    height: 7.0,
                  ),
                  new ListTile(
                    leading:
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: albums[i].metas.image.path != null
                          ? new Image.file(
                        File.fromUri(Uri.parse(albums[i].metas.image.path)),
                        height: 50.0,
                        width: 50,
                        fit: BoxFit.fill,
                      )
                          : new Image.asset(
                        "assets/images/album.jpg",
                        height: 50.0,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: new Text(albums[i].metas.album,
                        maxLines: 1,
                        style: new TextStyle(fontSize: 18.0,color:Theme.of(context).accentColor)),
                    subtitle: new Text(
                        albums[i].metas.extra["count"].toString()+" song(s)",
                      maxLines: 1,
                      style: new TextStyle(fontSize: 13.0,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.blueGrey:Colors.white70) ,
                    ),
                    trailing: new  Icon(FontAwesomeIcons.chevronRight,size: 18,color: DynamicTheme
                        .of(context)
                        .brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black54),
                    onTap: () async{
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CardDetail(0,widget.db,albums[i])));
                    },
                    onLongPress: () async{
                      final songs = await widget.db.fetchSongsFromAlbum(int.parse(albums[i].metas.id));
                      openbottomsheet(context, songs);
                    },
                  ),
                ],
              ),
            ),
          )
        ]));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

