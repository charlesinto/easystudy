

import 'package:flutter/material.dart';
import 'package:studyapp/util/colors.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:studyapp/util/theme.dart';

enum PlayerState { stopped, playing, paused }
typedef void OnError(Exception exception);

class AudioPlayerApp extends StatefulWidget{
  var material;
  AudioPlayerApp();
  AudioPlayerApp.fromApp(this.material);
  @override
  State<StatefulWidget> createState() => _AudioPlayerApp();
}

class _AudioPlayerApp extends State<AudioPlayerApp>{
  AudioPlayer audioPlayer = AudioPlayer();
  var position;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  PlayerState playerState = PlayerState.stopped;
  Duration duration;
  String localFilePath;
  double _value = 0.0;
  String kUrl =
    "https://www.mediacollege.com/downloads/sound-effects/nature/forest/rainforest-ambient.mp3";
  
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  bool isRepeated = false;
  bool isLoaded = false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen(_handleChangePosition
      );
      
      _audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            if(isRepeated){
              
              play();
            }else{
              onComplete();
            }
            
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          print(msg);
          setState(() {
            playerState = PlayerState.stopped;
            duration = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        });
        play();
  }
  _handleChangePosition(p){
    // p.inMilliseconds;
    // p.inMilliseconds / 1000;
    print((p.inMilliseconds / 1000).toStringAsFixed(2));
     setState(() { 
      position = p;
      _value = position != null ?  (position.inMilliseconds / 1000).toDouble() : 0.0;
    });
  }
  Future play() async {
    await audioPlayer.play(widget.material['file_url']);
    setState(() {
      playerState = PlayerState.playing;
      isLoaded = true;
    });
  }

  Future _playLocal() async {
    await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    _value = 0.0;
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future _loadFile() async {
    final bytes = await _loadFileBytes(kUrl,
        onError: (Exception exception) =>
            print('_loadFile => exception $exception'));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists())
      setState(() {
        localFilePath = file.path;
      });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }
  Positioned musicPlate(BuildContext context){
    var deviceWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 120.0,
      left: 0.0,
      child: Center(
        child: Container(
            width: deviceWidth,
            child: Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadow,
              color: AppColors.lightGrey
            ),
            child: Center(
              child: Icon(Icons.music_note, size: 60.0,),
            ) ,),
          )
      )
      
      );
  }
  _handleBackNavigation(BuildContext context){
    Navigator.pop(context);
  }
  Positioned backButton(BuildContext context){
    return Positioned(
      top: 10,
      left: 10,
      child: GestureDetector(
        onTap: () => _handleBackNavigation(context),
        child: Container(
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: AppTheme.shadow,
              color: AppColors.lightGrey,

            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
                onPressed: () => _handleBackNavigation(context))
            ),
          ),
        )
      )
    );
  }
  _hanldePlayPause(){
    if(!isPlaying){
      print('playede');
      play();
    }else{
      print('paused');
      pause();
    }
  }
  _hanldeRepeat(){
      setState(() {
        isRepeated = !isRepeated;
      });
    
  }
  _handleStop(){
    if(isPlaying || isPaused){
      stop();
    }
    
  }
  _hanldeSeekChange(value){
    audioPlayer.seek((value / 1000).roundToDouble());
    setState(() {
      _value = value;
    });
    
    
  }
  Positioned controls(){
    var deviceWidth = MediaQuery.of(context).size.width;
    var spacing = deviceWidth ~/ 4 > 60.0 ? 60.0 : deviceWidth ~/ 4;
    return Positioned(
      top: 280,
      left: 30,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: _hanldeRepeat,
            child: Container(
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadow,
                    color: AppColors.lightGrey
                  ),
                  width: 40.0,
                  height: 40.0,
                  child: Center(
                    child: Icon(Icons.repeat, color: isRepeated ? AppColors.red : Colors.black,)
                  ),
                ),
            ),
          ),
          SizedBox(width: spacing,),
          Container(
            child: GestureDetector(
              onTap: _hanldePlayPause,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadow,
                  color: AppColors.lightGrey
                ),
                width: 80.0,
                height: 80.0,
                child: Center(
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow , size: 60, color: AppColors.red,)
                ),
              ),
            ),
          ),
          SizedBox(width: spacing,),
          GestureDetector(
            onTap: _handleStop,
            child: Container(
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadow,
                    color: AppColors.lightGrey
                  ),
                  width: 50.0,
                  height: 50.0,
                  child: Center(
                    child: Icon(Icons.stop)
                  ),
                ),
            )
          )
        ],
      ));
  }
  Positioned progressBar(BuildContext context){
    var deviceWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 380,
      left: 10.0,
      child: Container(
        width: deviceWidth - 30,
        margin: EdgeInsets.only(right: 10.0),
        child: 
        Row(children: <Widget>[
         isLoaded ? Text(_value.toStringAsFixed(2), style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.bold
          ),) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.red), ),
          Expanded(
            flex: 1,
            child: Padding(
            padding: EdgeInsets.all(12.0),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.red[700],
                inactiveTrackColor: Colors.red[100],
                trackShape: RoundedRectSliderTrackShape(),
                trackHeight: 4.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                thumbColor: Colors.redAccent,
                overlayColor: Colors.red.withAlpha(32),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                tickMarkShape: RoundSliderTickMarkShape(),
                activeTickMarkColor: Colors.red[700],
                inactiveTickMarkColor: Colors.red[100],
                valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: Colors.redAccent,
                valueIndicatorTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ), 
            child: Slider(
                  divisions: 100,
                  inactiveColor: Colors.grey,
                  activeColor: AppColors.red,
                  value:position?.inMilliseconds?.toDouble() ?? 0.0,
                  onChanged: _hanldeSeekChange,
                  label: '$_value',
                  min: 0.0,
                  max: duration != null ? duration.inMilliseconds.toDouble() : 10.0))
            ,
          )),
          Text(duration != null ? (duration.inMilliseconds.toDouble() / 1000).toStringAsFixed(2) : '..:..', style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.bold
          ),)
        ],)
      )
    
    );
  }
  Positioned audioName(String name){
    var deviceWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 60,
      child: Container(
        width: deviceWidth ,
        child: Center(
          child: Text(name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),
          
        ),
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var deviceheight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(

        body: SafeArea(
          
          child: Container(
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    height: deviceheight,
                    width: deviceWidth,
                    color: AppColors.lightGrey,
                  ),
                ),
                audioName(widget.material['file_name']),
                backButton(context),
                musicPlate(context),
                controls(),
                progressBar(context)
              ],
            ) 
          ,)
        ),
      )
    );
  }

   Widget _buildPlayer() => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                onPressed: isPlaying ? null : () => play(),
                iconSize: 64.0,
                icon: Icon(Icons.play_arrow),
                color: Colors.cyan,
              ),
              IconButton(
                onPressed: isPlaying ? () => pause() : null,
                iconSize: 64.0,
                icon: Icon(Icons.pause),
                color: Colors.cyan,
              ),
              IconButton(
                onPressed: isPlaying || isPaused ? () => stop() : null,
                iconSize: 64.0,
                icon: Icon(Icons.stop),
                color: Colors.cyan,
              ),
            ]),
            duration != null ?
              Slider(
                  value: position?.inMilliseconds?.toDouble() ?? 0.0,
                  onChanged: (double value) {
                    return audioPlayer.seek((value / 1000).roundToDouble());
                  },
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble()): Container(),
            position != null ? _buildMuteButtons() : Container(),
            position != null ? _buildProgressView() : Container()
          ],
        ),
      );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            value: position != null && position.inMilliseconds > 0
                ? (position?.inMilliseconds?.toDouble() ?? 0.0) /
                    (duration?.inMilliseconds?.toDouble() ?? 0.0)
                : 0.0,
            valueColor: AlwaysStoppedAnimation(Colors.cyan),
            backgroundColor: Colors.grey.shade400,
          ),
        ),
        Text(
          position != null
              ? "${positionText ?? ''} / ${durationText ?? ''}"
              : duration != null ? durationText : '',
          style: TextStyle(fontSize: 24.0),
        )
      ]);

  Row _buildMuteButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        !isMuted ?
          FlatButton.icon(
            onPressed: () => mute(true),
            icon: Icon(
              Icons.headset_off,
              color: Colors.cyan,
            ),
            label: Text('Mute', style: TextStyle(color: Colors.cyan)),
          ):
      
          FlatButton.icon(
            onPressed: () => mute(false),
            icon: Icon(Icons.headset, color: Colors.cyan),
            label: Text('Unmute', style: TextStyle(color: Colors.cyan)),
          ),
      ],
    );
  }
}