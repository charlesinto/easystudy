

import 'package:flutter/cupertino.dart';
import 'package:studyapp/model/app_resource_material.dart';

class ResourceContent{
  final String name;
  final List<ResourceMaterial> materials;
  ResourceContent({@required this.materials, @required this.name});
}