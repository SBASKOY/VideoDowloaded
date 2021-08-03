import 'package:dowloandvideo/view/dowloaded_music/dowloaded_music_state.dart';
import 'package:dowloandvideo/view/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (c)=>DowloadedMusicState(),
          child: MaterialApp(
        title: 'Video Dowloand',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeView(),
      ),
    );
  }
}

