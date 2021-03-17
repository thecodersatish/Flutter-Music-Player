import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseClient {
  Database _db;
  SongInfo song;

  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, "database.db");
    _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
  }

  Future _create(Database db, int version) async {
    await db.execute("""
    CREATE TABLE songs(id NUMBER,title TEXT,duration NUMBER,albumArt TEXT,album TEXT,uri TEXT,filePath Text,artist TEXT,albumId NUMBER,isFav number NOT NULL default 0,timestamp number,count number not null default 0)
    """);
    await db.execute("""
    CREATE TABLE recents(id integer primary key autoincrement,title TEXT,duration NUMBER,albumArt TEXT,album TEXT,uri TEXT,artist TEXT,albumId NUMBER)
    """);
  }


  Future<int> songsCount() async {
    return Sqflite.firstIntValue(
        await _db.rawQuery("SELECT COUNT(*) FROM songs"));
  }

  Future<int> insertOrUpdateSong(SongInfo song) async {
    if (_db == null) await create();
    int count = Sqflite.firstIntValue(await _db
        .rawQuery("SELECT COUNT(*) FROM songs WHERE id = ${song.id}"));
    if (count == 0) {
      return await _db.insert("songs", song.toMap());
    }
    return await _db
        .update("songs", song.toMap(), where: "id= ?", whereArgs: [song.id]);
  }

  Future<bool> alreadyLoaded() async {
    var count =
    Sqflite.firstIntValue(await _db.rawQuery("SELECT COUNT(*) FROM songs"));
    if (count > 0) return true;
    return false;
  }

  Future<int> noOfFavorites() async {
    return Sqflite.firstIntValue(
        await _db.rawQuery("SELECT COUNT(*) FROM songs where isFav = 1"));
  }

  Future<List<Audio>> fetchSongs() async {
    List<Map> results =
    await _db.rawQuery("select distinct title,id,uri,filePath,duration,albumid,album,artist ,albumArt from songs group by title order by title");
    List<Audio> fetchedAudios = new List();
    /// create a FlutterAudioQuery instance.
    Directory directory = await getApplicationDocumentsDirectory();
    var dbPath = join(directory.path, "logo.png");
    ByteData data = await rootBundle.load("assets/images/download.png");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes);
   results.forEach((s)async{
     final audioQuery=new FlutterAudioQuery();
     Audio a=Audio.file(
         s["uri"],
         metas: Metas(
             id: s["id"].toString(),
             artist: s["artist"],
             album: s["album"],
             image: s["albumArt"]!=null?MetasImage.file(s["albumArt"]):MetasImage.file("/data/user/0/com.navya.satish_play_music/app_flutter/logo.png"),
             title: s["title"],
             extra: {"duration":new Duration(milliseconds: s["duration"]),"albumId":s["albumId"],"filePath":s["filePath"]}
         )
     );
     fetchedAudios.add(a);
   });
   return fetchedAudios;
  }

  Future<int> remove(int id)async{
    await _db.rawQuery("delete from songs where id=$id");
  }

  Future<List<Audio>> fetchSongsFromAlbum(int id) async {
    List<Map> results = await _db
        .rawQuery("select distinct title,id,uri,filePath,duration,albumid,album,artist ,albumArt from songs group by title having albumid=$id order by title");
    List<Audio> songs = results.map((s) => Audio.file(
        s["uri"],
        metas: Metas(
            id: s["id"].toString(),
            artist: s["artist"],
            album: s["album"],
            image: s["albumArt"]!=null?MetasImage.file(s["albumArt"]):MetasImage.file("/data/user/0/com.navya.satish_play_music/app_flutter/logo.png"),
            title: s["title"],
            extra: {"duration":new Duration(milliseconds: s["duration"]),"albumId":s["albumId"],"filePath":s["filePath"]}
        )
    )).toList();
    return songs;
  }

  Future<List<Audio>> fetchAlbum() async {
    List<Map> results = await _db.rawQuery(
        "select distinct albumid,album,artist ,albumArt from songs group by album order by album");
    List<Audio> albums = new List();
    albums=results.map((s)=>
        Audio.file(
        "",
        metas: Metas(
            id: s["albumId"].toString(),
            artist: s["artist"],
            album: s["album"],
            image: MetasImage.file(s["albumArt"]),
          extra: {"albumId":s["albumId"]}
        )
        )).toList();
    for(int i=0;i<albums.length;i++){
      int id=int.parse(albums[i].metas.id);
      int count= Sqflite.firstIntValue(
          await _db.rawQuery("select count(distinct title) from songs where albumid=$id"));
      albums[i].updateMetas(extra: {"count":count,"albumId":albums[i].metas.extra["albumId"]});
    }
    return albums;
  }

  Future<List<Audio>> fetchArtist() async {
    List<Map> results = await _db.rawQuery(
        "select distinct artist,album,albumArt from songs group by artist order by artist");
    List<Audio> artists = new List();
    artists=results.map((s)=>
        Audio.file(
            "",
            metas: Metas(
              id: s["albumId"].toString(),
              artist: s["artist"],
              album: s["album"],
              image: MetasImage.file(s["albumArt"]),
            )
        )).toList();
    for(int i=0;i<artists.length;i++){
      final artist=artists[i].metas.artist;
      int count= Sqflite.firstIntValue(
          await _db.rawQuery("SELECT count(distinct title) FROM songs where artist='$artist'"));
      artists[i].updateMetas(extra: {"count":count});
    }
    return artists;
  }

  Future<List<Audio>> fetchSongsByArtist(String artist) async {
    List<Map> results = await _db.rawQuery(
        "select distinct title,id,uri,filePath,duration,albumid,album,artist ,albumArt from songs group by title having artist='$artist' order by title");
    List<Audio> songs = results.map((s) => Audio.file(
        s["uri"],
        metas: Metas(
            id: s["id"].toString(),
            artist: s["artist"],
            album: s["album"],
            image: s["albumArt"]!=null?MetasImage.file(s["albumArt"]):MetasImage.file("/data/user/0/com.navya.satish_play_music/app_flutter/logo.png"),
            title: s["title"],
            extra: {"duration":new Duration(milliseconds: s["duration"]),"albumId":s["albumId"],"filePath":s["filePath"]}
        )
    )).toList();
    return songs;
  }


  Future<List<Audio>> fetchRecentSong() async {
    List<Map> results =
    await _db.rawQuery("select * from songs order by timestamp desc limit 25");
    List<Audio> songs = results.map((s) => Audio.file(
        s["uri"],
        metas: Metas(
            id: s["id"].toString(),
            artist: s["artist"],
            album: s["album"],
            image: s["albumArt"]!=null?MetasImage.file(s["albumArt"]):MetasImage.file("/data/user/0/com.navya.satish_play_music/app_flutter/logo.png"),
            title: s["title"],
            extra: {"duration":new Duration(milliseconds: s["duration"]),"albumId":s["albumId"],"filePath":s["filePath"]}
        )
    )).toList();
    return songs;
  }

  Future<List<Audio>> fetchTopSong() async {
    List<Map> results =
    await _db.rawQuery("select * from songs order by count desc limit 25");
    List<Audio> songs = results.map((s) => Audio.file(
        s["uri"],
        metas: Metas(
            id: s["id"].toString(),
            artist: s["artist"],
            album: s["album"],
            image: s["albumArt"]!=null?MetasImage.file(s["albumArt"]):MetasImage.file("/data/user/0/com.navya.satish_play_music/app_flutter/logo.png"),
            title: s["title"],
            extra: {"duration":new Duration(milliseconds: s["duration"]),"albumId":s["albumId"],"filePath":s["filePath"]}
        )
    )).toList();
    return songs;
  }


  Future<int> updateSong(int id) async {
      await _db.rawQuery("update songs set count =count +1 where id=$id");
      int timestamp=new DateTime.now().millisecondsSinceEpoch;
       await _db.rawQuery("update songs set timestamp=$timestamp where id=$id");
      print("updated");
  }
}
