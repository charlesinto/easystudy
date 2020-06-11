

import 'package:flutter/cupertino.dart';

class User{
  final String admissionNumber;
  final String schoolCode;
  final String userClass;
  final String id;
  final String type;
  User({@required this.admissionNumber,@required this.schoolCode,@required this.userClass,@required this.type,
   @required this.id});

  toJson(){
    return {'admissionNumber': admissionNumber, 'class': userClass, 'schoolCode': schoolCode, 'id': id};
  }
}