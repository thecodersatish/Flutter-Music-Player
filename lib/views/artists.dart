import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:satish_play_music/service/audioPlayerTask.dart';
import 'package:satish_play_music/pages/card_detail.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class Artists extends StatefulWidget {
  DatabaseClient db;
  Artists(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _stateArtist();
  }
}

class _stateArtist extends State<Artists> with AutomaticKeepAliveClientMixin{
  List<Audio> artists;
  var f;
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    initArtists();
  }

  void initArtists() async {
    final preferences = await StreamingSharedPreferences.instance;
    final refresh=preferences.getInt("refresh",defaultValue: 1);
    refresh.listen((value) async{
      artists=await widget.db.fetchArtist();
      setState(() {
        isLoading = false;
      });
    });
  }

  List<Card> _buildGridCards(BuildContext context) {
    return artists.map((artist) {
      return Card(
        child: new InkResponse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: artist.metas.artist,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: new Image.asset(
                    "assets/images/artist.jpg",
                    height: 120.0,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 0.0),
                      child: Text(
                        artist.metas.artist.length>10?artist.metas.artist.substring(0,10)+"...":artist.metas.artist,
                        style: new TextStyle(fontSize: 18.0),
                        maxLines: 1,
                      ),
                    ),
                  Spacer(),
                  IconButton(onPressed: ()async{

                  },icon: Icon(Icons.more_vert),)
                ],
              )
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
              itemCount: artists.length,
              itemBuilder: (context, i) =>
              new Column(
                children: <Widget>[
                  new Divider(
                    height: 8.0,
                  ),
                  new ListTile(
                    leading:
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset("assets/images/artist.jpg"),
                    ),
                    title: new Text(artists[i].metas.artist,
                        maxLines: 1,
                        style: new TextStyle(fontSize: 18.0,color:  DynamicTheme
                            .of(context)
                            .brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87)),
                    subtitle: new Text(
                      artists[i].metas.extra["count"].toString()+" song(s)",
                      maxLines: 1,
                      style: new TextStyle(fontSize: 13.0,color: DynamicTheme.of(context).brightness!=Brightness.dark?Colors.blueGrey:Colors.white54) ,
                    ),
                    trailing: new Icon(Icons.chevron_right,color:  DynamicTheme
                        .of(context)
                        .brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black87),
                    onTap: () async{
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>CardDetail(1,widget.db,artists[i])));
                    },
                    onLongPress: () async{
                      final songs = await widget.db.fetchSongsByArtist(artists[i].metas.artist);
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
