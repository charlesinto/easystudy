import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/model/app_state.dart';


class QuizResponse extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _QuizResponse();
}


class _QuizResponse extends State<QuizResponse>{
  Firestore _firestore = Firestore.instance;
  String schoolCode = "";
  Future<Map<String, dynamic>> getUser() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    var userString =_prefs.getString('user');
    var user = json.decode(userString);
    return user;
  }
  Future<Map<String, dynamic>> getStudent(DocumentSnapshot doc) async{
    var document = await _firestore.collection("/users/$schoolCode/activated users/").where('uid', isEqualTo: doc.data['studentUserId']).getDocuments();
    print(document.documents[0].data);
    return document.documents[0].data;

  }
  List<Widget> renderStudentScore(QuerySnapshot docs){
    return docs.documents.map((doc){
      return FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              if(snapshot.hasData){
                return Card(
                  elevation: 4.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(snapshot.data['firstName'] + " " + snapshot.data['lastName'])
                            ),
                          ],),
                          Row(
                            children: [
                              Container(
                                child: Text('Score', style: TextStyle(fontWeight: FontWeight.w700),),
                              ),
                              SizedBox(width: 8.0),
                              Row(
                              children: [
                                Container(
                                  
                                  child: Text(doc.data['totalMarksObtained'] == null ? '-' : doc.data['totalMarksObtained'].toString(),
                                    style: TextStyle(color: Colors.green),
                                  )
                                ),
                                SizedBox(width: 4,),
                                Container(
                                  child: Text('/',
                                    style: TextStyle(color: Colors.green),)
                                ),
                                SizedBox(width: 4,),
                                Container(
                                  child: Text(doc.data['totalValidMarks'] == null ? '-' : doc.data['totalValidMarks'].toString(),
                                    style: TextStyle(color: Colors.green),
                                  )
                                )
                              ]
                            )
                            ]
                          )
                      ]
                    ),
                  ),
                );
              }
            }
            return Card();
        } ,
        future: getStudent(doc),
      );
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    // TODO: implement build
    return StoreConnector<AppState, AppState>(builder: (BuildContext context, state){
       return Scaffold(
          appBar: AppBar(
            title: Text(state.testSelected.quizName),
            backgroundColor: Colors.blueAccent,
          ),
          body: FutureBuilder(
            builder: (BuildContext context, snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                schoolCode = snapshot.data['schoolCode'];
                 return StreamBuilder(
                    stream:  _firestore.collection("/studentResponse/${snapshot.data['schoolCode']}/test")
                        .where('assessmentId', isEqualTo: state.testSelected.id).orderBy('completedAt',descending: true).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                        if(snapshot.connectionState != ConnectionState.waiting){
                          if(snapshot.data.documents.length == 0){
                            return Container(
                              width: double.infinity,
                              height: deviceHeight,
                              child: Center(
                                child: Text('No submissions, yet'),)
                            );
                          }
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: renderStudentScore(snapshot.data) ,)
                            ),
                          );
                        }
                        return Container(
                          width: double.infinity,
                          height: deviceHeight,
                          child: Center(
                            child: CircularProgressIndicator(),)
                        );
                    },);
              }
              return Container(
                width: double.infinity,
                height: deviceHeight,
                child: Center(
                  child: CircularProgressIndicator(),)
              );
            } ,
            future: getUser(),
          )
        );
    },
      converter: (store) => store.state);
  }

}