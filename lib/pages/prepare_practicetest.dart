
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_practiceQuestion.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/model/app_testparams.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/util/theme.dart';

class PrepareTest extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _PrepareTest();
}

class _PrepareTest extends State<PrepareTest>{
  List<String> examyears = ['2000', '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010',
   '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019'];
   String selectedYear = '2019';
   List<String> numberOfQuestions = ['1','5','10', '20', '30', '50', '70', '100'];
   List<String> time=['1 min','5 mins', '15 mins', '30 mins', '60 mins', '120 mins', 'Don\'t Time'];
   String selectedNumberOfQuestion = '1';
   String _selectedTime = 'Don\'t Time';
  Widget _appPageCover(BuildContext context){
    return Positioned(
      top: 0,
      child: Container(
      width: App.fullWidth(context),
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/pic3.jpg'), fit: BoxFit.cover),
          
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 10,
            child: GestureDetector(
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
              )
            ,)
        ]
      ),
    ));
  }
  Future<List<String>> getQuestionYears(ExamQuestion question) async{
    List<String> years = [];
    question.questions.forEach((question) { 
      var index = years.firstWhere((element) => int.parse(element)  == question.year, orElse: () => '-1');
      if(index == '-1'){
        years.add(question.year.toString());
      }
    });
    years.sort();
    selectedYear = years[years.length - 1];
    return years;
  }
  Widget _examYearWidget(BuildContext context, ExamQuestion question){
    return FutureBuilder(
      future: getQuestionYears(question),
      builder: (BuildContext context,AsyncSnapshot<List<String>> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            // return Container();
            return StatefulBuilder(
            
              builder: (BuildContext context, StateSetter setState){
                return DropdownButton<String>(
                  value: selectedYear,
                  isDense: true,
                  onChanged: (String  value) {
                    setState(() {
                      selectedYear = value;
                    });
                  },
                  items: snapshot.data.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                );
              });
          }
          return CircularProgressIndicator();
      });
  }
  Widget _timeWidget(BuildContext context, ExamQuestion question){
    return StatefulBuilder(builder: (BuildContext contex, StateSetter setState){
      return DropdownButton<String>(
                  value: _selectedTime,
                  isDense: true,
                  onChanged: (String  value) {
                    setState(() {
                      _selectedTime = value;
                    });
                  },
                  items: time.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                );
    });
  }
  Widget _testDetails(BuildContext context, AppState state){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Exam Type'),
                Text(state.test.type.toUpperCase()),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Subject'),
                Text(state.test.title.toUpperCase()),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Number Of Questions'),
                DropdownButton(
                  value: selectedNumberOfQuestion,
                  isDense: true,
                  onChanged: (String  value) {
                    setState(() {
                      selectedNumberOfQuestion = value;
                    });
                  },
                  items: numberOfQuestions.map((String value) {
                    return new DropdownMenuItem(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Exam Year'),
                 _examYearWidget(context, state.test)
              
              ],
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 8.0),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: <Widget>[
            //     Text('Time'),
            //      _timeWidget(context, state.test)
              
            //   ],
            // ),
            // SizedBox(height: 8.0),
            // Divider(color: Colors.grey[300]),
          ],),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: App.fullWidth(context) - 40,
              child: Center(
                child: RaisedButton(
                color: Colors.green,
                onPressed: (){
                  StoreProvider.of<AppState>(context).dispatch(SetTestMode('new'));
                  int time = -1;
                  if(_selectedTime == 'Don\'t Time'){
                    StoreProvider.of<AppState>(context).dispatch(StartTest(TestParams(numberOfQuestion: selectedNumberOfQuestion ,year: selectedYear, time: time)));
                  }else{
                    var selectedtime = _selectedTime.split(" ")[0];
                    time = int.parse(selectedtime);
                    StoreProvider.of<AppState>(context).dispatch(StartTest(TestParams(numberOfQuestion: selectedNumberOfQuestion ,year: selectedYear, time: time)));
                  }
                  
                  Navigator.of(context).pushNamed('/practiceTest');
                },
                child: Text('Start Test', style: TextStyle(color: Colors.white),),
              ),)
            )
          )
          
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                height: App.fullHeight(context),
                width: App.fullWidth(context),
              )
            ),
            _appPageCover(context),
            Positioned(
              top: 290,
              child: Container(
                width: App.fullWidth(context),
                height: App.fullHeight(context) - 290,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: AppTheme.shadow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)
                  )
                ),
                child: StoreConnector<AppState, AppState>(
                  builder: (BuildContext context, AppState state){
                    return _testDetails(context, state);
                  },
                   converter: (store) => store.state)
              ))
          ],
        ),
      )
    );
  }
}