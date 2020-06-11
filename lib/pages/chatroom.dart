  
import 'dart:convert';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:line_icons/line_icons.dart';
import 'package:studyapp/pages/home.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:bubble/bubble.dart';
import 'dart:core';


class ChatRoom extends StatefulWidget{
  String selectedRoom = '';
  String schoolCode = "";
  ChatRoom();
  ChatRoom.fromselectedRoom(this.selectedRoom, this.schoolCode);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _ChatRoomState();
  }
}

class _ChatRoomState extends State<ChatRoom>{
  final String user = 'Bukola Damola';
   String _message = '';
  String currentUser = '';
  String _notiMessage = "";
  String _notiTitle = "";
  String _notiTarget = "";
  SharedPreferences prefs;
  var userDetails;
  final TextEditingController _controller =  new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserDetails();
  }
  Future<Map<String, dynamic>> getCurrentUserDetails() async{
    prefs = await SharedPreferences.getInstance();
    userDetails = json.decode(prefs.getString('user'));
    return userDetails;
  }
  _sendMessage(String roomname,BuildContext context) async{
      if(_message.isNotEmpty){
        _controller.clear();
        await Firestore.instance.collection('chats').document(widget.schoolCode)
            .collection(roomname).add({
              'senderId': (await FirebaseAuth.instance.currentUser()).uid,
              'message': _message,
              'sender': userDetails['firstName'] + ' ' + userDetails['lastName'],
              'createdAt': new DateTime.now()
            });
        
        // Navigator.of(context).pop();
      }
      
  }

  Future<String> getCurrentUser() async{
      if(currentUser.isEmpty){
         currentUser = (await FirebaseAuth.instance.currentUser()).uid;
      }
      return currentUser;
  }
   Widget renderNotificationForm(BuildContext context, QuerySnapshot teacherDoc, ta, intialValue){
    
     List<dynamic> classes = teacherDoc.documents.first['classes'];
     double deviceHeight = MediaQuery.of(context).size.height;
     return StatefulBuilder(
       builder: (context, sta){
         return GestureDetector(
           onTap:(){
             FocusScope.of(context).requestFocus(FocusNode());
           },
           child: SingleChildScrollView(
              child: Container(
              height: deviceHeight * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text('Send Notification',
                      style: TextStyle(color: Colors.black, fontFamily: 'Gilroy', fontWeight: FontWeight.w800, fontSize: 18),
                    )
                  ),
                    Form(
                      key: _formKey,
                      child: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    initialValue: '',
                                    decoration: InputDecoration(labelText: 'Notification Title',
                                      // prefixIcon: Icon(Icons.title),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                      onSaved: (value){
                                        _notiTitle = value;
                                    },
                                  )
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: TextFormField(

                                    keyboardType: TextInputType.text,
                                    initialValue: '',
                                    
                                    decoration: InputDecoration(labelText: 'Message',
                                      // prefixIcon: Icon(Icons.message),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
                                      onSaved: (value){
                                          _notiMessage = value;
                                      },
                                  )
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.0,),
                                    child: Text('Broadcast message To: ',
                                    style: TextStyle(fontWeight: FontWeight.w800),  
                                  ),),
                                  Container(
                                    child: DropdownButton<dynamic>(
                                          hint: Text('Choose'),
                                          value: intialValue,
                                          items: classes.map((dynamic value) {
                                            return new DropdownMenuItem(
                                              value: value['class'],
                                              child: new Text(value['class']),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            print(value);
                                            
                                            sta(() {
                                              intialValue = value;
                                              _notiTarget = value;
                                            });
                                          },
                                        ),
                                  )
                            ],
                          ) ,
                          )
                      ),
                    )
                ],)
            )
            )
         );
       },);
  }
  submitNotification(BuildContext context) async{
    _formKey.currentState.save();
    print(_notiTarget + _notiMessage + _notiTitle);
    if(_notiTitle.isEmpty || _notiMessage.isEmpty || _notiTarget.isEmpty){
      return showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
          content: Text('Could not submit, Notification Message, Title and Class is required'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Ok') ,)
            ]
           ,);
        }
      );
    }
    String uid = (await FirebaseAuth.instance.currentUser()).uid;
    await Firestore.instance.collection('notifications').add({
      "message": _notiMessage,
      "title": _notiTitle,
      "type": "teacherNotification",
      "target": _notiTarget,
      "createdBy": uid,
      "createdAt": DateTime.now()
    });
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
          content: Text('Notification Broadcasted successfully'),
            actions: <Widget>[
              FlatButton(
                onPressed: ()  {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Ok') ,)
            ]
           ,);
        }
      );
  }
  Widget linkifyText(String text){
    const String urlPattern = r'https?:/\/\\S+';
    const String emailPattern = r'\S+@\S+';
    const String phonePattern = r'[\d-]{9,}';
    // final RegExp linkRegExp = RegExp('($urlPattern)|($emailPattern)|($phonePattern)', caseSensitive: false);


    print('true t');
    if(text.contains(RegExp(emailPattern, caseSensitive: false))){
      print('is link');
      return GestureDetector(
        onTap: () async{
          if(await canLaunch(text)){
            await launch(text);
          }else{
            throw 'Could not luanch url';
          }
        },
        child: Text(text,
          style: TextStyle(
            color: Colors.greenAccent,
            decoration: TextDecoration.underline
          ),
        ),
      );
    }
    if(text.contains(RegExp(urlPattern, caseSensitive: false))){
      return GestureDetector(
        onTap: () async{
          if(await canLaunch("mailto:$text")){
            await launch("mailto:$text");
          }else{
            throw 'Could not luanch url';
          }
        },
        child: Text(text,
          style: TextStyle(
            color: Colors.greenAccent,
            decoration: TextDecoration.underline
          ),
        ),
      );
    }
    if(text.contains(RegExp(phonePattern, caseSensitive: false))){
      return GestureDetector(
        onTap: () async{
          if(await canLaunch("tel:$text")){
            await launch("tel:$text");
          }else{
            throw 'Could not luanch url';
          }
        },
        child: Text(text,
          style: TextStyle(
            color: Colors.greenAccent,
            decoration: TextDecoration.underline
          ),
        ),
      );
    }

    return Linkify(
      onOpen: _onOpen,
      text: text,
      style: TextStyle(fontSize: 16),
    );
  
  }
  Future<void> _onOpen(LinkableElement link) async {
    if(await canLaunch(link.url)){
    final bool nativeAppLaunchSucceeded = await launch(
                                            link.url,
                                            forceSafariVC: false,
                                            forceWebView: false,
                                            universalLinksOnly: true
                                          );
      if(!nativeAppLaunchSucceeded){
          launch(
            link.url,
            forceSafariVC: true,
            forceWebView: true,
          );
              return ;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double px = 1 / pixelRatio;
    BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
    );
    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
    );
    // TODO: implement build
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: StreamBuilder(
      stream: Firestore.instance.collection('chats').document('${widget.schoolCode}').collection(widget.selectedRoom)
                .orderBy('createdAt').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.connectionState != ConnectionState.waiting){
             if(!snapshot.hasError){
               
               return StoreConnector<AppState, AppState>(
                        converter:(store) => store.state,
                        builder: (context, state){
                          return Scaffold(
                              appBar:  AppBar(
                                    title: Text(state.selectedRoom['roomname']),
                                    backgroundColor: Colors.blueAccent,
                                    actions: <Widget>[
                                              FutureBuilder(
                                                future: getCurrentUserDetails(),
                                                builder: (BuildContext context, snapshot){
                                                   if(snapshot.connectionState == ConnectionState.done){
                                                     if(snapshot.hasError){
                                                       return Container();
                                                     }
                                                     return IconButton(
                                                          icon: Icon(
                                                            Icons.video_call,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () async {
                                                            // do something  
                                                            print(snapshot.data['type']);
                                                            if(snapshot.data['type'] == 'teacher'){
                                                               bool canlaunch = await canLaunch('https://skype.com');
                                                            if(canlaunch){
                                                              final bool nativeAppLaunchSucceeded = await launch(
                                                                                                      'https://skype.com',
                                                                                                      forceSafariVC: false,
                                                                                                      forceWebView: false,
                                                                                                      universalLinksOnly: true
                                                                                                    );
                                                                if(!nativeAppLaunchSucceeded){
                                                                    launch(
                                                                      'https://skype.com',
                                                                      forceSafariVC: true,
                                                                      forceWebView: true,
                                                                    );
                                                                        return ;
                                                                }
                                                            }
                                                              // showDialog(
                                                              //   context: context,
                                                              //   builder: (BuildContext context){
                                                              //     return AlertDialog(
                                                              //         content: Text('Skype not installed, please install to continue'),
                                                              //         actions: <Widget>[
                                                              //           FlatButton(
                                                              //             child: Text('Ok'),
                                                              //             onPressed: () {
                                                              //               Navigator.of(context).pop(false);
                                                              //             },
                                                              //           ),
                                                              //         ],
                                                              //       );
                                                              //   }
                                                              // );
                                                            print('pressed');
                                                            return;
                                                            }else{
                                                              return showDialog(
                                                                context: context,
                                                                builder: (BuildContext context){
                                                                  return AlertDialog(
                                                                        content: Text('Action not permitted, only a teacher can start video session'),
                                                                        actions: <Widget>[
                                                                          FlatButton(
                                                                            child: Text('Ok'),
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop(false);
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                }
                                                              );
                                                            }
                                                          },
                                                        );
                                                   }
                                                   return Container();
                                                },
                                              )
                                              , FutureBuilder(
                                                future: getCurrentUserDetails(),
                                                builder: (BuildContext context, AsyncSnapshot snapshot){
                                                    if(snapshot.connectionState == ConnectionState.done){
                                                      if(snapshot.hasError){
                                                        return Container();
                                                      }
                                                      if(snapshot.data['type'] == 'teacher'){
                                                          return IconButton(
                                                            icon: Icon(
                                                              Icons.mic,
                                                              color: Colors.white,
                                                            ), 
                                                          onPressed: () async{
                                                           QuerySnapshot doc = await Firestore.instance.collection('teachers')
                                                                .where('email', isEqualTo: snapshot.data['email'])
                                                                .where('partnerCode', isEqualTo: snapshot.data['schoolCode']).getDocuments();
                                                                String initialValue = doc.documents.first['classes'][0]['class'];
                                                              
                                                              return showDialog(
                                                                context: context,
                                                                builder: (BuildContext context){
                                                                  return StatefulBuilder(
                                                                    builder:(BuildContext context, setState){
                                                                        return AlertDialog(
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      color: Colors.red,
                                                                      child: Text('Cancel'),
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      
                                                                    ),
                                                                    RaisedButton(
                                                                      color: Colors.green,
                                                                      child: Text('Send',
                                                                        style: TextStyle(color: Colors.white) ,
                                                                      ),
                                                                      onPressed: () {
                                                                        submitNotification(context);
                                                                      },
                                                                    )
                                                                  ],
                                                                  content: renderNotificationForm(context, doc, setState, initialValue),
                                                                  );
                                                                    }
                                                                  ,);
                                                                }
                                                              );
                                                          });
                                                      }
                                                      return Container();
                                                    }
                                                    return Container();
                                                } ,)                                        
                                          ]
                                    ),
                              endDrawer: Drawer(
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
                                  child: Text(user,
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
                          
                        )  ,
                              body: Container(
                                width: double.infinity,
                                  height: deviceHeight,
                                  decoration: BoxDecoration(             
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/chatbg.jpeg'),
                                      )
                                  ),
                                child: Stack(
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                          Expanded(child: 
                                            ListView(
                                          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                                          physics: ScrollPhysics(), // to disable GridView's scrolling
                                          shrinkWrap: true,
                                          children: snapshot.data.documents.map((DocumentSnapshot document) {
                                            return FutureBuilder(
                                              future: getCurrentUser(),
                                              builder: (BuildContext context,AsyncSnapshot snapshot){
                                                if(snapshot.connectionState == ConnectionState.done){
                                                  if(snapshot.hasData){
                                                    if(snapshot.data == document['senderId']){
                                                      return Bubble(
                                                              style: styleMe,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                
                                                                SizedBox(height: 8.0,),
                                                                linkifyText(document['message'])
                                                              ]),
                                                            );
                                                    }
                                                    return Bubble(
                                                              style: styleSomebody,
                                                              child: Container(child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Container(
                                                                    padding: EdgeInsets.only(top: 4.0),
                                                                    child: Text(document['sender'],
                                                                      style: TextStyle(
                                                                        color: Colors.blueAccent,
                                                                        fontSize: 16,
                                                                        decoration: TextDecoration.underline
                                                                      ),
                                                                    ) ,),
                                                                    SizedBox(height: 8.0,),
                                                                    // Text(document['message'])
                                                                    linkifyText(document['message'])
                                                                ],
                                                              ),),
                                                            );
                                                  }
                                                  return Container();
                                                }
                                                return Container();
                                              },);
                                          }).toList(),
                                        
                                        )
                                          ,
                                        ),
                                      Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300], width: 1.0),
                                        color: Colors.white
                                      ),
                                      height: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                        child: TextField(
                                          controller: _controller,
                                          maxLines: 20,
                                          // controller: '',
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.send),
                                              onPressed: () {
                                                FocusScope.of(context).requestFocus(FocusNode());
                                                _sendMessage(state.selectedRoom['roomname'], context);
                                              },
                                            ),
                                            border: InputBorder.none,
                                            hintText: "enter your message",
                                          ),
                                          onChanged: (text) {
                                            _message = text;
                                            // print("First text field: $text");
                                          }
                                        ),
                                      ),
                                      )
                                    ],)
                                    
                                    ],)
                              )
                              ,
                              
                          );
                        },
                      );
             }
             
            return StoreConnector<AppState, AppState>(
                    converter:(store) => store.state,
                    builder: (context, state){
                      return Scaffold(
                          appBar:  AppBar(
                                title: Text(state.selectedRoom['roomname']),
                                backgroundColor: Colors.blueAccent,
                                actions: <Widget>[
                                          IconButton(
                                          icon: Icon(
                                            Icons.video_call,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async{
                                            // do something
                                            
                                            // if(){

                                            // }
                                            print('pressed');
                                          },
                                        )
                                      ]
                                ),
                          endDrawer: Drawer(
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
                              child: Text(user,
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
                      
                    )  ,
                          body: Container(
                            width: double.infinity,
                              height: deviceHeight,
                              decoration: BoxDecoration(             
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/chatbg.jpeg'),
                                  )
                              ),
                            child: Stack(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                      Expanded(child: 
                                        ListView(
                                      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                                      physics: ScrollPhysics(), // to disable GridView's scrolling
                                      shrinkWrap: true,
                                      children: <Widget>[
                                            
                                    ],)
                                      ,
                                    ),
                                  Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300], width: 1.0),
                                      color: Colors.white
                                    ),
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                    child: TextField(
                                      maxLines: 20,
                                      // controller: '',
                                      decoration: InputDecoration(
                                        // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () {},
                                        ),
                                        border: InputBorder.none,
                                        hintText: "enter your message",
                                      ),
                                      onChanged: (text) {
                                        print("First text field: $text");
                                      }
                                    ),
                                  ),
                                  )
                                ],)
                                ],)
                          )
                          ,
                          
                      );
                    },
                  );
          }
          
          return StoreConnector<AppState, AppState>(
                      converter:(store) => store.state,
                      builder: (context, state){
                        return Scaffold(
                            appBar:  AppBar(
                                  title: Text(state.selectedRoom['roomname']),
                                  backgroundColor: Colors.blueAccent,
                                  actions: <Widget>[
                                            IconButton(
                                            icon: Icon(
                                              Icons.video_call,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              // do something
                                              print('pressed');
                                            },
                                          )
                                        ]
                                  ),
                            endDrawer: Drawer(
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
                                child: Text(user,
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
                        
                      )  ,
                            body: Container(
                              width: double.infinity,
                                height: deviceHeight,
                                decoration: BoxDecoration(             
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage('assets/chatbg.jpeg'),
                                    )
                                ),
                              child: Stack(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                        Expanded(child: 
                                          ListView(
                                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                                        physics: ScrollPhysics(), // to disable GridView's scrolling
                                        shrinkWrap: true,
                                        children: <Widget>[
                                            
                                      ],)
                                        ,
                                      ),
                                    Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300], width: 1.0),
                                      color: Colors.white
                                    ),
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                      child: TextField(
                                        maxLines: 20,
                                        // controller: '',
                                        decoration: InputDecoration(
                                          // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.send),
                                            onPressed: () {},
                                          ),
                                          border: InputBorder.none,
                                          hintText: "enter your message",
                                        ),
                                        onChanged: (text) {
                                          print("First text field: $text");
                                        }
                                      ),
                                    ),
                                    )
                                  ],)
                                  ],)
                            ),
                        );
                      },
                    );
      } ,)
   ,
    );
    
  }
}

/*
 Bubble(
    style: styleSomebody,
    child: Container(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text('User',
            style: TextStyle(
              color: Colors.grey[800]
            ),
          ) ,),
          SizedBox(height: 6.0,),
          Text('Hi Jason. Sorry to bother you. I have a queston for you.')
      ],
    ),),
  ),
   Bubble(
    style: styleMe,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      
      SizedBox(height: 6.0,),
      Text('Whats\'up?')
    ]),
  ),

   
                                                
                                                
*/