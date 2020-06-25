

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_resource.dart';
import 'package:studyapp/model/app_resource_material.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/theme.dart';

class ResourcesContentPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ResourcesContentPage();
}

class _ResourcesContentPage extends State<ResourcesContentPage>{
  Icon _renderIcon(ResourceMaterial item){
  switch(item.fileType){
    case 'pdf':
      return Icon(Icons.picture_as_pdf, color: Colors.red,);
    case 'video':
      return Icon(Icons.play_circle_filled, color: Colors.red);
    case 'audio':
      return Icon(Icons.audiotrack, color: Colors.red);
    default:
      return Icon(Icons.book, color: Colors.red);
  }
}
_goToResorceViewPage(ResourceMaterial material){
  switch(material.fileType){
    case 'pdf':
      StoreProvider.of<AppState>(context).dispatch(ResourceToView(material));
      return Navigator.of(context).pushNamed('/pdf2');
    case 'video':
      StoreProvider.of<AppState>(context).dispatch(ResourceToView(material));
      return Navigator.of(context).pushNamed('/video2');
    case 'audio':
      StoreProvider.of<AppState>(context).dispatch(ResourceToView(material));
      return Navigator.of(context).pushNamed('/audio2');
    default:
      return;
  }
}
  @override
  Widget build(BuildContext context) {
    
    // TODO: implement build
    return StoreConnector<AppState, AppState>(

      builder: (BuildContext context, AppState state){
        return Scaffold(
          appBar: AppBar(
            title: Text(state.content.name),
            backgroundColor: Colors.blueAccent,
          ),
          body: Container(
            color: Color(0xfff4f4f4),
            width: AppTheme.fullWidth(context),
            height: AppTheme.fullHeight(context),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: state.content.materials.map((item) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: AppTheme.shadow,
                      borderRadius: BorderRadius.circular(4.0)
                    ),
                    child: ListTile(
                      onTap: () => _goToResorceViewPage(item),
                      leading: _renderIcon(item),
                      title: Text(item.fileName),
                      subtitle: Text(item.category),
                    ),
                  );
                }).toList() ,)
            ),
          ),
        );
      }, 
      converter: (store) => store.state);
  }
}