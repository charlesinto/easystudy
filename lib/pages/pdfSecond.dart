import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_resource_material.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:studyapp/util/theme.dart';

class PdfSecond extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _PdfSecond();
}

class _PdfSecond extends State<PdfSecond>{
  String pathPDF = "";
  String corruptedPathPDF = "";
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  PDFDocument document;
  Future<File> createFileOfPdfUrl(String url) async {
    print('called here now');
    // Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
        final filename = url.substring(url.lastIndexOf("/") + 1);
        print(url);
        print(filename);
        var response = await http.get(url);
        var dir = await getApplicationDocumentsDirectory();
        print('dir '+ dir.toString());
        print("Download files");
        print("${dir.path}/$filename");
        File file = File("${dir.path}/$filename");
        await file.writeAsBytes(response.bodyBytes, flush: true);
        document = await PDFDocument.fromFile(file);
        return file;
    } catch (e) {
      print('some erros '+ e.toString());
      throw Exception('Error parsing asset file!');
    }
  }
  // @override
  // void dispose() {
  //   _pdfController.dispose();
  //   super.dispose();
  // }
  Future<File> getFile(ResourceMaterial material) async{
    try{
      var file = await createFileOfPdfUrl(material.fileUrl);
      print(file.path);
      return file;
    }catch(error){
      throw error;
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StoreConnector<AppState, AppState>(
      builder: (BuildContext context, state){
        return Scaffold(
            appBar: AppBar(
              title: Text(state.resource.fileName),
              backgroundColor: Colors.blueAccent,
            ),
            body: SafeArea(
              child: Container(
                child: SingleChildScrollView(
                  child: FutureBuilder(
                    future: getFile(state.resource),
                    builder: (BuildContext context, AsyncSnapshot<File> snapshot){
                      if(snapshot.connectionState == ConnectionState.done){
                        if(snapshot.hasData){
                          print(snapshot.data);
                          return Container(
                            height: AppTheme.fullHeight(context),
                            child: 
                            PDFViewer(document: document)
                            
                          );
                        }
                        print(snapshot.data);
                        return Container(
                          height: AppTheme.fullHeight(context),
                          child: Center(
                            child: Text('Some error were encountered reading the material') ,)
                        );
                      }
                      return Container(
                        height: AppTheme.fullHeight(context),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SizedBox(height: 40.0,),
                          CircularProgressIndicator()
                        ]
                      )
                      );
                  }),
                  )
              ) ,)
          );
      },
     converter: (store) => store.state);
  }
}