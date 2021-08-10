import 'package:flutter/material.dart';

class ApiItem {
  late String apiName;
  late String apiNameCN;
  late String apiDesc;
  late String codeFile;
  late Widget detailRoute;

  ApiItem({
    required this.apiName,
    required this.apiNameCN,
    this.apiDesc = '',
    required this.detailRoute,
    required this.codeFile,
  });

  ApiItem.fromJson(Map<String, dynamic> json) {
    apiName = json['apiName'];
    apiNameCN = json['apiNameCN'];
    apiDesc = json['apiDesc'];
    detailRoute = json['detailRoute'];
    codeFile = json['codeFile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['apiName'] = this.apiName;
    data['apiNameCN'] = this.apiNameCN;
    data['apiDesc'] = this.apiDesc;
    data['detailRoute'] = this.detailRoute;
    data['codeFile'] = this.codeFile;
    return data;
  }
}
