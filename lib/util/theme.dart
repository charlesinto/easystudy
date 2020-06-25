import 'package:flutter/material.dart';

class AppTheme{
   static List<BoxShadow> shadow = <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ];
   static List<BoxShadow> blueshadow = <BoxShadow>[
                BoxShadow(
                  color: Color(0xff4F5D7B),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ];

  static List<BoxShadow> light = <BoxShadow>[
                BoxShadow(
                  color: Color(0xFF2B2121),
                  spreadRadius: 8,
                  blurRadius: 7,
                  offset: Offset(0, 10), // changes position of shadow
                ),
              ];
}