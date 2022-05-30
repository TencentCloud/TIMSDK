import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/shared_theme.dart';
import 'package:tim_ui_kit/ui/widgets/forward_message_screen.dart';

class MultiSelectPanel extends StatelessWidget {
  MultiSelectPanel(
      {Key? key,
      required this.conversationShowName,
      required this.conversationType})
      : super(key: key);
  final String conversationShowName;
  final int conversationType;
  final TUIChatViewModel _model = serviceLocator<TUIChatViewModel>();

  _handleForwardMessage(BuildContext context, bool isMergerForward) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ForwardMessageScreen(
                  isMergerForward: isMergerForward,
                  conversationShowName: conversationShowName,
                  conversationType: conversationType,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;
    final I18nUtils ttBuild = I18nUtils(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme?.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
          theme?.primaryColor ?? CommonColor.primaryColor
        ]),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              IconButton(
                icon: Image.asset('images/forward.png',
                    package: 'tim_ui_kit', color: Colors.white),
                iconSize: 40,
                onPressed: () {
                  _handleForwardMessage(context, false);
                },
              ),
              Text(ttBuild.imt("逐条转发"),
                  style: const TextStyle(color: Colors.white, fontSize: 12))
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Image.asset('images/merge_forward.png',
                    package: 'tim_ui_kit', color: Colors.white),
                iconSize: 40,
                onPressed: () {
                  _handleForwardMessage(context, true);
                },
              ),
              Text(
                ttBuild.imt("合并转发"),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Image.asset('images/delete.png',
                    package: 'tim_ui_kit', color: Colors.white),
                iconSize: 40,
                onPressed: () {
                  showCupertinoModalPopup<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoActionSheet(
                        title: Text(ttBuild.imt("确定删除已选消息")),
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              "cancel",
                            );
                          },
                          child: Text(ttBuild.imt("取消")),
                          isDefaultAction: false,
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              _model.deleteSelectedMsg();
                              _model.updateMultiSelectStatus(false);
                              Navigator.pop(
                                context,
                                "cancel",
                              );
                            },
                            child: Text(
                              ttBuild.imt("删除"),
                              style: TextStyle(color: theme?.cautionColor),
                            ),
                            isDefaultAction: false,
                          )
                        ],
                      );
                    },
                  );
                },
              ),
              Text(ttBuild.imt("删除"),
                  style: const TextStyle(color: Colors.white, fontSize: 12))
            ],
          )
        ],
      ),
    );
  }
}
