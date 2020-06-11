import 'package:flutter/material.dart';
import 'package:studyapp/model/app_practiceQuestion.dart';
import 'package:studyapp/model/app_testparams.dart';
import 'package:studyapp/model/app_userreport.dart';
import 'package:studyapp/model/test.dart';
import 'package:studyapp/model/user.dart';

class AppState{
  int selectedTabIndex;
  var selectedSubject;
  Map<String, dynamic> selectedMaterial;
  Map<String, dynamic> selectedRoom;
  String educationLevel = "";
  String user = "";
  String schoolLevel = "";
  List<dynamic> materials = [];
  Test testSelected;
  User loggedUser;
  String examtype = "";
  ExamQuestion test;
  TestParams testParams;
  TestReport report;
  String testMode = "new";
  AppState({this.selectedTabIndex});
  
  AppState.fromAppState(AppState anotherState){
    selectedTabIndex = anotherState.selectedTabIndex;
    selectedSubject = anotherState.selectedSubject;
    selectedMaterial = anotherState.selectedMaterial;
    selectedRoom = anotherState.selectedRoom;
    educationLevel = anotherState.educationLevel;
    user = anotherState.user;
    schoolLevel = anotherState.schoolLevel;
    materials = anotherState.materials;
    testSelected = anotherState.testSelected;
    loggedUser = anotherState.loggedUser;
    examtype = anotherState.examtype;
    test = anotherState.test;
    testParams = anotherState.testParams;
    report = anotherState.report;
    testMode = anotherState.testMode;
  }
}