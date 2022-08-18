// ignore_for_file: avoid_print


import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:example/config/config.dart';
import 'package:example/entity/api_data_entity.dart';
import 'package:example/entity/api_item_entity.dart';
import 'package:example/i18n/i18n_utils.dart';
import 'package:example/im/apiDetailLayout.dart'; 
import 'package:example/setting/userSetting.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class ExampleList extends StatefulWidget {
  const ExampleList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExampleListState();
}

class ExampleListState extends State<ExampleList> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: Config.apiData.map((e) => Managers(
                      ApiData.fromJson(e),
                    )).toList()
            ),
            
          ),
        )
      ],
    );
  }
}

class Managers extends StatelessWidget {
  final ApiData data;
   const Managers(this.data, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.blueAccent,
      //z轴的高度，设置card的阴影
      elevation: 10.0,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      //设置shape，这里设置成了R角
      shape:  const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      clipBehavior: Clip.antiAlias,
      semanticContainer: true,
      child: ExpandablePanel(
        header: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  data.managerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        collapsed: Container(),
        expanded: Column(
          children: data.apis.map((e) => Apis(e)).toList(),
        ),
        theme: const ExpandableThemeData(),
      ),
    );
  }
}

class Apis extends StatelessWidget {
  late final ApiItem api;
  final LocalStorage storage =  LocalStorage('package:example_user_info');

  Apis(this.api, {Key? key}) : super(key: key);

  toApiDetailPage(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ApiDetailLayout(api),
      ),
    );
  }

  Future<bool> isSetUser(context) async {
    String? sdkappid = storage.getItem("sdkappid");
    String? secret = storage.getItem("secret");
    String? userID = storage.getItem("userID");
    print("sdkappid $sdkappid secret $secret userID $userID");
    if (sdkappid == null && secret == null && userID == null) {
      OkCancelResult res = await showOkAlertDialog(
        context: context,
        title: imt("提示"),
        message: imt("检测到您还未配置应用信息，请先配置"),
        okLabel: imt("去配置"),
      );
      if (res.index == 0) {
        openSettingPage(context);
      }
      return false;
    }
    return true;
  }

  openSettingPage(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSetting(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        border:  Border(
          bottom: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          bool res = await isSetUser(context);
          if (res) {
            toApiDetailPage(context);
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${api.apiNameCN} ${api.apiName}',
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
