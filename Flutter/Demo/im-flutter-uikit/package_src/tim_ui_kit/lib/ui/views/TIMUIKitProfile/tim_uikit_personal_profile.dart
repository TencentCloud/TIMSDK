import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_personal_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_personal_profile_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/text_input_bottom_sheet.dart';

import '../../../i18n/i18n_utils.dart';

class TIMUIKitProfilePersonalInfoPage extends StatelessWidget {
  final String appBarTile;

  /// userID 必填写，会根据useID去initModel
  final String userID;

  // Profile Controller
  final TIMUIKitPersonalProfileController? controller;

  /// 用于自定义构造操作条目
  final Widget Function(
    BuildContext context,
    V2TimUserFullInfo userInfo,
  )? operationListBuilder;


  const TIMUIKitProfilePersonalInfoPage(
      {required this.userID,
      required this.appBarTile,
      this.controller,
      this.operationListBuilder,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(
            builder: (context, value, child) => Scaffold(
                appBar: AppBar(
                    shadowColor: Colors.white,
                    title: Text(
                      appBarTile,
                      style: const TextStyle(color: Colors.black),
                    ),
                    backgroundColor: value.theme.lightPrimaryColor,
                    iconTheme: const IconThemeData(
                      color: Colors.black,
                    )),
                body: TIMUIKitProfilePersonalInfo(
                    userID: userID,
                    controller: controller,
                    operationListBuilder: operationListBuilder))));
  }
}

class TIMUIKitProfilePersonalInfo extends StatefulWidget {
  final String userID;
  final TIMUIKitPersonalProfileController? controller;

  /// 用于自定义构造操作条目
  final Widget Function(
    BuildContext context,
    V2TimUserFullInfo userInfo,
  )? operationListBuilder;

  /// 头像
  static Widget portraitBar(Widget portraitWidget, I18nUtils ttBuild) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        operationName: ttBuild.imt("头像"),
        operationRightWidget: portraitWidget,
        showArrowRightIcon: false,
      ),
    );
  }

  /// 昵称
  static Widget nicknamekBar(String nickName, I18nUtils ttBuild) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        operationName: ttBuild.imt("昵称"),
        operationRightWidget: Text(nickName),
      ),
    );
  }

  /// 账号
  static Widget userNumBar(String userNum, I18nUtils ttBuild) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        showArrowRightIcon: false,
        operationName: ttBuild.imt("账号"),
        operationRightWidget: Text(userNum),
      ),
    );
  }

  /// 个性签名
  static Widget signatureBar(String signature, I18nUtils ttBuild) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        operationName: ttBuild.imt("个性签名"),
        operationRightWidget: Text(signature),
      ),
    );
  }

  /// 性别
  static Widget genderBar(String gender, I18nUtils ttBuild) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        operationName: ttBuild.imt("性别"),
        operationRightWidget: Text(gender),
      ),
    );
  }

  /// 生日
  static Widget birthdayBar(String birthday, I18nUtils ttBuild) {
    return InkWell(
      onTap: () {},
      child: TIMUIKitOperationItem(
        operationName: ttBuild.imt("生日"),
        operationRightWidget: Text(birthday),
      ),
    );
  }

  const TIMUIKitProfilePersonalInfo(
      {required this.userID,
      this.operationListBuilder,
      this.controller,
      Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => TIMUIKitProfilePersonalInfoState();
}

// 个人资料组件
class TIMUIKitProfilePersonalInfoState
    extends State<TIMUIKitProfilePersonalInfo> {
  late TIMUIKitPersonalProfileController _timuiKitPersonalProfileController;

  late TUIPersonalProfileViewModel _model;

  @override
  void initState() {
    _timuiKitPersonalProfileController =
        widget.controller ?? TIMUIKitPersonalProfileController();
    _model = _timuiKitPersonalProfileController.model;
    _timuiKitPersonalProfileController.loadData(widget.userID);
    super.initState();
  }

  showGenderChoseSheet(BuildContext context, I18nUtils ttBuild) {
    showAdaptiveActionSheet(
      context: context,
      title: Text(ttBuild.imt("性别")),
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: Text(ttBuild.imt("男")),
          onPressed: () {
            _timuiKitPersonalProfileController.updateGender(1);
            Navigator.pop(context);
          },
        ),
        BottomSheetAction(
          title: Text(ttBuild.imt("女")),
          onPressed: () {
            _timuiKitPersonalProfileController.updateGender(2);
            Navigator.pop(context);
          },
        ),
      ],
      cancelAction: CancelAction(
        title: Text(ttBuild.imt("取消")),
      ), // onPressed parameter is optional by default will dismiss the ActionSheet
    );
  }

  String handleGender(int gender, I18nUtils ttBuild) {
    switch (gender) {
      case 0:
        return ttBuild.imt("未设置");
      case 1:
        return ttBuild.imt("男");
      case 2:
        return ttBuild.imt("女");
      default:
        return "";
    }
  }

  Widget _defaultOperationListBuilder(
      V2TimUserFullInfo userInfo, bool isFriend, context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return isFriend
        ? Column(
            children: [
              TIMUIKitProfilePersonalInfo.portraitBar(
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Avatar(
                      faceUrl: userInfo.faceUrl ?? "",
                      showName: userInfo.nickName ?? ""),
                ), context
              ),
              TIMUIKitProfile.operationDivider(),

              GestureDetector(
                onTap: () {
                  _timuiKitPersonalProfileController.showTextInputBottomSheet(
                      context, ttBuild.imt("修改昵称"), ttBuild.imt("仅限中字、字母、数字和下划线"), (String nickName) {
                    _timuiKitPersonalProfileController.updateNickName(nickName);
                  });
                },
                child: TIMUIKitProfilePersonalInfo.nicknamekBar(
                    userInfo.nickName ?? "", context),
              ),

              TIMUIKitProfilePersonalInfo.userNumBar(userInfo.userID ?? "", context),
              TIMUIKitProfile.operationDivider(),

              GestureDetector(
                onTap: () {
                  _timuiKitPersonalProfileController.showTextInputBottomSheet(
                      context, ttBuild.imt("修改签名"), ttBuild.imt("仅限中字、字母、数字和下划线"),
                      (String selfSignature) {
                    _timuiKitPersonalProfileController
                        .updateSelfSignature(selfSignature);
                  });
                },
                child: TIMUIKitProfilePersonalInfo.signatureBar(
                    userInfo.selfSignature ?? ttBuild.imt("这个人很懒，什么也没写"), context),
              ),

              GestureDetector(
                onTap: () {
                  showGenderChoseSheet(context, context);
                },
                child: TIMUIKitProfilePersonalInfo.genderBar(
                    handleGender(userInfo.gender ?? 0, context), context),
              )

              // TODO新增字段plugin上线再做改动
              // TIMUIKitProfilePersonalInfo.birthdayBar(ttBuild.imt("等上线再改这个"))
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<TUIPersonalProfileViewModel>(
        builder: (context, value, child) {
          final userInfo = value.userInfo?.userProfile ?? V2TimUserFullInfo();

          return Column(
            children: [
              widget.operationListBuilder != null
                  ? widget.operationListBuilder!(context, userInfo)
                  : _defaultOperationListBuilder(userInfo, true, context)
            ],
          );
        },
      ),
    );
  }
}
