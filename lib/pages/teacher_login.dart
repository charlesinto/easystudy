import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/model/app_state.dart';

class TeacherLogin extends StatefulWidget{
  @override
  _TeacherLoginState createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
  String appName = "";
  String _pin = "";
  String _password = "";
  String _emailAddress = "";
  String errorMessage ="";
  bool isLoading = false;
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _activateApp(context) async{
    setState(() {
      errorMessage = "";
    });
    _formKey.currentState.save();
    if(_pin.isEmpty){
      return setState(() {
                errorMessage = "Please provide your school activation pin";
              });
    }
    if(_emailAddress.isEmpty || _password.isEmpty){
      return setState(() {
              errorMessage = "Email Address and Password is required";
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
      bool isSchoolPinValid = await confirmSchoolPin(_pin.trim(), _emailAddress);
      if(isSchoolPinValid){
        verifySchoolLicenceStatusAndSignInUser(context, _pin.trim(), _emailAddress.trim(), _password.trim());
      }else{
        Navigator.pop(context);
      }

  }
  verifySchoolLicenceStatusAndSignInUser(BuildContext context, String schoolpin,String email,String password) async{
      try{
        String pin = schoolpin.trim();
        print(pin);
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        DocumentSnapshot doc = await _firestore.document("/partners/$pin").get();
        print(doc.data);
        _prefs.setString('appDomain', doc.data['appDomain']);
        print(doc.data);//seconds 
        // DateTime date = new DateTime.fromMillisecondsSinceEpoch(doc.data['licenseEndDate'].toDate());
        DateTime licenseEndDate = doc.data['licenseEndDate'].toDate();
        DateTime today = DateTime.now();
        int diffDays = licenseEndDate.difference(today).inDays;
        print(1);
        if(diffDays > 0){
         await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
         QuerySnapshot docs = await _firestore.collection('teachers').where('email', isEqualTo: email)
                .where('partnerCode', isEqualTo: pin).getDocuments();
          print(2);
          var userData = {"email": email, "phoneNumber": docs.documents[0].data['phoneNumber'],
            "firstName": docs.documents[0].data['firstName'],"schoolCode": pin,
            "lastName": docs.documents[0].data['lastName'],
             "type": 'teacher'};
          print(3);
          _prefs.setString('user', json.encode(userData));
          var user = json.decode(_prefs.getString('user'))['firstName'] + " " + json.decode(_prefs.getString('user'))['lastName'];
          print(docs.documents[0].data['classes'].toString());
          docs.documents[0].data['classes'].forEach(( teacherClass){
              App.subscribeToNotiifcation(pin, teacherClass['class']);
          });
          print(4);
          StoreProvider.of<AppState>(context).dispatch(LoggedInUser(user));
          Navigator.pop(context);
          Navigator.of(context).pushReplacementNamed('/app');
        }else{
          setState(() {
            errorMessage = 'Licences has expired, please purchase a new licence or contact admin';
          });
          return Navigator.pop(context);
        }
        
      }catch(error){
        print(password);
        if(error.code == 'ERROR_WRONG_PASSWORD'){
          Navigator.pop(context);
          return setState(() {
            errorMessage ="Wrong or invalid password, please contact admin";
          });
          
        }
        print(error.code);
        Navigator.pop(context);
      }
  }
  Future<bool> confirmSchoolPin(String schoolPin,String emailAddress) async{
    try{
      print('verifying school');
     QuerySnapshot doc = await  _firestore.collection('teachers')
                          .where('partnerCode', isEqualTo: schoolPin)
                          .where('email', isEqualTo: emailAddress)
                          .getDocuments();
      print('verif school');
      if(doc.documents.isNotEmpty){
        print(' school');
        return true;
      }
      setState(() {
        errorMessage = 'School errors encountered verfying school, please contact your admin';
      });
      print('not school');
      return false;
    }catch(error){
      print('>>>>> ' +error);
      
      setState(() {
        errorMessage = 'School errors encountered verfying school, please contact your admin';
      });
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: GestureDetector(
            onTap: (){ FocusScope.of(context).requestFocus(FocusNode());},
            child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: Container(
            width: double.infinity,
            // height: deviceHeight,
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   fit: BoxFit.cover,
              //   image: AssetImage('assets/online.jpg'),
              // )
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Center(child: Text('Easy Study Login For Teachers',
                      style: TextStyle(
                        fontFamily:'Gilroy', fontSize: 20.0, fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                  ),)),
                  SizedBox(height: 40.0,),
                  Form(
                    key: _formKey,
                    child: Column(
                    children: <Widget>[
                         Card(
                          child: TextFormField(
                            initialValue: _pin,
                            decoration: InputDecoration(labelText: 'School Activation Pin',
                              prefixIcon: Icon(LineIcons.key),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              print('values 000'+  value);
                              _pin = value;
                            },
                          ) ,
                        ),
                        Card(
                          child: TextFormField(
                            initialValue: _emailAddress,
                            decoration: InputDecoration(labelText: 'Email Address',
                              prefixIcon: Icon(Icons.mail),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _emailAddress = value;
                            },
                          ) ,
                        ),
                        Card(
                          child: TextFormField(
                            initialValue: _password,
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Password',
                            
                              prefixIcon: Icon(Icons.lock),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _password = value;
                            },
                          ) ,
                        ),
                        SizedBox(height: 10.0,),
                        errorMessage.isNotEmpty ? Center(child: 
                        Text(errorMessage,
                          style: TextStyle(color:Colors.red, fontFamily: 'Gilroy'),
                        ),) : Text(''),
                        SizedBox(height: 20.0,),
                        Container(
                                      margin: EdgeInsets.symmetric(vertical: 20.0),
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
                                              Text('Activate',
                                                  style: TextStyle(
                                                    fontFamily: 'Gilroy',fontWeight: FontWeight.bold, 
                                                    fontSize: 18.0, color: Colors.white
                                                  ),
                                              )
                                          ],)
                                    )
                                    
                                  )
                    ]
                  ))
                ]
              )
            ,)
        )
          )
          ,),
    );
  }
}