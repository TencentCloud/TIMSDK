import 'package:flutter/material.dart';

typedef  LoadLib = Future<dynamic> Function();
typedef GetWidget = Widget Function();
class ApiItem {
  late String apiName;
  late String apiNameCN;
  late String apiDesc;
  late String codeFile;
  late LoadLib detailRoute;
  late GetWidget libs;

  ApiItem({
    required this.apiName,
    required this.apiNameCN,
    this.apiDesc = '',
    required this.detailRoute,
    required this.codeFile,
    required this.libs,
  });

  ApiItem.fromJson(Map<String, dynamic> json) {
    apiName = json['apiName'];
    apiNameCN = json['apiNameCN'];
    apiDesc = json['apiDesc'];
    detailRoute = json['detailRoute'];
    codeFile = json['codeFile'];
    libs = json['libs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>.from({});
    data['apiName'] = apiName;
    data['apiNameCN'] = apiNameCN;
    data['apiDesc'] = apiDesc;
    data['detailRoute'] = detailRoute;
    data['codeFile'] = codeFile;
    data['libs'] = libs;
    return data;
  }
}
