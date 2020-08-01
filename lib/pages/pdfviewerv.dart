// import 'dart:async';
// import 'dart:io' show Platform;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pdftron_flutter/pdftron_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';

// class Pdf extends StatefulWidget {
//   final String materialName;
//   final String url;
//   Pdf({@required this.materialName, @required this.url});
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<Pdf> {
//   String _version = 'Unknown';
//   String _document = "";

//   @override
//   void initState() {
//     super.initState();
//     _document = widget.url;
//     initPlatformState();

//     if (Platform.isIOS) {
//       // Open the document for iOS, no need for permission
//       showViewer();

//     } else {
//       // Request for permissions for android before opening document
//       launchWithPermission();
//     }
//   }

//   Future<void> launchWithPermission() async {
//     var permissions = await Permission.storage.request();
//     if (permissions.isGranted) {
//       showViewer();
//     }
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     String version;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       PdftronFlutter.initialize("");
//       version = await PdftronFlutter.version;
//     } on PlatformException {
//       version = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _version = version;
//     });
//   }


//   void showViewer() {
//     // Shows how to disable functionality. Uncomment to configure your viewer with a Config object.
//      var disabledElements = [Buttons.shareButton, Buttons.searchButton, Buttons.editPagesButton];
//      var disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
//      var config = Config();
//      config.disabledElements = disabledElements;
//      config.disabledTools = disabledTools;
//     config.customHeaders = {'headerName': widget.materialName};
//      PdftronFlutter.openDocument(_document, config: config);

//     // Open document without a config file which will have all functionality enabled.
//     // PdftronFlutter.openDocument(widget.url);
//   }

//   bool granted(PermissionStatus status) {
//     return status == PermissionStatus.granted;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title:  Text(widget.materialName),
//         ),
//         body: Center(
//           child: Text('Loading...'),
//         ),
//       ),
//     );
//   }
// }