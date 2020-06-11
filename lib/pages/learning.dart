import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/actions.dart';

class Learning extends StatelessWidget{
  Color schoolColor(String schoolType){
    return schoolType == "Primary School" ? Colors.purple : schoolType ==
    'Junior School' ? Colors.blueAccent : Colors.orangeAccent;
  }
  void _handleEducationLevelSelect(BuildContext context, String schoolType){
    final double deviceHieght = MediaQuery.of(context).size.height;
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      if(schoolType == 'Primary School'){
        return Container(
                height: deviceHieght * 0.55,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: Text('Your Class',
                          
                          style: TextStyle(fontSize: 26,
                                  fontFamily: 'Gilroy', fontWeight: FontWeight.bold
                                )
                      ),
                    ),
                    SizedBox(height: 16,),
                    FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Primary One'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('primary'));
                        Navigator.of(context).pushNamed('/selectSubjects/primary1');
                      }
                    ,),
                      FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Primary Two'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('primary'));
                        Navigator.of(context).pushNamed('/selectSubjects/primary2');
                      }
                    ,),
                      FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Primary Three'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('primary'));
                        Navigator.of(context).pushNamed('/selectSubjects/primary3');
                      }
                    ,),
                      FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Primary Four'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('primary'));
                        Navigator.of(context).pushNamed('/selectSubjects/primary4');
                      }
                    ,),
                      FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Primary Five'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('primary'));
                        Navigator.of(context).pushNamed('/selectSubjects/primary5');
                      }
                    ,),
                      FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Primary Six'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('primary'));
                        Navigator.of(context).pushNamed('/selectSubjects/primary6');
                      }
                    ,)
                  ],
                )
              );
      }
      else if( schoolType == 'Junior School'){
        return  Container(
        height: deviceHieght * 0.55,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: ListView(
          children: <Widget>[
            Container(
              child: Text('Your Class',
                  
                  style: TextStyle(fontSize: 26,
                          fontFamily: 'Gilroy', fontWeight: FontWeight.bold
                        )
              ),
            ),
            SizedBox(height: 16,),
             FlatButton(child: Card(
                        child: ListTile(
                          title: Text('JS One'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('Junior School'));
                        Navigator.of(context).pushNamed('/selectSubjects/js1');
                      }
                    ,),
              FlatButton(child: Card(
                        child: ListTile(
                          title: Text('JS Two'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('Junior School'));
                        Navigator.of(context).pushNamed('/selectSubjects/js2');
                      }
                    ,),
              FlatButton(child: Card(
                        child: ListTile(
                          title: Text('JS Three'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('Junior School'));
                        Navigator.of(context).pushNamed('/selectSubjects/js3');
                      }
                    ,),
              
          ],
        )
      );
      }
      return  Container(
        height: deviceHieght * 0.55,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: ListView(
          children: <Widget>[
            Container(
              child: Text('Your Class',
                  
                  style: TextStyle(fontSize: 26,
                          fontFamily: 'Gilroy', fontWeight: FontWeight.bold
                        )
              ),
            ),
            SizedBox(height: 16,),
             FlatButton(child: Card(
                        child: ListTile(
                          title: Text('SS One'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('Senior School'));
                        Navigator.of(context).pushNamed('/selectSubjects/ss1');
                      }
                    ,),
              FlatButton(child: Card(
                        child: ListTile(
                          title: Text('SS Two'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('Senior School'));
                        Navigator.of(context).pushNamed('/selectSubjects/ss2');
                      }
                    ,),
              FlatButton(child: Card(
                        child: ListTile(
                          title: Text('SS Three'),
                          leading: Icon(Icons.class_),
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        StoreProvider.of<AppState>(context).dispatch(EducationLevel('Senior School'));
                        Navigator.of(context).pushNamed('/selectSubjects/ss3');
                      }
              ,),
          ],
        )
      );
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state){
        return ListView(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),

              children: <Widget>[

              Container(
                padding: EdgeInsets.only(top: 32, left: 20.0),
                child: Row(
                    children: <Widget>[
                      Text('Choose your Class',
                        style: TextStyle(fontSize: 26,
                          fontFamily: 'Gilroy', fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                ) ,
              ),
              SizedBox(height: 16,),
              GridView.count(
                // crossAxisAlignment: CrossAxisAlignment.start, 
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                physics: ScrollPhysics(), // to disable GridView's scrolling
                shrinkWrap: true,
                children: <String>[
                  'Primary School',
                  'Junior School',
                  'Senior School',
                ].map((String schoolType){
                  return  GestureDetector(child: Container(
                          // width: 300,
                          decoration: BoxDecoration(
                            color: schoolColor(schoolType),
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            boxShadow: [
                                        new BoxShadow(
                                          color: Colors.grey[300],
                                          offset: new Offset(4.0, 2.0),
                                        )
                                      ]
                          ),
                          padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                          child: Center(child: Text(schoolType,
                              style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gilroy',
                                    fontSize: 18
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                      ), onTap: (){
                          StoreProvider.of<AppState>(context).dispatch(SchoolLevel(schoolType));
                        _handleEducationLevelSelect(context,schoolType);
                      },); 
                  
                }).toList(),
                ),
        ],
        );
      } ,);
  }
}

