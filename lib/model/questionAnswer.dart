

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:studyapp/model/response.dart';

class QuestionAnswer{
  final List<Response> response;
  final String assessmentId;
  final DateTime completedAt;
  final String studentUserId;
  final String totalNumberOfQuestions;
  final int numberOfCorrectAnswers;
  QuestionAnswer({@required this.response, @required this.assessmentId, 
    @required this.completedAt, @required this.studentUserId, @required this.totalNumberOfQuestions,
      @required this.numberOfCorrectAnswers});

    Map toJson(){
      var userResponse = [];
      response.forEach((doc) {
        userResponse.add({
          'question': doc.question,
          'questionNumber': doc.questionNumber,
          'selectedOption': doc.selectedOption,
          'correctOption': doc.correctOption
        });
      });
      String completedDateToString = completedAt.toString();
      return {'assessmentId': assessmentId,'response': userResponse, 'completedAt': completedDateToString,
        'studentUserId': studentUserId, 'numberOfCorrectAnswers': numberOfCorrectAnswers,
        'totalNumberOfQuestions': totalNumberOfQuestions
        };
    }
    
}