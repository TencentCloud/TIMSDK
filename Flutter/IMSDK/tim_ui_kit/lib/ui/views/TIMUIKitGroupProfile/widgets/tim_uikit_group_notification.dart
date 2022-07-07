import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/shared_data_widget.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class GroupProfileNotification extends TIMUIKitStatelessWidget {
  GroupProfileNotification({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final model = SharedDataWidget.of(context)?.model;
    if (model == null) {
      return Container();
    }
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
        ],
        builder: (context, w) {
          final notification = Provider.of<TUIGroupProfileViewModel>(context)
                  .groupInfo
                  ?.notification ??
              TIM_t("暂无群公告");
          return Container(
            padding: const EdgeInsets.only(top: 12, left: 16, bottom: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(
                        color: theme.weakDividerColor ??
                            CommonColor.weakDividerColor))),
            child: InkWell(
              onTap: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupProfileNotificationPage(
                            model: model, notification: notification)));
              }),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TIM_t("群公告"),
                          style: TextStyle(
                              color: theme.darkTextColor, fontSize: 16),
                        ),
                        Text(notification,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                                color: theme.weakTextColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right, color: theme.weakTextColor)
                ],
              ),
            ),
          );
        });
  }
}

class GroupProfileNotificationPage extends StatefulWidget {
  final String notification;
  final TUIGroupProfileViewModel model;

  const GroupProfileNotificationPage(
      {Key? key, required this.notification, required this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupProfileNotificationPageState();
}

class _GroupProfileNotificationPageState
    extends TIMUIKitState<GroupProfileNotificationPage> {
  final TextEditingController _controller = TextEditingController();
  bool isUpdated = false;

  _setGroupNotification() async {
    final notification = _controller.text;
    await widget.model.setGroupNotification(notification);
    setState(() {
      isUpdated = true;
    });
  }

  @override
  void initState() {
    _controller.text = widget.notification;
    super.initState();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          TIM_t("群公告"),
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        shadowColor: theme.weakDividerColor,
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
        actions: [
          TextButton(
            onPressed: () {
              if (isUpdated) {
                setState(() {
                  isUpdated = false;
                });
              } else {
                _setGroupNotification();
              }
            },
            child: Text(
              isUpdated ? TIM_t("编辑") : TIM_t("完成"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
            readOnly: isUpdated,
            minLines: 1,
            maxLines: 4,
            controller: _controller,
            keyboardType: TextInputType.multiline,
            autofocus: true,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(
                  // fontSize: 10,
                  color: Color(0xFFAEA4A3),
                ),
                hintText: '')),
      ),
    );
  }
}
