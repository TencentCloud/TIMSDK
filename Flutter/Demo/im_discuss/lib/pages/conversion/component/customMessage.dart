import 'dart:convert';

import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/pages/conversion/component/filemessage.dart';
import 'package:discuss/pages/conversion/component/imagemessage.dart';
import 'package:discuss/pages/conversion/component/merge_message.dart';
import 'package:discuss/pages/conversion/component/soundmessage.dart';
import 'package:discuss/pages/conversion/component/systemmessage.dart';
import 'package:discuss/pages/conversion/component/videomessage.dart';
import 'package:discuss/pages/conversion/conversion.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_custom_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_text_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomMessage extends StatefulWidget {
  final V2TimMessage message;
  final String selectedMsgId;
  final void Function(String msgId) setSelectedMsgId;
  const CustomMessage({
    Key? key,
    required this.message,
    required this.selectedMsgId,
    required this.setSelectedMsgId,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => CustomMessageState();
}

class CustomMessageState extends State<CustomMessage> {
  V2TimMessage? message;
  @override
  void initState() {
    message = widget.message;

    super.initState();
  }

  final List<Map<String, String>> allTags = [
    {"text": "性能", "color": "229800"},
    {"text": "BUG", "color": "b61903"},
    {"text": "Flutter", "color": "5fe5f4"},
    {"text": "TRTC", "color": "0279a4"},
    {"text": "Electron", "color": "d4c5fa"},
    {"text": "PC", "color": "fbca05"},
    {"text": "iOS", "color": "2b2b2b"},
    {"text": "Android", "color": "e4f0fe"}
  ];
  Widget getTag(text) {
    String color = 'e4f0fe';
    int index = allTags.indexWhere((element) => element['text'] == text);

    if (index > -1) {
      color = allTags[index]['color']!;
    }

    return Container(
      alignment: Alignment.center,
      height: 18,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      width: 54,
      decoration: BoxDecoration(
        color: Color(int.parse(color, radix: 16)).withAlpha(255),
        borderRadius: const BorderRadius.all(Radius.circular(12.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          textBaseline: TextBaseline.alphabetic,
          color: Colors.white,
          backgroundColor: Colors.transparent,
          height: 1,
        ),
      ),
    );
  }

  openMessage(groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Conversion('group_$groupId'),
      ),
    );
  }

  Widget? displayMessage(int type, V2TimMessage message) {
    Widget res = Container();
    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        res = CustomMessage(
            message: message,
            selectedMsgId: widget.selectedMsgId,
            setSelectedMsgId: widget.setSelectedMsgId);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        res = FileMessage(message);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        res = SystemMessage(message);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        res = ImageMessage(
          message: message,
          isSelect: true,
        );
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        res = MergeMessage(message: message);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_NONE:
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        res = SoundMessage(
            message: message,
            selectedMsgId: widget.selectedMsgId,
            setSelectedMsgId: widget.setSelectedMsgId);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        res = Text(
          "${getShowName(message)}:${message.textElem!.text!}",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            color: type == 1 ? hexToColor('171538') : hexToColor('000000'),
          ),
        );
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        res = VideoMessage(message);
        break;
    }
    return res;
  }

  getShowName(message) {
    return message.friendRemark == null || message.friendRemark == ''
        ? message.nickName == null || message.nickName == ''
            ? message.sender
            : message.nickName
        : message.friendRemark;
  }

  void _launchURL(_url) async =>
      await canLaunch(_url) ? await launch(_url) : Utils.toast("跳转连接异常，请检查");
  isSelf() {
    return widget.message.isSelf;
  }

  Widget showMessage() {
    Widget res = const Text("自定义消息");
    V2TimCustomElem? customElem = widget.message.customElem;
    String? cloudCustomData = widget.message.cloudCustomData;
    bool hascloudCustomData = cloudCustomData != null && cloudCustomData != "";
    if (customElem != null) {
      String? data = customElem.data;

      if (data != null) {
        dynamic dataobj = jsonDecode(data);

        if (dataobj.runtimeType.toString() ==
            '_InternalLinkedHashMap<String, dynamic>') {
          dynamic version = dataobj['version'];
          dynamic text = dataobj['text'];
          dynamic link = dataobj['link'];
          dynamic type = dataobj['type'];
          dynamic businessID = dataobj['businessID'];
          if (version == 4) {
            if (businessID == 'group_create') {
              return res = Text("${dataobj['opUser']}创建群组");
            } else if (businessID == 'text_link') {
              // 跳转
              res = Card(
                child: InkWell(
                  onTap: () {
                    _launchURL(link);
                  },
                  child: SizedBox(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 30,
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 0.0,
                                  ),
                                  dense: true,
                                  title: Text(
                                    "云通信",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  text,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          }
          if (type == 'discuss') {
            String title = dataobj['title'] ?? "";
            String name = dataobj['creator'] ?? "";
            V2TimUserFullInfo? info;
            if (name != "") {
              info = V2TimUserFullInfo.fromJson(jsonDecode(name));
            }
            // List<dynamic> tags = dataobj['tags'] ?? [];
            // String discussName = dataobj['data']['discuss'] ?? "话题";
            // return res = Card(
            //   child: InkWell(
            //     onTap: () async {
            //       String groupId = dataobj['data']['groupId'];

            //       V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
            //           .joinGroup(groupID: groupId, message: "大家好");
            //       if (res.code == 0 || res.code == 10013) {
            //         openMessage(groupId);
            //       } else {
            //         Utils.toast("进入讨论区异常 ${res.desc}");
            //       }
            //     },
            //     child: SizedBox(
            //       child: Row(
            //         children: [
            //           Expanded(
            //             child: Column(
            //               children: [
            //                 SizedBox(
            //                   height: 30,
            //                   child: ListTile(
            //                     contentPadding: const EdgeInsets.symmetric(
            //                       horizontal: 16.0,
            //                       vertical: 0.0,
            //                     ),
            //                     dense: true,
            //                     title: Text(
            //                       discussName,
            //                       style: const TextStyle(
            //                           fontWeight: FontWeight.w900),
            //                     ),
            //                   ),
            //                 ),
            //                 const Divider(),
            //                 ListTile(
            //                   title: Text(
            //                     title,
            //                     style: const TextStyle(
            //                         fontWeight: FontWeight.w500),
            //                   ),
            //                 ),
            //                 tags.isNotEmpty
            //                     ? ListTile(
            //                         title: Row(
            //                           children:
            //                               tags.map((e) => getTag(e)).toList(),
            //                         ),
            //                       )
            //                     : Container(),
            //               ],
            //             ),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // );
            return res = Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Image(
                      width: 20,
                      height: 20,
                      image: AssetImage('images/topic_icon.png'),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          String groupId = dataobj['data']['groupId'];

                          V2TimCallback res = await TencentImSDKPlugin
                              .v2TIMManager
                              .joinGroup(groupID: groupId, message: "大家好");
                          if (res.code == 0 || res.code == 10013) {
                            openMessage(groupId);
                          } else {
                            Utils.toast("进入讨论区异常 ${res.desc}");
                          }
                        },
                        child: Text(
                          "${info == null ? '管理员' : info.nickName ?? info.userID}开始了一个讨论: $title ",
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
              ],
            );
          }
          // TODO 木器是为了兼容已经存在的老消息，后面可以删除
          if (type == 'reply') {
            var originMessage = dataobj['originMessage'];
            var reply = dataobj['reply'];

            V2TimMessage message = V2TimMessage.fromJson(originMessage);
            if (message.customElem != null) {
              dynamic dataobj = jsonDecode(message.customElem!.data!);
              String replyText = dataobj["reply"];

              message.textElem = V2TimTextElem(text: replyText);
              message.elemType = MessageElemType.V2TIM_ELEM_TYPE_TEXT;
              message.customElem = null;
            }
            return res = Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: widget.message.isSelf!
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelf() ? hexToColor("DCEAFD") : hexToColor("ECECEC"),
                    borderRadius: BorderRadius.only(
                      topLeft:
                          isSelf() ? const Radius.circular(10) : Radius.zero,
                      bottomLeft: const Radius.circular(10),
                      topRight:
                          isSelf() ? Radius.zero : const Radius.circular(10),
                      bottomRight: const Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(reply),
                      ),
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 30,
                        ),
                        padding: const EdgeInsets.only(
                            top: 4, bottom: 4, left: 6, right: 8),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: hexToColor("d3deef"),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: displayMessage(message.elemType, message)!,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }
      }
    }
    // 用来处理replyMessage
    if (hascloudCustomData) {
      String? reply = widget.message.textElem?.text ?? "引用消息为空了";
      Map<String, dynamic> cloudCustomDataMap = {
        'messageReply': {'messageAbstract': '', 'messageSender': ''}
      };
      try {
        cloudCustomDataMap = json.decode(cloudCustomData);
      } catch (e) {
        // handle 旧的消息类型无法被正常decode
      }
      Map<String, dynamic> messageReply = cloudCustomDataMap["messageReply"];
      String originMessageAbstract = messageReply["messageAbstract"];
      String sender = messageReply["messageSender"];

      var reolayMessage = V2TimMessage(
          textElem: V2TimTextElem(text: originMessageAbstract),
          elemType: MessageElemType.V2TIM_ELEM_TYPE_TEXT,
          sender: sender);
      return res = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: widget.message.isSelf!
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 6,
            ),
            decoration: BoxDecoration(
              color: isSelf() ? hexToColor("DCEAFD") : hexToColor("ECECEC"),
              borderRadius: BorderRadius.only(
                topLeft: isSelf() ? const Radius.circular(10) : Radius.zero,
                bottomLeft: const Radius.circular(10),
                topRight: isSelf() ? Radius.zero : const Radius.circular(10),
                bottomRight: const Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(reply),
                ),
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 30,
                  ),
                  padding: const EdgeInsets.only(
                      top: 4, bottom: 4, left: 6, right: 8),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: hexToColor("d3deef"),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: displayMessage(
                      MessageElemType.V2TIM_ELEM_TYPE_TEXT, reolayMessage)!,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Text('null');
    }
    return showMessage();
  }
}
