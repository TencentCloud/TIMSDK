import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/forward_message_screen.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class MultiSelectPanel extends TIMUIKitStatelessWidget {
  final ConvType conversationType;

  MultiSelectPanel({Key? key, required this.conversationType})
      : super(key: key);

  _handleForwardMessage(BuildContext context, bool isMergerForward,
      TUIChatSeparateViewModel model) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ForwardMessageScreen(
                  model: model,
                  isMergerForward: isMergerForward,
                  conversationType: conversationType,
                )));
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final TUIChatSeparateViewModel model =
        Provider.of<TUIChatSeparateViewModel>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
          theme.primaryColor ?? CommonColor.primaryColor
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
                  _handleForwardMessage(context, false, model);
                },
              ),
              Text(TIM_t("逐条转发"),
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
                  _handleForwardMessage(context, true, model);
                },
              ),
              Text(
                TIM_t("合并转发"),
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
                        title: Text(TIM_t("确定删除已选消息")),
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              "cancel",
                            );
                          },
                          child: Text(TIM_t("取消")),
                          isDefaultAction: false,
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              model.deleteSelectedMsg();
                              model.updateMultiSelectStatus(false);
                              Navigator.pop(
                                context,
                                "cancel",
                              );
                            },
                            child: Text(
                              TIM_t("删除"),
                              style: TextStyle(color: theme.cautionColor),
                            ),
                            isDefaultAction: false,
                          )
                        ],
                      );
                    },
                  );
                },
              ),
              Text(TIM_t("删除"),
                  style: const TextStyle(color: Colors.white, fontSize: 12))
            ],
          )
        ],
      ),
    );
  }
}
