


import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:studyapp/model/app_practiceQuestion.dart';
import 'package:studyapp/model/app_resource_category.dart';
import 'package:studyapp/model/app_resource_material.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/model/app_testQuestion.dart';
import 'package:studyapp/model/user.dart';
import 'package:studyapp/util/colors.dart';
import 'package:http/http.dart' as http;

class App{
  
  static Future<List<User>> getUserClass(String schoolCode, String admissionNumber) async{
    List<User> user = [];
    try{
       Firestore _firestore = Firestore.instance;
        QuerySnapshot queryDocuments = await _firestore.collection('students')
          .where('schoolCode', isEqualTo: schoolCode)
          .where('admissionNumber', isEqualTo: admissionNumber)
          .getDocuments();
        
        if(queryDocuments.documents.isNotEmpty){
          queryDocuments.documents.forEach((doc) {
              user.add(User(admissionNumber: doc.data['admissionNumber'],schoolCode:
              doc.data['schoolCode'] ,userClass: doc.data['class'], id: doc.documentID));
          });
        }
        print(user.length);
        return user;
    }catch(error){
      print('error is: '+ error);
      return user;
    }
  }
  static subscribeToNotiifcation(String schoolCode, String notificationGroup){
    FirebaseMessaging _fcm = FirebaseMessaging();
    List<String> wordGroups = notificationGroup.split(" ");
    var group = wordGroups.join('-');
    _fcm.subscribeToTopic("${schoolCode.toLowerCase()}-${group.toLowerCase()}");
  }
  static Future<List<ExamQuestion>> getQuestions(BuildContext context, {String examtype = "jamb"}) async{
    List<ExamQuestion> questions = [];
    switch(examtype){
      case 'jamb':
        try{
            var dataString = await DefaultAssetBundle.of(context).loadString("assets/jamb.json");
            var data = json.decode(dataString);
            data.keys.forEach((key){
              var setQuestions = data[key];
              List<TestQuestion> test = [];
              
              setQuestions.forEach((item){
                test.add(
                  TestQuestion(id: item['id'], answer: item['answer'], examtype: item['examtype'], images: item['image_asset'], 
                  linkToAnswer: item['linkToanswer'], question: item['qestion'], sourceUrl: item['source_url'], subject: item['subject'], year: item['year'], options: item['options'])
                );
              });
              questions.add(ExamQuestion(title: key , type: 'jamb', questions: test));
            });
        }catch(error){
          print(error);
        }
      break;
      default:
      break;
    }
    return questions;
  }
  static double fullWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
  static double fullHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
  static showActionSuccess(BuildContext context, {String message = "Action Performed successfully", Function onConfirm}){
    return Alert(
          context: context,
          type: AlertType.success,
          title: "Action Successful",
          desc: message,
          buttons: [
            DialogButton(
              color: AppColors.lightGreen,
              child: Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pop(context);
                onConfirm(context);
              },
              width: 120,
            ),
          ],
        ).show();
  }
  static showActionError(BuildContext context, {String message = "Action could not be performed", Function onConfirm}){
    return Alert(
          context: context,
          type: AlertType.error,
          title: "Action Error",
          desc: message,
          buttons: [
            DialogButton(
              color: AppColors.lightGreen,
              child: Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pop(context);
                onConfirm(context);
              },
              width: 120,
            ),
          ],
        ).show();
  }
  static showConfirmDialog(BuildContext context,String title, String message, Function onConfirm,{dynamic params}){
    return Alert(
          context: context,
          type: AlertType.info,
          title: title,
          desc: message,
          buttons: [
            DialogButton(
              color: AppColors.red,
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pop(context);
              },
              width: 120,
            ),
            DialogButton(
              color: AppColors.lightGreen,
              child: Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pop(context);
                onConfirm(context, params);
              },
              width: 120,
            ),
          ],
        ).show();
  }

  static Future<List<ResourceCategory>> getResourceCatgeories(BuildContext context) async{
    try{
        List<ResourceCategory> catgories = [];
          var response = await http.get('http://cbccollege.easystudy.com.ng/resource_cat.php');
          var resoureCategories = json.decode(response.body)['resource_cat'];
          resoureCategories.forEach((cat) {
            catgories.add(ResourceCategory(description: cat['description'] , id: cat['id'], title:cat['title'] ));
          });
          return catgories;
    }catch(error){
      throw error;
    }
  }
   static isLoading(BuildContext context){
    return showDialog(
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
  }
  static stopLoading(BuildContext context){
    return Navigator.pop(context);
  }
  static Future<List<ResourceMaterial>> getMaterialResourceById(String id) async{
    try{
      List<ResourceMaterial> resource = [];
      
      var response = await http.get('http://cbccollege.easystudy.com.ng/resource_materials.php?id=$id');
      if(response.statusCode == 200 && response.body != ''){
        var materials = json.decode(response.body)['material'];
        materials.forEach((item){
          resource.add(ResourceMaterial(id: item['id'], category: item['category'], categoryId: item['cat_id'], fileName: item['file_name'], fileType: item['file_type'], fileUrl: item['file_url']));
        });
        return resource;
      }
      return resource;
    }catch(error){
      throw error;
    }
  }
}