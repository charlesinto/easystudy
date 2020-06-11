

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_practiceQuestion.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/util/theme.dart';

class PracticeSubjects extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _PracticeSubject();
}

class _PracticeSubject extends State<PracticeSubjects>{
  Future<List<ExamQuestion>> getTest(BuildContext context) async{
    var questions = await App.getQuestions(context);
    print(questions.length);
    return questions;
  }
  Widget _courses(BuildContext context){
    return FutureBuilder(
      builder: (BuildContext context,AsyncSnapshot<List<ExamQuestion>> snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return Container(
            margin: EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
            children: snapshot.data.map((ExamQuestion item){
               return GestureDetector(
                 onTap: () {
                   StoreProvider.of<AppState>(context).dispatch(PracticeQuestionSelected(item));
                   Navigator.of(context).pushNamed('/preparePracticeTest');
                 },
                 child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                        height: 80,
                        decoration: BoxDecoration(
                          boxShadow: AppTheme.shadow,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0)
                        ),
                        width: App.fullWidth(context) - 40,
                        child: Stack(
                          children: <Widget>[
                            Container(),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Text(item.title, 
                                  style: TextStyle(fontFamily:'Gilroy', fontSize: 18.0),)
                                ,),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                height: 15.0,
                                width: 60.0,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(4.0), bottomLeft: Radius.circular(4.0))
                                ),
                                child: Center(
                                  child: Text(item.questions.length.toString(), 
                                  style: TextStyle(fontFamily:'Gilroy', fontSize: 11.0, color: Colors.white),)
                                ),
                              )
                                ,),
                                Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 20.0,
                                width: 80.0,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(4.0), topLeft: Radius.circular(4.0))
                                ),
                                child: Center(
                                  child: Text('TAKE TEST', 
                                  style: TextStyle(fontFamily:'Take Text', fontSize: 11.0, color: Colors.white),)
                                ),
                              )
                                ,)
                          ],
                        ),
                    )
               );
            }).toList()
          )
          );
        }
        return Container();
      },
      future:  getTest(context));
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(child: Container(
        height: App.fullHeight(context),
        color: Colors.white,
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
              child: Row(
                
                children: [
                  GestureDetector(
              onTap: (){
                Navigator.pop(context);
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
              ), 
              SizedBox(width: 16.0),
                  Text('Choose Subject', style: TextStyle(fontSize: 30, color: Colors.black, fontFamily:'Gilroy'),)
                ]
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: SingleChildScrollView(
                    child: _courses(context)
                  )
              )
            )
          ],
        )
      )
        ),
      );
  }

}