

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassConversation extends StatefulWidget{
  final String schoolCode;
  final String userClass;
  ClassConversation({@required this.schoolCode, @required this.userClass});
  @override
  State<StatefulWidget> createState() => _ClassConversation();
}

class _ClassConversation extends State<ClassConversation>{
  Firestore _firestore;
  FirebaseAuth _firebaseAuth;
  BubbleStyle styleSomebody;
  BubbleStyle styleMe;
  String message = '';
  TextEditingController _textField = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var uid;
  var user = {};
  SharedPreferences prefs;
  initState(){
    super.initState();
    _firestore = Firestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    SharedPreferences.getInstance().then((preferences)  {
      user = json.decode(preferences.getString('user'));
      print('called here now');
      prefs = preferences;
    });
    _firebaseAuth.currentUser().then((user)  {
      uid = user.uid;
    });
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
  Stream<QuerySnapshot> getChatSnapshot(BuildContext context, user){
      // var schoolCode = user['schoolCode'];
    return  _firestore.collection('chats/${widget.schoolCode}/${widget.userClass.toLowerCase()}').orderBy('createdAt',descending: false).snapshots();
  }
  Future getUser() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return json.decode(_prefs.getString('user'));
  }
  _renderChats(BuildContext context){
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double px = 1 / pixelRatio;
    styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
    );
    styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
    );
    final double deviceHeight = MediaQuery.of(context).size.height;
    
    var deviceWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 0,
      left: 0,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
        width: deviceWidth ,
        height: deviceHeight ,
        padding: EdgeInsets.only(bottom: 130, top: 10),
      child: FutureBuilder(
        future: getUser(),
        builder: (BuildContext context,AsyncSnapshot snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
                return chatsStream(context, snapshot.data);
            }
            return Container();
          }
          return Container();
        },
      )
    ),
      )
      
      );
  }
  chatsStream(BuildContext context, var user){
    return StreamBuilder(
      stream: getChatSnapshot(context, user),
      builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
        print('oops');
        if(snapshot.connectionState != ConnectionState.waiting){
          if(snapshot.hasData){
            return KeyboardAvoider(
              autoScroll: true,
              child: ListView.builder(
                controller: _scrollController,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index){
                  if(snapshot.data.documents[index].data['uid'] == uid){
                    print(snapshot.data.documents[index].data);
                    return Column(
                      children: <Widget>[
                        Bubble(
                          style: styleMe,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            
                            SizedBox(height: 8.0,),
                            linkifyText(snapshot.data.documents[index].data['message'])
                            
                          ]),
                        ),
                        SizedBox(
                            height: 10,
                          )
                      ],
                    );
                    
                  }
                  return Column(
                      children: <Widget>[
                        Bubble(
                          style: styleSomebody,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            Container(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Text(snapshot.data.documents[index]['createdBy'],
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                                decoration: TextDecoration.underline
                              ),
                            ) ,),
                            SizedBox(height: 8.0,),
                            linkifyText(snapshot.data.documents[index].data['message'])
                            
                          ]),
                        ),
                        SizedBox(
                            height: 10,
                          )
                      ],
                    );
              }),
            );
             
          }
          return Container();
        }
        return Container();
      },
      );
  }
  _renderTextInput(BuildContext context){
    var deviceWidth = MediaQuery.of(context).size.width;
    print('called here now 23');
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: deviceWidth,
        color: Colors.green,
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300], width: 1.0),
              color: Colors.white
            ),
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: TextField(
                controller: _textField,
                maxLines: 20,
                // controller: '',
                decoration: InputDecoration(
                  // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async{
                      print(user);
                      if(message.isEmpty){
                        return ;
                      }
                      try{
                        await _firestore.collection('chats/${widget.schoolCode}/${widget.userClass.toLowerCase()}').add({
                        'schoolCode': user['schoolCode'],
                        'uid': user['uid'],
                        'message': message,
                        'sender': '${user['firstName']} ${user['lastName']}',
                        'createdAt': new DateTime.now()
                      });
                      _textField.clear();
                      }catch(error){
                        print(error);
                      }
                    },
                  ),
                  border: InputBorder.none,
                  hintText: "enter your message",
                ),
                onChanged: (text) {
                  message = text;
                  print("First text field: $text");
                }
              ),
            ),
            ),
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    
    var deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // resizeToAvoidBottomPadding : false,
      appBar: AppBar(
        title: Text(widget.userClass),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: deviceWidth,
                    color: Colors.black,
                    height: deviceHeight,
        child:  Stack(
            children: <Widget>[
               GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    width: deviceWidth,
                    color: Colors.white,
                    height: deviceHeight,
                  )),
                _renderChats(context),
                _renderTextInput(context)
            ],
          ),
      ),
    );
  }
}