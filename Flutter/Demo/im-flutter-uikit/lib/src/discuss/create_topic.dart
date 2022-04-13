import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/utils/discuss.dart';
import 'package:timuikit/utils/toast.dart';

import '../chat.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class CreateTopic extends StatefulWidget {
  final String disscussId;
  final String message;
  final List<String> messageIdList;
  const CreateTopic({
    Key? key,
    required this.disscussId,
    required this.message,
    required this.messageIdList,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => CreateTopicState();
}

class CreateTopicState extends State<CreateTopic> {
  final TextEditingController controller = TextEditingController();
  String disscussId = "";
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  final List<Map<String, String>> allTags = [
    {"text": imt("性能"), "color": "229800"},
    {"text": "BUG", "color": "b61903"},
    {"text": "Flutter", "color": "5fe5f4"},
    {"text": "TRTC", "color": "0279a4"},
    {"text": "Electron", "color": "d4c5fa"},
    {"text": "PC", "color": "fbca05"},
    {"text": "iOS", "color": "2b2b2b"},
    {"text": "Android", "color": "e4f0fe"}
  ];
  final FocusNode focusNode = FocusNode();
  List selected = [imt("性能")];
  String title = '';
  List<Map<String, dynamic>> discussList = [];
  String currentSelectedDis = '';
  List<String> messageIdList = [];
  List<V2TimMessage> messageList = [];

  @override
  initState() {
    if (widget.message.isNotEmpty) {
      controller.value = TextEditingValue(text: widget.message);
    }
    setState(() {
      title = widget.message;
      disscussId = widget.disscussId;
      messageIdList = widget.messageIdList;
    });
    getMessages();
    getDiscussList();
    super.initState();
  }

  getMessages() async {
    if (widget.messageIdList.isNotEmpty) {
      V2TimValueCallback<List<V2TimMessage>> res =
          await sdkInstance.getMessageManager().findMessages(
                messageIDList: widget.messageIdList,
              );
      if (res.code == 0) {
        String getMsg = res.data!.length.toString();
        Utils.log(
            imt_para("获取到的消息:{{getMsg}}", "获取到的消息:$getMsg")(getMsg: getMsg));
        setState(() {
          messageList = res.data!;
        });
      }
    }
  }

  tagTap(String text) {
    focusNode.unfocus();
    List selectedCopy = selected;
    if (selected.contains(text)) {
      selectedCopy.remove(text);
    } else {
      selectedCopy.add(text);
    }
    setState(() {
      selected = selectedCopy;
    });
  }

  getDiscussList() async {
    Map<String, dynamic> res = await DisscussApi.getDiscussList(
      offset: 0,
      limit: 100,
    );
    int code = res['code'];
    String message = res['message'];
    Map<String, dynamic> data = res['data'];
    if (code == 0) {
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(data['rows']);
      String select = '';
      String id = disscussId;
      for (var item in list) {
        if (item['imGroupId'] == disscussId) {
          select = item['name'];
        }
      }
      if (select == '') {
        select = list[0]['name'];
        id = list[0]['imGroupId'];
      }
      setState(() {
        discussList = list;
        currentSelectedDis = select;
        disscussId = id;
      });
    } else {
      Utils.toast(imt_para("获取讨论区列表失败 {{message}}", "获取讨论区列表失败 $message")(
          message: message));
    }
  }

  Widget tagBuilder({
    required String color,
    required String text,
  }) {
    return InkWell(
      onTap: () {
        tagTap(text);
      },
      child: Container(
        alignment: Alignment.center,
        height: 25,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
        width: 70,
        decoration: BoxDecoration(
          color: Color(int.parse(color, radix: 16)).withAlpha(255),
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
          border: selected.contains(text)
              ? Border.all(
                  width: 2,
                  style: BorderStyle.solid,
                  color: Colors.amber,
                )
              : Border.all(
                  width: 0,
                  style: BorderStyle.none,
                ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            textBaseline: TextBaseline.alphabetic,
            color: Colors.white,
            backgroundColor: Colors.transparent,
            height: 1,
          ),
        ),
      ),
    );
  }

  titleChange(text) {
    setState(() {
      title = text;
    });
  }

  directToMessage(V2TimConversation conversation) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(selectedConversation: conversation),
      ),
    );
  }

  Future<V2TimConversation> getConversion(String conversationID) async {
    final data = await sdkInstance.getConversationManager().getConversation(
          conversationID: conversationID,
        );
    return data.data!;
  }

  createTopic() async {
    if (title == '') {
      Utils.toast(imt("请完善话题标题"));
      return;
    }
    if (selected.isEmpty) {
      Utils.toast(imt("必须选择一个标签"));
      return;
    }
    V2TimValueCallback<String> data = await sdkInstance.getLoginUser();
    String? userId = data.data;

    if (userId!.isNotEmpty) {
      V2TimValueCallback<List<V2TimUserFullInfo>> userInfo =
          await sdkInstance.getUsersInfo(userIDList: [userId]);

      Map<String, dynamic> res = await DisscussApi.addTopic(
        disscussImGroupId: disscussId,
        title: title,
        tags: jsonEncode(selected),
        creator: jsonEncode(userInfo.data![0].toJson()),
        aboutMessages: jsonEncode(messageList.map((e) => e.toJson()).toList()),
      );

      int code = res['code'];
      String message = res['message'];
      Map<String, dynamic> data = res["data"];
      Utils.log(data);
      if (code != 0) {
        Utils.toast(imt_para("创建话题失败 {{message}}", "创建话题失败 $message")(
            message: message));
      } else {
        String imGroupId = data['imGroupId'];
        V2TimConversation conversation =
            await getConversion('group_$imGroupId');
        Utils.toast(imt("创建话题成功"));
        directToMessage(conversation);
      }
    } else {
      Utils.toast(imt("创建者异常"));
    }
  }

  onActionItemTap(item) {
    setState(() {
      currentSelectedDis = item['name'];
      disscussId = item['imGroupId'];
    });
    Navigator.pop(context);
  }

  showDiscussSelector() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(imt("选择讨论区")),
          actions: discussList
              .map(
                (e) => CupertinoActionSheetAction(
                  onPressed: () {
                    onActionItemTap(e);
                  },
                  child: Text(e['name']),
                  isDefaultAction: e['name'] == currentSelectedDis,
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shadowColor: theme.weakBackgroundColor,
        elevation: 1,
        title: Text(
          imt("创建话题"),
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: messageList.isEmpty ? 65 : 300,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            if (messageList.isNotEmpty)
              Text(
                imt("---- 相关讨论 ----"),
                style: TextStyle(color: theme.weakTextColor),
              ),
            // if (messageList.isNotEmpty) MessageViewer(messageList: messageList),
            SizedBox(
              height: 45,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: createTopic,
                      child: Text(imt("创建话题")),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          focusNode.unfocus();
        },
        child: Container(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: showDiscussSelector,
                      style: const ButtonStyle(
                        alignment: Alignment.centerLeft,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentSelectedDis,
                            ),
                          ),
                          const Icon(Icons.expand_more_sharp)
                        ],
                      ),
                    ),
                  )
                ],
              ),
              TextField(
                keyboardType: TextInputType.text,
                focusNode: focusNode,
                maxLines: 3,
                maxLength: 100,
                controller: controller,
                onChanged: titleChange,
                decoration: InputDecoration(
                  hintText: imt("填写话题标题"),
                  filled: true,
                  fillColor: theme.weakBackgroundColor,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: InkWell(
                  child: Text(
                    imt("+标签（至少添加一个）"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Wrap(
                  children: allTags.map((e) {
                    return tagBuilder(color: e['color']!, text: e['text']!);
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
