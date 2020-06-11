import 'package:flutter/material.dart';

class AppPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AppPageState();
  
}

class _AppPageState extends State<AppPage>{
   @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.lightBlue, Colors.deepPurple]
            )
          ),
          child: Stack(
            children: [
              Column(
                children: [
                    Container(
                    margin: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Text('Easy Study PS', 
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white
                      )
                    ),
                    )
                  )
                ]
              ),
              Positioned(
                left: 16,
                bottom: deviceHeight * 0.25,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          child: Text('Choose Application',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w800
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 28.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    // padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                    child: GestureDetector(
                                      onTap: () { 
                                        Navigator.of(context).pushReplacementNamed('/login');
                                      },
                                      child: Card(
                                      color: Colors.deepPurple,
                                      elevation: 8,
                                      shape: CircleBorder(),
                                      child: Container(
                                        child: CircleAvatar(
                                        radius: 40.0,
                                        // backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.school,
                                          size: 32,
                                        ) ,
                                        )
                                      )
                                    ),
                                    )
                                    ),
                                    Container(

                                      margin: EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(
                                        child: Text('Students',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white
                                          ),
                                        ) ,
                                      )
                                    )
                                ]
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric( horizontal: 32.0),
                                    child: GestureDetector(
                                      onTap: (){ 
                                        Navigator.of(context).pushReplacementNamed('/teachersLogin');
                                      },
                                      child: Card(
                                      color: Colors.deepPurple,
                                      elevation: 8,
                                      shape: CircleBorder(),
                                      child: Container(
                                        child: CircleAvatar(
                                        radius: 40.0,
                                        // backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.present_to_all,
                                          size: 32,
                                        ) ,
                                        )
                                      )
                                    )
                                    ) ,
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                      child: Center(
                                        child: Text('Teachers',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white
                                          ),
                                        ) ,
                                      )
                                    )

                                ]
                              ),
                              

                            ],)
                          ),
                        )
                    ]
                  ),
                )
                
              )
              // Align(
              //   alignment: Alignment.bottomLeft,
              //   child: Column(
              //     children: <Widget>[
              //       Container(
              //         child: Text('Choose Application',
              //           style: TextStyle(color: Colors.white),
              //         ),)
              //     ]
              //   )
              // )
            ]
          )
        )
      )
    );
  }
}

//Color(0xfffbb448), Color(0xfff7892b)



