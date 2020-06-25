
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_resource_material.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class VideoSecond extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _VideoSecond();
}

class _VideoSecond extends State<VideoSecond>{
  bool videoLoaded = false;
  bool foundLocalRes = false;
  VideoPlayerController _controller;
  final String user = 'Bukola Damola ';
  _getVideoRes(ResourceMaterial material){
      if(!foundLocalRes){
        print(material.toString());
        _controller = VideoPlayerController.network(material.fileUrl);
      }
      _controller.addListener(() {
        setState(() {
        });
      });
      _controller.setLooping(true);
    _controller.initialize().then((_){
      print('initialized');
    }).catchError((onError){
      print('error in init'+ onError.toString());
    });
    _controller.play().then((value) => setState(() {
      print('loaded');
      
    })).catchError((onError){
      print('error on play'+ onError.toString());
    });
    setState(() {
      videoLoaded = true;
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
  Future<String> getLoggedInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = json.decode(prefs.getString('user'));
    return user['firstName'] + " " + user['lastName'];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if(!videoLoaded){
          _getVideoRes(state.resource);
        }
        return Scaffold(
            appBar: AppBar(
            title: Text(state.resource.fileName),
            backgroundColor: Colors.blueAccent,
          ),
                  body: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  // ClosedCaption(text: _controller.value.caption.text),
                  _PlayPauseOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            )
                );
      }, );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}