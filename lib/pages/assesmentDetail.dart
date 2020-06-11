import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/model/test.dart';
import 'package:studyapp/redux/actions.dart';

class AssessmentDetailPage extends StatefulWidget{
  @override
  _AssessmentDetailPageState createState() => _AssessmentDetailPageState();
}

class _AssessmentDetailPageState extends State<AssessmentDetailPage>{
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Test _test;
  Future<String> getCurrentUser() async{
    String currentUser = (await _firebaseAuth.currentUser()).uid;
    return currentUser;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (BuildContext context, state) {
          _test = state.testSelected;
          return Scaffold(
            appBar: AppBar(
              title: Text(_test.quizName),
              backgroundColor: Colors.blueAccent,
            ),
            body: Stack(
              children: <Widget> [
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListView(
                        physics: ScrollPhysics(), // to disable GridView's scrolling
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                        children: <Widget>[
                          Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Total Number of questions')
                              ),
                              Container(
                                child: Text(_test.numberOfQuestions,style: TextStyle(fontWeight: 
                                  FontWeight.bold, fontFamily: 'Gilroy'),
                                )
                              )
                            ],)
                            )
                            ,),
                            Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Total Number of Marks Obtainable',style: TextStyle(fontWeight: 
                                  FontWeight.bold, fontFamily: 'Gilroy'),
                                )
                              ),
                              Container(
                                child: Text(_test.totalValidMarks)
                              )
                            ],)
                            )
                            ,),
                            Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Is Timed?')
                              ),
                              Container(
                                child: Text(_test.isTimed ? 'True' : 'False',style: TextStyle(fontWeight: 
                                  FontWeight.bold, fontFamily: 'Gilroy'),
                                )
                              )
                            ],)
                            )
                            ,),
                            _test.isTimed ? Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Number of Minutes to Complete')
                              ),
                              Container(
                                child: Text(_test.numberOfMinutesToComplete,
                                style: TextStyle(fontWeight: 
                                  FontWeight.bold, fontFamily: 'Gilroy'),
                                )
                              )
                            ],)
                            )
                            ,) : Container(),
                            Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Valid Until',style: TextStyle(fontWeight: 
                                  FontWeight.bold, fontFamily: 'Gilroy'),
                                )
                              ),
                              Container(
                                child: Text(_test.validUntil,
                                  style: TextStyle(fontWeight: 
                                  FontWeight.bold, fontFamily: 'Gilroy'),
                                )
                                
                              )
                            ],)
                            )
                            ,),
                            Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Submission Status')
                              ),
                              Container(
                                child: FutureBuilder(
                                  future: getCurrentUser(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot){
                                    if(snapshot.connectionState == ConnectionState.done){
                                        if(snapshot.hasData){
                                          return StreamBuilder(
                                              stream: _firestore.collection('studentResponse/${_test.schoolCode}/test')
                                                       .where('studentUserId', isEqualTo: snapshot.data)
                                                       .where('assessmentId', isEqualTo: _test.id).snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                                if(snapshot.connectionState != ConnectionState.waiting){
                                                  if(!snapshot.hasError){
                                                      
                                                     if(snapshot.data.documents.isNotEmpty){
                                                       return Text('Completed',
                                                            style: TextStyle(fontWeight: 
                                                            FontWeight.bold, color: Colors.green, fontFamily: 'Gilroy'),
                                                          );
                                                     }
                                                     return  Text('Pending',
                                                            style: TextStyle(fontWeight: 
                                                            FontWeight.bold,  fontFamily: 'Gilroy'),
                                                          );
                                                  }
                                                  return Text('Could not verify status',
                                                    style: TextStyle(fontWeight: 
                                                    FontWeight.bold, fontFamily: 'Gilroy'),
                                                  );
                                                }
                                                return Text('Verifying Status...',
                                                    style: TextStyle(fontWeight: 
                                                    FontWeight.bold, fontFamily: 'Gilroy'),
                                                  );
                                              },);
                                        }
                                        return Text('Verifying Status...',
                                              style: TextStyle(fontWeight: 
                                              FontWeight.bold, fontFamily: 'Gilroy'),
                                            );
                                    }
                                    return Container();
                                  },
                                )
                              )
                            ],)
                            )
                            ,),
                            state.loggedUser.type != 'teacher' ? Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Number of Correct Answers')
                              ),
                              Container(
                                child: FutureBuilder(
                                  future: getCurrentUser(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot){
                                    if(snapshot.connectionState == ConnectionState.done){
                                        if(snapshot.hasData){
                                          return StreamBuilder(
                                              stream: _firestore.collection('studentResponse/${_test.schoolCode}/test')
                                                       .where('studentUserId', isEqualTo: snapshot.data)
                                                       .where('assessmentId', isEqualTo: _test.id).snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                                if(snapshot.connectionState != ConnectionState.waiting){
                                                  if(!snapshot.hasError){
                                                      
                                                     if(snapshot.data.documents.isNotEmpty){
                                                       return Text(snapshot.data.documents[0].data['numberOfCorrectAnswers'] != null ?
                                                        snapshot.data.documents[0].data['numberOfCorrectAnswers'].toString() : '-',
                                                            style: TextStyle(fontWeight: 
                                                            FontWeight.bold, color: Colors.black, fontFamily: 'Gilroy'),
                                                          );
                                                     }
                                                     return  Text('Pending',
                                                            style: TextStyle(fontWeight: 
                                                            FontWeight.bold,  fontFamily: 'Gilroy'),
                                                          );
                                                  }
                                                  return Text('Could not verify status',
                                                    style: TextStyle(fontWeight: 
                                                    FontWeight.bold, fontFamily: 'Gilroy'),
                                                  );
                                                }
                                                return Text('Verifying Status...',
                                                    style: TextStyle(fontWeight: 
                                                    FontWeight.bold, fontFamily: 'Gilroy'),
                                                  );
                                              },);
                                        }
                                        return Text('Verifying Status...',
                                              style: TextStyle(fontWeight: 
                                              FontWeight.bold, fontFamily: 'Gilroy'),
                                            );
                                    }
                                    return Container();
                                  },
                                )
                              )
                            ],)
                            )
                            ,) : Container(),
                            state.loggedUser.type != 'teacher' ? Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                            
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text('Total Marks Obtained')
                              ),
                              Container(
                                child: FutureBuilder(
                                  future: getCurrentUser(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot){
                                    if(snapshot.connectionState == ConnectionState.done){
                                        if(snapshot.hasData){
                                          return StreamBuilder(
                                              stream: _firestore.collection('studentResponse/${_test.schoolCode}/test')
                                                       .where('studentUserId', isEqualTo: snapshot.data)
                                                       .where('assessmentId', isEqualTo: _test.id).snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                                if(snapshot.connectionState != ConnectionState.waiting){
                                                  if(!snapshot.hasError){
                                                      
                                                     if(snapshot.data.documents.isNotEmpty){
                                                       return Text(snapshot.data.documents[0].data['totalMarksObtained'] != null ?
                                                        snapshot.data.documents[0].data['totalMarksObtained'].toString() : '-',
                                                            style: TextStyle(fontWeight: 
                                                            FontWeight.bold, color: Colors.black, fontFamily: 'Gilroy'),
                                                          );
                                                     }
                                                     return  Text('Pending',
                                                            style: TextStyle(fontWeight: 
                                                            FontWeight.bold,  fontFamily: 'Gilroy'),
                                                          );
                                                  }
                                                  return Text('Could not verify status',
                                                    style: TextStyle(fontWeight: 
                                                    FontWeight.bold, fontFamily: 'Gilroy'),
                                                  );
                                                }
                                                return Text('Verifying Status...',
                                                    style: TextStyle(fontWeight: 
                                                    FontWeight.bold, fontFamily: 'Gilroy'),
                                                  );
                                              },);
                                        }
                                        return Text('Verifying Status...',
                                              style: TextStyle(fontWeight: 
                                              FontWeight.bold, fontFamily: 'Gilroy'),
                                            );
                                    }
                                    return Container();
                                  },
                                )
                              )
                            ],)
                            )
                            ,) : Container()
                        ]
                      )
                    ],
                  ),
                state.loggedUser.type != 'teacher' ?
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: FutureBuilder(
                                  future: getCurrentUser(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot){
                                    if(snapshot.connectionState == ConnectionState.done){
                                        if(snapshot.hasData){
                                          return StreamBuilder(
                                              stream: _firestore.collection('studentResponse/${_test.schoolCode}/test')
                                                       .where('studentUserId', isEqualTo: snapshot.data)
                                                       .where('assessmentId', isEqualTo: _test.id).snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                                if(snapshot.connectionState != ConnectionState.waiting){
                                                  if(!snapshot.hasError){
                                                      
                                                     if(snapshot.data.documents.isEmpty){
                                                       return RaisedButton(
                                                            color: Colors.green,
                                                            onPressed: (){
                                                              StoreProvider.of<AppState>(context).dispatch(OnTestSelected(_test));
                                                              Navigator.of(context).pushNamed('/quiz');
                                                            },
                                                            child: Text('START TEST',
                                                                style: TextStyle(
                                                                  color: Colors.white),
                                                              ) ,
                                                            );
                                                     }
                                                     return Container();
                                                  }
                                                }
                                                return Container();
                                              },);
                                        }
                                        return Container();
                                    }
                                    return Container();
                                  },
                                )
                    ) ,
                  )
                : Container(),
                state.loggedUser.type == 'teacher' ? 
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: RaisedButton(
                      color: Colors.green,
                      onPressed: (){
                        StoreProvider.of<AppState>(context).dispatch(OnTestSelected(_test));
                        Navigator.of(context).pushNamed('/quizResponses');
                      },
                      child: Text('VIEW RESPONSES',
                          style: TextStyle(
                            color: Colors.white),
                        ) ,
                      ),
                    ))
                 : Container()
              ]
            )
          );
        },
      );
  }
}