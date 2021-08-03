import 'package:flutter/material.dart';

Widget slider(state) {
  return Container(
    child: StreamBuilder<int>(
        stream: state!.curPosition,
        initialData: 0,
        builder: (context, snapshot) {
          return Slider.adaptive(
              activeColor: Colors.blue[800],
              inactiveColor: Colors.grey[350],
              value: snapshot.data!.toDouble(),
              max: state!.getLengh.toDouble(),
              onChanged: (value) {
                state!.seekToSec(value.toInt());
              });
        }),
  );
}

Widget buildBottoMusicControllBar(state) {
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Colors.blue),
    height: 50,
    child: Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => state!.backMusic(),
        ),
        StreamBuilder<bool>(
            stream: state!.isPauseMusic,
            initialData: false,
            builder: (c, snap) {
              if (!snap.data!) {
                return IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () => state!.pauseMusic());
              }
              return IconButton(
                icon: Icon(
                  Icons.pause,
                  color: Colors.white,
                ),
                onPressed: () => state!.resumeMusic(),
              );
            }),
        IconButton(
            icon: Icon(
              Icons.stop,
              color: Colors.white,
            ),
            onPressed: () => state!.stopMusic()),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onPressed: () => state!.nextMusic(),
        ),
        Expanded(child: slider(state))
      ],
    ),
  );
}
