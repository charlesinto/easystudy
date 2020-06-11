import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/model/user.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:toast/toast.dart';

class Profile extends StatefulWidget{
    @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String _firstName = "Charles";
  String _lastName = "Onuorah";
  String _phoneNumber ="08163113450";
  String _emailAddress = "charles.onuorah@yahoo.com";
  String _initals = "" ;
  String _class = "";
  String _admissionNumber = "";
  String _type = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _initals = _firstName.substring(0,1).toUpperCase() +" "+ _lastName.substring(0,1).toUpperCase();
  }
  _saveProfile() async{
    _formkey.currentState.save();
    print(_firstName);
    if(_firstName.isEmpty || _lastName.isEmpty|| _emailAddress.isEmpty|| _phoneNumber.isEmpty){
      return Toast.show("Some erros were encountered, incomplete profile", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    }
     SharedPreferences _prefs = await SharedPreferences.getInstance();
    var _pin = json.decode(_prefs.getString('user'))['schoolCode'];
    List<User> student = await App.getUserClass( _pin, _admissionNumber);
    if(student.length > 0){
      var data = {
        "email": _emailAddress,
        "phoneNumber": _phoneNumber,
        "firstName": _firstName,
        "lastName": _lastName,
        "type": "student",
        "admissionNumber": _admissionNumber
      };
      var user = _firstName + " " + _lastName;
      var uid = (await FirebaseAuth.instance.currentUser()).uid;
      var documents = await Firestore.instance.collection('/users/$_pin/activated users').where('uid', isEqualTo: uid).getDocuments();
      await Firestore.instance.document('/users/$_pin/activated users/${documents.documents[0].documentID}').updateData(data);
      _prefs.setString('user', json.encode('userData'));
      var studentData = json.decode(_prefs.getString('student'));
      studentData['class'] = student[0].userClass;
      _prefs.setString('student', json.encode(studentData));
      StoreProvider.of<AppState>(context).dispatch(LoggedInUser(user));
      }else{
        var data = {
        "email": _emailAddress,
        "phoneNumber": _phoneNumber,
        "firstName": _firstName,
        "lastName": _lastName,
        "type": "student",
      };
      var user = _firstName + " " + _lastName;
        var uid = (await FirebaseAuth.instance.currentUser()).uid;
        var documents = await Firestore.instance.collection('/users/$_pin/activated users').where('uid', isEqualTo: uid).getDocuments();
        await Firestore.instance.document('/users/$_pin/activated users/${documents.documents[0].documentID}').updateData(data);
        
        StoreProvider.of<AppState>(context).dispatch(LoggedInUser(user));
        _prefs.setString('user', json.encode('userData'));
      }
      Toast.show("Profile Updated Successfully", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      setState(() {
         _initals = _firstName.substring(0,1).toUpperCase() +" "+ _lastName.substring(0,1).toUpperCase();
      });
    }
  
  Future<Map<String, dynamic>> getUserProfile() async{
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> userInfo = json.decode(_prefs.getString('user'));
      String _firstName = userInfo['firstName'];
      String _lastName = userInfo['lastName'];
      
      userInfo['class'] = json.decode(_prefs.getString('student'))['class'].toUpperCase();
      _initals = _firstName.substring(0,1).toUpperCase() +" "+ _lastName.substring(0,1).toUpperCase();
      _firstName = userInfo['firstName'];
      _lastName = userInfo['lastName'];
      _emailAddress = userInfo['email'];
      _admissionNumber = userInfo['admissionNumber'];
      _phoneNumber = userInfo['phoneNumber'];
      return userInfo;
  }
  Future<String> getInitials() async{
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> userInfo = json.decode(_prefs.getString('user'));
      String _firstName = userInfo['firstName'];
      String _lastName = userInfo['lastName'];
      String _initials = _firstName.substring(0,1).toUpperCase() +" "+ _lastName.substring(0,1).toUpperCase();
      _type = json.decode(_prefs.getString('user'))['type'];
      return _initials;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body:StoreConnector<AppState, AppState>(
        builder: (context, state) {
          return GestureDetector(
                onTap: (){ FocusScope.of(context).requestFocus(FocusNode());},
                child: SingleChildScrollView(
                            child: Column(
                              children:<Widget>[
                                    Container(
                                        // color: Colors.greenAccent,
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                                        child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Card(
                                                      elevation: 6.0,
                                                      shape: CircleBorder(),
                                                      child: Container(
                                                        width: 200.0,
                                                        height: 200.0,
                                                        decoration: new BoxDecoration(
                                                          // color: Colors.orange,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors.white60,
                                                          child: FutureBuilder(
                                                            future: getInitials(),
                                                            builder: (BuildContext context,AsyncSnapshot snapshot){
                                                                if(snapshot.connectionState == ConnectionState.done){
                                                                  if(snapshot.hasData){
                                                                    return Text(snapshot.data,
                                                                            style: TextStyle(
                                                                              color: Colors.black, fontFamily: 'Gilroy', fontWeight: FontWeight.bold, 
                                                                              fontSize: 60
                                                                            ),
                                                                          );
                                                                  }
                                                                  return Container();
                                                                }
                                                                return Container();
                                                            })
                                                        ),
                                                      ),
                                                    ),
                                                      Card(
                                                        elevation: 4.0,
                                                        shape: CircleBorder(),
                                                        child: Container(
                                                        child: IconButton(
                                                          iconSize: 32.0,
                                                          icon: Icon(Icons.camera_alt) ,
                                                        onPressed: (){
                                                          print('change photo requested');
                                                        }),
                                                      ),
                                                      )
                                                ],
                                                )
                                      ),
                                    FutureBuilder(
                                      future: getUserProfile(),
                                      builder: (BuildContext context, AsyncSnapshot snapshot){
                                          if(snapshot.connectionState == ConnectionState.done){
                                            if(snapshot.hasData){
                                              return Form(
                                                    key: _formkey,
                                                    child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0) ,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Card(
                                                    child: TextFormField(
                                                      initialValue: snapshot.data['firstName'].toString(),
                                                      decoration: InputDecoration(labelText: 'First Name',
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                      onSaved: (value){
                                                        _firstName = value;
                                                      },
                                                    ) ,
                                                  ),
                                                  Card(
                                                    child: TextFormField(
                                                      initialValue: snapshot.data['lastName'],
                                                      decoration: InputDecoration(labelText: 'Last Name',
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                        onSaved: (value){
                                                        _lastName = value;
                                                      }
                                                      ) ,
                                                  ),
                                                  Card(
                                                    child: TextFormField(
                                                        initialValue: snapshot.data['phoneNumber'],
                                                        keyboardType: TextInputType.number,
                                                        decoration: InputDecoration(labelText: 'Phone Number', 
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                        onSaved: (value){
                                                        _phoneNumber = value;
                                                      }
                                                    ) ,
                                                  ),
                                                snapshot.data['type'] == 'student' ?  Card(
                                                    child: TextFormField(
                                                      readOnly: true,
                                                        initialValue: snapshot.data['class'],
                                                        keyboardType: TextInputType.number,
                                                        decoration: InputDecoration(labelText: 'Class', 
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                        onSaved: (value){
                                                        _class = value;
                                                      }
                                                    ) ,
                                                  ) : Container(),
                                                  snapshot.data['type'] == 'student' ?  Card(
                                                    child: TextFormField(
                                                        initialValue: snapshot.data['admissionNumber'],
                                                        keyboardType: TextInputType.number,
                                                        decoration: InputDecoration(labelText: 'Admission Number', 
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                        onSaved: (value){
                                                        _admissionNumber = value;
                                                      }
                                                    ) ,
                                                  ) : Container(),
                                                  Card(
                                                    child: TextFormField(
                                                      readOnly: true,
                                                      initialValue: snapshot.data['email'],
                                                      keyboardType: TextInputType.emailAddress,
                                                      decoration: InputDecoration(labelText: 'Email Address',
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                      onSaved: (value){
                                                        _emailAddress = value;
                                                      }
                                                    ) ,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(vertical: 20.0),
                                                    child: RaisedButton(
                                                      color: Colors.greenAccent[700],
                                                      onPressed: (){
                                                        _saveProfile();
                                                      },
                                                      child: Row(

                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets.only(right: 8.0),
                                                              child: Icon(Icons.save,
                                                                color: Colors.white,
                                                              ),),
                                                            Text('Update Profile',
                                                                style: TextStyle(
                                                                  fontFamily: 'Gilroy',fontWeight: FontWeight.bold, 
                                                                  fontSize: 18.0, color: Colors.white
                                                                ),
                                                            )
                                                        ],)
                                                  )
                                                  
                                                )
                                                      ]
                                                    ),
                                                  
                                                )
                                              );
                                            }
                                            return Form(
                                                  key: _formkey,
                                                  child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0) ,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Card(
                                                  child: TextFormField(
                                                    initialValue: '',
                                                    decoration: InputDecoration(labelText: 'First Name',
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                    onSaved: (value){
                                                      _firstName = value;
                                                    },
                                                  ) ,
                                                ),
                                                Card(
                                                  child: TextFormField(
                                                    initialValue: '',
                                                    decoration: InputDecoration(labelText: 'Last Name',
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                      onSaved: (value){
                                                      _lastName = value;
                                                    }
                                                    ) ,
                                                ),
                                                Card(
                                                  child: TextFormField(
                                                      initialValue: '',
                                                      keyboardType: TextInputType.number,
                                                      decoration: InputDecoration(labelText: 'Phone Number', 
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                      onSaved: (value){
                                                      _phoneNumber = value;
                                                    }
                                                  ) ,
                                                ),
                                                Card(
                                                  child: TextFormField(
                                                    initialValue: '',
                                                    keyboardType: TextInputType.emailAddress,
                                                    decoration: InputDecoration(labelText: 'Email Address',
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                                    onSaved: (value){
                                                      _emailAddress = value;
                                                    }
                                                  ) ,
                                                ),
                                                _type == 'student' ?
                                                Container(
                                                  margin: EdgeInsets.symmetric(vertical: 20.0),
                                                  child: RaisedButton(
                                                    color: Colors.greenAccent[700],
                                                    onPressed: (){
                                                      _saveProfile();
                                                    },
                                                    child: Row(

                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                          Container(
                                                            padding: EdgeInsets.only(right: 8.0),
                                                            child: Icon(Icons.save,
                                                              color: Colors.white,
                                                            ),),
                                                          Text('Update Profile',
                                                              style: TextStyle(
                                                                fontFamily: 'Gilroy',fontWeight: FontWeight.bold, 
                                                                fontSize: 18.0, color: Colors.white
                                                              ),
                                                          )
                                                      ],)
                                                )
                                                
                                              ) : Container()
                                                    ]
                                                  ),
                                                
                                              )
                                                );
                                          }
                                          print('not here 2');
                                          return Container();
                                          // return Form(
                                          //         key: _formkey,
                                          //         child: Container(
                                          //         padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0) ,
                                          //         child: Column(
                                          //           children: <Widget>[
                                          //             Card(
                                          //         child: TextFormField(
                                          //           initialValue: '',
                                          //           decoration: InputDecoration(labelText: 'First Name',
                                          //             contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                          //           onSaved: (value){
                                          //             _firstName = value;
                                          //           },
                                          //         ) ,
                                          //       ),
                                          //       Card(
                                          //         child: TextFormField(
                                          //           initialValue: '',
                                          //           decoration: InputDecoration(labelText: 'Last Name',
                                          //           contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                          //             onSaved: (value){
                                          //             _lastName = value;
                                          //           }
                                          //           ) ,
                                          //       ),
                                          //       Card(
                                          //         child: TextFormField(
                                          //             initialValue: '',
                                          //             keyboardType: TextInputType.number,
                                          //             decoration: InputDecoration(labelText: 'Phone Number', 
                                          //             contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                          //             onSaved: (value){
                                          //             _phoneNumber = value;
                                          //           }
                                          //         ) ,
                                          //       ),
                                          //       Card(
                                          //         child: TextFormField(
                                          //           initialValue: '',
                                          //           keyboardType: TextInputType.emailAddress,
                                          //           decoration: InputDecoration(labelText: 'Email Address',
                                          //           contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                          //           onSaved: (value){
                                          //             _emailAddress = value;
                                          //           }
                                          //         ) ,
                                          //       ),
                                          //       Container(
                                          //         margin: EdgeInsets.symmetric(vertical: 20.0),
                                          //         child: RaisedButton(
                                          //           color: Colors.greenAccent[700],
                                          //           onPressed: (){
                                          //             _saveProfile();
                                          //           },
                                          //           child: Row(

                                          //             mainAxisAlignment: MainAxisAlignment.center,
                                          //             children: <Widget>[
                                          //                 Container(
                                          //                   padding: EdgeInsets.only(right: 8.0),
                                          //                   child: Icon(Icons.save,
                                          //                     color: Colors.white,
                                          //                   ),),
                                          //                 Text('Update Profile',
                                          //                     style: TextStyle(
                                          //                       fontFamily: 'Gilroy',fontWeight: FontWeight.bold, 
                                          //                       fontSize: 18.0, color: Colors.white
                                          //                     ),
                                          //                 )
                                          //             ],)
                                          //       )
                                                
                                          //     )
                                          //           ]
                                          //         ),
                                                
                                          //     )
                                          //       );
                                      }
                                    )
                                    
                                    
                              ]
                            )
                            )
                );
        },
        converter: (store) => store.state ,
        ) 
    );
     
    
  }
}

/*


Container(
                color: Colors.greenAccent,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: 120.0,
                                height: 120.0,
                                decoration: new BoxDecoration(
                                  // color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white60,
                                  child: Text('AH',
                                    style: TextStyle(
                                      color: Colors.white, fontFamily: 'Gilroy', fontWeight: FontWeight.bold, 
                                      fontSize: 26.0
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  iconSize: 32.0,
                                  icon: Icon(LineIcons.camera_retro) ,
                                 onPressed: (){
                                   print('change photo requested');
                                 }),
                              )
                        ],
                        )
              )
*/