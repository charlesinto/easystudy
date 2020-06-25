

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_resource.dart';
import 'package:studyapp/model/app_resource_category.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:studyapp/util/app.dart';
import 'package:studyapp/util/theme.dart';
import 'package:toast/toast.dart';

class OtherResources extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _OtherResources();
}

class _OtherResources extends State<OtherResources>{
  Future<List<ResourceCategory>> getResources(BuildContext context) async{
    try{
      // App.isLoading(context);
      
      var materials = await App.getResourceCatgeories(context);
      // App.stopLoading(context);
      return materials;
    }catch(error){
      print(error);
      App.stopLoading(context);
      return [];
    }
  }
  getOneMaterial(BuildContext context, String id, String title) async{
    App.isLoading(context);
    var materials = await App.getMaterialResourceById(id);
    App.stopLoading(context);
    if(materials.length > 0){
      
      StoreProvider.of<AppState>(context).dispatch(SelectedContent(ResourceContent(materials: materials, name: title)));
      return Navigator.of(context).pushNamed('/resourcesView');
    }
    return Toast.show("No Content yet, check again later", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }
  Column _renderResources(BuildContext context, List<ResourceCategory> data){
    return Column(
      children: data.map((item) {
        if(item.title == 'Havilah Books'){
          return Container(
            margin: EdgeInsets.only(bottom: 20.0),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.white,
              boxShadow: AppTheme.shadow
            ),
            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.asset('assets/havilah.png', width: AppTheme.fullWidth(context), height: 120, fit: BoxFit.contain,),
                        SizedBox(height: 10.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(onPressed: (){
                              getOneMaterial(context, item.id, item.title);
                            }, 
                            child: Text('View All', 
                            style: TextStyle(
                              color: Colors.orange
                            ),))
                          ],
                        )
                      ],
                    ),
          );
        }
        return Container(
          margin: EdgeInsets.only(bottom: 20.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Colors.white,
            boxShadow: AppTheme.shadow
          ),
          child: ListTile(
            onTap: () =>  getOneMaterial(context, item.id, item.title),
            title: Text(item.title),
            subtitle: Text(item.description),
          )
        );
      }).toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Other Resources'),
        backgroundColor:  Colors.blueAccent,
      ),
      body: Container(
        color: Color(0xfff4f4f4),
        width: AppTheme.fullWidth(context),
        height: AppTheme.fullHeight(context),
        child: StoreConnector<AppState, AppState>(
          builder: (BuildContext context, AppState state){
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: SingleChildScrollView(
                child: FutureBuilder(
                      future: getResources(context) ,
                      builder: (BuildContext context, AsyncSnapshot<List<ResourceCategory>> snapshot){
                        if(snapshot.connectionState == ConnectionState.done){
                          if(snapshot.hasData && snapshot.data.length > 0){
                            return _renderResources(context, snapshot.data);
                          }
                          return Container(
                            width: AppTheme.fullWidth(context),
                            height: AppTheme.fullHeight(context),
                            child: Center(child: Text('No Resources yet')),
                          );
                        }
                        return Container(
                          width: AppTheme.fullWidth(context),
                            height: AppTheme.fullHeight(context),
                            child: Center(child: CircularProgressIndicator()),
                        );
                      })
              )
            );
          }, 
          converter: (store) => store.state),
      ),
    );
  }
}