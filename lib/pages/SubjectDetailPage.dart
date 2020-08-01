
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/pages/audioplayer.dart';
import 'package:studyapp/pages/conversation.dart';
import 'package:studyapp/pages/home.dart';
import 'package:studyapp/pages/pdfviewerv.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
// import 'package:badges/badges.dart';

class SubjectDetailPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SubjectDetailPage();
}

class _SubjectDetailPage extends State<SubjectDetailPage>{
  final String user = 'Bukola Damola';
  String errorMessage = "";
  final List<Map<String, dynamic>> courseMaterial = [
    {'id': 1, 'name': 'Trignometry', 'type':'audio', 'url': 'https://www.mediacollege.com/downloads/sound-effects/nature/forest/rainforest-ambient.mp3'},
    {'id': 2, 'name': 'Comprehension', 'type':'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
    
    {'id': 4, 'name': 'Algebraic Expressions', 'type':'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
    {'id': 5, 'name': 'Common Factors', 'type':'pdf', 'url': 'https://pdfkit.org/docs/guide.pdf'}
  ];
  renderIcon(var material){
    switch(material['file_type']){
      case 'ppt':
      case 'doc':
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
  refreshMaterials(BuildContext context) async{
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
      await _fetchPrimarySchoolSubject(context);
      await _getJuniorSchoolData(context);
      await _getSeniorSchoolSubject(context);
      Navigator.pop(context);
      setState(() {
        errorMessage = "";
      });
  }
     _fetchPrimarySchoolSubject(BuildContext context) async {
      // print('here 1');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var appDomain = prefs.getString('appDomain');
      final response = await http.get(appDomain+'read.php?id=2');
      if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // print('here 2');
      // print(json.decode(response.body).toString());
      // SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final responseSubjects = json.decode(response.body);

      prefs.setString('primary_subjects', json.encode(responseSubjects['subjects']));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load primary school data";
      });
      throw Exception('Failed to load album');
    }
  }

  _getJuniorSchoolData(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
      var appDomain = prefs.getString('appDomain');
    final response = await http.get(appDomain+'read.php?id=3');
      if (response.statusCode == 200) {
         final SharedPreferences prefs = await SharedPreferences.getInstance();
      // final SharedPreferences prefs = await _prefs;
      // print('here o'+ json.decode(response.body).toString());
      final responseSubjects = json.decode(response.body);
      prefs.setString('junior_subjects', json.encode(responseSubjects['subjects']));

      // print('hello '+ json.decode(prefs.getString('primary_subjects')).toString());
      // Navigator.of(context).pop();
      }else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load junior secondary school data";
      });
      // throw Exception('Failed to load album');
    }
  }

  _getSeniorSchoolSubject(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
      var appDomain = prefs.getString('appDomain');
      final response = await http.get(appDomain+'read.php?id=4');
      if (response.statusCode == 200) {
         final SharedPreferences prefs = await SharedPreferences.getInstance();
      // final SharedPreferences prefs = await _prefs;
      // print('here o'+ json.decode(response.body).toString());
      final responseSubjects = json.decode(response.body);
      prefs.setString('senior_subjects', json.encode(responseSubjects['subjects']));
      // print('hello '+ json.decode(prefs.getString('primary_subjects')).toString());
      // Navigator.of(context).pop();
      }else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load senior secondary school data";
      });
      // throw Exception('Failed to load album');
    }
  }
  @override
  Widget build(BuildContext context) {
    print('reloaded');
    double deviceHeight = MediaQuery.of(context).size.height;
    return StoreConnector<AppState, AppState>( 
      converter: (store) => store.state, 
      builder: (context, state){
        return Scaffold(
          appBar: AppBar(
         title: Text(state.selectedSubject['subject']),
         backgroundColor: Colors.blueAccent,
         actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                refreshMaterials(context);
              },
              child: Text("Refresh"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ) ,
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
                                                        // StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
                                                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ConversationPage(roomname)) );
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
                                                    child: Text('Join Conversation'),
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
                                                        if(material['file_type'].trim().toLowerCase() == 'pdf' || material['file_type'].trim().toLowerCase() == 'ppt' || material['file_type'].trim().toLowerCase() == 'doc'){
                                                          // print(material);
                                                          
                                                          // return Navigator.push(context, MaterialPageRoute(builder: (context) => Pdf(materialName: material['file_name'], url: material['file_url'])));
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