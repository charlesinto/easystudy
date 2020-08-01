import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/pages/LandingPage.dart';
import 'package:studyapp/pages/SubjectDetailPage.dart';
import 'package:studyapp/pages/assesmentDetail.dart';
import 'package:studyapp/pages/assessment.dart';
import 'package:studyapp/pages/audioplayer.dart';
import 'package:studyapp/pages/chatroom.dart';
import 'package:studyapp/pages/classroom.dart';
import 'package:studyapp/pages/home.dart';
import 'package:studyapp/pages/learning.dart';
import 'package:studyapp/pages/login.dart';
import 'package:studyapp/pages/notifications.dart';
import 'package:studyapp/pages/otherResources.dart';
import 'package:studyapp/pages/pdfSecond.dart';
import 'package:studyapp/pages/pdfViewer.dart';
import 'package:studyapp/pages/practiceSubjects.dart';
import 'package:studyapp/pages/practice_page.dart';
import 'package:studyapp/pages/practice_reportpage.dart';
import 'package:studyapp/pages/practice_test.dart';
import 'package:studyapp/pages/prepare_practicetest.dart';
import 'package:studyapp/pages/profile.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/pages/quiz.dart';
import 'package:studyapp/pages/quizResponse.dart';
import 'package:studyapp/pages/resoucesDetailPage.dart';
import 'package:studyapp/pages/resources.dart';
import 'package:studyapp/pages/subjectPages.dart';
import 'package:studyapp/pages/teacher_login.dart';
import 'package:studyapp/pages/userLogin.dart';
import 'package:studyapp/pages/videoPlayer.dart';
import 'package:studyapp/pages/videoSecond.dart';
import 'package:studyapp/redux/reducers.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:permission_handler/permission_handler.dart';
import './pages/app_page.dart';



void main() {
  // SharedPreferences.setMockInitialValues({});
  final _initialState = AppState(selectedTabIndex: 0);
  final Store<AppState> _store = Store<AppState>(reducer, initialState: _initialState);
  runApp(MyApp(_store));
}


class MyApp extends StatefulWidget {
  final Store<AppState> store;
  MyApp(this.store);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final Firestore _firestore = Firestore.instance;
  double deviceHeight;
  bool rebuild = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fcm.configure(
          onMessage: (Map<String, dynamic> message) async {
            print("onMessage: $message");
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                        content: ListTile(
                        title: Text(message['notification']['title']),
                        subtitle: Text(message['notification']['body']),
                        ),
                        actions: <Widget>[
                        FlatButton(
                            child: Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(),
                        ),
                    ],
                ),
            );
        },
        onLaunch: (Map<String, dynamic> message) async {
            print("onLaunch: $message");
            // TODO optional
        },
        onResume: (Map<String, dynamic> message) async {
            print("onResume: $message");
            // TODO optional
        },
      );
  }
  // final SharedPreferences prefs;

  Future<String> getLocalUser() async{
    // print('here in');
    
    await Permission.storage.request(); 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('user');
    return  prefs.getString('user');
  }
  Future<Map<String, dynamic>> getLicenseStatus() async{
    String currentUser = await getLocalUser();
    try{
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if(prefs.getString('user') != null){
          var schoolCode = json.decode(prefs.getString('user'))['schoolCode'];
          DocumentSnapshot doc =  await _firestore.document("/partners/$schoolCode").get();
          DateTime licenseEndDate = doc.data['licenseEndDate'].toDate();
          DateTime today = DateTime.now();
          int diffDays = licenseEndDate.difference(today).inDays;
          if(diffDays > 0){
            
            return {"isLicensed":true, "user": currentUser};
          }
          return  {"isLicensed":false, "user": currentUser};
        }
        return  {"isLicensed":true, "user": currentUser};
    }catch(error){
      return  {"isLicensed":true, "user": currentUser};
    }
  }
  @override
  Widget build(BuildContext context)  {
     return FutureBuilder(
       future: getLicenseStatus() ,
       builder: (BuildContext context,AsyncSnapshot<Map<String, dynamic>> snapshot){
         
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData && snapshot.data['isLicensed'] == true){
              return StoreProvider<AppState>(store: widget.store, 
                      child: MaterialApp(
                        title: 'Study App',
                        theme: ThemeData(
                            primaryColor: Colors.grey[800],
                          ),
                          home: snapshot.data['user'] != null ? Home():  AppPage(),
                          // initialRoute: '/',
                          routes: {
                            '/app': (context) => Home(),
                            '/selectapp': (context) => AppPage(),
                            '/home': (context) => LandingPage(),
                            '/login': (context) => Login(),
                            '/learning': (context) => Learning(),
                            '/classroom': (context) => ClassRoom(),
                            '/profile': (context) => Profile(),
                            '/viewsubject': (context) => SubjectDetailPage(),
                            '/pdfview': (context) => PdfViewer(),
                            '/videoView': (context) => VideoPlayerWidget(),
                            '/chatroom': (context) => ChatRoom(),
                            '/teachersLogin': (context) => TeacherLogin(),
                            '/assessmentDetail': (context) => AssessmentDetailPage(),
                            "/assessments": (context) => Assessment(),
                            '/quiz': (context) => Quiz(),
                           '/notifications': (context) => Notifications(),
                           '/quizResponses': (context) => QuizResponse(),
                           '/studentSignIn': (context) => UserLogin(),
                           '/practicepage': (_) => PracticePage(),
                           '/practicesubjects': (_) => PracticeSubjects(),
                           '/preparePracticeTest': (_) => PrepareTest(),
                           '/practiceTest': (_) => PracticeTest(),
                           '/report': (_) => PracticeReport(),
                           '/otherResources': (_) => OtherResources(),
                           '/resourcecatgories': (_) => ResourceDetail(),
                           '/resourcesView': (_) => ResourcesContentPage(),
                           '/pdf2': (_) => PdfSecond(),
                           '/video2': (_) => VideoSecond()
                          },
                          onGenerateRoute: (RouteSettings setting){
                            List<String> pathElements = setting.name.split('/');
                            if(pathElements[0] != ''){
                              return null;
                            }
                            if(pathElements[1] == 'selectSubjects'){
                                return MaterialPageRoute(builder: (BuildContext context)  {
                                  return SelectSubjectPage(pathElements[2]);
                                });
                            }
                            return null;
                          }
                      )
                      );
              
            }
            return MaterialApp(
              title: 'Study App',
              theme: ThemeData(
                  primaryColor: Colors.grey[800],
                ),
              home: Scaffold(
                appBar: AppBar(
                  title: Text('Easy Study Ps'),
                  backgroundColor:  Colors.blueAccent,
                ),
                body: Container(
                    width: double.infinity,
                    height: deviceHeight,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                    child: Center(
                      child: Column(
                            children: <Widget>[
                              Container(
                                child: Center(
                                  child: Text('License has expired, please purchase a new license or contact school admin.',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.black) ,
                                ),
                                ),
                              ),
                              SizedBox(height: 60.0,),
                              RaisedButton(
                                  onPressed: (){
                                    setState(() {
                                      rebuild = true;
                                    });
                                    getLicenseStatus();
                                  } ,
                                  color: Colors.green,
                                  child: Text('Try again', style: TextStyle(color: Colors.white),
                                  ),
                              )
                            ],
                          )
                    ),
                  ),
              )
            );
          }
          return MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.lightBlue, Colors.deepPurple]
                    )
                  )
              )
            )
          );
       } ,);
  } 
}





