import 'package:im_api_example/entity/api_item_entity.dart';

class ApiData {
  late String apiManager;
  late String managerName;
  late List<ApiItem> apis;

  ApiData({
    required this.apiManager,
    required this.managerName,
    required this.apis,
  });

  ApiData.fromJson(Map<String, dynamic> json) {
    apiManager = json['apiManager'];
    managerName = json['managerName'];
    apis = [];
    json['apis'].forEach((v) {
      apis.add(new ApiItem.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['apiManager'] = this.apiManager;
    data['managerName'] = this.managerName;
    data['apis'] = this.apis.map((v) => v.toJson()).toList();
    return data;
  }
}
