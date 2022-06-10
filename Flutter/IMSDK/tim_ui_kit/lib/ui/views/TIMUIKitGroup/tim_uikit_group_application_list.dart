// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import '../../../business_logic/view_models/tui_chat_view_model.dart';
import '../../../data_services/group/group_services.dart';
import '../../../i18n/i18n_utils.dart';
import '../../utils/color.dart';
import '../../widgets/avatar.dart';

typedef GroupApplicationItemBuilder = Widget Function(
    BuildContext context, V2TimGroupApplication applicationInfo, int index);

enum ApplicationStatus {
  none,
  accept,
  reject,
}

class TIMUIKitGroupApplicationList extends StatefulWidget {
  /// the builder for the request item
  final GroupApplicationItemBuilder? itemBuilder;

  /// group ID
  final String groupID;

  const TIMUIKitGroupApplicationList(
      {Key? key, this.itemBuilder, required this.groupID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitGroupApplicationListState();
}

class TIMUIKitGroupApplicationListState
    extends State<TIMUIKitGroupApplicationList> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  List<V2TimGroupApplication> groupApplicationList = [];
  List<ApplicationStatus> applicationStatusList = [];

  @override
  void initState() {
    super.initState();
    groupApplicationList = model.groupApplicationList
        .where((item) => (item.groupID == widget.groupID))
        .toList();
    applicationStatusList =
        groupApplicationList.map((item) => ApplicationStatus.none).toList();
  }

  GroupApplicationItemBuilder _getItemBuilder() {
    return widget.itemBuilder ?? _defaultItemBuilder;
  }

  Widget _defaultItemBuilder(
      BuildContext context, V2TimGroupApplication applicationInfo, int index) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final I18nUtils ttBuild = I18nUtils(context);
    final ApplicationStatus currentStatus = applicationStatusList[index];

    String _getUserName() {
      if (applicationInfo.fromUserNickName != null &&
          applicationInfo.fromUserNickName!.isNotEmpty &&
          applicationInfo.fromUserNickName != applicationInfo.fromUser) {
        return "${applicationInfo.fromUserNickName} (${applicationInfo.fromUser})";
      } else {
        return "${applicationInfo.fromUser}";
      }
    }

    String _getRequestMessage() {
      String option2 = applicationInfo.requestMsg!;
      return ttBuild.imt_para("验证消息: {{option2}}", "验证消息: $option2")(
          option2: option2);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(
                color: theme.weakDividerColor ?? const Color(0xFFDBDBDB))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Avatar(
                  faceUrl: applicationInfo.fromUserFaceUrl ?? "",
                  showName: applicationInfo.fromUserNickName ??
                      applicationInfo.fromUser ??
                      ""),
            ),
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getUserName(),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.darkTextColor),
              ),
              Text(
                _getRequestMessage(),
                style: TextStyle(fontSize: 15, color: theme.weakTextColor),
              ),
            ],
          )),
          if (currentStatus == ApplicationStatus.none &&
              applicationInfo.handleStatus == 0)
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: InkWell(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: theme.primaryColor,
                        border: Border.all(
                            width: 1,
                            color: theme.weakTextColor ??
                                CommonColor.weakTextColor)),
                    child: Text(
                      ttBuild.imt("同意"), // agree
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () async {
                    final res = await _groupServices.acceptGroupApplication(
                      groupID: applicationInfo.groupID,
                      fromUser: applicationInfo.fromUser!,
                      toUser: applicationInfo.toUser!,
                    );
                    if (res.code == 0) {
                      setState(() {
                        applicationStatusList[index] = ApplicationStatus.accept;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        model.refreshGroupApplicationList();
                      });
                    }
                  }),
            ),
          if (currentStatus == ApplicationStatus.none &&
              applicationInfo.handleStatus == 0)
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color:
                            theme.weakTextColor ?? CommonColor.weakTextColor)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  ttBuild.imt("拒绝"), // reject
                  style: TextStyle(
                    color: theme.primaryColor,
                  ),
                ),
              ),
              onTap: () async {
                final res = await _groupServices.refuseGroupApplication(
                    addTime: applicationInfo.addTime!,
                    groupID: applicationInfo.groupID,
                    fromUser: applicationInfo.fromUser!,
                    toUser: applicationInfo.toUser!,
                    type:
                        GroupApplicationTypeEnum.values[applicationInfo.type]);
                if (res.code == 0) {
                  setState(() {
                    applicationStatusList[index] = ApplicationStatus.reject;
                  });
                  Future.delayed(const Duration(seconds: 1), () {
                    model.refreshGroupApplicationList();
                  });
                }
              },
            ),
          if (currentStatus == ApplicationStatus.accept ||
              applicationInfo.handleStatus == 1)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Text(
                ttBuild.imt("已同意"),
                style: TextStyle(fontSize: 15, color: theme.weakTextColor),
              ),
            ),
          if (currentStatus == ApplicationStatus.reject ||
              applicationInfo.handleStatus == 2)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Text(
                ttBuild.imt("已拒绝"),
                style: TextStyle(fontSize: 15, color: theme.weakTextColor),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
        ChangeNotifierProvider.value(value: model)
      ],
      builder: (context, w) {
        final theme = Provider.of<TUIThemeViewModel>(context).theme;
        return Container(
          decoration: BoxDecoration(color: theme.weakBackgroundColor),
          child: ListView.builder(
            itemCount: groupApplicationList.length,
            itemBuilder: (context, index) {
              final applicationInfo = groupApplicationList[index];
              final itemBuilder = _getItemBuilder();
              return itemBuilder(context, applicationInfo, index);
            },
          ),
        );
      },
    );
  }
}
