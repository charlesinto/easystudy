

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_practiceQuestion.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/util/theme.dart';

class PracticePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _PracticePage();
}

class _PracticePage extends State<PracticePage>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  getPracticeQuestions(BuildContext context) async{
    print('called');
    var questions = await App.getQuestions(context);
    print(questions.length);
    questions.forEach(( ExamQuestion question) {
      print(question.title + 'number of questions: ' + question.questions.length.toString());
    });
  }
  Widget _appPageCover(BuildContext context){
    return Positioned(
      top: 0,
      child: Container(
      width: App.fullWidth(context),
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/pic2.jpg'), fit: BoxFit.cover),
          
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).pushReplacementNamed('/app');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: AppTheme.shadow,
                  borderRadius: BorderRadius.circular(4.0)
                ),
                child: Center(
                  child: Icon(Icons.arrow_back_ios, color: Colors.black,)
                )
              ) 
              )
            ,)
        ]
      ),
    ));
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(children: <Widget>[
            SingleChildScrollView(
              child: Container(
                height: App.fullHeight(context),
                width: App.fullWidth(context),
              )
            ),
            _appPageCover(context),
            Positioned(
              top: 280,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                height: App.fullHeight(context) - 300,
                width: App.fullWidth(context),
                decoration: BoxDecoration(
                  boxShadow: AppTheme.shadow,
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), 
                  topLeft: Radius.circular(16.0))
                ),
                child: Column(
                    children: [
                      ListTile(
                        onTap: (){
                          StoreProvider.of<AppState>(context).dispatch(SelectedExamType('jamb'));
                          Navigator.of(context).pushNamed('/practicesubjects');
                        },
                        leading: CircleAvatar(
                          child: Text('J'),
                        ),
                        title: Text('JAMB'),
                      ),

                      Divider(
                        color: Colors.grey[300],
                        height: 1.0,
                      ),
                      ListTile(
                        onTap: (){},
                        leading: CircleAvatar(
                          child: Text('W'),
                        ),
                        title: Text('WAEC'),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        height: 1.0,
                      ),
                      ListTile(
                        onTap: (){},
                        leading: CircleAvatar(
                          child: Text('N'),
                        ),
                        title: Text('NECO'),
                      ),
                      // Container(
                      //   margin: EdgeInsets.symmetric(horizontal: 20.0),
                      //   height: 60,
                      //   decoration: BoxDecoration(
                      //     boxShadow: AppTheme.shadow,
                      //     color: Colors.white
                      //   ),
                      //   width: App.fullWidth(context) - 40,)
                    ]
                  ),
              )
            )
          ],)
        ),
      )
    );
  }
}