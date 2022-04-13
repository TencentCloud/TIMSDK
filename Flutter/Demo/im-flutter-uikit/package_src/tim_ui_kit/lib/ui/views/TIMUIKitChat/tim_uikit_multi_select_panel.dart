import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
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
              const Text("逐条转发",
                  style: TextStyle(color: Colors.white, fontSize: 12))
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
              const Text(
                "合并转发",
                style: TextStyle(color: Colors.white, fontSize: 12),
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
                        title: const Text("确定删除已选消息"),
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              "cancel",
                            );
                          },
                          child: const Text("取消"),
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
                              "删除",
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
              const Text("删除",
                  style: TextStyle(color: Colors.white, fontSize: 12))
            ],
          )
        ],
      ),
    );
  }
}
