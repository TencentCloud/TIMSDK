import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

class TIMUIKitSearchNotSupport extends TIMUIKitStatelessWidget {
  TIMUIKitSearchNotSupport({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: hexToColor("ecf3fe"),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              // 因为底部有波浪图， icon向上一点，感觉视觉上更协调
              margin: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  Text(
                    TIM_t("Web网页端不支持搜索"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.darkTextColor,
                    ),
                  ),
                  Text(
                    TIM_t("暂时仅限 Android/iOS 端"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.darkTextColor,
                    ),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Image.asset(
                "images/logo_bottom.png",
                package: 'tim_ui_kit',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              ),
            )
          ],
        ),
      ),
    );
  }
}
