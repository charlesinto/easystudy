import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PdfViewer extends StatefulWidget{
  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> with WidgetsBindingObserver {
  String pathPDF = "";
  String corruptedPathPDF = "";
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  Future<File> createFileOfPdfUrl(String url) async {
    // final url =
    // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
    // final url = "https://pdfkit.org/docs/guide.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
  Future<File> getFile(var material) async{
    try{
      var file = await createFileOfPdfUrl(material['file_url']);
      print(file.path);
      return file;
    }catch(error){
      throw error;
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var deviceHeight = MediaQuery.of(context).size.height;
    return StoreConnector<AppState, AppState>(
      builder: (BuildContext context, state){
        return Scaffold(
            appBar: AppBar(
              title: Text(state.selectedMaterial['file_name'].toString()),
              backgroundColor: Colors.blueAccent,
            ),
            body: SafeArea(
              child: Container(
                child: SingleChildScrollView(
                  child: FutureBuilder(
                    future: getFile(state.selectedMaterial),
                    builder: (BuildContext context, AsyncSnapshot<File> snapshot){
                      if(snapshot.connectionState == ConnectionState.done){
                        if(snapshot.hasData){
                          return Container(
                            height: deviceHeight,
                            child: PDFView(
                                    filePath: snapshot.data.path,
                                    enableSwipe: true,
                                    swipeHorizontal: true,
                                    autoSpacing: true,
                                    pageFling: true,
                                    defaultPage: currentPage,

                                    // fitPolicy: FitPolicy,
                                    onRender: (_pages) {
                                      setState(() {
                                        pages = _pages;
                                        isReady = true;
                                      });
                                    },
                                    onError: (error) {
                                      setState(() {
                                        errorMessage = error.toString();
                                      });
                                      print(error.toString());
                                    },
                                    onPageError: (page, error) {
                                      setState(() {
                                        errorMessage = '$page: ${error.toString()}';
                                      });
                                      print('$page: ${error.toString()}');
                                    },
                                    onViewCreated: (PDFViewController pdfViewController) {
                                      _controller.complete(pdfViewController);
                                    },
                                    onPageChanged: (int page, int total) {
                                      print('page change: $page/$total');
                                      setState(() {
                                        currentPage = page;
                                      });
                                    },
                                  )
                          );
                        }
                        print(snapshot.data);
                        return Container(
                          height: deviceHeight,
                          child: Center(
                            child: Text('Some error were encountered reading the material') ,)
                        );
                      }
                      return Container(
                        height: deviceHeight,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40.0,),
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