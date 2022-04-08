import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_call_invite_list.dart';
import 'package:tim_ui_kit_calling_plugin/enum/tim_uikit_trtc_calling_scence.dart';
import 'package:tim_ui_kit_calling_plugin/tim_ui_kit_calling_plugin.dart';
import 'package:tim_ui_kit_sticker_plugin/tim_ui_kit_sticker_plugin.dart';
import 'package:tim_ui_kit_lbs_plugin/pages/location_picker.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/location_utils.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';
import 'package:tim_ui_kit_lbs_plugin/widget/location_msg_element.dart';
import 'package:timuikit/src/group_profile.dart';
import 'package:timuikit/src/provider/custom_sticker_package.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/user_profile.dart';
import 'package:timuikit/src/widgets/lbs/baidu_implements/map_service_baidu_implement.dart';
import 'package:timuikit/src/widgets/lbs/baidu_implements/map_widget_baidu_implement.dart';
import 'package:provider/provider.dart';

import 'package:timuikit/i18n/i18n_utils.dart';
import '../i18n/i18n_utils.dart';
import '../src/widgets/lbs/baidu_implements/map_service_baidu_implement.dart';
import '../src/widgets/lbs/baidu_implements/map_widget_baidu_implement.dart';

class Chat extends StatefulWidget {
  final V2TimConversation selectedConversation;
  final int? initFindingTimestamp;

  const Chat(
      {Key? key, required this.selectedConversation, this.initFindingTimestamp})
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
    await _timuiKitChatController.removeMessageListener();
    await _timuiKitChatController.setMessageListener();
  }

  _onTapAvatar(String userID) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfile(userID: userID),
        ));
  }

  _onTapLocation() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPicker(
            onChange: (LocationMessage location) async {
              final locationMessageInfo = await sdkInstance.v2TIMMessageManager
                  .createLocationMessage(
                      desc: location.desc,
                      longitude: location.longitude,
                      latitude: location.latitude);
              final messageInfo = locationMessageInfo.data!.messageInfo;
              _timuiKitChatController.sendMessage(
                  convID: _getConvID()!,
                  convType: _getConvType(),
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
  }

  _goToVideoUI() async {
    final isGroup = widget.selectedConversation.type == 2;
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
      _calling.call(widget.selectedConversation.userID!, CallingScenes.Video);
    }
  }

  _goToVoiceUI() async {
    final isGroup = widget.selectedConversation.type == 2;
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
      _calling.call(widget.selectedConversation.userID!, CallingScenes.Audio);
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
        sendFaceMsg: sendFaceMessage,
        deleteText: deleteText,
        addText: addText,
        customStickerPackageList: customStickerPackageList,
        backgroundColor: theme.weakBackgroundColor,
        lightPrimaryColor: theme.lightPrimaryColor);
  }

  @override
  Widget build(BuildContext context) {
    return TIMUIKitChat(
        customStickerPanel: renderCustomStickerPanel,
        config: const TIMUIKitChatConfig(
          // 仅供演示，非全部配置项，实际使用中，可只传和默认项不同的参数，无需传入所有开关
          isAllowClickAvatar: true,
          isAllowLongPressMessage: true,
          isShowReadingStatus: true,
        ),
        conversationID: _getConvID() ?? '',
        conversationType: widget.selectedConversation.type ?? 0,
        onTapAvatar: _onTapAvatar,
        conversationShowName: _getTitle(),
        initFindingTimestamp: widget.initFindingTimestamp,
        draftText: _getDraftText(),
        locationMessageItemBuilder:
            (locationElem, isFromSelf, isShowJump, clearJump, messageID) =>
                LocationMsgElement(
                  messageID: messageID,
                  locationElem: locationElem,
                  isFromSelf: isFromSelf,
                  isShowJump: isShowJump,
                  clearJump: clearJump,
                  mapBuilder: (onMapLoadDone, mapKey) => BaiduMap(
                    onMapLoadDone: onMapLoadDone,
                    key: mapKey,
                  ),
                  locationUtils: LocationUtils(BaiduMapService()),
                ),
        morePanelConfig: MorePanelConfig(
          extraAction: [
            MorePanelItem(
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
                          builder: (context) => UserProfile(userID: userID!),
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
                icon: Image.asset(
                  'images/more.png',
                  package: 'tim_ui_kit',
                  height: 34,
                  width: 34,
                ))
          ],
        ));
  }
}
