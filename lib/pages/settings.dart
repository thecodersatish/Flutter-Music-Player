import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:satish_play_music/database/database_client.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class Settings extends StatefulWidget {
  DatabaseClient db;
  Settings(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _settingState();
  }
}

class _settingState extends State<Settings> {
  var isLoading = false;
  var selected = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return new SimpleDialog(
          backgroundColor: Theme.of(context).accentColor,
          title: new Text("Refresh songs",style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
          children: [
            Center(
              child: CircularProgressIndicator(backgroundColor: Theme.of(context).scaffoldBackgroundColor,),
            ),
            Center(
              child: Text("Please Wait",style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
            )
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldState,
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      body: new Container(
        child: Column(
          children: <Widget>[
            new ListTile(
                leading:
                new Icon(Icons.style, color: Theme.of(context).accentColor),
                title: new Text(("Mode"),style: TextStyle(color: Theme.of(context).accentColor),),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return new SimpleDialog(
                          title: new Text("Select Mode"),
                          children: <Widget>[
                            new ListTile(
                              title: Text("Day"),
                              onTap: ()async {
                                final preferences = await StreamingSharedPreferences.instance;
                                final theme=preferences.getInt("theme",defaultValue: 1);
                                DynamicTheme.of(context).setBrightness(
                                    Brightness.light
                                );
                                DynamicTheme.of(context).setThemeData(ThemeData(
                                    scaffoldBackgroundColor: Colors.white,
                                    primaryColor: Colors.white,
                                    accentColor: Colors.black,
                                ),);
                                theme.setValue(0);
                                Navigator.of(context).pop();
                              },
                              trailing: DynamicTheme
                                  .of(context)
                                  .brightness ==
                                  Brightness.light
                                  ? Icon(Icons.check)
                                  : null,
                            ),
                            new ListTile(
                              title: Text("Moon"),
                              onTap: () async{
                                final preferences = await StreamingSharedPreferences.instance;
                                final theme=preferences.getInt("theme",defaultValue: 1);
                                DynamicTheme.of(context).setBrightness(
                                    Brightness.dark);
                                DynamicTheme.of(context).setThemeData(new ThemeData(
                                  primarySwatch: Colors.grey,
                                  primaryColor: Colors.black,
                                  brightness: Brightness.dark,
                                  scaffoldBackgroundColor: Colors.black,
                                  accentColor: Colors.white,
                                  accentIconTheme: IconThemeData(color: Colors.black),
                                  dividerColor: Colors.white12,
                                ),);
                                theme.setValue(1);
                                Navigator.of(context).pop();
                              },
                              trailing: DynamicTheme
                                  .of(context)
                                  .brightness ==
                                  Brightness.dark
                                  ? Icon(Icons.check)
                                  : null,
                            ),
                          ],
                        );
                      });
                }),
            new ListTile(
              leading:
              new Icon(Icons.refresh_rounded, color: Theme.of(context).accentColor),
              title: new Text(("Refresh"),style: TextStyle(color: Theme.of(context).accentColor),),
              onTap: ()async{
                _showDialog();
                print("hi");
                Map<String,int> songids={};
                Map<String,int> dbsongids={};
                final audioquery=new FlutterAudioQuery();
                final songs1 = await audioquery.getSongs();
                songs1.forEach((element) {
                  songids[element.id]=1;
                });
                final songs = await widget.db.fetchSongs();
                songs.forEach((element) {
                  if(!songids.containsKey(element.metas.id)){
                    widget.db.remove(int.parse(element.metas.id));
                  }
                  else{
                    dbsongids[element.metas.id]=1;
                  }
                });
                songs1.forEach((element) {
                  if(!dbsongids.containsKey(element.id)){
                    widget.db.insertOrUpdateSong(element);
                  }
                });
                print("hi");
                final preferences = await StreamingSharedPreferences.instance;
                preferences.setInt("refresh", new DateTime.now().millisecondsSinceEpoch);
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
