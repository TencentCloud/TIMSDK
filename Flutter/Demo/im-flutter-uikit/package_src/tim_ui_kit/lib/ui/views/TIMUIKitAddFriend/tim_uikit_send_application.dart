import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_add_friend_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class SendApplication extends StatefulWidget {
  final V2TimUserFullInfo friendInfo;
  final TUIAddFriendViewModel model;
  const SendApplication(
      {Key? key, required this.friendInfo, required this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendApplicationState();
}

class _SendApplicationState extends State<SendApplication> {
  final TextEditingController _verficationController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final showName = widget.model.loginUserInfo?.nickName ??
        widget.model.loginUserInfo?.userID;
    _verficationController.text = "我是: $showName";
  }

  @override
  Widget build(BuildContext context) {
    final faceUrl = widget.friendInfo.faceUrl ?? "";
    final userID = widget.friendInfo.userID ?? "";
    final showName = widget.friendInfo.nickName ?? userID;
    final selfSignature = widget.friendInfo.selfSignature ?? "";
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
                              "ID: $userID",
                              style: TextStyle(
                                  fontSize: 13, color: theme.weakTextColor),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              ttBuild.imt_para("个性签名: {{signature}}",
                                      "个性签名: $selfSignature")(
                                  signature: selfSignature),
                              style: TextStyle(
                                  fontSize: 13, color: theme.weakTextColor),
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
                      ttBuild.imt("请填写备注和分组"),
                      style:
                          TextStyle(fontSize: 16, color: theme.weakTextColor),
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
                          ttBuild.imt("备注"),
                          style: TextStyle(
                              color: theme.darkTextColor, fontSize: 16),
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
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ttBuild.imt("分组"),
                          style: TextStyle(
                              color: theme.darkTextColor, fontSize: 16),
                        ),
                        Text(
                          ttBuild.imt("我的好友"),
                          style: TextStyle(
                              color: theme.darkTextColor, fontSize: 16),
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
                          final friendGroup = ttBuild.imt("我的好友");
                          final res = await widget.model.addFriend(
                              userID, remark, friendGroup, addWording);
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
                              msg: ttBuild.imt("好友申请已发送"),
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
