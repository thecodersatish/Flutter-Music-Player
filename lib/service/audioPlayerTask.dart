import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'dart:convert';

openbottomsheet(var context,List<Audio> songs){
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      builder: (context)
  {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState
            /*You can rename this!*/) {
          return Container(
            height: 350,
            child: Container(
              child:  _buildBottomNavigationMenu(context,songs),
              decoration: BoxDecoration(
                color: DynamicTheme.of(context).brightness==Brightness.dark?Colors.grey[900]:Colors.white70,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(30),
                  topRight: const Radius.circular(30),
                ),
              ),
            ),
          );
        });
  });
}

Column _buildBottomNavigationMenu(var context, List<Audio> songs){
  return Column(
    children: <Widget>[
      Column(
        children: [
          Container(width: MediaQuery.of(context).size.width*0.10,child: Divider(color:Theme.of(context).accentColor,thickness: 3.0,),),
          SizedBox(height: 5,),
          Text("Play Settings",style: TextStyle(fontSize: 20,color:Theme.of(context).accentColor),),
        ],
      ),
      Spacer(),
      ListTile(
        leading: Text('Play Now',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: (){
          playAudioByIndex(songs,0);
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Text('Shuffle All',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: (){
          songs.shuffle();
          playAudioByIndex(songs,0);
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Text('Play Next',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: ()async{
          AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
          if(_assetsAudioPlayer.isPlaying.valueWrapper.value){
            for(int i=0;i<songs.length;i++){
              _assetsAudioPlayer.playlist.insert(_assetsAudioPlayer.current.valueWrapper.value.index+i+1, songs[i]);
            }
            updateplayinglist();
          }
          else{
            playAudioByIndex(songs, 0);
          }
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Text('Add to Queue',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: () async{
          AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
          if(_assetsAudioPlayer.isPlaying.valueWrapper.value){
            for(int i=0;i<songs.length;i++){
              _assetsAudioPlayer.playlist.insert(_assetsAudioPlayer.playlist.numberOfItems, songs[i]);
            }
            updateplayinglist();
          }
          else{
            playAudioByIndex(songs, 0);
          }
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Text('Close',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: (){Navigator.pop(context);},
      ),
      SizedBox(height: 10,),
    ],
  );
}
void playAudioByIndex(List<Audio> songs,int i)async{
  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
  _assetsAudioPlayer.stop();
  await _assetsAudioPlayer.open(
    Playlist(audios: songs,startIndex: i),
    autoStart: false,
    showNotification: true,
    playInBackground: PlayInBackground.enabled,
    audioFocusStrategy: AudioFocusStrategy.request(
        resumeAfterInterruption: true, resumeOthersPlayersAfterDone: true),
    headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
  notificationSettings:NotificationSettings(
    stopEnabled: false
    ),
  );
  _assetsAudioPlayer.play();
  updateplayinglist();
}

void updateplayinglist()async{
  final preferences = await StreamingSharedPreferences.instance;
  final playlist=preferences.getStringList("playingList",defaultValue: []);
  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
  List<String>a=[];
  _assetsAudioPlayer.playlist.audios.forEach((element) {
    Map<String,dynamic>temp={};
    temp["filePath"]=element.metas.extra["filePath"];
    temp["id"]=element.metas.id;
    temp["album"]=element.metas.album;
    temp["artist"]=element.metas.artist;
    temp["title"]=element.metas.title;
    temp["uri"]=element.path;
    temp["albumArt"]=element.metas.image.path;
    temp["duration"]=element.metas.extra["duration"].inMilliseconds;
    temp["albumId"]=element.metas.extra["albumId"];
    a.add(json.encode(temp));
  });
  playlist.setValue(a);
}


void UpdateRecents()async{
  final preferences = await StreamingSharedPreferences.instance;
  preferences.setStringList("recents", []);
}

void UpdateTopTracks()async{
  final preferences = await StreamingSharedPreferences.instance;
  preferences.setStringList("toptracks", []);
}

void UpdateFavourites(String s)async{
  final preferences = await StreamingSharedPreferences.instance;
  final favourites=preferences.getStringList("favourites",defaultValue: []);
  final value=favourites.getValue();
  if(value.contains(s)){
    value.remove(s);
    favourites.setValue(value);
  }
  else{
    value.add(s);
    favourites.setValue(value);
  }
}



opensongoptions(var context,Audio song){
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      builder: (context)
      {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState
                /*You can rename this!*/) {
              return Container(
                height: 400,
                child: Container(
                  child:  _buildsongBottomNavigationMenu(context,song),
                  decoration: BoxDecoration(
                    color: DynamicTheme.of(context).brightness==Brightness.dark?Colors.grey[900]:Colors.white70,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(30),
                    ),
                  ),
                ),
              );
            });
      });
}

Column _buildsongBottomNavigationMenu(var context, Audio song) {
  return Column(
    children: <Widget>[
      Column(
        children: [
          SizedBox(height: 2,),
          Container(width: MediaQuery.of(context).size.width*0.10,child: Divider(color:Theme.of(context).accentColor,thickness: 3.0,),),
          SizedBox(height: 5,),
          Text("Song Settings",style: TextStyle(fontSize: 20,color:Theme.of(context).accentColor),),
        ],
      ),
      Spacer(),
      ListTile(
        focusColor: Theme.of(context).accentColor,
        leading: Text('Play Next',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: ()async{
          AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
          if(_assetsAudioPlayer.isPlaying.valueWrapper.value){
              _assetsAudioPlayer.playlist.insert(_assetsAudioPlayer.current.valueWrapper.value.index+1, song);
            updateplayinglist();
          }
          else{
            playAudioByIndex([song], 0);
          }
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Text('Add to Queue',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: () async{
          AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("music");
          if(_assetsAudioPlayer.isPlaying.valueWrapper.value){
              _assetsAudioPlayer.playlist.insert(_assetsAudioPlayer.playlist.numberOfItems, song);
            updateplayinglist();
          }
          else{
            playAudioByIndex([song], 0);
          }
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Text('Set as Ringtone',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: ()async{
          const platform = const MethodChannel('ringtone');
          Navigator.pop(context);
          try {
            final String temp = await platform.invokeMethod(
                'setringtone', {
              "arg": song.path
            });
            print(temp);
          }on PlatformException catch (e) {
            print(e);
          }
        },
      ),
      ListTile(
        leading: Text('Share',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: ()async{
          await FlutterShare.shareFile(
            title: "Share Music File",
            text: song.metas.title,
            filePath: song.metas.extra["filePath"],
          );
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Text('Delete',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: (){Navigator.pop(context);},
      ),
      ListTile(
        leading: Text('Close',style: new TextStyle(fontSize: 17.0,color:Theme.of(context).accentColor)),
        onTap: (){Navigator.pop(context);},
      ),
      SizedBox(height: 10,),
    ],
  );
}
