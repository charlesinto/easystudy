import 'package:flutter/material.dart';

class AppColors {
  static Color primaryWhite = Color(0xFFCADCED);
    // static Color primaryWhite = Colors.indigo[100];
  static Color moodyBlue = Color(0xff4F5D7B);
  static Color lightGrey = Color(0xffDEE7E9);
  static Color lightGreen = Color(0xff7BC774);
  static Color red = Color(0xffD02431);
  static Color green = Color(0xff1BAC74);
  static List pieColors = [
    Colors.indigo[400],
    Colors.blue,
    Colors.green,
    Colors.indigo,
    Colors.deepOrange,
    Colors.brown,
    Colors.deepPurpleAccent,
    Colors.blueGrey,
    Colors.cyanAccent,
    Colors.greenAccent,
    Colors.black12,
    Colors.lightBlueAccent,
    Colors.orange[800],
    Colors.purpleAccent,
    Colors.blueGrey,
    Colors.red,
    Colors.tealAccent,
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.lightBlueAccent,
    Colors.indigoAccent,
    Colors.deepOrangeAccent,
    Colors.amberAccent,
    Colors.cyan,
    Colors.purpleAccent,
    Colors.indigoAccent
  ];
  static List<BoxShadow> neumorpShadow = [
    BoxShadow(
        color: Colors.white.withOpacity(0.5), spreadRadius: -5, offset: Offset(0, 5), blurRadius: 30),
    BoxShadow(
        color: Colors.white.withOpacity(.2),
        spreadRadius: 2,

        offset: Offset(7, 7),
        blurRadius: 20)
  ];
  Color getBackgroundColor(String text){
    var firstCharacter = text.substring(0,1).toLowerCase();
    return pieColors[getCharcterIndex(firstCharacter)];
  }
  int getCharcterIndex(String firstCharacter){
    int index;
    switch(firstCharacter){
      case 'a':
        index = 0;
        break;
      case 'b':
        index = 1;
        break;
        case 'c':
        index = 2;
        break;
        case 'd':
        index = 3;
        break;
        case 'e':
        index = 4;
        break;
        case 'f':
        index = 5;
        break;
        case 'g':
        index = 6;
        break;
        case 'h':
        index = 7;
        break;
        case 'i':
        index = 8;
        break;
        case 'j':
        index = 9;
        break;
        case 'k':
        index = 10;
        break;
        case 'l':
        index = 11;
        break;
        case 'm':
        index = 12;
        break;
        case 'n':
        index = 13;
        break;
        case 'o':
        index = 14;
        break;
        case 'p':
        index = 15;
        break;
        case 'q':
        index = 16;
        break;
        case 'r':
        index = 17;
        break;
         case 's':
        index = 18;
        break;
        case 't':
        index = 18;
        break;
        case 'u':
        index = 19;
        break;
        case 'v':
        index = 20;
        break;
        case 'w':
        index = 21;
        break;
        case 'x':
        index = 22;
        break;
        case 'y':
        index = 23;
        break;
        case 'z':
        index = 24;
        break;
        default:
          index = 25;
    }
    return index;
  }
}