

import 'package:flutter/material.dart';

class TestQuestion{
  final int id;
  final int year;
  final String examtype;
  final String subject;
  final String question;
  final List<dynamic> images;
  final List<dynamic> options;
  final String linkToAnswer;
  final String sourceUrl;
  final String answer;
  TestQuestion({@required this.id, @required this.answer, @required this.examtype,
  @required this.images, @required this.linkToAnswer, @required this.question,
  @required this.sourceUrl, @required this.subject, @required this.year, @required this.options});
}

/*

{"id": 8004, "year": 2000, "examtype": "Jamb", "subject": "Mathematics", "qestion": 
"Let P = {1, 2, u, v, w, x}; Q = {2, 3, u, v, w, 5, 6, y} and R = {2, 3, 4, v, x, y}. Determine (P-Q) \u2229 R", "image_asset": [], 
"options": ["A.   {1, x}", "B.   {x y}", "C.   {x}", "D.   \u0278"], "answer": "Correct Answer: Option C", 
"linkToanswer": "https://myschool.ng/classroom/mathematics/552?exam_type=jamb&exam_year=2000&page=1",
 "source_url": "https://myschool.ng/classroom/mathematics?exam_type=jamb&exam_year=2000&page=1"}

 */