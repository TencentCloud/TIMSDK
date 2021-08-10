import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomMessage extends StatefulWidget {
  CustomMessage(this.message);
  final V2TimMessage message;
  @override
  State<StatefulWidget> createState() => CustomMessageState();
}

class CustomMessageState extends State<CustomMessage> {
  V2TimMessage? message;
  @override
  void initState() {
    this.message = widget.message;
    super.initState();
  }

  Widget showMessage() {
    Widget res;
    String? data = message!.customElem!.data;
    try {
      var version = json.decode(data!)['version'];
      String text = json.decode(data)['text'];
      String link = json.decode(data)['link'];
      if (version == 4) {
        print(data);
        String businessID = json.decode(data)['businessID'];
        if (businessID == 'group_create') {
          res = Container(
            child: Text("${json.decode(data)['opUser']}创建群组"),
          );
        } else {
          res = Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                InkWell(
                  onTap: () {
                    launch(
                      link,
                    );
                  },
                  child: Text(
                    '点击查看>>>',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: CommonColors.getThemeColor(),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      } else {
        res = Text(
          '自定义消息未解析成功 $data',
        );
      }
    } catch (err) {
      res = Text('自定义消息解析失败 $data');
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return Container(
        child: Text('null'),
      );
    }
    return showMessage();
  }
}
