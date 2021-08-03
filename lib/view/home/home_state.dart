import 'dart:io';

import 'package:dowloandvideo/extension/context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;

class HomeState {
  final url = new BehaviorSubject<Uri>();
  final title = new BehaviorSubject<String>();
  final percent = new BehaviorSubject<int>();
  final isMp3 = new BehaviorSubject<bool>.seeded(true);
  final quality = new BehaviorSubject<bool>.seeded(false);

  late final YoutubeExplode yt;
  Uri get getUrl => url.value;
  Function(Uri) get setUrl => url.sink.add;
  Function(String) get setTitle => title.sink.add;
  Function(bool) get setIsMp3 => isMp3.sink.add;
  Function(bool) get setQuality => quality.sink.add;
  HomeState() {
    yt = YoutubeExplode();
  }


  Future<void> dowloand(BuildContext context) async {
    try {
      await Permission.storage.request();

      var rex = new RegExp("(?<=v=)(.{11})");
      if (!rex.hasMatch(url.value.toString())) {
        context.showSnackBar(Text(
          "Lütfen bir video acınız",
          style: TextStyle(color: Colors.amber),
        ));
        return;
      }

      var videoID = rex.allMatches(url.value.toString()).elementAt(0).group(0);

      var nameReg = new RegExp(r"\W");
      var name = title.value.replaceAll(nameReg, "_").replaceAll("___YouTube", "");
      percent.sink.add(10);
      context.showSnackBar(Text(
        "İndiriliyor...",
        style: TextStyle(color: Colors.purple),
      ));
      var path;
      if (isMp3.value) {
        path = await dowloandMp3(videoID!, name);
      } else {
        path = await downloadVideo(videoID!, name);
      }

      context.showSnackBar(InkWell(
        onTap: () {
          OpenFile.open(path);
        },
        child: Text(
          "$name indirildi",
          style: TextStyle(color: Colors.green),
        ),
      ));
    } catch (e) {
      percent.sink.addError('');

      context.showSnackBar(Text(
        e.toString(),
        style: TextStyle(color: Colors.red),
      ));
    }
  }

  Future<String> dowloandMp3(String videoID, String name) async {
    var id = VideoId(videoID);

    // var dir = (await DownloadsPathProvider.musicDirectory)!.path;
    var dir = (await getExternalStorageDirectories(type: StorageDirectory.music))!.first.path;

    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.last;

    var filePath = path.join(dir, '$name.${audio.container.name}');
    var file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    var fileStream = file.openWrite();
    await yt.videos.streamsClient.get(audio).pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();
    percent.sink.addError('');
    return filePath;
  }

  Future<String> downloadVideo(String id, String name) async {
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var streams = manifest.muxed;

    var dir = (await getExternalStorageDirectories(type: StorageDirectory.downloads))!.first.path;
    var audio = quality.value ? streams.last : streams.first;
    var audioStream = yt.videos.streamsClient.get(audio);

    var filePath = path.join(dir, '$name.${audio.container.name}');

    var file = File(filePath);

    if (file.existsSync()) {
      file.deleteSync();
    }

    var output = file.openWrite(mode: FileMode.writeOnlyAppend);
    await for (final data in audioStream) {
      output.add(data);
    }
    percent.sink.addError('');
    await output.flush();
    await output.close();
    return filePath;
  }

  dispose() {
    url.close();
    percent.close();
    title.close();
    isMp3.close();
    quality.close();

  }
}
