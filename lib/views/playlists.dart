import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:satish_play_music/pages/list_songs.dart';

class PlayList extends StatefulWidget {
  DatabaseClient db;
  PlayList(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _statePlaylist();
  }
}

class _statePlaylist extends State<PlayList> with AutomaticKeepAliveClientMixin {
  var mode;
  var selected;
  Orientation orientation;
  List<Audio> songs;
  @override
  void initState() {
    mode = 1;
    selected = 1;
    super.initState();
    init();
  }

  init()async{
    songs=await widget.db.fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    return new Container(
      child: /*orientation == Orientation.portrait ? */potrait() /*: landscape()*/,
    );
  }

  Widget potrait() {
    return new ListView(
      key: new PageStorageKey('playlist'),
      children: <Widget>[
        new ListTile(
          leading: new Icon(Icons.refresh_rounded,
              color: Theme.of(context).accentColor),
          title: new Text("Recently played",style: TextStyle(color:Theme.of(context).accentColor),),
          subtitle: new Text("songs",style: TextStyle(color:Theme.of(context).accentColor),),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ListSongs(widget.db,1,[])));
          },
        ),
        new Divider(),
        new ListTile(
          leading:
              new Icon(Icons.show_chart, color: Theme.of(context).accentColor),
          title: new Text("Top tracks",style: TextStyle(color:Theme.of(context).accentColor),),
          subtitle: new Text("songs",style: TextStyle(color:Theme.of(context).accentColor),),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ListSongs(widget.db,2,[])));
          },
        ),
        new Divider(),
        new ListTile(
          leading:
              new Icon(Icons.favorite, color: Theme.of(context).accentColor),
          title: new Text("Favourites",style: TextStyle(color:Theme.of(context).accentColor),),
          subtitle: new Text("Songs",style: TextStyle(color:Theme.of(context).accentColor),),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ListSongs(widget.db,3,songs)));
          },
        ),
        new Divider(),
      ],
    );
  }

  Widget landscape() {
    return new Row(
      children: <Widget>[
        new Container(
          width: MediaQuery
              .of(context)
              .size
              .width / 2.5,
          child: new ListView(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.refresh),
                title: new Text("Recently played",
                    style: new TextStyle(
                        color: selected == 1 ? Colors.deepPurpleAccent : Colors
                            .black)),
                subtitle: new Text("songs"),
                onTap: () {
                  setState(() {
                    mode = 1;
                    selected = 1;
                  });
                },
              ),
              new Divider(),
              ListTile(
                  leading: new Icon(Icons.show_chart),
                  title: new Text("Top tracks",
                      style: new TextStyle(
                          color: selected == 2 ? Colors.deepPurpleAccent : Colors
                              .black)),
                  subtitle: new Text("songs"),
                  onTap: (){

                  }
              ),
              new Divider(),
              ListTile(
                        leading: new Icon(Icons.favorite),
                        title: new Text("Favourites",
                            style: new TextStyle(
                                color: selected == 3
                                    ? Colors.deepPurpleAccent
                                    : Colors.black)),
                        subtitle: new Text("Songs"),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ListSongs(widget.db,3,songs)));
                          // setState(() {
                          //   mode = 3;
                          //   selected = 3;
                          // });
                        },
                      ),
              new Divider(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
