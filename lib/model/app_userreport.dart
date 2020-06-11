
import 'package:flutter/material.dart';
import 'package:studyapp/model/app_userresponse.dart';

class TestReport{

  final int totalCorrect;
  final int totalQuestion;
  final List<PracticeTestAnswer> response;
  TestReport({@required this.response, @required this.totalCorrect, @required this.totalQuestion});
}