import 'package:flutter/material.dart';
import 'package:im_api_example/config/config.dart';
import 'package:im_api_example/provider/event.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:im_api_example/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
// import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class SetOfflinePushConfig extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SetOfflinePushConfigState();
}

class SetOfflinePushConfigState extends State<SetOfflinePushConfig> {
  late TextEditingController bcontroller = new TextEditingController();
  Map<String, dynamic>? resData;
  int businessID = 0;
  String deviceToken = ''; // 设备token，im推送用这个。
  String token = ''; // tpns的token,业务后台可以用这个。
  String pushType = "";
  List<String> users = List.empty(growable: true);
  Map<String, int> config = Map<String, int>.from({
    "fcm": 6768,
    "huawei": 5220,
  });
  setOfflinePushConfig() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getOfflinePushManager()
        .setOfflinePushConfig(
          businessID: businessID.toDouble(),
          token: deviceToken,
        );
    setState(() {
      resData = res.toJson();
    });
  }

  void initState() {
    super.initState();
    // initPlatformState();
  }

  // initPlatformState() async {
  //   /// 开启DEBUG
  //   XgFlutterPlugin().setEnableDebug(true);

  //   // /// 添加回调事件
  // XgFlutterPlugin().addEventHandler(
  //   onRegisteredDeviceToken: (String msg) async {
  //     print("onRegisteredDeviceToken $msg");
  //     Provider.of<Event>(context, listen: false).addEvents(
  //       new Map<String, dynamic>.from(
  //         {"type": "onRegisteredDeviceToken", "data": msg},
  //       ),
  //     );
  //   },
  //     onRegisteredDone: (String msg) async {
  //       print("onRegisteredDone $msg");
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "onRegisteredDone", "data": msg},
  //         ),
  //       );
  //       _showAlert("注册成功");
  //       setState(() {
  //         token = msg;
  //       });
  //     },
  //     unRegistered: (String msg) async {
  //       print("unRegistered $msg");
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "unRegistered", "data": msg},
  //         ),
  //       );
  //       _showAlert(msg);
  //     },
  //     onReceiveNotificationResponse: (Map<String, dynamic> msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "onReceiveNotificationResponse", "data": msg},
  //         ),
  //       );
  //       print("flutter onReceiveNotificationResponse $msg");
  //     },
  //     onReceiveMessage: (Map<String, dynamic> msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "onReceiveMessage", "data": msg},
  //         ),
  //       );
  //       print("flutter onReceiveMessage $msg");
  //     },
  //     xgPushDidSetBadge: (String msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "xgPushDidSetBadge", "data": msg},
  //         ),
  //       );
  //       print("flutter xgPushDidSetBadge: $msg");

  //       /// 在此可设置应用角标
  //       /// XgFlutterPlugin().setAppBadge(0);
  //       _showAlert(msg);
  //     },
  //     xgPushDidBindWithIdentifier: (String msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "xgPushDidBindWithIdentifier", "data": msg},
  //         ),
  //       );
  //       print("flutter xgPushDidBindWithIdentifier: $msg");
  //       _showAlert(msg);
  //     },
  //     xgPushDidUnbindWithIdentifier: (String msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "xgPushDidUnbindWithIdentifier", "data": msg},
  //         ),
  //       );
  //       print("flutter xgPushDidUnbindWithIdentifier: $msg");
  //       _showAlert(msg);
  //     },
  //     xgPushDidUpdatedBindedIdentifier: (String msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "xgPushDidUpdatedBindedIdentifier", "data": msg},
  //         ),
  //       );
  //       print("flutter xgPushDidUpdatedBindedIdentifier: $msg");
  //       _showAlert(msg);
  //     },
  //     xgPushDidClearAllIdentifiers: (String msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "xgPushDidClearAllIdentifiers", "data": msg},
  //         ),
  //       );
  //       print("flutter xgPushDidClearAllIdentifiers: $msg");
  //       _showAlert(msg);
  //     },
  //     xgPushClickAction: (Map<String, dynamic> msg) async {
  //       Provider.of<Event>(context, listen: false).addEvents(
  //         new Map<String, dynamic>.from(
  //           {"type": "xgPushClickAction", "data": msg},
  //         ),
  //       );
  //       print("flutter xgPushClickAction $msg");
  //       _showAlert("flutter xgPushClickAction");
  //     },
  //   );

  //   // /// 如果您的应用非广州集群则需要在startXG之前调用此函数
  //   // /// 香港：tpns.hk.tencent.com
  //   // /// 新加坡：tpns.sgp.tencent.com
  //   // /// 上海：tpns.sh.tencent.com
  //   // // XgFlutterPlugin().configureClusterDomainName("tpns.hk.tencent.com");
  //   XgFlutterPlugin().startXg(Config.XG_ACCESS_ID, Config.XG_ACCESS_KEY);

  //   XgFlutterPlugin.xgApi.enableOtherPush();
  //   XgFlutterPlugin.xgApi.regPush();
  //   // print("********");
  //   String ot = await XgFlutterPlugin.xgApi.getOtherPushToken();
  //   print("ot $ot");
  //   String oty = await XgFlutterPlugin.xgApi.getOtherPushType();
  //   print("oty $oty");
  //   // String xt = await XgFlutterPlugin.xgApi.getXgToken();

  //   // print("xt $xt");

  //   setState(() {
  //     deviceToken = ot;
  //     pushType = oty;
  //     switch (oty) {
  //       case 'fcm':
  //         if (config.isNotEmpty) {
  //           businessID = config['fcm']!;
  //           XgFlutterPlugin.xgApi.startFcmPush();
  //         }
  //         break;
  //       case 'huawei':
  //         businessID = config['huawei']!;
  //         XgFlutterPlugin.xgApi.startHuaWeiPush();
  //         break;
  //     }
  //   });
  //   bcontroller.value =
  //       TextEditingValue.fromJSON({"text": businessID.toString()});
  //   print("********");
  // }

  void _showAlert(String title) {
    Utils.toast(title);
  }

  getToken() {}
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text("token"),
              Expanded(
                  child: Container(
                child: Text(deviceToken),
                margin: EdgeInsets.only(left: 12),
                alignment: Alignment.centerLeft,
                height: 60,
              ))
            ],
          ),
          Form(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: "证书id",
                    hintText: "控制台上传证书返回的id",
                    prefixIcon: Icon(Icons.person),
                  ),
                  controller: bcontroller,
                  keyboardType: TextInputType.number,
                  onChanged: (res) {
                    setState(() {
                      businessID = int.parse(res);
                    });
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: setOfflinePushConfig,
                  child: Text("上报推送配置"),
                ),
              )
            ],
          ),
          SDKResponse(resData),
        ],
      ),
    );
  }
}
