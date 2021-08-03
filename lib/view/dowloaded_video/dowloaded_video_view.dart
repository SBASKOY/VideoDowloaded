import 'dart:io';

import 'package:dowloandvideo/extension/context_extension.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'dowloaded_video_state.dart';

class DowloadedVideoView extends StatelessWidget {
  late final DowloadedVideoState state;
  DowloadedVideoView() {
    state = new DowloadedVideoState();
  }
  @override
  Widget build(BuildContext context) {
    state.getList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Videolar"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: StreamBuilder<List<FileSystemEntity>>(
            stream: state.pathList,
            builder: (c, snap) {
              if (snap.hasData) {
                if (snap.data!.length == 0) {
                  return Text("Henüz indirme yapmadınız.Hemen İndirin");
                }
                return buildList(snap.data!, state, c);
              }
              if (snap.hasError) {
                return Text(snap.error.toString());
              }

              return CupertinoActivityIndicator();
            },
          ),
        ),
      ),
    );
  }

  Widget buildList(List<FileSystemEntity> data, DowloadedVideoState state, BuildContext context) {
    return Column(
      children: List.generate(
          data.length,
          (index) => Dismissible(
                key: Key(index.toString()),
                background: slideRightBackground(),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    state.deleteList(index);
                    context.showSnackBar(Text(
                      "Dosya silindi",
                      style: TextStyle(color: Colors.green),
                    ));
                    return true;
                  }
                  return false;
                },
                child: Card(
                  child: ListTile(
                    onTap: (){
                      OpenFile.open(data[index].path);
                    },
                    title: Text(data[index].path.split("/").last),
                    trailing:Icon(Icons.play_circle_fill),
                      
                  ),
                ),
              )),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Sil",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
