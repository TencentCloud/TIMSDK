import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/merger_message_screen.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class TIMUIKitMergerElem extends TIMUIKitStatelessWidget {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final V2TimMergerElem mergerElem;
  final String messageID;
  final bool isSelf;

  TIMUIKitMergerElem(
      {Key? key,
      required this.mergerElem,
      required this.isSelf,
      required this.messageID})
      : super(key: key);

  _handleTap(BuildContext context) async {
    if (messageID != "") {
      final mergerMessageList = await model.downloadMergerMessage(messageID);
      if (mergerMessageList != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MergerMessageScreen(messageList: mergerMessageList),
            ));
      }
    }
  }

  List<String>? _getAbstractList() {
    final length = mergerElem.abstractList!.length;
    if (length <= 4) {
      return mergerElem.abstractList;
    }
    return mergerElem.abstractList!.getRange(0, 4).toList();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isSelf ? const Radius.circular(10) : Radius.zero,
          bottomLeft: const Radius.circular(10),
          topRight: isSelf ? Radius.zero : const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
        border: Border.all(
          color: theme.weakDividerColor ?? CommonColor.weakDividerColor,
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _handleTap(context);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mergerElem.title!,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              // const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _getAbstractList()!
                    .map(
                      (e) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              e,
                              textAlign: TextAlign.left,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: theme.weakTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(
                height: 4,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    TIM_t("聊天记录"),
                    style: TextStyle(
                      color: theme.weakTextColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
