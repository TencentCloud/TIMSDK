import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/tim_uikit_personal_profile.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

import '../../../i18n/i18n_utils.dart';

typedef OnSelfAvatarTap = void Function();

class TIMUIKitProfile extends StatefulWidget {
  /// 用户ID
  final String userID;

  /// 用于自定义构造操作条目
  final Widget Function(
      BuildContext context,
      V2TimFriendInfo friendInfo,
      V2TimConversation conversation,
      int friendType,
      bool isDisturb)? operationListBuilder;

  /// 用于自定义构造操作条目
  final Widget Function(BuildContext context, V2TimFriendInfo? friendInfo,
      V2TimConversation? conversation, int friendType)? bottomOperationBuilder;

  /// 个人详情卡片tap 回调
  final void Function(BuildContext context, V2TimUserFullInfo? userFullInfo)?
      handleProfileDetailCardTap;

  // Profile Controller
  final TIMUIKitProfileController? controller;

  /// 是否可以跳转至个人详情界面
  final bool canJumpToPersonalProfile;

  final OnSelfAvatarTap? onSelfAvatarTap;

  const TIMUIKitProfile({
    Key? key,
    required this.userID,
    this.operationListBuilder,
    this.bottomOperationBuilder,
    this.handleProfileDetailCardTap,
    this.canJumpToPersonalProfile = false,
    this.onSelfAvatarTap,
    this.controller,
  }) : super(key: key);

  static Widget operationDivider() {
    return const SizedBox(
      height: 10,
    );
  }

  /// 备注
  static Widget remarkBar(String remark, BuildContext context,
      {Function()? handleTap}) {
    final I18nUtils ttBuild = I18nUtils(context);
    return InkWell(
      onTap: () {
        if (handleTap != null) {
          handleTap();
        }
      },
      child: TIMUIKitOperationItem(
        operationName: ttBuild.imt("备注名"),
        operationRightWidget: Text(remark),
      ),
    );
  }

  /// 查找聊天内容
  static Widget searchBar(BuildContext context, V2TimConversation conversation,
      {Function()? handleTap}) {
    final I18nUtils ttBuild = I18nUtils(context);
    return InkWell(
      onTap: () {
        if (handleTap != null) {
          handleTap();
        }
      },
      child: TIMUIKitOperationItem(
        operationName: ttBuild.imt("查找聊天内容"),
      ),
    );
  }

  /// 加入黑名单
  static Widget addToBlackListBar(
      bool value, BuildContext context, Function(bool value)? onChanged) {
    final I18nUtils ttBuild = I18nUtils(context);
    return TIMUIKitOperationItem(
      operationName: ttBuild.imt("加入黑名单"),
      type: "switch",
      operationValue: value,
      onSwitchChange: (value) {
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }

  /// 置顶聊天
  static Widget pinConversationBar(
      bool value, BuildContext context, Function(bool value)? onChanged) {
    final I18nUtils ttBuild = I18nUtils(context);
    return TIMUIKitOperationItem(
      operationName: ttBuild.imt("置顶聊天"),
      type: "switch",
      operationValue: value,
      onSwitchChange: (value) {
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }

  /// 消息免打扰
  static Widget messageDisturb(
      BuildContext context, bool isDisturb, Function(bool value)? onChanged) {
    final I18nUtils ttBuild = I18nUtils(context);
    return TIMUIKitOperationItem(
      operationName: ttBuild.imt("消息免打扰"),
      type: "switch",
      operationValue: isDisturb,
      onSwitchChange: (value) {
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }

  static Widget operationItem({
    required String operationName,
    required String type,
    bool? operationValue,
    String? operationText,
    void Function(bool newValue)? onSwitchChange,
  }) {
    return TIMUIKitOperationItem(
      operationName: operationName,
      type: type,
      operationRightWidget: Text(operationText ?? ""),
      operationValue: operationValue,
      onSwitchChange: onSwitchChange,
    );
  }

  @override
  State<StatefulWidget> createState() => _TIMUIKitProfileState();
}

class _TIMUIKitProfileState extends State<TIMUIKitProfile> {
  late TUIProfileViewModel _model;
  late TIMUIKitProfileController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TIMUIKitProfileController();
    _model = _controller.model;
    _controller.loadData(widget.userID);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  handleTapRemarkBar(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    _controller.showTextInputBottomSheet(
        context, ttBuild.imt("修改备注名"), ttBuild.imt("仅限中字、字母、数字和下划线"),
        (String remark) {
      _controller.updateRemarks(widget.userID, remark);
    });
  }

  Widget _defaultOperationListBuilder(V2TimFriendInfo friendInfo,
      V2TimConversation conversation, bool isFriend, bool isDusturb) {
    final I18nUtils ttBuild = I18nUtils(context);
    return isFriend
        ? Column(
            children: [
              TIMUIKitProfile.operationDivider(),
              TIMUIKitProfile.remarkBar(
                  friendInfo.friendRemark ?? ttBuild.imt("无"), context,
                  handleTap: handleTapRemarkBar(context)),
              TIMUIKitProfile.operationDivider(),
              TIMUIKitProfile.pinConversationBar(
                  conversation.isPinned ?? false, context, (value) {
                _controller.pinedConversation(value, widget.userID);
              }),
              TIMUIKitProfile.messageDisturb(
                  context,
                  isDusturb,
                  (value) =>
                      _controller.setMessageDisturb(widget.userID, value)),
              TIMUIKitProfile.operationDivider(),
              TIMUIKitProfile.addToBlackListBar(
                  _model.isAddToBlackList ?? false, context, (value) {
                _controller.addUserToBlackList(value, widget.userID);
              }),
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<TUIProfileViewModel>(
        builder: (context, value, child) {
          final userInfo = value.userProfile?.friendInfo ??
              V2TimFriendInfo(userID: widget.userID);
          final conversation = value.userProfile?.conversation ??
              V2TimConversation(conversationID: "c2c_${widget.userID}");
          final isFriend = value.firendType != 0;
          final isDisturb = value.isDisturb ?? false;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(children: [
              // 个人信息小Card
              InkWell(
                onTap: () async {
                  if (widget.canJumpToPersonalProfile) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TIMUIKitProfilePersonalInfoPage(
                                // userID: widget.userID, //不填写代表使用登陆用户资料
                                appBarTile: ttBuild.imt("个人资料"),
                                onSelfAvatarTap: widget.onSelfAvatarTap,
                              )),
                    );
                    value.loadData(userID: widget.userID);
                  }

                  if (widget.handleProfileDetailCardTap != null) {
                    final userInfo = value.userProfile?.friendInfo?.userProfile;
                    widget.handleProfileDetailCardTap!(context, userInfo);
                  }
                },
                child: TIMUIKitProfileUserInfoCard(
                  showArrowRightIcon: widget.canJumpToPersonalProfile,
                  userInfo: value.userProfile?.friendInfo?.userProfile ??
                      V2TimUserFullInfo(),
                ),
              ),
              widget.operationListBuilder != null
                  ? widget.operationListBuilder!(context, userInfo,
                      conversation, value.firendType, isDisturb)
                  : _defaultOperationListBuilder(
                      userInfo, conversation, isFriend, isDisturb),
              if (widget.bottomOperationBuilder != null)
                widget.bottomOperationBuilder!(
                    context, userInfo, conversation, value.firendType)
            ]),
          );
        },
      ),
    );
  }
}

class TIMUIKitProfileUserInfoCard extends StatelessWidget {
  final V2TimUserFullInfo userInfo;
  final bool isJumpToPersonalProfile;

  // Show arrow_right icons?
  final bool showArrowRightIcon;

  const TIMUIKitProfileUserInfoCard(
      {Key? key,
      required this.userInfo,
      this.isJumpToPersonalProfile = false,
      this.showArrowRightIcon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final faceUrl = userInfo.faceUrl ?? "";
          final nickName = userInfo.nickName ?? "";
          final signature = userInfo.selfSignature;
          final showName = nickName != "" ? nickName : userInfo.userID;
          final signatureText = signature != null
              ? ttBuild.imt_para("个性签名: {{signature}}", "个性签名: $signature")(
                  signature: signature)
              : ttBuild.imt("暂无个性签名");

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child:
                      Avatar(faceUrl: faceUrl, showName: showName ?? ""),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Text(
                          showName ?? "",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                          softWrap: true,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "ID:  ${userInfo.userID ?? ""}",
                          style: TextStyle(
                              fontSize: 13,
                              color: value.theme.weakTextColor),
                        ),
                      ),
                      Text(signatureText,
                          style: TextStyle(
                              fontSize: 13,
                              color: value.theme.weakTextColor))
                    ],
                  ),
                ),
                showArrowRightIcon
                    ? const Icon(Icons.keyboard_arrow_right)
                    : Container()
              ],
            ),
          );
        }));
  }
}
