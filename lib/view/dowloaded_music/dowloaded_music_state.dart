import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io' as io;

class DowloadedMusicState {
  final pathList = new BehaviorSubject<List<io.FileSystemEntity>>();

  final isPlayMusic = new BehaviorSubject<bool>.seeded(false);
  final isPauseMusic = new BehaviorSubject<bool>.seeded(false);
  final selectedIndex = new BehaviorSubject<int>.seeded(-1);
  final musicLength = new BehaviorSubject<int>.seeded(1000);
  final curPosition = new BehaviorSubject<int>.seeded(0);

  int get getLengh => musicLength.value;
  bool get getIsPlayMusic => isPlayMusic.value;
  late AudioPlayer _player;
  late final AudioCache cache;
  DowloadedMusicState() {
    _player = new AudioPlayer();
    _player.notificationService.startHeadlessService();
    _player.onDurationChanged.listen((d) => musicLength.sink.add(d.inSeconds.toInt()));

    _player.onAudioPositionChanged.listen((p) => curPosition.sink.add(p.inSeconds.toInt()));
    _player.onPlayerCompletion.listen((event) {
      nextMusic();
    });
    cache = new AudioCache(fixedPlayer: _player);
  }
  void getList() async {
    try {
      var dir = (await getExternalStorageDirectories(type: StorageDirectory.music))!.first.path;

      var file = io.Directory(dir).listSync();
      pathList.sink.add(file);
    } catch (e) {}
  }

  void setSelectedIndex(int index) {
    selectedIndex.sink.add(index);
  }

  void pauseMusic() async {
    if (!isPauseMusic.value) {
      isPauseMusic.sink.add(true);
      //await SoundService.pauseMusic();
      await _player.pause();
    }
  }

  void resumeMusic() async {
    if (isPlayMusic.value) {
      isPauseMusic.sink.add(false);
      //await SoundService.resumeMusic();
      await _player.resume();
    }
  }

  void stopMusic() async {
    if (isPlayMusic.value) {
      isPlayMusic.sink.add(false);
      selectedIndex.sink.add(-1);
      //await SoundService.stopMusic();
      await _player.stop();
    }
  }

  Future<void> playMusic() async {
    if (pathList.value.length > 0) {
      if (isPlayMusic.value) {
        _player.stop();
        isPlayMusic.sink.add(false);
      }
      if (!isPlayMusic.value) {
        isPlayMusic.sink.add(true);
        isPauseMusic.sink.add(false);
        //bool? val = await SoundService.startMusic(pathList.value[selectedIndex.value].path);
        //SoundService.getDuration();
        //print(val ?? false);
        await _player.play(pathList.value[selectedIndex.value].path, isLocal: true);
      }
    }
  }

  void backMusic() {
    if (pathList.value.length > 0) {
      var currentIndex = selectedIndex.value;
      int nextIndex = currentIndex - 1;
      if (nextIndex < 0) {
        nextIndex = pathList.value.length - 1;
      }
      selectedIndex.sink.add(nextIndex);
      this.playMusic();
    }
  }

  void nextMusic() {
    if (pathList.value.length > 0) {
      var currentIndex = selectedIndex.value;
      int nextIndex = currentIndex + 1;
      if (nextIndex > pathList.value.length - 1) {
        nextIndex = 0;
      }

      selectedIndex.sink.add(nextIndex);
      this.playMusic();
    }
  }

  void deleteList(int index) {
    pathList.value[index].deleteSync();
    pathList.value.removeAt(index);
  }

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _player.seek(newPos);
  }

  dispose() {
    pathList.close();
    musicLength.close();
    curPosition.close();
    isPlayMusic.close();
    selectedIndex.close();
    isPauseMusic.close();
  }
}
