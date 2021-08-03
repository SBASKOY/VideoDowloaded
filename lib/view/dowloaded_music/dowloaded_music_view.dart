import 'dart:io';
import 'package:dowloandvideo/extension/context_extension.dart';
import 'package:dowloandvideo/helper/bottom_music_controll.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dowloaded_music_state.dart';

class DowloadedMusicView extends StatefulWidget {
  @override
  _DowloadedMusicViewState createState() => _DowloadedMusicViewState();
}

class _DowloadedMusicViewState extends State<DowloadedMusicView> {
  DowloadedMusicState? state;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (state == null) {
      state = Provider.of<DowloadedMusicState>(context, listen: false);
    }

    state!.getList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Muzikler"),
      ),
      bottomNavigationBar: buildBottoMusicControllBar(state),
      body: SingleChildScrollView(
        child: Center(
          child: StreamBuilder<List<FileSystemEntity>>(
            stream: state!.pathList,
            builder: (c, snap) {
              if (snap.hasData) {
                if (snap.data!.length == 0) {
                  return Text("Henüz indirme yapmadınız.Hemen İndirin");
                }
                return buildList(snap.data!, state!, c);
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



  Widget buildList(List<FileSystemEntity> data, DowloadedMusicState state, BuildContext context) {
    return StreamBuilder<int>(
        stream: state.selectedIndex,
        initialData: -1,
        builder: (context, snapshot) {
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
                          onTap: () {
                            state.setSelectedIndex(index);
                            state.playMusic();
                          },
                          title: Text(
                            data[index].path.split("/").last,
                            style: TextStyle(color: index == snapshot.data! ? Colors.green : Colors.black),
                          ),
                          trailing: Icon(Icons.play_circle_fill),
                        ),
                      ),
                    )),
          );
        });
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
