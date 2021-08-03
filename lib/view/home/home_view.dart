import 'package:dowloandvideo/extension/context_extension.dart';

import 'package:dowloandvideo/view/dowloaded_music/dowloaded_music_view.dart';
import 'package:dowloandvideo/view/dowloaded_video/dowloaded_video_view.dart';
import 'package:dowloandvideo/view/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeState state;
  late InAppWebViewController _controller;
  late final UserScript script;
  late String adsJs;
  _HomeViewState() {
    state = new HomeState();
    adsJs = """
 
    const clear = (() => {
    const defined = v => v !== null && v !== undefined;
    const timeout = setInterval(() => {
        const ad = [...document.querySelectorAll('.ad-showing')][0];
        if (defined(ad)) {
            const video = document.querySelector('video');
            if (defined(video)) {
                video.currentTime = video.duration;
            }
        }
    }, 500);
    return function() {
        clearTimeout(timeout);
    }
})();

clear();
        Array.from(document.getElementsByTagName('img')).forEach(function (e) {
        if (!e.src.includes(window.location.host)) {
         e.remove();
        }
        });
        Array.from(document.getElementsByTagName('div')).forEach(function (e) {
        var currentZIndex = parseInt(document.defaultView.getComputedStyle(e, null).zIndex);
        if (currentZIndex > 999) {
        console.log(parseInt(currentZIndex));
        e.remove()
        }
        });
   
    """;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(""),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                stream: state.percent,
                builder: (c, snap) {
                  if (snap.hasData) {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.green,
                    );
                  }
                  return Container();
                },
              ),
            ),
            Row(
              children: [
                Text("D. Kalite"),
                StreamBuilder<bool>(
                  stream: state.quality,
                  builder: (c, snap) {
                    return Switch(activeColor: Colors.green, value: snap.data ?? false, onChanged: state.setQuality);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("mp4"),
                  StreamBuilder<bool>(
                    stream: state.isMp3,
                    builder: (c, snap) {
                      return Switch(activeColor: Colors.green, value: snap.data ?? false, onChanged: state.setIsMp3);
                    },
                  ),
                  Text("mp3")
                ],
              ),
            ),
            // IconButton(icon: Icon(Icons.download_sharp), onPressed: () => context.pushReplement(new DowloadedView())),
          ],
        ),
        body: Center(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse("www.youtube.com")),
            onTitleChanged: (controller, x) async {
              _controller = controller;
              //await controller.evaluateJavascript(source: adsJs);
              print("-- saada second js file ------");
              await controller.evaluateJavascript(source: adsJs);

              var res = await controller.evaluateJavascript(source: "window.location.href");
              var title = await controller.evaluateJavascript(source: "document.title");
              state.setUrl(Uri.parse(res));
              state.setTitle(title);
            },
            onLoadStop: (controller, url) async {
              _controller = controller;
              print("-- saada titlr changed js file ------");
              await controller.evaluateJavascript(source: adsJs);

              var res = await controller.evaluateJavascript(source: "window.location.href");
              var title = await controller.evaluateJavascript(source: "document.title");
              state.setUrl(Uri.parse(res));
              state.setTitle(title);
            },
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.blue),
          height: 50,
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Wrap(
                    spacing: 20,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.video_collection,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pushReplement(new DowloadedVideoView())),
                      IconButton(
                          icon: Icon(
                            Icons.music_video,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pushReplement(new DowloadedMusicView()))
                    ],
                  )),
              Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (await _controller.canGoBack()) _controller.goBack();
                    }),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (await _controller.canGoForward()) {
                        _controller.goForward();
                      }
                    }),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.download_sharp),
          onPressed: () {
            state.dowloand(context);
          },
        ),
      ),
    );
  }
}
