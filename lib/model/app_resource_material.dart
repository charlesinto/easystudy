

import 'package:flutter/cupertino.dart';

class ResourceMaterial{
  final String id;
  final String fileName;
  final String fileType;
  final String category;
  final String categoryId;
  final String fileUrl;
  ResourceMaterial({@required this.id, @required this.category, @required this.categoryId, @required this.fileName,
   @required this.fileType, @required this.fileUrl});
}