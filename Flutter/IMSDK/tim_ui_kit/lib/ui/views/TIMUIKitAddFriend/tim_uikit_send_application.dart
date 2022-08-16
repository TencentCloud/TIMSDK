import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/add_friend_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class SendApplication extends StatefulWidget {
  final V2TimUserFullInfo friendInfo;
  final TUISelfInfoViewModel model;
  final bool? isShowDefaultGroup;
  final AddFriendLifeCycle? lifeCycle;

  const SendApplication(
      {Key? key,
      this.lifeCycle,
      required this.friendInfo,
      required this.model,
      this.isShowDefaultGroup = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendApplicationState();
}

class _SendApplicationState extends TIMUIKitState<SendApplication> {
  final TextEditingController _verficationController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final showName = widget.model.loginInfo?.nickName ??
        widget.model.loginInfo?.userID;
    _verficationController.text = "我是: $showName";
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final FriendshipServices _friendshipServices =
    serviceLocator<FriendshipServices>();

    final faceUrl = widget.friendInfo.faceUrl ?? "";
    final userID = widget.friendInfo.userID ?? "";
    final showName = widget.friendInfo.nickName ?? userID;
    final option2 = widget.friendInfo.selfSignature ?? "";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TIM_t("添加好友"),
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        shadowColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    child: Avatar(faceUrl: faceUrl, showName: showName),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showName,
                        style:
                            TextStyle(color: theme.darkTextColor, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "ID: $userID",
                        style:
                            TextStyle(fontSize: 13, color: theme.weakTextColor),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        TIM_t_para("个性签名: {{option2}}", "个性签名: $option2")(
                            option2: option2),
                        style:
                            TextStyle(fontSize: 13, color: theme.weakTextColor),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                TIM_t("填写验证信息"),
                style: TextStyle(fontSize: 16, color: theme.weakTextColor),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 6, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: TextField(
                  // minLines: 1,
                  maxLines: 4,
                  controller: _verficationController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xFFAEA4A3),
                      ),
                      hintText: '')),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                TIM_t("请填写备注"),
                style: TextStyle(fontSize: 16, color: theme.weakTextColor),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TIM_t("备注"),
                    style: TextStyle(color: theme.darkTextColor, fontSize: 16),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextField(
                        controller: _nickNameController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color(0xFFAEA4A3),
                            ),
                            hintText: '')),
                  )
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            if (widget.isShowDefaultGroup == true)
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TIM_t("分组"),
                      style:
                          TextStyle(color: theme.darkTextColor, fontSize: 16),
                    ),
                    Text(
                      TIM_t("我的好友"),
                      style:
                          TextStyle(color: theme.darkTextColor, fontSize: 16),
                    )
                  ],
                ),
              ),
            Container(
              color: Colors.white,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              child: TextButton(
                  onPressed: () async {
                    final remark = _nickNameController.text;
                    final addWording = _verficationController.text;
                    final friendGroup = TIM_t("我的好友");

                    if (widget.lifeCycle?.shouldAddFriend != null &&
                        await widget.lifeCycle!.shouldAddFriend(userID, remark,
                                friendGroup, addWording, context) ==
                            false) {
                      return;
                    }

                    final res = await _friendshipServices.addFriend(
                        userID: userID,
                        addType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH,
                        remark: remark,
                        addWording: addWording,
                        friendGroup: friendGroup);

                    if (res.code == 0 && res.data?.resultCode == 0) {
                      // onTIMCallback(TIMCallback(
                      //     type: TIMCallbackType.INFO,
                      //     infoRecommendText: TIM_t("好友申请已发送"),
                      //     infoCode: 6660101));
                    }
                  },
                  child: Text(TIM_t("发送"))),
            )
          ],
        ),
      ),
    );
  }
}
