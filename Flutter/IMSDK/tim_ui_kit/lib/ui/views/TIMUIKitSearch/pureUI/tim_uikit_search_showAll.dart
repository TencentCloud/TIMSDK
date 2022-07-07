// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitSearchShowALl extends TIMUIKitStatelessWidget {
  final String textShow;
  final VoidCallback? onClick;
  final bool isNeedMoreBottom;

  TIMUIKitSearchShowALl(
      {Key? key,
      this.onClick,
      required this.textShow,
      this.isNeedMoreBottom = false})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(color: hexToColor("DBDBDB"), width: 0.5))),
        padding: EdgeInsets.fromLTRB(0, 8, 0, (isNeedMoreBottom ? 24 : 8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: hexToColor("979797"),
            ),
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // height: 24,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      textShow,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            )),
            Icon(
              Icons.expand_more,
              color: hexToColor("979797"),
            ),
          ],
        ),
      ),
    );
  }
}
