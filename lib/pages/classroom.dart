import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/pages/chatroom.dart';
import 'package:studyapp/pages/home.dart';
import 'package:studyapp/redux/actions.dart';

// class ClassRoom extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _ClassRoomState();
//   }
// }

class ClassRoom extends StatelessWidget{
  final List<Map<String, dynamic>> classRooms = [
    {'id': 1, 'subject': 'Maths', 'category':'Primay 1', 'roomName': 'Primary One Maths', 'lastJoined':''},
    {'id': 1, 'subject': 'Biology', 'category':'Primay 1', 'roomName': 'Primary One Biology', 'lastJoined':''},
    {'id': 1, 'subject': 'English', 'category':'Primay 1', 'roomName': 'Primary One English', 'lastJoined':''},
    {'id': 1, 'subject': 'Physics', 'category':'Primay 1', 'roomName': 'Primary One Physics', 'lastJoined':''}
  ];
  var user;
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }
  Future getUserChatRooms() async{
    print('cahhlled');
    List<dynamic> subjects = [];
    String uid;
    uid = (await FirebaseAuth.instance.currentUser()).uid;
    // FirebaseAuth.instance.currentUser().then((value) => uid = value.uid);
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    user = json.decode(_prefs.getString('user'));
    print('user id: '+ uid);
    try{
      QuerySnapshot querySnapshot = await Firestore.instance.collection('chatrooms/'+uid+'/rooms').getDocuments();
      print(querySnapshot.documents.toString());
      querySnapshot.documents.forEach((element) {
        print('here o'+ element.data.toString());
        subjects.add(element.data);
      });
      print(subjects.toString());
      return subjects;
    }catch(error){
      print('some errors were encountered: '+ error.toString());
    }
  }
  signTeacherToClass(var teacherClasses) async{
     await teacherClasses.forEach((subject) async{
                  final String roomname = subject['schoolLevel'] + ' ' + subject['subject'];
                  print(roomname);
                  try{
                    final String uid = (await FirebaseAuth.instance.currentUser()).uid;
                    await  Firestore.instance
                          .collection('chatrooms').document(uid).collection('rooms').document(roomname)
                          .get().then((doc) async {
                              print(doc.data.toString());
                              if(doc.exists){
                                print('delete multiple');
                                await  Firestore.instance
                                    .collection('chatrooms').document(uid)
                                    .collection('rooms').document(roomname).delete();
                                print('here in push');
                                  await  Firestore.instance
                                        .collection('chatrooms').document(uid).collection('rooms').document(roomname)
                                        .setData({
                                          'roomname': roomname,
                                          'status':'joined'
                                        });
                              }
                              print('escaped');
                              print('here in push');
                              await  Firestore.instance
                                    .collection('chatrooms').document(uid).collection('rooms').document(roomname)
                                    .setData({
                                      'roomname': roomname,
                                      'status':'Recently Joined'
                                    });
                          });
                      print('compllee');
                    return true;
                }catch(error){
                  print(error);
                  return false;
                }
              });
  }
  Widget renderTeacherChatrooms(String email, String schoolCode, BuildContext context){
    Firestore _firestore = Firestore.instance;
    double deviceHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
      stream: _firestore.collection('teachers')
              .where('email', isEqualTo: email)
              .where('partnerCode', isEqualTo: schoolCode).snapshots() ,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.connectionState != ConnectionState.waiting){
              if(snapshot.hasError){
                return Container(
                      width: double.infinity,
                      color: Colors.white,
                      height: deviceHeight,
                    );
              }
              // signTeacherToClass(snapshot.data.documents.first['subjects']);
              return FutureBuilder(
                future: signTeacherToClass(snapshot.data.documents.first['subjects']),
                builder: (BuildContext context,AsyncSnapshot snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                     if(snapshot.hasError){
                       return Container();
                     }
                     return renderStudentChatRooms();
                  }
                  return Container();
                },
              );
              // return renderStudentChatRooms();
               
          }
          return Container(
            width: double.infinity,
            color: Colors.white,
            height: deviceHeight,
          );
        } ,
      );
  }
  renderStudentChatRooms(){
      return Container(
        child: FutureBuilder(
                  future: getUserChatRooms(),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    if(snapshot.connectionState == ConnectionState.done){
                      if(snapshot.hasData && snapshot.data.length > 0){
                        return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Your Classrooms',
                                    style: TextStyle(fontFamily: 'Gilroy', fontSize: 26.0, 
                                    fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(height: 16.0,),
                                Container(
                                  child: ListView(
                                    physics: ScrollPhysics(), // to disable GridView's scrolling
                                    shrinkWrap: true,
                                    children: snapshot.data.map<Widget>((var document){
                                        return FlatButton(
                                          onPressed: (){
                                            print('>>>> '+document.toString());
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChatRoom.fromselectedRoom(document['roomname'], user['schoolCode'])));
                                            StoreProvider.of<AppState>(context).dispatch(SelectedRoom(document));
                                            // print("++++"+ document['roomname']);
                                            // Navigator.of(context).pushNamed('/chatroom');
                                            
                                          },
                                          child: Card(
                                            child: ListTile(
                                              title: Text(document['roomname']),
                                              leading: Icon(Icons.school),
                                              trailing: CircleButton(
                                                      onTap: (){},
                                                      iconData: Icons.chat
                                                    ),
                                            ),
                                          )
                                        );
                                    }).toList()
                                    ,)
                                    ,)
                            ],);
                      }
                      return Center(
                              child: Container(
                                child: RaisedButton(onPressed: (){
                                    StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                },
                                color: Colors.deepOrangeAccent,
                                textColor: Colors.white,
                                  child: Text('No Classroom found, Join Classroom'),
                                )
                                ,)
                            );
                    }
                    return Center(
                        child: Container(
                          child: Text('Loading Chatrooms')
                          ,)
                      );
                  })
      );
  }
  Widget renderChatRooms(var user, BuildContext context){
      if(user['type'] == 'teacher'){
        print('ren render');
        return renderTeacherChatrooms(user['email'], user['schoolCode'], context);
      }
      print('in dtudents');
      return renderStudentChatRooms();
  }
  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    var userDetails = json.decode(prefs.getString('user'));
    return userDetails;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final double deviceHeight = MediaQuery.of(context).size.height;
    
    // TODO: implement build
    return FutureBuilder(
      future: getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasError){
            return Container();
          }
          return StoreConnector<AppState,AppState>(
              converter: (store) => store.state,
              builder: (context, state) {
                return Container(
                        width: double.infinity,
                        height: deviceHeight,
                        decoration: BoxDecoration(             
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/chatbg.jpeg'),
                            )
                          ),
                      child: SafeArea(
                        minimum: EdgeInsets.symmetric(vertical: 40.0),
                        child: renderChatRooms(snapshot.data, context)
                        )
                      ,);
              },
              );
        }
        return Container();
      },);
  }
}

/*

Center(
                  child: Container(
                    child: RaisedButton(onPressed: (){},
                    color: Colors.deepOrangeAccent,
                     textColor: Colors.white,
                      child: Text('No Classroom found, Join Classroom'),
                    )
                    ,)
                )

Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Your Classrooms',
                        style: TextStyle(fontFamily: 'Gilroy', fontSize: 26.0, 
                        fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16.0,),
                    Container(
                      child: ListView(
                        physics: ScrollPhysics(), // to disable GridView's scrolling
                        shrinkWrap: true,
                        children: classRooms.map((Map<String, dynamic> room){
                            return FlatButton(
                              onPressed: (){
                                StoreProvider.of<AppState>(context).dispatch(SelectedRoom(room));
                                Navigator.of(context).pushNamed('/chatroom');
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(room['roomName']),
                                  leading: Icon(Icons.book),
                                  trailing: CircleButton(
                                          onTap: (){},
                                          iconData: Icons.chat
                                        ),
                                ),
                              )
                            );
                        }).toList()
                        ,)
                        ,)
                ],)

[
    {'id': 1, 'subject': 'Maths', 'category':'Primay 1', 'roomName': 'Primary One Maths', 'lastJoined':''},
    {'id': 1, 'subject': 'Biology', 'category':'Primay 1', 'roomName': 'Primary One Maths', 'lastJoined':''},
    {'id': 1, 'subject': 'English', 'category':'Primay 1', 'roomName': 'Primary One Maths', 'lastJoined':''},
    {'id': 1, 'subject': 'Physics', 'category':'Primay 1', 'roomName': 'Primary One Maths', 'lastJoined':''}
  ]

*/

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;

  const CircleButton({Key key, this.onTap, this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 50.0;

    return new InkResponse(
      onTap: onTap,
      child: new Container(
        width: size,
        height: size,
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: new Icon(
          iconData,
          color: Colors.black,
        ),
      ),
    );
  }

}

/*
final String roomname = state.schoolLevel + ' ' + state.selectedSubject['subject'];
print(roomname);
try{
  final String uid = (await FirebaseAuth.instance.currentUser()).uid;
  await  Firestore.instance
        .collection('chatrooms').document(uid).collection('rooms').document(roomname)
        .get().then((doc) async {
            print(doc.data.toString());
            if(doc.exists){
              print('delete multiple');
              await  Firestore.instance
                  .collection('chatrooms').document(uid)
                  .collection('rooms').document(roomname).delete();
              print('here in push');
                await  Firestore.instance
                      .collection('chatrooms').document(uid).collection('rooms').document(roomname)
                      .setData({
                        'roomname': roomname,
                        'status':'joined'
                      });
            }
            print('escaped');
            print('here in push');
            await  Firestore.instance
                  .collection('chatrooms').document(uid).collection('rooms').document(roomname)
                  .setData({
                    'roomname': roomname,
                    'status':'Recently Joined'
                  });
        });

*/