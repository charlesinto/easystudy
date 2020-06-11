import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/pages/LandingPage.dart';
import 'package:toast/toast.dart';
import 'package:studyapp/pages/home.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:http/http.dart' as http;
import 'package:studyapp/util/colors.dart';

class SelectSubjectPage extends StatefulWidget {
  final String classSelected;
  SelectSubjectPage(this.classSelected);
  
  State<StatefulWidget> createState() => SelectedSubjectState();
  
}

class SelectedSubjectState extends State<SelectSubjectPage>{
  var subjects = [];
  final String user = 'Bukola Damola';
  AppColors _appColor = AppColors();
  int index = 0;
  String errorMessage = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subjects = [
          {'id': 1, 'subject': 'English Language'},
          {'id': 2, 'subject': 'Matematics'},
          {'id': 3, 'subject': 'Health Education'},
          {'id': 4, 'subject': 'Computer Science'},
          
      ];
    print(widget.classSelected);
  }
  _hanldeNavigationToCourseDetailPage(Map<String, dynamic> selectedSubject, String schoolLevel){
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
          _fetchSubjectMaterials(selectedSubject,schoolLevel, context);
        } catch(error){
          print(error);
        }
      
      /*
          

      */
    
  }
   _fetchSubjectMaterials(Map<String, dynamic> selectedSubject,schoolLevel, BuildContext context) async{
      try{

          SharedPreferences prefs = await SharedPreferences.getInstance();
          print(prefs.getString("${schoolLevel}${selectedSubject['subject']}"));
        if(prefs.getString("${schoolLevel}${selectedSubject['subject']}") == null){
          String appDomain = "";
          if(prefs.getString('appDomain') == null){
              print('hello');
              var schoolCode = json.decode(prefs.getString('user'))['schoolCode'];

              var doc = await Firestore.instance.document("/partners/$schoolCode").get();
              if(doc.exists){
                appDomain = doc.data['appDomain'];
                print('domain: > '+ appDomain);
              }else{
                return ;
              }
          }else{
            appDomain = prefs.getString('appDomain');
            print('2 000');
          }
          print(appDomain+'materials.php?id='+ selectedSubject['id']);
          final response = await http.get(appDomain+'materials.php?id='+ selectedSubject['id']);
            print(response.body);
            print(prefs.getString('appDomain'));
            print(response.statusCode);
            if (response.statusCode == 200 && response.body.trim() != '') {
              
                final responseSubjects = json.decode(response.body);
                print('>>>>: '+ response.body);
                prefs.setString(schoolLevel + selectedSubject['subject'] , json.encode(responseSubjects['materials']));
              

            } else {
              // If the server did not return a 200 OK response,
              // then throw an exception.
              
              print('here now 2');
              Navigator.of(context).pop();
                Toast.show("Some error encountered could not load subject, kindly try again", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
               throw Exception('Failed to load subjects');
            }
        }
        Navigator.of(context).pop();
        StoreProvider.of<AppState>(context).dispatch(SelectSubject(selectedSubject));
        Navigator.of(context).pushNamed('/viewsubject');
      } catch(error){
        print(error);
      }
      
      
  }
   _fetchPrimarySchoolSubject(BuildContext context, String appDomain) async {
      print('here 1');
      try{
        print('233444');
        var response = await http.get(appDomain+'read.php?id=2');
        print(response);
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
      print(response.toString());
      // Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load primary school data";
      });
      throw Exception('Failed to load album');
      }
    }catch(error){
      print('error is>>'+ error);
    }
  }
  _getJuniorSchoolData(BuildContext context, String appDomain) async{
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
      Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load junior secondary school data";
      });
      throw Exception('Failed to load album');
    }
  }
  _getSeniorSchoolSubject(BuildContext context, String appDomain) async{
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
      Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load senior secondary school data";
      });
      throw Exception('Failed to load album');
    }
  }
  Future getSubject(BuildContext context, AppState state) async{
    print('app state'+ state.educationLevel.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    var appDomain = prefs.getString('appDomain');
    if(state.educationLevel == 'primary'){
      print('helllo');
      // final Map<dynamic, dynamic> response = prefs.getString('primary_subjects');
      var data = prefs.getString('primary_subjects');
      try{
          // print(json.decode(data));
          var appDomain = prefs.getString('appDomain');
          if(data == null){
            print('is null >>>>' + appDomain);
            await _fetchPrimarySchoolSubject(context, appDomain);
            data = prefs.getString('primary_subjects');
          }
          var response = json.decode(data);
          print(response);
          return response;
      }catch(error){
        print('error is+++' + error);
      }
    }
    else if(state.educationLevel == 'Junior School'){
      print('helllo');
      // final Map<dynamic, dynamic> response = prefs.getString('primary_subjects');
      var data = prefs.getString('junior_subjects');
      try{
          // print(json.decode(data));
          if(data == null){
            await _getJuniorSchoolData(context, appDomain);
            data = prefs.getString('primary_subjects');
          }
          var response = json.decode(data);
          print(response);
          return response;
      }catch(error){
        print(error);
      }
    }
    else if(state.educationLevel == 'Senior School'){
      print('helllo');
      // final Map<dynamic, dynamic> response = prefs.getString('primary_subjects');
      var data = prefs.getString('senior_subjects');
      try{
          // print(json.decode(data));
          if(data == null){
            await _getJuniorSchoolData(context, appDomain);
            data = prefs.getString('primary_subjects');
          }
          var response = json.decode(data);
          print(response);
          return response;
      }catch(error){
        print(error);
      }
    }
  }
  Future<String> getLoggedInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = json.decode(prefs.getString('user'));
    return user['firstName'] + " " + user['lastName'];
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int count = 0;
    return StoreConnector<AppState, AppState>(
        builder: (context, state){
          return Scaffold(
      appBar: AppBar(
         title: Text('Select your subject'),
         backgroundColor: Colors.blueAccent,
        ),
      endDrawer: FutureBuilder(
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
        ,),
      body: FutureBuilder(
        future: getSubject(context,state),
        builder: (context, AsyncSnapshot snapshot){
           if(snapshot.connectionState == ConnectionState.done){
             if(snapshot.hasData){
               return  StoreConnector<AppState,AppState>(converter: (store) => store.state,
                builder: (context, state){
                  return ListView(
                            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal:16.0),
                            children: snapshot.data.map<Widget>((var item){
                                return Card(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                              child: ListTile(
                                              onTap: () {
                                                _hanldeNavigationToCourseDetailPage(item, state.schoolLevel);
                                              },
                                              leading: CircleAvatar(
                                                radius: 20.0,
                                                backgroundColor: _appColor.getBackgroundColor(item['subject']) ,
                                                child: Text(item['subject'].substring(0, 1).toUpperCase(),
                                                  style: TextStyle(
                                                    color:Colors.white, fontFamily: 'Gilroy',
                                                    fontSize: 18.0, fontWeight: FontWeight.bold
                                                    ),
                                                ),
                                              ),
                                              title: Text(item['subject'],
                                                style: TextStyle(
                                                    color:Colors.black, fontFamily: 'Gilroy',
                                                    fontSize: 16.0, fontWeight: FontWeight.bold
                                                    ),
                                              ),
                                              trailing: Icon(Icons.arrow_forward_ios),
                                            )
                                            ),
                                          );
                                }
                            ).toList()
                          );
                },
               );
             }
             return Container(
             width: MediaQuery.of(context).size.width,
             height: MediaQuery.of(context).size.height,
             child: Center(
               child: Text('Some errors were encountered')
             ),
           );
           }
           return Container(
             width: MediaQuery.of(context).size.width,
             height: MediaQuery.of(context).size.height,
             child: Center(
               child: CircularProgressIndicator()
             ),
           );
        },),
    );
        },
    
        converter: (store) => store.state ,);
  }
}

/*
GridView.count(
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 2,
                          physics: ScrollPhysics(), // to disable GridView's scrolling
                          shrinkWrap: true,
                          children: snapshot.data.map<Widget>((var item){
                            index = index + 1;
                            return GestureDetector(child: Container(
                                            // width: 300,
                                            decoration: BoxDecoration(
                                              color: index % 2 == 0 ? Colors.deepOrangeAccent : Colors.deepPurpleAccent ,
                                              borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                              boxShadow: [
                                                          new BoxShadow(
                                                            color: Colors.grey[300],
                                                            offset: new Offset(4.0, 2.0),
                                                          )
                                                        ]
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                            child: Center(child: Text(item['subject'],
                                                style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Gilroy',
                                                      fontSize: 18
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                        ), onTap: (){
                                          
                                          _hanldeNavigationToCourseDetailPage(item, state.schoolLevel);
                                        }
                                        ,);
                          }).toList(),
                        )

*/