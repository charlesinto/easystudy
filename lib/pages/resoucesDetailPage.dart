

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_resource.dart';
import 'package:studyapp/model/app_resource_category.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/util/theme.dart';
import 'package:toast/toast.dart';

class ResourceDetail extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ResourceDetail();
}

class _ResourceDetail extends State<ResourceDetail>{
  Future<List<ResourceCategory>> getMaterials(BuildContext context, AppState state) async{
    try{
      var categories = await App.getResourceCatgeories(context);
      return categories;
    }catch(error){
      print(error);
      return [];
    }
  }
  getOneMaterial(BuildContext context, String id, String title) async{
    var materials = await App.getMaterialResourceById(id);
    if(materials.length > 0){
      
      StoreProvider.of<AppState>(context).dispatch(SelectedContent(ResourceContent(materials: materials, name: title)));
      return Navigator.of(context).pushNamed('/resources');
    }
    return Toast.show("No Content yet, check again later", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }
  Column _showCategories(BuildContext context, List<ResourceCategory> data){
    return Column(
      children: data.map((cat){
        return Container(
          width: AppTheme.fullWidth(context),
          margin: EdgeInsets.only(bottom: 20.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),
          decoration: BoxDecoration(
            boxShadow: AppTheme.shadow,
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0)
          ),
          child: ListTile(
            onTap: () => getOneMaterial(context, cat.id, cat.title),
            title: Text(cat.title),
            subtitle: Text(cat.description),
          ),
        );
      }).toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StoreConnector<AppState, AppState>(
      builder: (BuildContext context, AppState state){
        return Scaffold(
          appBar: AppBar(
            title: Text(state.selectedResource),
            backgroundColor: Colors.blueAccent,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            width: AppTheme.fullWidth(context),
            height: AppTheme.fullHeight(context),
            color: Color(0xfff4f4f4),
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: getMaterials(context, state),
                builder: (BuildContext context,AsyncSnapshot<List<ResourceCategory>> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasData && snapshot.data.length > 0){
                      return  _showCategories(context, snapshot.data);
                    }
                    return Container(
                      width: AppTheme.fullWidth(context),
                      height: AppTheme.fullWidth(context),
                      child: Center(child: Text('No Resource'),)
                    );
                  }
                  return Container(
                      width: AppTheme.fullWidth(context),
                      height: AppTheme.fullWidth(context),
                      child: Center(child: CircularProgressIndicator(),)
                    );
                } ,
              )
            ),
          ),
        );
      },
       converter: (store) => store.state);
  }
}