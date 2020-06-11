import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/model/appUser.dart';

class Notifications extends StatefulWidget{
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notifications>{
  Firestore _firestore = Firestore.instance;
  AppUser _appUser = AppUser(); 
  Future<AppUser> getUserDetails() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var user = json.decode(_prefs.getString('user'));
    
    _appUser.setUserSchoolCode(user['schoolCode']);
    return _appUser;
  }
  void onSelect(BuildContext context, DocumentSnapshot doc){
    print(doc.data);
    
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar:  AppBar(
        title: Text('Notifications'),
            backgroundColor:  Colors.blueAccent,
          ),
      
      body: FutureBuilder(
        future: getUserDetails(),
        builder: (context, AsyncSnapshot snapshot){
            if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.hasData){
                  return StreamBuilder(
                      stream: _firestore.collection('notifications')
                        .where('schoolCode', isEqualTo: snapshot.data.getSchoolCode())
                        .orderBy('createdAt',descending: true).limit(20).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                          if(snapshot.connectionState != ConnectionState.waiting){
                              if(!snapshot.hasError){
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical:16.0),
                                  child: ListView(
                                      children: snapshot.data.documents.map((DocumentSnapshot doc){
                                          return Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                                            child: doc['type'] == 'Test' ? Card(
                                                child: ListTile(
                                                  onTap: (){
                                                    onSelect(context, doc);
                                                  },
                                                  title: Text(doc['quizName']),
                                                  subtitle: Text(doc['type']),
                                                  trailing: Badge(
                                                    borderRadius: 4.0,
                                                    badgeColor: Colors.redAccent,
                                                    shape: BadgeShape.square,
                                                    badgeContent: Text('New',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Gilroy'
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ) : Card(
                                                child: ListTile(
                                                  onTap: (){
                                                    showDialog(context: context,
                                                      builder: (BuildContext context){
                                                        return AlertDialog(
                                                          content: Container(
                                                            width: MediaQuery.of(context).size.width * 0.6,
                                                            padding: EdgeInsets.symmetric(vertical: 16.0,),
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                Container(
                                                                  padding: EdgeInsets.symmetric(horizontal: 8.0,),
                                                                  child: Text(
                                                                    "${doc['target']} Notifications",
                                                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                                                  )
                                                                ),
                                                                SizedBox(height: 10),
                                                                Divider(color: Colors.grey, height: 2.0,),
                                                                Container(
                                                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: <Widget>[
                                                                    SizedBox(height: 20),
                                                                      Container(
                                                                        
                                                                        child: Text(doc['message'], textAlign: TextAlign.justify,)
                                                                      )
                                                                  ],)
                                                                )
                                                              ],)
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            RaisedButton(onPressed: (){
                                                              Navigator.pop(context);
                                                            },
                                                            color: Colors.blueAccent,
                                                             child: Text('Close', style: TextStyle(color: Colors.white),),)
                                                          ],
                                                        );
                                                      }
                                                    );
                                                  },
                                                  title: Text(doc['target']),
                                                  subtitle: Text('Teacher Notification'),
                                                  trailing: Badge(
                                                    borderRadius: 4.0,
                                                    badgeColor: Colors.green,
                                                    shape: BadgeShape.square,
                                                    badgeContent: Text('View',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Gilroy'
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              )
                                          );
                                      }).toList()
                                    )
                                );
                              }
                              return Container(
                                child: Center(
                                  child: Text('No new notification! ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Gilroy',
                                      ),
                                    ) ,),
                              );
                          }
                          return Center(
                            child: CircularProgressIndicator(
                                  
                                )
                          );
                      }
                    );
                }
                return Container();
            }
            return Container();
        }),
    );
  }
}