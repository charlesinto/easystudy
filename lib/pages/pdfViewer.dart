import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:studyapp/model/app_state.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';

class PdfViewer extends StatefulWidget{
  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> with WidgetsBindingObserver {
  String pathPDF = "";
  String corruptedPathPDF = "";
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int _actualPageNumber = 1, _allPagesCount = 0;
  PdfController _pdfController;
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
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
        // final url = "https://pdfkit.org/docs/guide.pdf";
        // final url = "http://www.pdf995.com/samples/pdf.pdf";
        final filename = url.substring(url.lastIndexOf("/") + 1);
        print(url);
        print(filename);
        // var request = await HttpClient().getUrl(Uri.parse(url));
        // var response = await request.close();
        var response = await http.get(url);
        // print(response.)
        // print(response);
        // var bytes = await consolidateHttpClientResponseBytes(response);
        // print('>>>>>>>>'+ bytes.toString());
        var dir = await getApplicationDocumentsDirectory();
        print('dir '+ dir.toString());
        print("Download files");
        print("${dir.path}/$filename");
        File file = File("${dir.path}/$filename");
        //  _pdfController = PdfController(document: PdfDocument.openFile(file.path) );
        await file.writeAsBytes(response.bodyBytes, flush: true);
        document = await PDFDocument.fromFile(file);
        // document = PDFDocument.
        // completer.complete(file);
        return file;
    } catch (e) {
      print('some erros '+ e.toString());
      throw Exception('Error parsing asset file!');
    }

    // return completer.future;
    // final url =
    // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
    // final url = "https://pdfkit.org/docs/guide.pdf";
    // final filename = url.substring(url.lastIndexOf("/") + 1);
    // var request = await HttpClient().getUrl(Uri.parse(url));
    // var response = await request.close();
    // var bytes = await consolidateHttpClientResponseBytes(response);
    // String dir = (await getExternalStorageDirectory()).path;
    // print(dir);
    // File file = new File('$dir/$filename');
    // await file.writeAsBytes(bytes);
    // _pdfController = PdfController(document: PdfDocument.openAsset(file.path));
    // return file;
  }
  // @override
  // void dispose() {
  //   _pdfController.dispose();
  //   super.dispose();
  // }
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
                          print(snapshot.data);
                          return Container(
                            height: deviceHeight,
                            child: 
                            PDFViewer(document: document)
                            // PDFViewerScaffold(
                            //   // appBar: AppBar(
                            //   //   // title: Text(state.selectedMaterial['file_name']),
                            //   //   actions: <Widget>[
                            //   //     IconButton(
                            //   //       icon: Icon(LineIcons.sticky_note_o),
                            //   //       onPressed: () {},
                            //   //     ),
                            //   //   ],
                            //   // ),
                            //   path: snapshot.data.path)
                            // PdfView(
                            //     documentLoader: Center(child: CircularProgressIndicator()),
                            //     pageLoader: Center(child: CircularProgressIndicator()),
                            //     controller: _pdfController,
                            //     onDocumentLoaded: (document) {
                            //       setState(() {
                            //         _allPagesCount = document.pagesCount;
                            //       });
                            //     },
                            //     onPageChanged: (page) {
                            //       setState(() {
                            //         _actualPageNumber = page;
                            //       });
                            //     },
                            //   ),
                            // PDFView(
                            //         filePath: snapshot.data.path,
                            //         enableSwipe: true,
                            //         swipeHorizontal: true,
                            //         autoSpacing: true,
                            //         pageFling: true,
                            //         defaultPage: currentPage,
                            //         fitPolicy: FitPolicy.HEIGHT,
                            //         // fitPolicy: FitPolicy,
                            //         onRender: (_pages) {
                            //           setState(() {
                            //             pages = _pages;
                            //             isReady = true;
                            //           });
                            //         },
                            //         onError: (error) {
                            //           // print('error'+ error.t);
                            //           setState(() {
                            //             errorMessage = error.toString();
                            //           });
                            //           print(error.toString());
                            //         },
                            //         onPageError: (page, error) {

                            //           setState(() {
                            //             errorMessage = '$page: ${error.toString()}';
                            //           });
                            //           print('$page: ${error.toString()}');
                            //         },
                            //         onViewCreated: (PDFViewController pdfViewController) {
                            //           _controller.complete(pdfViewController);
                            //         },
                            //         onPageChanged: (int page, int total) {
                            //           print('page change: $page/$total');
                            //           setState(() {
                            //             currentPage = page;
                            //           });
                            //         },
                            //       )
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