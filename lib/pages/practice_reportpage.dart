

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/util/colors.dart';

class PracticeReport extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _PracticeReport();
}

class _PracticeReport extends State<PracticeReport>{
  AssetImage _renderBg(BuildContext context, AppState state){
    var score = state.report.totalCorrect / state.report.totalQuestion * 100;
    print('score is: '+ score.toString());
    if(score >= 60){
      return AssetImage('assets/pic4.jpg',);
    }
    return AssetImage('assets/pic5.jpg',);
  }
  Widget _renderScore(BuildContext context, AppState state){
    var score = (state.report.totalCorrect / state.report.totalQuestion * 100).toStringAsFixed(0);
    return Positioned(
      bottom: App.fullHeight(context) * 0.25,
      left: 0,
      child: Container(
        width: App.fullWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            
              Text('$score %', style: TextStyle(
              fontFamily: 'Gilroy', fontSize: 80, color: AppColors.lightGreen, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Score', style: TextStyle(
              fontFamily: 'Gilroy', fontSize: 40,)),
              SizedBox(width: 6),
          ],
        )
      ));
  }
  Widget _renderBtn(BuildContext context){
    // var score = state.report.totalCorrect ~/ state.report.totalQuestion * 100;
    return Positioned(
      bottom: App.fullHeight(context) * 0.11,
      left: 0,
      child: Container(
        width: App.fullWidth(context),
        child: Column(

          children: <Widget>[
            Container(
              width: 200,
              child: RaisedButton(
                  color: Colors.white,
                  onPressed: (){
                    StoreProvider.of<AppState>(context).dispatch(SetTestMode('view'));
                    Navigator.of(context).pushNamed('/practiceTest');
                  },
                  child: Text('View Result', style: TextStyle(color: AppColors.lightGreen),),
                )
            ),
            SizedBox(height: 10.0),
            Container(
              width: 200,
              child: RaisedButton(
                  color: AppColors.lightGreen,
                  onPressed: (){
                      StoreProvider.of<AppState>(context).dispatch(SetTestMode('new'));
                      Navigator.of(context).pushReplacementNamed('/practicepage');
                  },
                  child: Text('Contiue', style: TextStyle(color: Colors.white),),
                )
            )
          ],
        )
      ));
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    
    return Scaffold(
      body: 
      SafeArea(
        child: Container(
          child: StoreConnector<AppState, AppState>(
            builder: (BuildContext context,AppState state){
              return Stack(
                children: <Widget>[
                  Container(
                    height: App.fullHeight(context),
                    width: App.fullWidth(context),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _renderBg(context, state),
                        fit: BoxFit.cover
                        )
                    ),
                  ),
                  _renderScore(context,state),
                  _renderBtn(context)
                ],
              );
            }, 
            converter: (store) => store.state)
        ),
      )
    );
  }
}