import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class CreateTopicInCommunity extends StatefulWidget {
  const CreateTopicInCommunity({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateGroupState();
}

class CreateGroupState extends State<CreateTopicInCommunity> {
  Map<String, dynamic>? resData;

  String topicName = '';
  String groupID = '@TGS#_@TGS#cXNJ3HIM62CC';
  String notification = "";
  String introduction = "";
  String createdTopicId = "";
  // 3.6.0 后不建议使用简单方法创建群
  createGroup() async {
    V2TimValueCallback<String> res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .createTopicInCommunity(
            groupID: '@TGS#_@TGS#cXNJ3HIM62CC',
            topicInfo: V2TimTopicInfo.fromJson({
              "topicName": "Test topic",
              "notification": notification,
              "introduction": introduction
            }));
    setState(() {
      createdTopicId = res.data!;
      resData = res.toJson();
    });
  }

  deleteTopic() async {
    V2TimValueCallback<List<V2TimTopicOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .deleteTopicFromCommunity(
                groupID: '@TGS#_@TGS#cXNJ3HIM62CC',
                topicIDList: [createdTopicId]);
    setState(() {
      resData = res.toJson();
    });
  }

  updateTopic() async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().setTopicInfo(
            groupID: '@TGS#_@TGS#cXNJ3HIM62CC',
            topicInfo: V2TimTopicInfo.fromJson({
              "topicID": createdTopicId,
              "topicName": "updated topic",
              "notification": notification,
              "introduction": introduction
            }));
    // V2TimValueCallback<List<V2TimTopicOperationResult>> res =
    //     await TencentImSDKPlugin.v2TIMManager
    //         .getGroupManager()
    //         .deleteTopicFromCommunity(
    //             groupID: '@TGS#_@TGS#cXNJ3HIM62CC',
    //             topicIDList: [
    //       "@TGS#_@TGS#cXNJ3HIM62CC@TOPIC#_@TOPIC#cPOJ3HIM62CN"
    //     ]);

    setState(() {
      resData = res.toJson();
    });
  }

  getTopic() async {
    V2TimValueCallback<List<V2TimTopicInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getTopicInfoList(
                groupID: '@TGS#_@TGS#cXNJ3HIM62CC', topicIDList: []);
    setState(() {
      resData = res.toJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        labelText: imt("群ID"),
                        hintText: imt("需要创建话题的社群ID"),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: (res) {
                        setState(() {
                          groupID = res;
                        });
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: imt("话题名称"),
                        hintText: imt("话题名称"),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: (res) {
                        setState(() {
                          topicName = res;
                        });
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: imt("notification"),
                        hintText: imt("notification"),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: (res) {
                        setState(() {
                          notification = res;
                        });
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: imt("简介"),
                        hintText: imt("简介"),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: (res) {
                        setState(() {
                          introduction = res;
                        });
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: createGroup,
                child: Text(imt("创建话题")),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: getTopic,
                child: Text(imt("获取话题")),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: deleteTopic,
                child: Text(imt("删除话题")),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: updateTopic,
                child: Text(imt("更新话题")),
              ),
            )
          ],
        ),
        SDKResponse(resData),
      ],
    );
  }
}
