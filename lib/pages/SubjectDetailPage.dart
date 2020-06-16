
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/pages/audioplayer.dart';
import 'package:studyapp/pages/home.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:badges/badges.dart';

class SubjectDetailPage extends StatelessWidget{
  final String user = 'Bukola Damola';
  final List<Map<String, dynamic>> courseMaterial = [
    {'id': 1, 'name': 'Trignometry', 'type':'audio', 'url': 'https://www.mediacollege.com/downloads/sound-effects/nature/forest/rainforest-ambient.mp3'},
    {'id': 2, 'name': 'Comprehension', 'type':'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
    
    {'id': 4, 'name': 'Algebraic Expressions', 'type':'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
    {'id': 5, 'name': 'Common Factors', 'type':'pdf', 'url': 'https://pdfkit.org/docs/guide.pdf'}
  ];
  renderIcon(var material){
    switch(material['file_type']){
      case 'pdf':
        return LineIcons.file_pdf_o;
      case 'video':
        return LineIcons.play_circle;
      case 'audio':
        return LineIcons.music;
      default:
        return LineIcons.book;
    }
  }
  Future<String> getLoggedInUser() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = json.decode(prefs.getString('user'));
    return user['firstName'] + " " + user['lastName'];
  }
  getMaterials(String schoolLevel, String subject) async{
    // print('string  here'+ schoolLevel + ' ' + subject);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> materials = json.decode(prefs.getString(schoolLevel+subject));
    // print( json.decode(prefs.getString(schoolLevel+subject)));
    print('materials: '+ materials.toString());
    var fileredMaterials = materials.where((element) => element['file_type'].isNotEmpty && element['file_name'].isNotEmpty);
    print('print hel: '+ fileredMaterials.toString());
    
    return  fileredMaterials;
  }
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    // TODO: implement build   
    return StoreConnector<AppState, AppState>( 
      converter: (store) => store.state, 
      builder: (context, state){
        print(state.selectedSubject.toString());
        return Scaffold(
          appBar: AppBar(
         title: Text(state.selectedSubject['subject']),
         backgroundColor: Colors.blueAccent,
        ),
          endDrawer:  FutureBuilder(
        future: getLoggedInUser() ,
        builder: (context, AsyncSnapshot snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                 if(snapshot.hasData){
                      return  Drawer(
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
                                    child: Text(snapshot.data,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(

                                        color: Colors.white, fontFamily: 'Gilroy',
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800
                                        ),
                                    ) ,)
                                ,),
                                SizedBox(height: 20,),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Home'),
                                              leading: Icon(Icons.home),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                ),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Learning'),
                                              leading: Icon(LineIcons.book),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                ),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Classroom'),
                                              leading: Icon(LineIcons.users),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                ),
                                FlatButton(child: Card(
                                            child: ListTile(
                                              title: Text('Profile'),
                                              leading: Icon(LineIcons.user),
                                            ),
                                          ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                }
                                )
                            ],)
                            ,) 
                            
                          );
                 }
                 return  Drawer(
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
                    child: Text('',
                      textAlign: TextAlign.center,
                      style: TextStyle(

                        color: Colors.white, fontFamily: 'Gilroy',
                          fontSize: 26,
                          fontWeight: FontWeight.w800
                        ),
                    ) ,)
                ,),
                SizedBox(height: 20,),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Home'),
                              leading: Icon(Icons.home),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Learning'),
                              leading: Icon(LineIcons.book),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Classroom'),
                              leading: Icon(LineIcons.users),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Profile'),
                              leading: Icon(LineIcons.user),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                )
            ],)
            ,) 
            
          );
              }
              return  Drawer(
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
                    child: Text('',
                      textAlign: TextAlign.center,
                      style: TextStyle(

                        color: Colors.white, fontFamily: 'Gilroy',
                          fontSize: 26,
                          fontWeight: FontWeight.w800
                        ),
                    ) ,)
                ,),
                SizedBox(height: 20,),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Home'),
                              leading: Icon(Icons.home),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Learning'),
                              leading: Icon(LineIcons.book),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Classroom'),
                              leading: Icon(LineIcons.users),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                ),
                FlatButton(child: Card(
                            child: ListTile(
                              title: Text('Profile'),
                              leading: Icon(LineIcons.user),
                            ),
                          ),
                onPressed: (){
                  Navigator.pop(context);
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                }
                )
            ],)
            ,) 
            
          );
          } 
        ,) ,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: ListView(children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: deviceHeight * 0.32,
                    padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                            
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/study3.jpg'),
                        )
                    ),
                    child: Text(
                      state.selectedSubject['subject'],
                      style: TextStyle(color: Colors.white,
                      fontSize: 18, fontWeight: FontWeight.bold,
                       fontFamily: 'Gilroy'),
                    )
                  ,),
                  SizedBox(height: 20.0,),
                  FutureBuilder(
                    future: getMaterials(state.schoolLevel,state.selectedSubject['subject']),
                    builder:(context, AsyncSnapshot snapshot){
                        if(snapshot.connectionState == ConnectionState.done){
                           if(snapshot.hasData && snapshot.data.length > 0){
                             return  Column(
                                      children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Text('Resources',
                                                    style: TextStyle(
                                                      color: Colors.black87, fontFamily: 'Gilroy', fontSize: 18.0, 
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),

                                                ),
                                                Container(
                                                  child: RaisedButton(
                                                    onPressed: () async{
                                                      
                                                      // FirebaseAuth.instance.currentUser()
                                                      // // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                                      // Firestore.instance.collection('chatrooms').document(state.schoolLevel+state.selectedSubject['subject']).setData({
                                                      //   uid: FirebaseAuth.instance.currentUser().then((value) => null)
                                                      // })
                                                      try{

                                                      
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible: false,
                                                          builder: (BuildContext context) {
                                                            return Dialog(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(vertical:16.0, horizontal: 16.0),
                                                                child: new Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  new CircularProgressIndicator(),
                                                                  Container(padding: EdgeInsets.symmetric(horizontal:16.0),
                                                                    child: new Text("Loading"),
                                                                  )
                                                                ],
                                                              ),),
                                                            );
                                                            });
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
                                                        print('done pushing');
                                                        Navigator.of(context).pop();
                                                        StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                                                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
                                                      }catch(error){
                                                        print('some errors were encountered: '+ error.toString());
                                                      }
                                                      
                                                      
                                                      // FirebaseAuth.instance.currentUser().then((value){
                                                        
                                                      // })
                                                      }
                                                      catch(error){
                                                        Navigator.of(context).pop();
                                                      }
                                                    },
                                                    color: Colors.white,
                                                    child: Text('Join Classroom'),
                                                  ) ,)
                                              ]
                                            )
                                            ,),
                                            SizedBox(height: 8.0,),
                                            Container(
                                              child: ListView(
                                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                                physics: ScrollPhysics(), // to disable GridView's scrolling
                                                shrinkWrap: true,
                                                children: snapshot.data.map<Widget>((var material){
                                                  return FlatButton(
                                                      child: Card(
                                                        child: ListTile(
                                                          title: Text(material['file_name']),
                                                          leading: Icon(Icons.book),
                                                          trailing: CircleButton(
                                                                  onTap: (){},
                                                                  iconData: renderIcon(material)
                                                                ),
                                                        ),
                                                      ),
                                                      onPressed: (){
                                                        StoreProvider.of<AppState>(context).dispatch(SelectedMaterial(material));
                                                        if(material['file_type'].trim().toLowerCase() == 'pdf'){
                                                          
                                                          return Navigator.of(context).pushNamed('/pdfview');
                                                        }
                                                        if(material['file_type'].trim().toLowerCase() == 'video'){
                                                          return Navigator.of(context).pushNamed('/videoView');
                                                        }
                                                        if(material['file_type'].trim().toLowerCase() == 'audio'){
                                                          return Navigator.push(context, MaterialPageRoute(builder: (context) => AudioPlayerApp.fromApp(material)));
                                                        }
                                                        print('her insider o');
                                                        return null;
                                                      },
                                                    );
                                                }).toList(),) ,
                                            )
                                      ]
                                    );
                    
                           }

                          //  showDialog(context: null)
                           return Container(
                             child: Center(child: Text('No Materials Found'),) ,
                          );
                        }
                        return Container(
                             child: Center(child: Text('Loading Material...'),) ,
                        );
                    } ,
                  )

              ],))
            ]
          ) ,
          floatingActionButton: Builder(builder: (BuildContext context){
                  return FloatingActionButton(
                  child: new Icon(LineIcons.sticky_note),
                  onPressed: (){
                    print('pressed o');
                    Scaffold.of(context).openDrawer();
                  },
                );
          },),
        );
      });
  }
}

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