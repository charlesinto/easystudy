import 'package:flutter/material.dart';
import 'package:studyapp/model/app_practiceQuestion.dart';
import 'package:studyapp/model/app_testparams.dart';
import 'package:studyapp/model/app_userreport.dart';
import 'package:studyapp/model/test.dart';
import 'package:studyapp/model/user.dart';

class TabIndex{
  final int payload;
  TabIndex(this.payload);
}

class SelectSubject{
  var payload;
  SelectSubject(this.payload);
}

class SelectedMaterial{
  var payload;
  SelectedMaterial(this.payload);
}

class SelectedRoom{
  final Map<String, dynamic> payload;
  SelectedRoom(this.payload);
}

class EducationLevel{
  final String payload;
  EducationLevel(this.payload);
}

class LoggedInUser{
  final String payload;
  LoggedInUser(this.payload);
}

class SchoolLevel{
  final String payload;
  SchoolLevel(this.payload);
}

class MaterialLoaded{
  final List<dynamic> payload;
  MaterialLoaded(this.payload);
}

class OnTestSelected{
  final Test payload;
  OnTestSelected(this.payload);
}

class UserSelectAssessment{
  final User payload;
  UserSelectAssessment(this.payload);
}

class SelectedExamType{
  final String payload;
  SelectedExamType(this.payload);
}

class PracticeQuestionSelected{
  final ExamQuestion payload;
  PracticeQuestionSelected(this.payload);
}

class StartTest{
  final TestParams payload;
  StartTest(this.payload);
}

class ReportGenerated{
  final TestReport payload;
  ReportGenerated(this.payload);
}

class SetTestMode{
  final String payload;
  SetTestMode(this.payload);
}