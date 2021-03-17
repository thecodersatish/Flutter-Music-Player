import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'dart:io';
import 'package:satish_play_music/views/miniPlayer.dart';
import 'package:satish_play_music/service/audioPlayerTask.dart';

class SearchSong extends StatefulWidget {
  DatabaseClient db;
  SearchSong(this.db);
  @override
  _SearchSongState createState() => _SearchSongState();
}

class _SearchSongState extends State<SearchSong> {
  List<Audio> results,songs;
  bool isloading=true;
  @override
  void initState() {
    super.initState();
    init();
    results = [];
  }
  init()async{
    songs=await widget.db.fetchSongs();
    setState(() {
      isloading=false;
    });
  }

  dynamic getImage(Audio s) {
    return s.metas.image.path == null
        ? null
        : new File.fromUri(Uri.parse(s.metas.image.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      body: isloading
          ? new Center(
        child: new CircularProgressIndicator(),
      )
          :SafeArea(
        child: FloatingSearchBar.builder(pinned: true,
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
              child:Image.file(File.fromUri(Uri.parse(results[index].metas.image.path)),height: 50,width: 50,)),
              title: new Text(results[index].metas.title,
                  maxLines: 1, style: new TextStyle(fontSize: 18.0,color:Theme.of(context).accentColor)),
              subtitle: new Text(
                results[index].metas.artist,
                maxLines: 1,
                style: new TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
              trailing: new Text(
                  results[index].metas.extra["duration"]
                      .toString()
                      .split('.')
                      .first,
                  style: new TextStyle(fontSize: 12.0, color: Colors.grey)),
              onTap: () {
                playAudioByIndex(results,index);
              },
            );
          },
          trailing: Icon(Icons.search),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          onChanged: (String value) {
            if (value.trim() == "") {
              setState(() {
                results = [];
              });
            } else {
              setState(() {
                results = songs
                    .where((song) =>
                song.metas.title
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                    song.metas.artist
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    song.metas.album.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            }
            print(results.length);
          },
          onTap: () {
            print("On tap callled");
          },
          decoration: InputDecoration.collapsed(
            hintText: "Search song, artist or album",
          ),
        ),
      ),
      bottomNavigationBar: MiniPlayer(widget.db),
    );
    // return new Scaffold(
    //     backgroundColor: Colors.deepPurple,
    //     body: new SafeArea(

    //       child: new MaterialSearch<String>(
    //         barBackgroundColor:Theme.of(context).accentColor,
    //         iconColor: Colors.white,
    //         placeholder: 'Search songs', //placeholder of the search bar text input
    //         results: songs
    //             .map((song) => new MaterialSearchResult<String>(
    //           value: song.title, //The value must be of type <String>
    //           text: song.title, //String that will be show in the list
    //           icon: FontAwesomeIcons.compactDisc,
    //         ))
    //             .toList(),
    //         onSelect: (dynamic selected) async {
    //           if (selected == null) {
    //             return;
    //           }

    //           results = songs.where((song) => song.title == selected).toList();

    //           Navigator.pop(context);
    //           MyQueue.songs = results;
    //           Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
    //             return new NowPlaying(db, results, 0, 0);
    //           }));
    //         },
    //         onSubmit: (String value) {

    //         },
    //       ),
    //     ));
  }
}
