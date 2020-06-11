import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/pages/home.dart';
import 'package:video_player/video_player.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class VideoPlayerWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VideoPlayerWidgetState();
  }
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>{
  bool videoLoaded = false;
  bool foundLocalRes = false;
  VideoPlayerController _controller;
  final String user = 'Bukola Damola ';
  _getVideoRes(Map<String, dynamic> material){
      if(!foundLocalRes){
        print(material.toString());
        _controller = VideoPlayerController.network(material['file_url']);
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
          _getVideoRes(state.selectedMaterial);
        }
        return Scaffold(
            appBar: AppBar(
            title: Text(state.selectedMaterial['file_name']),
            backgroundColor: Colors.blueAccent,
          ),
          endDrawer: FutureBuilder(
        future: getLoggedInUser() ,
        builder: (context, AsyncSnapshot snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                 if(snapshot.hasData){
                      return  Drawer(
                            child: SafeArea(
                              child: Column(
                                crossAxisAlignment:  CrossAxisAlignment.start,
                                children: <Widget>[
                                Container(

                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                  ),
                                  child: Center(
                                    child: Text(snapshot.data,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(

                                        color: Colors.white, fontFamily: 'Gilroy',
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800
                                        ),
                                    ) ,)
                                ,),
                                SizedBox(height: 20,),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Home'),
                                              leading: Icon(Icons.home),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                ),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Learning'),
                                              leading: Icon(LineIcons.book),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                ),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Classroom'),
                                              leading: Icon(LineIcons.users),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                ),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Profile'),
                                              leading: Icon(LineIcons.user),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                )
                            ],)
                            ,) 
                            
                          );
                 }
                 return  Drawer(
            child: SafeArea(
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: <Widget>[
                Container(

                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                  ),
                  child: Center(
                    child: Text('',
                      textAlign: TextAlign.center,
                      style: TextStyle(

                        color: Colors.white, fontFamily: 'Gilroy',
                          fontSize: 26,
                          fontWeight: FontWeight.w800
                        ),
                    ) ,)
                ,),
                SizedBox(height: 20,),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Home'),
                              leading: Icon(Icons.home),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Learning'),
                              leading: Icon(LineIcons.book),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Classroom'),
                              leading: Icon(LineIcons.users),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Profile'),
                              leading: Icon(LineIcons.user),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                )
            ],)
            ,) 
            
          );
              }
              return  Drawer(
            child: SafeArea(
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: <Widget>[
                Container(

                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                  ),
                  child: Center(
                    child: Text('',
                      textAlign: TextAlign.center,
                      style: TextStyle(

                        color: Colors.white, fontFamily: 'Gilroy',
                          fontSize: 26,
                          fontWeight: FontWeight.w800
                        ),
                    ) ,)
                ,),
                SizedBox(height: 20,),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Home'),
                              leading: Icon(Icons.home),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Learning'),
                              leading: Icon(LineIcons.book),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Classroom'),
                              leading: Icon(LineIcons.users),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Profile'),
                              leading: Icon(LineIcons.user),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                )
            ],)
            ,) 
            
          );
          } 
        ,),
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