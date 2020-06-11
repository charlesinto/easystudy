

import 'package:flutter/cupertino.dart';

class Options{
  final String answer;
  final String option;
  Options({@required this.answer, @required this.option});

  Map toJson(){
    return {'answer': answer, 'option': option};
  }
}