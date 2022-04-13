import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_add_group_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class SendJoinGroupApplication extends StatefulWidget {
  final V2TimGroupInfo groupInfo;
  final TUIAddGroupViewModel model;
  const SendJoinGroupApplication(
      {Key? key, required this.groupInfo, required this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendJoinGroupApplicationState();
}

class _SendJoinGroupApplicationState extends State<SendJoinGroupApplication> {
  final TextEditingController _verficationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final showName = widget.model.loginUserInfo?.nickName ??
        widget.model.loginUserInfo?.userID;
    _verficationController.text = "我是: $showName";
  }

  String _getGroupType(String type) {
    final I18nUtils ttBuild = I18nUtils(context);
    String groupType;
    switch (type) {
      case GroupType.AVChatRoom:
        groupType = ttBuild.imt("聊天室");
        break;
      case GroupType.Meeting:
        groupType = ttBuild.imt("会议群");
        break;
      case GroupType.Public:
        groupType = ttBuild.imt("公开群");
        break;
      case GroupType.Work:
        groupType = ttBuild.imt("工作群");
        break;
      default:
        groupType = ttBuild.imt("未知群");
        break;
    }
    return groupType;
  }

  @override
  Widget build(BuildContext context) {
    final faceUrl = widget.groupInfo.faceUrl ?? "";
    final groupID = widget.groupInfo.groupID;
    final showName = widget.groupInfo.groupName ?? groupID;
    final groupType = _getGroupType(widget.groupInfo.groupType);
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final I18nUtils ttBuild = I18nUtils(context);
          final theme = value.theme;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                ttBuild.imt("添加好友"),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
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
                              style: TextStyle(
                                  color: theme.darkTextColor, fontSize: 18),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              "ID: $groupID",
                              style: TextStyle(
                                  fontSize: 13, color: theme.weakTextColor),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              "群类型: $groupType",
                              style: TextStyle(
                                  fontSize: 12, color: theme.weakTextColor),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      ttBuild.imt("填写验证信息"),
                      style:
                          TextStyle(fontSize: 16, color: theme.weakTextColor),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                              await widget.model.addGroup(groupID, addWording);
                          if (res.code != 0) {
                            Fluttertoast.showToast(
                              msg: res.desc,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              textColor: Colors.white,
                              backgroundColor: Colors.black,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: ttBuild.imt("群申请已发送"),
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              textColor: Colors.white,
                              backgroundColor: Colors.black,
                            );
                          }
                        },
                        child: Text(ttBuild.imt("发送"))),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
