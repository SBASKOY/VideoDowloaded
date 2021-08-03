import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io' as io;

class DowloadedVideoState {
  final pathList = new BehaviorSubject<List<io.FileSystemEntity>>();

  void getList() async {
    try {
      var dir = (await getExternalStorageDirectories(type: StorageDirectory.downloads))!.first.path;

      var file = io.Directory(dir).listSync();
      pathList.sink.add(file);
    } catch (e) {}
  }

  void deleteList(int index) {
    pathList.value[index].deleteSync();
    pathList.value.removeAt(index);
    
  }

  dispose() {
    pathList.close();
  }
}
