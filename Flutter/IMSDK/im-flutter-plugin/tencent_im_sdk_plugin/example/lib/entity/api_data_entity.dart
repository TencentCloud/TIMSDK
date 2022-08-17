import 'package:example/entity/api_item_entity.dart';

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
    try {
      apiManager = json['apiManager'];
      managerName = json['managerName'];
      apis = [];
      json['apis'].forEach((v) {
        apis.add(ApiItem.fromJson(v));
      });
    } catch (err) {
      print(err);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>.from({});
    data['apiManager'] = apiManager;
    data['managerName'] = managerName;
    data['apis'] = apis.map((v) => v.toJson()).toList();
    return data;
  }
}
