import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';

import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

class TIMUIKitSearchInput extends StatefulWidget {
  final ValueChanged<String> onChange;
  final String? initValue;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? prefixText;

  const TIMUIKitSearchInput({
    required this.onChange,
    this.initValue,
    this.controller,
    Key? key,
    this.prefixIcon,
    this.prefixText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitSearchInputState();
}

class TIMUIKitSearchInputState extends TIMUIKitState<TIMUIKitSearchInput> {
  late FocusNode focusNode = FocusNode();
  late TextEditingController textEditingController =
      widget.controller ?? TextEditingController();
  bool isEmptyInput = true;

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.initValue ?? "";
    isEmptyInput = textEditingController.text.isEmpty;
  }

  hideAllPanel() {
    focusNode.unfocus();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(color: theme.primaryColor, boxShadow: [
        BoxShadow(
          color: theme.weakBackgroundColor ?? hexToColor("E6E9EB"),
          offset: const Offset(0.0, 2.0),
        )
      ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: SizedBox(
            height: 36,
            child: TextField(
              autofocus: true,
              onChanged: (value) async {
                final trimValue = value.trim();
                final isEmpty = trimValue.isEmpty;
                setState(() {
                  isEmptyInput = isEmpty ? true : false;
                });
                widget.onChange(trimValue);
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              maxLines: 4,
              minLines: 1,
              focusNode: focusNode,
              controller: textEditingController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: hexToColor("CCCCCC"),
                ),
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                hintText: TIM_t("搜索"),
                prefix: widget.prefixText != null
                    ? Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: widget.prefixText,
                      )
                    : null,
                prefixIcon: widget.prefixIcon,
                suffixIcon: isEmptyInput
                    ? null
                    : IconButton(
                        onPressed: () {
                          textEditingController.clear();
                          setState(() {
                            isEmptyInput = true;
                          });
                          widget.onChange("");
                        },
                        icon: Icon(Icons.cancel, color: hexToColor("979797")),
                      ),
              ),
            ),
          )),
          Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(TIM_t("取消"),
                    style: const TextStyle(
                      color: Colors.white,
                    )),
              ))
        ],
      ),
    );
  }
}
