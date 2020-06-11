import 'package:flutter/material.dart';
import 'package:flutter_rounded_progress_bar/flutter_icon_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'dart:math';

class LearningCourse extends StatelessWidget{
  MaterialColor colorCustom;
  final List<Map<String, dynamic>> recentCourses = [
    {'subject': 'Mathematics', 'topic':'Trignometry', 'id': 1, 'progress': 20.0},
    {'subject': 'English', 'topic':'Comprehension', 'id': 2, 'progress': 70.0},
    {'subject': 'Physics', 'topic':'Sonic Waves', 'id': 3, 'progress': 40.0}
  ];
  final List<String> images = [
      'assets/study3.jpg'
     'assets/study2.jpg'];
  final Map<int, Color> color = {
              50:Color.fromRGBO(76,19,100, .1),
              100:Color.fromRGBO(76,19,100, .2),
              200:Color.fromRGBO(76,19,100, .3),
              300:Color.fromRGBO(76,19,100, .4),
              400:Color.fromRGBO(76,19,100, .5),
              500:Color.fromRGBO(76,19,100, .6),
              600:Color.fromRGBO(76,19,100, .7),
              700:Color.fromRGBO(76,19,100, .8),
              800:Color.fromRGBO(76,19,100, .9),
              900:Color.fromRGBO(76,19,100, 1),
  };
  LearningCourse(){
    colorCustom = MaterialColor(0xFF880E4F, color);
  }
  _handleSelectedCourse(int index){
    print('selected' + index.toString());
  }
  int getRandom(){
    var rng = new Random();
    int d = rng.nextInt(2);
    print(d);
    return d;
  }
  Widget buildRecentCourses(BuildContext context, int index){
    double deviceWidth = MediaQuery.of(context).size.width;
    // double deviceHeight
    final double progess = recentCourses[index]['progress'];
    return Container(
            width: deviceWidth * 0.6,
            margin: EdgeInsets.symmetric(horizontal: 0.5),
            
            child: FlatButton(
              onPressed: (){
                _handleSelectedCourse(index);
              },
              child: Card(
                  
                  color: Colors.white,
                  child: Container(
                    // padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 130.0,
                        //  padding: EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/study3.jpg')
                          )
                        ),
                      ),
                      Container(
                        height: 120,
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: Text(recentCourses[index]['subject'],
                                style: TextStyle(color: colorCustom,
                                  fontFamily: 'Gilroy', fontWeight: FontWeight.bold,
                                  fontSize: 18
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              child: Text(recentCourses[index]['topic'],
                                style: TextStyle(color: Colors.black,
                                  fontFamily: 'Gilroy', fontWeight: FontWeight.bold,
                                  fontSize: 14
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text('Progress',
                                      style: TextStyle(color: Colors.black87),
                                  )
                                ),
                                Container(
                                  //  child: Text('50%')
                                  width: 100,
                                  child: RoundedProgressBar(
                                      style: RoundedProgressBarStyle(
                                              borderWidth: 0, 
                                              widthShadow: 0),
                                        margin: EdgeInsets.symmetric(vertical: 2),
                                        childLeft: Text(progess.toString() + '%',
                                            style: TextStyle(color: Colors.white)),
                                        percent: progess,
                                        height: 6,
                                        theme: RoundedProgressBarTheme.green)
                                  //  Text('50%')
                                  //  Text('50%')
                                )
                                
                              ],
                            )
                          ]
                        ),
                        )
                    ]
                  )
                  ),
                ),)
            
          );
    
    
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build Text('Hi below');
    return Column(
      children: <Widget>[
        Container(
           height: 270.0,
          // color: Colors.green,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: buildRecentCourses, itemCount: recentCourses.length,)
        )
      ]
    );
  }
}