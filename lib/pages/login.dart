import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:line_icons/line_icons.dart';
import 'package:studyapp/model/user.dart';
import 'package:studyapp/pages/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';


class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}


class _LoginState extends State<Login>{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  
  String appName = "";
  String _pin = "";
  String _lastName = "";
  String _firstName = "";
  String _phoneNumber = "";
  String _emailAddress = "";
  String errorMessage ="";
  String _admissionNumber = "";
  String _dropdownValue = "";
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    
    super.initState();
    appName = 'Easy StudyPS';
    // _firestore.settings({
    //   sslEnabled: false,
    //   persistenceEnabled: false,
    // });
  }
  _activateApp(context) async{
    print('hello o');
    setState(() {
      errorMessage = "";
    });
    _formKey.currentState.save();
    if(_emailAddress.isEmpty || _pin.isEmpty 
      || _firstName.isEmpty || _lastName.isEmpty || _admissionNumber.isEmpty){
      return setState((){
          errorMessage = "Email, School Activation,Admission Number, Fist Name and Last Name pin are required";
      });
    }
    
    // print(student[0].admissionNumber);
    // print(json.encode(student[0]));
    // call the api to activat school
    // get the school domain name and store as global variable
    // appDomain = 'http://digitalschool.easystudy.com.ng/';
    // fetch all secondary school
    // print('here 00000');
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
    // _fetchPrimarySchoolSubject(context);
    // print('_pin:  '+ _pin);
    // Navigator.of(context).pushReplacementNamed('/app');
    getSchoolDomain(_pin, context);
    
    // call the api to get school domain

    // Navigator.of(context).pushReplacementNamed('/app');
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
              
              // check if admission Number exists


              var isAdmissionNumberValid =  await _verifyAdmissionNumber();
              
              if(isAdmissionNumberValid){
                await _fetchPrimarySchoolSubject(context);
                await _getJuniorSchoolData(context);
                await _getSeniorSchoolSubject(context);
                return  checkIfEmailNotExistThenSignUpUser(context, schoolCode);
              }else{
                Navigator.pop(context);
                return setState((){
                      errorMessage = "Admission Number not registered with school, please contact admin";
                });
              }
                
              
                
              
           }
           setState((){
                      errorMessage = "School Activation Pin is Invalid";
            });
           
        })
        .catchError((onError){
          
          Navigator.of(context).pop();
          setState((){
                      errorMessage = "Some errors were encountered, please try again";
            });
          print('error: '+ onError.toString());
        });
      
  }

  Future<bool> _verifyAdmissionNumber() async{
    var docSnapshot = await  Firestore.instance.collection('students').where('schoolCode', isEqualTo: _pin).where('admissionNumber', isEqualTo: _admissionNumber).getDocuments();
    if(docSnapshot.documents.isNotEmpty){
      return true;
    }
    return false;
  }
  
   checkIfEmailNotExistThenSignUpUser(BuildContext context,String schoolCode){
     Firestore.instance.collection('users').document(_pin)
      .collection('activated users').where('email',  isEqualTo: _emailAddress)
      .getDocuments()
      .then((doc) {
          if(doc.documents.length > 0){
            Navigator.of(context).pop();
            return setState((){
                errorMessage = "Email Address already exists";
            });
          }
         return signUpUser(_emailAddress.trim(), 'bacon34567890', schoolCode.trim(), {
                          "email": _emailAddress,
                          "phoneNumber": _phoneNumber,
                          "firstName": _firstName,
                          "lastName": _lastName,
                          "schoolCode":schoolCode,
                          "type": "student",
                          "admissionNumber": _admissionNumber
                        }, context);
      })
      .catchError((onError){
        Navigator.of(context).pop();
        setState((){
            errorMessage = "Some error encountered, please try again";
        });
      });
  }

   signUpUser(String email, String password,String schoolActivationPin, 
      Map<String, dynamic> userData, BuildContext context) async{
      try{
        print(email);
        print(password);
        print('signing up user');
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        List<User> studentClass = await App.getUserClass( schoolActivationPin, _admissionNumber.trim());
          
          if(studentClass.length <= 0){
            Navigator.of(context).pop();
            return  setState((){
                errorMessage = "No student account found with the admission number, please contact admin";
            });
          }

          App.subscribeToNotiifcation(studentClass[0].schoolCode, studentClass[0].userClass);
            prefs.setString('student', json.encode(studentClass[0]));
        
        var phoneNumber = _phoneNumber.trim(); 
        AuthResult result = await _firebaseAuth
                                .createUserWithEmailAndPassword(email: email, password: phoneNumber);
          print(result);
          // await Firestore.instance.document('/users/'+email).setData(userData);
          var uid =  ( await _firebaseAuth.currentUser()).uid;
          userData['uid'] = uid;
          userData['class'] = studentClass[0].userClass;
          await Firestore.instance.collection('users')
                  .add(userData);
          
          prefs.setString('user', json.encode(userData));
          
          print('user fond: '+ prefs.getString('user'));
          var user = json.decode(prefs.getString('user'))['firstName'] + " " + json.decode(prefs.getString('user'))['lastName'];
          StoreProvider.of<AppState>(context).dispatch(LoggedInUser(user));
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/app');
      }catch(error){
        Navigator.of(context).pop();
        print(error);
        // print('error message: '+ error.message);
        if(error.code == 'auth/email-already-exists'){
          return setState(() {
            errorMessage = "Email Already exists";
          });
        }
        if(error.code == 'auth/weak-password'){
          return setState(() {
            errorMessage = "Phone Number format is invalid, phone number should have 11 digits";
          });
        }
         
         return setState((){
                errorMessage = "Sorry, could not perform registration";
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
      // Navigator.of(context).pop();
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
      // Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load junior secondary school data";
      });
      // throw Exception('Failed to load album');
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
      // Navigator.of(context).pop();
      setState(() {
        errorMessage = "failed to load senior secondary school data";
      });
      // throw Exception('Failed to load album');
    }
  }
  
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
          Text('Are you a returning Student?'),
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
                Navigator.of(context).pushNamed('/studentSignIn');
              },
              child: Container(
                decoration: BoxDecoration(
                  // boxShadow: <BoxShadow>[
                  //   BoxShadow(
                  //       color: Colors.grey.shade200,
                  //       offset: Offset(2, 4),
                  //       blurRadius: 5,
                  //       spreadRadius: 2)
                  // ]
                ),
                child: Text(
                'Log In',
                style: TextStyle(fontSize: 20, color: Colors.black),
              )
              ),
            )
          );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final double deviceHeight = MediaQuery.of(context).size.height;
    return StoreConnector<AppState,AppState>(converter: (store) => store.state,
      builder: (context, state) {
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
                    child: Center(child: Text(appName,
                      style: TextStyle(
                        fontFamily:'Gilroy', fontSize: 26.0, fontWeight: FontWeight.bold
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
                        // Card(
                        //   child: DropdownButton<String>(
                        //     value: _dropdownValue,
                        //     // icon: Icon(Icons.arrow_downward),
                        //     // iconSize: 24,
                        //     // elevation: 16,
                        //     style: TextStyle(
                        //       // color: Colors.deepPurple
                              
                        //     ),
                        //     underline: Container(
                        //       height: 2,
                        //       color: Colors.deepPurpleAccent,
                        //     ),
                        //     onChanged: (String newValue) {
                        //       setState(() {
                        //         _dropdownValue = newValue;
                        //       });
                        //     },
                        //     items: <String>['Student', 'Teacher']
                        //       .map<DropdownMenuItem<String>>((String value) {
                        //         return DropdownMenuItem<String>(
                        //           value: value,
                        //           child: Text(value),
                        //         );
                        //       })
                        //       .toList(),
                        //   )
                        // ),
                        Card(
                          child: TextFormField(
                            initialValue: _admissionNumber,
                            decoration: InputDecoration(labelText: 'Admission Number',
                              prefixIcon: Icon(Icons.school),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              print('values 000'+  value);
                              _admissionNumber = value;
                            },
                          ) ,
                        ),
                        Card(
                          child: TextFormField(
                            initialValue: _pin,
                            decoration: InputDecoration(labelText: 'First Name',
                              prefixIcon: Icon(Icons.person),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _firstName = value;
                            },
                          ) ,
                        ),
                        Card(
                          child: TextFormField(
                            initialValue: _pin,
                            decoration: InputDecoration(labelText: 'Last Name',
                              prefixIcon: Icon(Icons.person),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _lastName = value;
                            },
                          ) ,
                        ),
                        Card(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: _pin,
                            decoration: InputDecoration(labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _phoneNumber = value;
                            },
                          ) ,
                        ),
                        Card(
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            initialValue: _pin,
                            decoration: InputDecoration(labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                            onSaved: (value){
                              _emailAddress = value;
                            },
                          ) ,
                        ),
                        SizedBox(height: 10.0,),
                        errorMessage.isNotEmpty ? Center(child: 
                        Text(errorMessage,
                          style: TextStyle(color:Colors.red, fontFamily: 'Gilroy'),
                        ),) : Text(''),
                        SizedBox(height: 10.0,),
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
                                              Text('Activate',
                                                  style: TextStyle(
                                                    fontFamily: 'Gilroy',fontWeight: FontWeight.bold, 
                                                    fontSize: 18.0, color: Colors.white
                                                  ),
                                              )
                                          ],)
                                    )
                                    
                                  ),
                        _divider(),
                        SizedBox(height: 10.0,),
                        _signupButton(context)
                    ]
                  ))
                ]
              )
            ,)
        )
          )
          ,)
        );
      },
    );
  }
}