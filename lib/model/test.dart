

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:studyapp/model/question.dart';

class Test{
  final String schoolLevel;
  final String quizName;
  final String subject;
  final String id;
  final List<Questions> questions;
  final bool isTimed;
  final String createdBy;
  final String studentClass;
  final Timestamp createdAt;
  final String validUntil;
  final String numberOfQuestions;
  final String numberOfMinutesToComplete;
  final String schoolCode;
  final String totalValidMarks;
  
  Test({@required this.schoolLevel, @required this.quizName, @required this.subject, @required this.questions,
    @required this.isTimed, @required this.createdBy, @required this.studentClass, @required this.createdAt,
      @required this.validUntil, @required this.numberOfQuestions, @required this.numberOfMinutesToComplete,
      @required this.schoolCode, @required this.totalValidMarks, @required this.id});
}