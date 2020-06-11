

import 'package:flutter/material.dart';
import 'package:studyapp/model/app_testQuestion.dart';

class ExamQuestion{
  final String title;
  final String type;
  List<TestQuestion> questions = [];
  ExamQuestion({@required this.title, @required this.type,@required this.questions });
}