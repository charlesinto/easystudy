

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_practiceQuestion.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/model/app_testQuestion.dart';
import 'package:studyapp/model/app_testparams.dart';
import 'package:studyapp/model/app_userreport.dart';
import 'package:studyapp/model/app_userresponse.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/util/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:studyapp/util/theme.dart';

class PracticeTest extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _PracticeTestState();
}

class _PracticeTestState extends State<PracticeTest>{
  int count = 0;
  int numberOfQuestions = 0;
  ExamQuestion test;
  bool isTimeRemaining = true;
  List<PracticeTestAnswer> responses = [];
  _appPageNumber(BuildContext context, ExamQuestion test){
    return Positioned(
      top: 10,
      left: 0,
      child: Container(
        width: App.fullWidth(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text((1 + count).toString(), style: TextStyle(
            color: Colors.white, fontFamily: 'Gilroy', fontSize: 20 )),
            SizedBox(width: 4.0),
            Text('/', style: TextStyle(
            color: Colors.white, fontFamily: 'Gilroy', fontSize: 14 )),
            SizedBox(width: 4.0),
            Text(numberOfQuestions.toString(), style: TextStyle(
            color: Colors.white, fontFamily: 'Gilroy', fontSize: 20 ))
          ],
        ),
      ));
  }
  _appBackArrow(BuildContext context){
    return Positioned(
      top: 40,
      left: 0,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
        width: 70,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0)
          ),
          color: AppColors.lightGreen),
        child: Center(
          child: Icon(Icons.arrow_back, color: Colors.white,),
        ),
      ) 
      )
      );
  }
  Widget _renderImages(BuildContext context, ExamQuestion question, int count){
    print(question.questions[count].images);
    if(question.questions[count].images.length > 0){
      return SizedBox(
        height: 300,
        child: StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              itemCount: question.questions[count].images.length,
              itemBuilder: (BuildContext context, int index) {
                return Image.network(question.questions[count].images[index],
                 fit: BoxFit.contain,
                );
              },
              staggeredTileBuilder: (int index) =>
                  new StaggeredTile.count(2, index.isEven ? 2 : 1),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
      );
       
    }
    return SizedBox(
      height: 180
    );
  }
  _calculateAnswer(BuildContext context, ExamQuestion test, dynamic option, int index, StateSetter setState){
    if(!isTimeRemaining){
    
      return App.showConfirmDialog(context, 'Your time has elapsed', 'Time Elapsed, kindly click on continue to end test and view result', onConfirm);
    }
    List<PracticeTestAnswer> newResponses = responses;
    var selectedOption = option.split('.')[0];
    print('selected Option: '+ selectedOption);
    print('answer: '+ test.questions[index].answer);
    var correctOption = test.questions[index].answer.split(' ')[test.questions[index].answer.split(' ').length - 1];
    var item = newResponses.firstWhere((element) => element.questionNumber == index, orElse: () => null);
    if(item != null){
      int index = newResponses.indexOf(item);
      newResponses.removeAt(index);
    }
    newResponses.add(PracticeTestAnswer(answer: selectedOption, correctAnswer: correctOption, question: test.questions[index], questionNumber: index,));
    setState(() {
      responses = newResponses;
    });
  }
  isAnswerCorrect(int index, String answer,List<PracticeTestAnswer> response){
    var item = response.firstWhere((element) {
      return element.questionNumber == index;
    }, orElse: () => null);
    if(item != null){
      if(item.correctAnswer.toLowerCase().trim() == answer.toLowerCase().trim()){
        return true;
      }
    }
    return false;
  }
  _addBorder(int index, String option, String mode, AppState state){
    var selectedOption = option.split('.')[0];
    var item;
    if(mode == 'new'){
      item = responses.firstWhere((element) => element.questionNumber == index && element.answer.toLowerCase().trim() == selectedOption.trim().toLowerCase(), orElse: () => null);
    }else{
      item = state.report.response.firstWhere((element) => element.questionNumber == index, orElse: () => null);
    }
    
    print(mode);
    if(item != null){
      return Border.all(
        color: mode == 'new' ? AppColors.lightGreen : isAnswerCorrect(index, selectedOption,state.report.response) ? AppColors.lightGreen : AppColors.red,
        width: 1,
      );
    }
    return null;
  }

  Widget _renderOptions (BuildContext context, ExamQuestion test, count, String mode, state){
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
      return ListView(
          children: test.questions[count].options.map((option) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    if(mode == 'new')
                      return _calculateAnswer(context,test, option, count, setState);
                    return;
                  },
                  child: Container(
                    width: App.fullWidth(context) - 40,
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: AppTheme.blueshadow, 
                      borderRadius: BorderRadius.circular(4.0),
                      border: _addBorder(count, option, mode, state)
                      ),
                      
                    child: Text(option)
                  )
                ),
                SizedBox(
                  height: 10
                )
              ],
            );
          }).toList()

        );
    });
  }
  Widget _appQuestion(BuildContext context, ExamQuestion appTest, String mode, state){
    return Positioned(
      top: 80,
      left: 0,
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setState){
        return Container(
            width: App.fullWidth(context) - 40.0,
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: StoreConnector<AppState, AppState>(
              builder: (BuildContext context,AppState state){
                return  SingleChildScrollView(
                  child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text('Question', style: TextStyle(
                              fontFamily: 'Gilroy', fontSize: 18, color: Colors.white
                            ),) ,),
                            SizedBox(height: 20.0),
                            Text(appTest.questions[count].question, style: TextStyle(
                                fontFamily: 'Gilroy', fontSize: 14, color: Colors.white
                              ),),
                              _renderImages(context, appTest, count),
                              SizedBox(
                                height: 20,
                              ),
                            SizedBox(
                              height: 500,
                              child:  _renderOptions(context, appTest, count, mode, state)
                            )
                        ],
                      )
                );
              }, 
              converter: (store) => store.state),
          );
      })
    );
  }
  onConfirm(BuildContext context,AppState state){
    //caulae number of correct answers;
    int numberOfCorrect = 0;
    responses.forEach((element) {
      if(element.answer.toLowerCase().trim() == element.correctAnswer.toLowerCase().trim()){
        numberOfCorrect++;
      }
    });
    var report = new TestReport(response: responses, totalCorrect: numberOfCorrect, totalQuestion: numberOfQuestions);
    print(report.totalCorrect);
    if(state.testMode == 'new'){
      StoreProvider.of<AppState>(context).dispatch(ReportGenerated(report));
    }else{
      StoreProvider.of<AppState>(context).dispatch(ReportGenerated(state.report));
    }
    
    Navigator.of(context).pushReplacementNamed('/report');
  }
  goToNextQuestion(BuildContext context, ExamQuestion test,AppState state){
    if(!isTimeRemaining){
      return App.showConfirmDialog(context, 'Your time has elapsed', 'Time Elapsed, kindly click on continue to end test and view result', onConfirm);
    }
    if((count + 1) == numberOfQuestions){
      return App.showConfirmDialog(context, 'End Assessment', 'Are you done? proceed and view result!', onConfirm, params: state);
      
    }
    setState(() {
      count = count + 1;
    });
  }
  goToPrevQuestion(BuildContext context, ExamQuestion test){
    if(!isTimeRemaining){
      return App.showConfirmDialog(context, 'Your time has elapsed', 'Time Elapsed, kindly click on continue to end test and view result', onConfirm);
    }
    if(count == 0){
      return ;
    }
    setState(() {
      count = count - 1;
    });
  }
  Widget _appNextQuestion(BuildContext context){
    return Positioned(
      bottom: 30,
      left: App.fullWidth(context) / 4,
      child: StoreConnector<AppState, AppState>(
        builder: (BuildContext context, AppState state){
          return GestureDetector(
              onTap: () => goToPrevQuestion(context, state.test),
              child: Column(

              children: <Widget>[
                Icon(Icons.arrow_back, color: AppColors.red ,),
                SizedBox(height: 2.0),
                Text('prev', style: TextStyle(
                  fontSize: 9, color: Colors.white
                ),)
              ],
            )
            );
        }, 
        converter: (store) => store.state)
      );
  }
  Widget _appPrevsQuestion(BuildContext context){
    return Positioned(
      bottom: 30,
      right: App.fullWidth(context) / 4,
      child: StoreConnector<AppState, AppState>(
        builder: (BuildContext context, AppState state){
          return GestureDetector(
            onTap: () => goToNextQuestion(context, state.test, state),
            child: Column(
            children: <Widget>[
              Icon(Icons.arrow_forward, color: AppColors.green ,),
              SizedBox(height: 2),
              Text('next', style: TextStyle(
                fontSize: 9,
                color: Colors.white
              ),)
            ],
          )
          );
        }, 
        converter: (store) => store.state)
      );
  }
  Future<ExamQuestion> getQuestions(ExamQuestion question, TestParams params) async{
    try{  
      var questions =  question.questions.where((element) => element.year == int.parse(params.year));
      List<TestQuestion> newQuestion = [];
      questions.forEach((item){
        newQuestion.add(item);
      });
      numberOfQuestions = newQuestion.length > int.parse(params.numberOfQuestion) ?  int.parse(params.numberOfQuestion) : newQuestion.length;
      // setState(() {
      //   numberOfQuestions = validQuestionNumber;
      // });
      return ExamQuestion(title: '', type: '', questions: newQuestion);
    }catch(error){
      print(error);
      throw error;
    }
    
  }
  Widget _appWaitingStage(BuildContext context){
    return Stack(children: <Widget>[
                          Container(
                            color: AppColors.moodyBlue,
                            height: App.fullHeight(context),
                            width: App.fullWidth(context)
                          ),
                          _appBackArrow(context),
                          _appNextQuestion(context),
                          _appPrevsQuestion(context)
                      ],);
  }
  
  Widget _appLoaded(BuildContext context,AppState state, AsyncSnapshot<ExamQuestion> snapshot, {String timer: '00:00'}){
    return Stack(children: <Widget>[
                          Container(
                            color: AppColors.moodyBlue,
                            height: App.fullHeight(context),
                            width: App.fullWidth(context)
                          ),
                          _appPageNumber(context, snapshot.data),
                          _appBackArrow(context),
                          _appTimer(context, state.testParams.time),
                          _appQuestion(context, snapshot.data, state.testMode, state),
                          _appNextQuestion(context),
                          
                          _appPrevsQuestion(context),
                          !isTimeRemaining ? App.showConfirmDialog(context, 'Your time has elapsed', 'Time Elapsed, kindly click on continue to end test and view result', onConfirm): Container()
                      ],);
  }
  Widget _appBuilder(BuildContext context, AppState state, {String timer = '00:00'}){
    return FutureBuilder(
                  future: getQuestions(state.test,state.testParams),
                  builder: (BuildContext context,AsyncSnapshot<ExamQuestion> snapshot){
                    if(snapshot.connectionState == ConnectionState.done){
                      // test = new ExamQuestion(title: state.test.title, type: state.test.type, questions: snapshot.data);
                      
                      return _appLoaded(context, state, snapshot, timer: timer);
                    }
                    return _appWaitingStage(context);
                  });
  }
  Stream<String> startTimer(Duration period, int timeAllocated) async*{
    //minutes = timeAllocated e.g 15

    var counter = 0;
    var totalSeconds = timeAllocated * 60;
    // var usedUpSceonds = 0;
    while(true){
      if(totalSeconds - counter > 0){
        await Future.delayed(period);
        counter++;
        var currentTime = totalSeconds - counter;
        var remainingMinutes = (currentTime / 60).toStringAsFixed(2);
        yield '$remainingMinutes';
        //yield i++;
      }else{
        yield '00:00';
        break;
      }
      
      
    }
  }
  Widget _appTimer(BuildContext context, int time){
    return Positioned(
      top: 40,
      right: 10,
      child: time != -1 ? StreamBuilder(
            stream: startTimer(Duration(milliseconds: 1200),time ),
            builder: (BuildContext context,AsyncSnapshot<String> snapshot){
              if(snapshot.connectionState != ConnectionState.waiting){
                if(snapshot.data == '00:00'){
                  
                  isTimeRemaining = false;
                }
                return Container(
                  child: Text(snapshot.data, style: TextStyle(color: Colors.red, fontSize: 14))
                );
              }
              return Container(
                child: Text("00:00", style: TextStyle(color: Colors.red, fontSize: 14))
              );
            }) : Container(
                child: Text("00:00", style: TextStyle(color: Colors.red, fontSize: 14))
              )
      );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
          child: Container(
            child:  StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (BuildContext context, AppState state ){
                print(state.testParams.time);
                if(state.testParams.time == -1){
                  return _appBuilder(context, state);
                }
                // var totalNumberOfSeconds = state.testParams.time * 60;
                return _appBuilder(context, state);
              } ,)
        )
    ));
  }
}