import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/learning_course.dart';
import 'package:studyapp/model/appUser.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/util/colors.dart';
import 'package:studyapp/util/size.dart';
import 'dart:async';

class LandingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LandingPage();
  }
  
}

class _LandingPage extends State<LandingPage>{
  GlobalKey<ScaffoldState> _drawerWidget = GlobalKey<ScaffoldState>();
  AppUser _appUser = AppUser();
  Firestore _firestore = Firestore.instance;
  String username = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  getAppState() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> userData = json.decode(prefs.getString('user'));
    // username = userData['firstName'] + " " + userData["lastName"];
    setState(() {
      username = userData['firstName'].toString().trim() + " " + userData["lastName"].toString().trim();
    });
  }
  Future<AppUser> getUserDetails() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var user = json.decode(_prefs.getString('user'));
    
    _appUser.setUserSchoolCode(user['schoolCode']);
    return _appUser;
  }
  @override
  Widget build(BuildContext context) {
    double deviceHieght = SizeConfig.getHeight(context);
    double deviceWidth = SizeConfig.getWidth(context);
    if(username.isEmpty){
      getAppState();
    }
    handleOnPress(){
      print('pressed');
      _drawerWidget.currentState.openDrawer();
    }
    // TODO: implement build
    return StoreConnector<AppState, AppState>(converter: (store) => store.state,
    builder: (context, state) {
          return Scaffold(
            key: _drawerWidget,
            drawer: Drawer(
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
                            child: Text(username,
                              textAlign: TextAlign.center,
                              style: TextStyle(

                                color: Colors.white, fontFamily: 'Gilroy',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800
                                ),
                            ) ,)
                        ,),
                        Expanded(
                          child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                            SizedBox(height: 20,),
                        FlatButton(child: Card(
                                    child: ListTile(
                                      title: Text('Home'),
                                      leading: Icon(Icons.home),
                                    ),
                                  ),
                        onPressed: (){
                          Navigator.pop(context);
                          // StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
                          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                        }
                        ),
                        FlatButton(child: Card(
                                    child: ListTile(
                                      title: Text('Notifications'),
                                      leading: Icon(Icons.notifications),
                                    ),
                                  ),
                        onPressed: (){
                          Navigator.pop(context);
                          // StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                          Navigator.of(context).pushNamed('/notifications');
                          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                        }
                        ),
                        FlatButton(child: Card(
                                    child: ListTile(
                                      title: Text('Assessments'),
                                      leading: Icon(Icons.storage),
                                    ),
                                  ),
                        onPressed: (){
                          Navigator.pop(context);
                          StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                          
                          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                        }
                        ),
                        FlatButton(child: Card(
                                    child: ListTile(
                                      title: Text('Practice Exercises'),
                                      leading: Icon(Icons.pie_chart_outlined),
                                    ),
                                  ),
                        onPressed: (){
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed('/practicepage');
                          
                          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                        }
                        ),
                        FlatButton(child: Card(
                                    child: ListTile(
                                      title: Text('Other Resources'),
                                      leading: Icon(Icons.school),
                                    ),
                                  ),
                        onPressed: (){
                          Navigator.pop(context);
                          // StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                          Navigator.of(context).pushNamed('/otherResources');
                          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                        }
                        ),
                        FlatButton(child: Card(
                                    child: ListTile(
                                      title: Text('My Profile'),
                                      leading: Icon(Icons.account_circle),
                                    ),
                                  ),
                        onPressed: (){
                          Navigator.pop(context);
                          // StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                          Navigator.of(context).pushNamed('/profile');
                          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                        }
                        ),
                        FlatButton(child: Card(
                                    child: ListTile(
                                      title: Text('Log Out'),
                                      leading: Icon(Icons.arrow_back_ios),
                                    ),
                                  ),
                        onPressed: () async{
                          SharedPreferences _prefs = await SharedPreferences.getInstance();
                          _prefs.remove('user');
                          Navigator.of(context).pushReplacementNamed('/selectapp');
                          print('done');
                        }
                        ),
                        SizedBox(height: 20,),
                          ],)
                        )
                          
                        )
                    ],)
                    ,)

                ),
            body:Container(
              // color: AppColors.primaryWhite,
              child: ListView(
                      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                      children: <Widget>[
                        SafeArea(
                      minimum: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                                Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                            Container(
                                                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                  child: Row(
                                                  
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text('Hello',

                                                    )
                                                  ] ,
                                                )
                                              )
                                              ,
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    constraints: BoxConstraints(maxWidth: deviceWidth * 0.4 > 400 ? 400 : deviceWidth * 0.4),
                                                    child:Text(username,
                                                  overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold, fontSize: 26),
                                                  )
                                                  )
                                                ]
                                              )
                                      ],
                                    ),
                                    FlatButton(
                                      onPressed: (){
                                        handleOnPress();
                                      },
                                      child: Card(
                                        elevation: 4.0,
                                        shape: CircleBorder(),
                                        child: Container(
                                          height: 70,
                                        width: 70,
                                        // color: AppColors.primaryWhite,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // boxShadow: AppColors.neumorpShadow,
                                          shape: BoxShape.circle
                                        ),
                                          child:Stack(children: <Widget>[
                                          Center(
                                              child: Container(
                                                margin: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                    color: Colors.orange, shape: BoxShape.circle),
                                              ),
                                            ),
                                            Center(
                                                child: Container(
                                                  margin: EdgeInsets.all(11),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      // boxShadow: AppColors.neumorpShadow,
                                                      shape: BoxShape.circle),
                                                ),
                                              ),
                                              Center(
                                                child: FutureBuilder(
                                                  future: getUserDetails(),
                                                  builder: (BuildContext context,AsyncSnapshot snapshot){
                                                      if(snapshot.connectionState == ConnectionState.done){
                                                        if(snapshot.hasData){
                                                          return StreamBuilder(
                                                            stream: _firestore.collection('notifications')
                                                                    .where('schoolCode', isEqualTo: snapshot.data.getSchoolCode())
                                                                    .orderBy('createdAt').snapshots() ,
                                                            builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                                                                if(snapshot.connectionState != ConnectionState.waiting){
                                                                    if(!snapshot.hasError){
                                                                        if(snapshot.data.documents.length > 0){
                                                                          return Badge(
                                                                            badgeColor: Colors.redAccent,
                                                                            position: BadgePosition.topRight(top:-9, right: -6),
                                                                            badgeContent: Text(''),
                                                                            child: Icon(Icons.menu)
                                                                          );
                                                                        }
                                                                        return Container();
                                                                    }
                                                                    return Container();
                                                                }
                                                                return Container();
                                                            });
                                                        }
                                                      }
                                                      return Container();
                                                  }
                                                )
                                              )
                                        ],
                                        )
                                        )
                                      ),
                                    )
                                  ]
                                ),
                                Card(
                                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                                          // height: deviceHieght * 0.32,
                                          padding: EdgeInsets.only(top: 20, bottom: 20),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage('assets/getStarted.png'),
                                            )
                                            ),
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 142,
                                                    child: Text('What do you want to learn today?',
                                                      style: TextStyle(fontFamily: 'Gilroy', 
                                                      fontSize: 18,
                                                      height: 1.4,
                                                      fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(height: 16,),
                                                  Container(
                                                    child: RaisedButton(
                                                    onPressed: (){
                                                      // print('Hello');
                                                      StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                                                      // Navigator.pushReplacementNamed(context, '/learning');
                                                    },
                                                    color: Colors.deepOrangeAccent,
                                                    textColor: Colors.white,
                                                    child: Text('Get Started',
                                                    ),  
                                                  )
                                                  )
                                                ]
                                              ),
                                              
                                            )
                                          )
                                        ),
                                        
                                      ]
                                    )
                                  ),
                                ),
                            ],)
                            ),
                            SizedBox(height: 8,),
                            Container(
                              child:Text('Currently Viewing Subjects',
                                  style: TextStyle(color: Colors.grey[800], fontFamily: 'Gilroy'),
                                ),
                            ),
                            SizedBox(height: 16,),
                            Container(
                              width: double.infinity,
                              // height: 300.0,
                              child: LearningCourse()
                            ),
                            SizedBox(height: 16,),
                            Container(
                              child:Text('Frequently Viewed Subjects',
                                  style: TextStyle(color: Colors.grey[800], fontFamily: 'Gilroy'),
                                ),
                            ),
                            SizedBox(height: 16,),
                            Container(
                              width: double.infinity,
                              // height: 200.0,
                              child: LearningCourse()
                            ),
                        ]
                      )
                    )
                    ],
                    )
            )
          );
  
    } 
    ,);
}
}

/*
height: 60,
                                        width: 60,
                                        // color: AppColors.primaryWhite,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: AppColors.neumorpShadow,
                                          shape: BoxShape.circle
                                        )

*/



