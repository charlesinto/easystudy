
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/model/user.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';

class UserLogin extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // String _admissionNumber = "";
  String _pin = "";
  String _phoneNumber = "";
  String _emailAddress = "";
  String errorMessage = "";
  String appDomain = "";
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical:0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('I don\'t have an account?'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  _signupButton(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            child: OutlineButton(
              
              borderSide: BorderSide(width: 1.0,color: Color(0xfff7892b)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                ),
                child: Text(
                'Activate My Account',
                style: TextStyle(fontSize: 20, color: Colors.black),
              )
              ),
            )
          );
  }

  _activateApp(BuildContext context) async{
    print('hello o');
    setState(() {
      errorMessage = "";
    });
    _formKey.currentState.save();
    if(_emailAddress.isEmpty || _phoneNumber.isEmpty){
      return setState((){
          errorMessage = "Email, Phone Number are required";
      });
    }
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
      signupUser(context);
    
  }

  getSchoolDomain(String schoolCode, BuildContext context) async{
      // print('called');
      // print(schoolCode);
      // Navigator.of(context).pop();
      print('here: '+ schoolCode);
      await Firestore.instance.collection('partners').document(schoolCode).get()
        .then(( DocumentSnapshot doc) async {
           if(doc.exists){
            
             final SharedPreferences prefs = await SharedPreferences.getInstance();
             prefs.setString('appDomain', doc.data['appDomain']);
              appDomain = doc.data['appDomain'];
              DateTime licenseEndDate = doc.data['licenseEndDate'].toDate();
              DateTime today = DateTime.now();
              int diffDays = licenseEndDate.difference(today).inDays;
              if(diffDays <= 0){
                Navigator.pop(context);
                return setState((){
                  errorMessage= "Licences has expired, please purchase a new licence or contact admin";
                });
              }
              print('appDomain: '+ appDomain);
              print('app domain: '+ appDomain);
              await _fetchPrimarySchoolSubject(context);
              await _getJuniorSchoolData(context);
              await _getSeniorSchoolSubject(context);

              // if(checkIfEmailExists()){
              //     Navigator.of(context).pop();
              //     return setState((){
              //         errorMessage = "Email Already exist";
              //     });
                   
              // }
              
              
                // checkIfEmailNotExistThenSignUpUser(context, schoolCode);
               Navigator.of(context).pop();
              return Navigator.of(context).pushReplacementNamed('/app');
              
           }
           setState((){
                      errorMessage = "School Activation Pin is Invalid";
            });
           
        })
        .catchError((onError){

          Navigator.of(context).pop();
          print('error: '+ onError.toString());
        });

  }

  signupUser(BuildContext context) async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = _emailAddress.trim();
      var passworsd = _phoneNumber.trim();
      var pin = _pin.trim();
      var authUser = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: passworsd);
      
      var userData = await _firestore.collection('users').where('uid', isEqualTo: authUser.user.uid).getDocuments();
      if(userData.documents.isEmpty){
         Navigator.of(context).pop();
         return setState(() {
            errorMessage = "No such account found";
          }); 
      }
      var user = userData.documents[0].data['firstName'] +" "+ userData.documents[0].data['lastName'];
      List<User> student = await App.getUserClass( pin, userData.documents[0].data['admissionNumber']);
          
      if(student.length > 0){
        // App.subscribeToNotiifcation(student[0].schoolCode, student[0].userClass);
        prefs.setString('student', json.encode(student[0]));
      }
      print(user);
      prefs.setString('user', json.encode(userData.documents[0].data));
      StoreProvider.of<AppState>(context).dispatch(LoggedInUser(user));
      getSchoolDomain(userData.documents[0].data['schoolCode'], context);
          
    }catch(error){
       Navigator.of(context).pop();
      setState(() {
        errorMessage = "No such account found";
      });
    }
  }

     _fetchPrimarySchoolSubject(BuildContext context) async {
      // print('here 1');
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
      Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load primary school data";
      });
      throw Exception('Failed to load album');
    }
  }

  _getJuniorSchoolData(BuildContext context) async{
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

  _getSeniorSchoolSubject(BuildContext context) async{
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
  

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            SizedBox(height: 20,),
            Container(
                child: Center(child: Text('Easy StudyPS',
                  style: TextStyle(
                    fontFamily:'Gilroy', fontSize: 26.0, fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
              ),)),
              SizedBox(height: 8,),
              Container(
              child: Center(
                child: Text('We are glad to have you back!',
                style: TextStyle(color: Colors.grey, fontSize: 11),)
              )
              ),
              SizedBox(height: 20,),
              Form(
                key: _formKey,
                child: Column(
                children: <Widget>[
                    // Card(
                    //       child: TextFormField(
                    //         initialValue: _pin,
                    //         decoration: InputDecoration(labelText: 'School Activation Pin',
                    //           prefixIcon: Icon(LineIcons.key),
                    //           contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                    //         onSaved: (value){
                    //           print('values 000'+  value);
                    //           _pin = value;
                    //         },
                    //       ) ,
                    //     ),
                        Card(
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            initialValue: _emailAddress,
                            decoration: InputDecoration(labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _emailAddress = value;
                            },
                          ) ,
                        ),
                        Card(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: _phoneNumber,
                            decoration: InputDecoration(labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _phoneNumber = value;
                            },
                          ) ,
                        ),
                        errorMessage.isNotEmpty ? Center(child: 
                        Text(errorMessage,
                          style: TextStyle(color:Colors.red, fontFamily: 'Gilroy'),
                        ),) : Text('')
                  ]
                )
              ),
              Container(
                                      margin: EdgeInsets.symmetric(vertical: 10.0),
                                      child: RaisedButton(
                                        color: Colors.greenAccent[700],
                                        onPressed: (){
                                          _activateApp(context);
                                        },
                                        child: Row(

                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.only(right: 8.0),
                                                child: Icon(LineIcons.check,
                                                  color: Colors.white,
                                                ),),
                                              Text('Log In',
                                                  style: TextStyle(
                                                    fontFamily: 'Gilroy',fontWeight: FontWeight.bold, 
                                                    fontSize: 18.0, color: Colors.white
                                                  ),
                                              )
                                          ],)
                                    )
                                    
                                  ),
              SizedBox(height: 20,),
            _divider(),
            SizedBox(height: 10),
            _signupButton(context)
          ],)
        ),
      ),
        )
        )
    );
  }
}