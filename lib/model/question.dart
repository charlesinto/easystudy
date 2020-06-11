
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:studyapp/model/options.dart';

class Questions{
  final List<dynamic> images;
  // final Sring id;
  final List<Options> options;
  final String questionMark;
  final bool hasImage;
  final String question;
  final String correctOption;
  Questions({@required this.images, @required this.options, @required this.questionMark, 
  @required this.hasImage, @required this.correctOption, @required this.question});

  Map toJson(){
    var questionOption = [];
    options.forEach((option) {
      questionOption.add( {
        'answer': option.answer,
        'option': option.option
      });
    });
    return {'images': images, 'options': questionOption, 'hasImage': hasImage,
      'question': question, 'correctOption': correctOption};
  }
}