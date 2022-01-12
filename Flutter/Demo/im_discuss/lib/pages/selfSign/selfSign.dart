import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/colors.dart';

class SelfSign extends StatefulWidget {
  const SelfSign({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SelfSignState();
}

class SelfSignState extends State<SelfSign> {
  String sign = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        title: const Text(
          '设置签名',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                onChanged: (v) {
                  setState(() {
                    sign = v;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        V2TimCallback res =
                            await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
                          userFullInfo: V2TimUserFullInfo.fromJson(
                            {
                              "selfSignature": sign,
                            },
                          ),
                        );
                        if (res.code == 0) {
                          Utils.log("succcess");
                          Navigator.pop(context);
                        } else {
                          Utils.log(res);
                        }
                      },
                      child: const Text("确定"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
