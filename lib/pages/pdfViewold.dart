import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/pages/home.dart';
import 'package:toast/toast.dart';
import 'package:studyapp/redux/actions.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PdfViewerState();
  }
}

class _PdfViewerState extends State<PdfViewer>{
  final String user = 'Bukola Damola';
  String pathPDF = "";
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  // Permission permission;
  Permission _permission;
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    print('state loaded');
    requestPermission();
  }

  Future<String> get _localPath async {
    var directory;
    directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> _localFile(String schoolLevel, String subject) async {
    final path = await _localPath;
    return File('$path/$schoolLevel/$subject.pdf');
  }

  Future<File> writeToExternalFiles(String subject, String materialName, String schoolLevel) async{
    File file;
    try{
      final status = await Permission.storage.request();
      print('print: ' + status.toString());
      if(status.isGranted){
        // await get
        String path = (await getExternalStorageDirectory()).path;
        print('here now pdf file path');
        file = File('$path/Documents/easystudy/resources/$schoolLevel/$subject/$materialName.pdf');
        return file;
      }
      throw 'Could not luanch file';
    }catch(error){
      print('some errors were encountered: '+ error.toString());
      throw 'Could not luanch file';
    }
  }

   requestPermission() async{
    final status = await Permission.storage.request();
    if(status.isGranted){
      print('permission is granted');
    }
    print('permission is not granted');
  }

  Future<bool> checkIfMaterialExistInStorage(String schoolLevel, String subject, String materialName) async{
    final status = await Permission.storage.request();
    File file;
    if(status.isGranted){
      String path = (await getExternalStorageDirectory()).path;
        print('here now pdf file path');
        file = File('$path/Documents/easystudy/resources/$schoolLevel/$subject/$materialName.pdf');
        return await file.exists();
    }
    throw 'Some errors encountered opening file path';
  }

  Future<File> getMaterialFromStorage(String schoolLevel, String subject, String materialName) async{
    final status = await Permission.storage.request();
    File file;
    if(status.isGranted){
      String path = (await getExternalStorageDirectory()).path;
        print('here now pdf file path');
        File file = File('$path/Documents/easystudy/resources/$schoolLevel/$subject/$materialName.pdf');
        return file;
    }
    Toast.show("Permission to file storage not granted. Please kindly grant permission", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    throw 'Some errors encountered opening file path';
  }

   Future<File> createFileOfPdfUrl(Map<String, dynamic> material, String schoolLevel) async {
     try{
          if( await checkIfMaterialExistInStorage(schoolLevel, material['subject'], material['file_name'])){
              print('fetching from local storage');
              var file = await getMaterialFromStorage(schoolLevel, material['subject'], material['file_name']);
              return file;
            }else{
              print('fetching from the internet');
              final url = material['file_url'];
              final filename = url.substring(url.lastIndexOf("/") + 1);
              var request = await HttpClient().getUrl(Uri.parse(url));
              var response = await request.close();
              var bytes = await consolidateHttpClientResponseBytes(response);
              String dir = (await getApplicationDocumentsDirectory()).path;
              File file = new File('$dir/$filename');
              // print('bytes: '+ bytes.toString());
              await file.writeAsBytes(bytes);

              File localFileMaterial = await writeToExternalFiles(material['subject'], material['file_name'], schoolLevel);
              if(!(await localFileMaterial.exists())){
                print('file does not exists');
                await localFileMaterial.create(recursive: true);
                print('file and file path created');
                await localFileMaterial.writeAsBytes(bytes);
                print('file wrtten to: '+ localFileMaterial.path.toString());

              }
              return file;
            }
     }catch(error){
        print('fetching from the internet');
        final url = material['file_url'];
        final filename = url.substring(url.lastIndexOf("/") + 1);
        var request = await HttpClient().getUrl(Uri.parse(url));
        var response = await request.close();
        var bytes = await consolidateHttpClientResponseBytes(response);
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = new File('$dir/$filename');
        // print('bytes: '+ bytes.toString());
        await file.writeAsBytes(bytes);
        return file;
     }
    
  }
    Future<File> readcontent(String schoolLevel, String subject ) async {
      try {
        final file = await _localFile(schoolLevel, subject);
        // Read the file
        var fileReaded = await file.readAsBytes();
        String dir = (await getApplicationDocumentsDirectory()).path;
        File files = new File('$dir/$schoolLevel/$subject.pdf');
        var fileRead = files.writeAsBytes(fileReaded);
        return fileRead;
      } catch (e) {
        // If there is an error reading, return a default String
        throw 'Error';
      }
    }
  getDownloadMaterial(Map<String, dynamic> material, String schoolLevel){
    createFileOfPdfUrl(material, schoolLevel).then((f) {
      setState(() {
        pathPDF = f.path;
        print('pfg of is: '+pathPDF);
      });
    }).catchError((t){
      print('erros is'+ t.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('file: '+ pathPDF);
    
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if(pathPDF.isEmpty){
          getDownloadMaterial(state.selectedMaterial, state.schoolLevel);
        }
        print('selected: '+ state.selectedMaterial.toString());
        if(state.selectedMaterial != null){
            return Scaffold(

          // appBar: AppBar(
          //   title: Text(state.selectedMaterial['name']),
          //   backgroundColor: Colors.blueAccent,
          // ),
          endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment:  CrossAxisAlignment.start,
            children: <Widget>[
            Container(

              height: 200,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
              ),
              child: Center(
                child: Text(user,
                  textAlign: TextAlign.center,
                  style: TextStyle(

                    color: Colors.white, fontFamily: 'Gilroy',
                      fontSize: 26,
                     fontWeight: FontWeight.w800
                    ),
                ) ,)
            ,),
            SizedBox(height: 20,),
            FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Home'),
                          leading: Icon(Icons.home),
                        ),
                      ),
            onPressed: (){
              Navigator.pop(context);
              StoreProvider.of<AppState>(context).dispatch(TabIndex(0));
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
            }
            ),
            FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Learning'),
                          leading: Icon(LineIcons.book),
                        ),
                      ),
            onPressed: (){
              Navigator.pop(context);
              StoreProvider.of<AppState>(context).dispatch(TabIndex(1));
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
            }
            ),
            FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Classroom'),
                          leading: Icon(LineIcons.users),
                        ),
                      ),
            onPressed: (){
              Navigator.pop(context);
              StoreProvider.of<AppState>(context).dispatch(TabIndex(2));
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
            }
            ),
            FlatButton(child: Card(
                        child: ListTile(
                          title: Text('Profile'),
                          leading: Icon(LineIcons.user),
                        ),
                      ),
            onPressed: (){
              Navigator.pop(context);
              StoreProvider.of<AppState>(context).dispatch(TabIndex(3));
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()) );
            }
            )
        ],)
        ,) 
        
      ) ,
          body: Stack(children: <Widget>[
                pathPDF.isNotEmpty ? PDFViewerScaffold(
        appBar: AppBar(
          title: Text(state.selectedMaterial['file_name']),
          actions: <Widget>[
            IconButton(
              icon: Icon(LineIcons.sticky_note_o),
              onPressed: () {},
            ),
          ],
        ),
        path: pathPDF) : 
          Center(
                      child: CircularProgressIndicator(),
          ),
          // errorMessage.isEmpty
          //     ? !isReady
          //         ? Center(
          //             child: CircularProgressIndicator(),
          //           )
          //         : Container()
          //     : Center(
          //         child: Text(errorMessage),
          //       )
          ],),
        );
        }
        return Scaffold(
          body: Center(child: Text(''),)
        );
      });
    
        
  }
}

/*
PDFView(
            filePath:  pathPDF,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            defaultPage: currentPage,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
                print('on render is called: '+ pages.toString());
              });
              
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
                print('error is in here: ' + error.toString());
              });
              print('error is: ' + error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
                print('page error is: ' + '$page: ${error.toString()}');
              });
              
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
              print('view created');
            },
            onPageChanged: (int page, int total) {
              print('error is: ' +'page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          )

          PDFViewerScaffold(
        appBar: AppBar(
          title: Text(state.selectedMaterial['name']),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        path: pathPDF)
*/