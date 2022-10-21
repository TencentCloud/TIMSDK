// ignore_for_file: avoid_print, unused_field, unused_element

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/chat_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_call_invite_list.dart';
import 'package:tim_ui_kit_calling_plugin/enum/tim_uikit_trtc_calling_scence.dart';
import 'package:tim_ui_kit_calling_plugin/tim_ui_kit_calling_plugin.dart';
import 'package:tim_ui_kit_lbs_plugin/pages/location_picker.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/location_utils.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';
import 'package:tim_ui_kit_lbs_plugin/widget/location_msg_element.dart';
import 'package:tim_ui_kit_sticker_plugin/tim_ui_kit_sticker_plugin.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/group_application_list.dart';

import 'package:timuikit/src/group_profile.dart';
import 'package:timuikit/src/provider/custom_sticker_package.dart';
import 'package:timuikit/src/provider/local_setting.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/user_profile.dart';
import 'package:provider/provider.dart';

import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/utils/baidu_implements/map_service_baidu_implement.dart';
import 'package:timuikit/utils/baidu_implements/map_widget_baidu_implement.dart';
import 'package:timuikit/utils/push/push_constant.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  final V2TimConversation selectedConversation;
  final V2TimMessage? initFindingMsg;

  const Chat(
      {Key? key, required this.selectedConversation, this.initFindingMsg})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TIMUIKitChatController _timuiKitChatController =
      TIMUIKitChatController();
  final TUICalling _calling = TUICalling();
  bool isDisscuss = false;
  bool isTopic = false;
  String? backRemark;
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  GlobalKey<dynamic> tuiChatField = GlobalKey();
  String? conversationName;

  String _getTitle() {
    return backRemark ?? widget.selectedConversation.showName ?? "";
  }

  String? _getDraftText() {
    return widget.selectedConversation.draftText;
  }

  String? _getConvID() {
    return widget.selectedConversation.type == 1
        ? widget.selectedConversation.userID
        : widget.selectedConversation.groupID;
  }

  ConvType _getConvType() {
    return widget.selectedConversation.type == 1
        ? ConvType.c2c
        : ConvType.group;
  }

  _initListener() async {
    // 这个注册监听的逻辑，我们在TIMUIKitChat内已处理，您如果没有单独需要，可不手动注册
    // await _timuiKitChatController.removeMessageListener();
    // await _timuiKitChatController.setMessageListener();
  }

  _onTapAvatar(String userID) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfile(
            userID: userID,
            onRemarkUpdate: (String newRemark){
              setState(() {
                conversationName = newRemark;
              });
            },
          ),
        ));
  }

  _onTapLocation() {
    if(kIsWeb){
      Utils.toast(imt("百度地图插件暂不支持网页版，请使用手机APP DEMO体验位置消息能力。"));
      return;
    }
    if (IMDemoConfig.baiduMapIOSAppKey.isNotEmpty) {
      tuiChatField.currentState.inputextField.currentState.hideAllPanel();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPicker(
              onChange: (LocationMessage location) async {
                final locationMessageInfo =
                    await sdkInstance.v2TIMMessageManager.createLocationMessage(
                        desc: location.desc,
                        longitude: location.longitude,
                        latitude: location.latitude);
                final messageInfo = locationMessageInfo.data!.messageInfo;
                _timuiKitChatController.sendMessage(
                    messageInfo: messageInfo);
              },
              mapBuilder: (onMapLoadDone, mapKey, onMapMoveEnd) => BaiduMap(
                onMapMoveEnd: onMapMoveEnd,
                onMapLoadDone: onMapLoadDone,
                key: mapKey,
              ),
              locationUtils: LocationUtils(BaiduMapService()),
            ),
          ));
    } else {
      Utils.toast("请根据Demo的README指引，配置百度AK，体验DEMO的位置消息能力");
      print("请根据本文档指引 https://docs.qq.com/doc/DSVliWE9acURta2dL ， 快速体验位置消息能力");
    }
  }

  _goToVideoUI() async {
    final hasCameraPermission =
        await Permissions.checkPermission(context, Permission.camera.value);
    final hasMicphonePermission =
        await Permissions.checkPermission(context, Permission.microphone.value);
    if (!hasCameraPermission || !hasMicphonePermission) {
      return;
    }
    final isGroup = widget.selectedConversation.type == 2;
    tuiChatField.currentState.textFieldController.hideAllPanel();
    if (isGroup) {
      List<V2TimGroupMemberFullInfo>? selectedMember = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectCallInviter(
            groupID: widget.selectedConversation.groupID,
          ),
        ),
      );
      if (selectedMember != null) {
        final inviteMember = selectedMember.map((e) => e.userID).toList();
        _calling.groupCall(inviteMember, CallingScenes.Video,
            widget.selectedConversation.groupID);
      }
    } else {
      final user = await sdkInstance.getLoginUser();
      final myId = user.data;
      OfflinePushInfo offlinePush = OfflinePushInfo(
        title: "",
        desc: imt("邀请你视频通话"),
        ext: "{\"conversationID\": \"\"}",
        disablePush: false,
        androidOPPOChannelID: PushConfig.OPPOChannelID,
        ignoreIOSBadge: false,
      );

      _calling.call(widget.selectedConversation.userID!, CallingScenes.Video,
          offlinePush);
    }
  }

  _goToVoiceUI() async {
    final hasMicphonePermission =
        await Permissions.checkPermission(context, Permission.microphone.value);
    if (!hasMicphonePermission) {
      return;
    }
    final isGroup = widget.selectedConversation.type == 2;
    tuiChatField.currentState.textFieldController.hideAllPanel();
    if (isGroup) {
      List<V2TimGroupMemberFullInfo>? selectedMember = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectCallInviter(
            groupID: widget.selectedConversation.groupID,
          ),
        ),
      );
      if (selectedMember != null) {
        final inviteMember = selectedMember.map((e) => e.userID).toList();
        _calling.groupCall(inviteMember, CallingScenes.Audio,
            widget.selectedConversation.groupID);
      }
    } else {
      final user = await sdkInstance.getLoginUser();
      final myId = user.data;
      OfflinePushInfo offlinePush = OfflinePushInfo(
        title: "",
        desc: imt("邀请你语音通话"),
        ext: "{\"conversationID\": \"\"}",
        disablePush: false,
        androidOPPOChannelID: PushConfig.OPPOChannelID,
        ignoreIOSBadge: false,
      );

      _calling.call(widget.selectedConversation.userID!, CallingScenes.Audio,
          offlinePush);
    }
  }

  @override
  void initState() {
    super.initState();
    _initListener();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget renderCustomStickerPanel(
      {sendTextMessage, sendFaceMessage, deleteText, addText}) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    final customStickerPackageList =
        Provider.of<CustomStickerPackageData>(context).customStickerPackageList;
    return StickerPanel(
        sendTextMsg: sendTextMessage,
        sendFaceMsg: (index, data) =>
            sendFaceMessage(index + 1, (data.split("/")[3]).split("@")[0]),
        deleteText: deleteText,
        addText: addText,
        customStickerPackageList: customStickerPackageList,
        backgroundColor: theme.weakBackgroundColor,
        lightPrimaryColor: theme.lightPrimaryColor);
  }

  @override
  Widget build(BuildContext context) {
    final LocalSetting localSetting = Provider.of<LocalSetting>(context);
    return TIMUIKitChat(
        controller: _timuiKitChatController,
        lifeCycle:
            ChatLifeCycle(newMessageWillMount: (V2TimMessage message) async {
          // This configuration is unnecessary and only for demonstration purpose.
          // It shows if you tend to avoid a message from rending, you can `return null` here.
          return message;
        }),
        onDealWithGroupApplication: (String groupId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupApplicationList(
                groupID: groupId,
              ),
            ),
          );
        },
        groupAtInfoList: widget.selectedConversation.groupAtInfoList,
        key: tuiChatField,
        customStickerPanel: renderCustomStickerPanel,
        config: TIMUIKitChatConfig(
          // For demonstration only, not all configuration items.
          // In practical use, only parameters that are different from the default items need be provided.
          isAllowClickAvatar: true,
          isAllowLongPressMessage: true,
          isShowReadingStatus: localSetting.isShowReadingStatus,
          isShowGroupReadingStatus: localSetting.isShowReadingStatus,
          notificationTitle: "",
          notificationOPPOChannelID: PushConfig.OPPOChannelID,
          urlPreviewType: UrlPreviewType.previewCardAndHyperlink,
          groupReadReceiptPermissionList: [
            // The group receipt function only works with `Ultimate Edition`

            // GroupReceiptAllowType.work,
            // GroupReceiptAllowType.meeting,
            // GroupReceiptAllowType.public
          ],
          timeDividerConfig: TimeDividerConfig(
            timeInterval: 300,
            // timestampParser: (int timestamp) => "$timestamp",
          ),
          faceURIPrefix: (String path) {
            if (path.contains("assets/custom_face_resource/")) {
              return "";
            }
            int? dirNumber;
            if (path.contains("yz")) {
              dirNumber = 4350;
            }
            if (path.contains("ys")) {
              dirNumber = 4351;
            }
            if (path.contains("gcs")) {
              dirNumber = 4352;
            }
            if (dirNumber != null) {
              return "assets/custom_face_resource/$dirNumber/";
            } else {
              return "";
            }
          },
          faceURISuffix: (String path) {
            return "@2x.png";
          },
        ),
        conversationID: _getConvID() ?? '',
        conversationType:
            ConvType.values[widget.selectedConversation.type ?? 1],
        onTapAvatar: _onTapAvatar,
        conversationShowName: _getTitle(),
        initFindingMsg: widget.initFindingMsg,
        draftText: _getDraftText(),
        messageItemBuilder: MessageItemBuilder(
          locationMessageItemBuilder: (message, isShowJump, clearJump) {
            if (kIsWeb) {
              String dividerForDesc = "/////";
              String address = message.locationElem?.desc ?? "";
              String addressName = address;
              String? addressLocation;
              if(RegExp(dividerForDesc).hasMatch(address)){
                addressName = address.split(dividerForDesc)[0];
                addressLocation = address.split(dividerForDesc)[1] != "null" ? address.split(dividerForDesc)[1] : null;
              }
              final borderRadius = (message.isSelf ?? true)
                  ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(2),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))
                  : const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10));
              const backgroundColor = Colors.white;
              return GestureDetector(
                onTap: () {
                  launchUrl(
                    Uri.parse("http://api.map.baidu.com/marker?location=${message.locationElem?.latitude},${message.locationElem?.longitude}&title=$addressName&content=$addressLocation&output=html"),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: borderRadius,
                      border: Border.all(color: hexToColor("DDDDDD")),
                    ),
                    constraints: const BoxConstraints(maxWidth: 240),
                    padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: hexToColor("5c6168"),
                          size: 32,
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(addressName.isNotEmpty)Text(
                              addressName,
                              softWrap: true,
                              style: const TextStyle(fontSize: 16),
                            ),

                            if(addressLocation != null &&
                                addressLocation.isNotEmpty) Text(
                              addressLocation,
                              softWrap: true,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: CommonColor.weakTextColor
                              ),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              );
            }
            return LocationMsgElement(
              isAllowCurrentLocation: false,
              messageID: message.msgID,
              locationElem: LocationMessage(
                longitude: message.locationElem!.longitude,
                latitude: message.locationElem!.latitude,
                desc: message.locationElem?.desc ?? "",
              ),
              isFromSelf: message.isSelf ?? false,
              isShowJump: isShowJump,
              clearJump: clearJump,
              mapBuilder: (onMapLoadDone, mapKey) => BaiduMap(
                onMapLoadDone: onMapLoadDone,
                key: mapKey,
              ),
              locationUtils: LocationUtils(BaiduMapService()),
            );
          },
        ),
        morePanelConfig: MorePanelConfig(
          extraAction: [
            MorePanelItem(
                // 使用前，清先根据本文档配置AK。https://docs.qq.com/doc/DSVliWE9acURta2dL
                id: "location",
                title: imt("位置"),
                onTap: (c) {
                  _onTapLocation();
                },
                icon: Container(
                  height: 64,
                  width: 64,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Icon(
                    Icons.location_on,
                    color: hexToColor("5c6168"),
                    size: 32,
                  ),
                )),
            MorePanelItem(
                id: "voiceCall",
                title: imt("语音通话"),
                onTap: (c) {
                  // _onFeatureTap("voiceCall", c);
                  _goToVoiceUI();
                },
                icon: Container(
                  height: 64,
                  width: 64,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: SvgPicture.asset(
                    "images/voice-call.svg",
                    package: 'tim_ui_kit',
                    height: 64,
                    width: 64,
                  ),
                )),
            MorePanelItem(
                id: "videoCall",
                title: imt("视频通话"),
                onTap: (c) {
                  // _onFeatureTap("videoCall", c);
                  _goToVideoUI();
                },
                icon: Container(
                  height: 64,
                  width: 64,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: SvgPicture.asset(
                    "images/video-call.svg",
                    package: 'tim_ui_kit',
                    height: 64,
                    width: 64,
                  ),
                ))
          ],
        ),
        appBarConfig: AppBar(
          backgroundColor: hexToColor("f2f3f5"),
          textTheme: TextTheme(
              titleMedium: TextStyle(
                  color: hexToColor("010000"),
                  fontSize: 16
              )
          ),
          actions: [
            IconButton(
                padding: const EdgeInsets.only(left: 8, right: 16),
                onPressed: () async {
                  final conversationType = widget.selectedConversation.type;
                  if (conversationType == 1) {
                    final userID = widget.selectedConversation.userID;
                    // if had remark modifed its will back new remark
                    String? newRemark = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfile(
                            userID: userID!,
                            onRemarkUpdate: (String newRemark){
                              setState(() {
                                conversationName = newRemark;
                              });
                            },
                          ),
                        ));
                    setState(() {
                      backRemark = newRemark;
                    });
                  } else {
                    final groupID = widget.selectedConversation.groupID;
                    if (groupID != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupProfilePage(
                              groupID: groupID,
                            ),
                          ));
                    }
                  }
                },
                icon: Icon(
                  Icons.more_horiz,
                  color: hexToColor("010000"),
                  size: 20,
                ))
          ],
        ));
  }
}
