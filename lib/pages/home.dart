import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:studyapp/pages/LandingPage.dart';
import 'package:studyapp/pages/assessment.dart';
import 'package:studyapp/pages/classroom.dart';
import 'package:studyapp/pages/learning.dart';
import 'package:studyapp/pages/profile.dart';


import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/reducers.dart';
import 'package:studyapp/redux/actions.dart';


class Home extends StatefulWidget {
  // final int _selectedIndex = 0;
  Map<String,dynamic> loggedInUser;
  Home();
  Home.fromHome(this.loggedInUser);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
  
}

class _HomeState extends State<Home>{
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static final List<Widget> _widgetOptions = <Widget>[
    LandingPage(),
    Learning(),
    ClassRoom(),
    // Profile(),
    Assessment()
    
  ];

  @override
  Widget build(BuildContext context) {
    print('user  '+ widget.loggedInUser.toString());
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
    builder: (context, state) {
        return Scaffold(
      // appBar: AppBar(
      //   title: const Text('BottomNavigationBar Sample'),
      // ),
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(child: _widgetOptions.elementAt(state.selectedTabIndex))
        ],
        // child: _widgetOptions.elementAt(state.selectedTabIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: Duration(milliseconds: 800),
                tabBackgroundColor: Colors.blue,
                tabs: [
                  GButton(
                    icon: LineIcons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: LineIcons.book,
                    text: 'Learning',
                  ),
                  GButton(
                    icon: LineIcons.users,
                    text: 'Classroom',
                  ),
                  GButton(
                    icon: Icons.storage,
                    text: 'Assessments',
                  ),
                ],
                selectedIndex: state.selectedTabIndex,
                onTabChange: (index) {
                  StoreProvider.of<AppState>(context).dispatch(TabIndex(index));
                  print('change');
                  // setState(() {
                  //   _selectedIndex = index;
                  // });
                }),
          ),
        ),
      ),
    );
    });
    
  }
}
