import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:satish_play_music/pages/Walkthrough.dart';

void main()async{
  StreamingSharedPreferences preferences;
  int theme;
  WidgetsFlutterBinding.ensureInitialized();
  preferences = await StreamingSharedPreferences.instance;
  final themedata=preferences.getInt("theme",defaultValue: 1);
  theme=themedata.getValue();
  runApp(new MyApp(theme));
}

class MyApp extends StatelessWidget {
  int theme;
  MyApp(this.theme);
  @override
  Widget build(BuildContext context){
    return new DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) =>
        theme==1?new ThemeData(
          primarySwatch: Colors.grey,
          primaryColor: Colors.black,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          accentColor: Colors.white,
          accentIconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.white12,
        ):
        ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.white,
          accentColor: Colors.black87,
        ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
              title: 'Satish Play Music',
              theme: theme,
              debugShowCheckedModeBanner: false,
              home: new SplashScreen(),
            );
        });
  }
}


