import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/add_group_life_cycle.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class SendJoinGroupApplication extends StatefulWidget {
  final V2TimGroupInfo groupInfo;
  final AddGroupLifeCycle? lifeCycle;
  const SendJoinGroupApplication(
      {Key? key, required this.groupInfo, this.lifeCycle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendJoinGroupApplicationState();
}

class _SendJoinGroupApplicationState
    extends TIMUIKitState<SendJoinGroupApplication> {
  final TextEditingController _verficationController = TextEditingController();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final CoreServicesImpl _coreServicesImpl = serviceLocator<CoreServicesImpl>();

  @override
  void initState() {
    super.initState();
    final loginUserInfo = _coreServicesImpl.loginUserInfo;
    final option1 = loginUserInfo?.nickName ?? loginUserInfo?.userID;
    _verficationController.text =
        TIM_t_para("我是: {{option1}}", "我是: $option1")(option1: option1);
  }

  Future<V2TimCallback?> addGroup(String groupID, String message) async {
    if (widget.lifeCycle?.shouldAddGroup != null &&
        await widget.lifeCycle!.shouldAddGroup(groupID, message, context) ==
            false) {
      return null;
    }
    return _groupServices.joinGroup(groupID: groupID, message: message);
  }

  String _getGroupType(String type) {
    String groupType;
    switch (type) {
      case GroupType.AVChatRoom:
        groupType = TIM_t("聊天室");
        break;
      case GroupType.Meeting:
        groupType = TIM_t("会议群");
        break;
      case GroupType.Public:
        groupType = TIM_t("公开群");
        break;
      case GroupType.Work:
        groupType = TIM_t("工作群");
        break;
      default:
        groupType = TIM_t("未知群");
        break;
    }
    return groupType;
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final faceUrl = widget.groupInfo.faceUrl ?? "";
    final groupID = widget.groupInfo.groupID;
    final showName = widget.groupInfo.groupName ?? groupID;
    final option1 = _getGroupType(widget.groupInfo.groupType);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TIM_t("进群申请"),
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        "ID: $groupID",
                        style:
                            TextStyle(fontSize: 13, color: theme.weakTextColor),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        TIM_t_para("群类型: {{option1}}", "群类型: $option1")(
                            option1: option1),
                        style:
                            TextStyle(fontSize: 12, color: theme.weakTextColor),
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
            Container(
              color: Colors.white,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              child: TextButton(
                  onPressed: () async {
                    final addWording = _verficationController.text;
                    final res =
                        await addGroup(groupID, addWording);
                    if (res?.code == 0) {
                      onTIMCallback(TIMCallback(
                          type: TIMCallbackType.INFO,
                          infoRecommendText: TIM_t("群申请已发送"),
                          infoCode: 6660201));
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
