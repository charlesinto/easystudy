
import 'package:flutter/cupertino.dart';
import 'package:studyapp/model/question.dart';

class Response {
  final Questions question;
  final String selectedOption;
  final String correctOption;
  final int questionNumber;
  
  Response({@required this.question, @required this.selectedOption,
     @required this.correctOption, @required this.questionNumber});

  Map toJson(){
    return {'question': question, 'selectedOption': selectedOption, 'correctOption': correctOption, 
      'questionNumber': questionNumber};
  }
}