

import 'package:flutter/material.dart';
import 'package:studyapp/model/app_testQuestion.dart';

class PracticeTestAnswer{
  final TestQuestion question;
  final String answer;
  final String correctAnswer;
  final int questionNumber;
  PracticeTestAnswer({@required this.answer, @required this.correctAnswer, @required this.question, @required this.questionNumber});
}