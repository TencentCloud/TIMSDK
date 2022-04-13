import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';

class TIMUIKitSearchItem extends StatelessWidget {
  final String faceUrl;
  final String showName;
  final String lineOne;
  final String? lineOneRight;
  final String? lineTwo;
  final VoidCallback? onClick;

  const TIMUIKitSearchItem({Key? key,
    required this.faceUrl,
    required this.showName,
    required this.lineOne,
    this.lineTwo,
    this.lineOneRight,
    this.onClick}) : super(key: key);

  _renderLineOneRight(String? text, TUITheme theme){
    if(text != null){
      return Text(text,
          style: TextStyle(
            fontSize: 12,
            color: theme.weakTextColor,
          ));
    }else{
      return Container();
    }
  }

  _renderLineTwo(String? text, TUITheme theme){
    return (text != null) ?
        Text(
          text,
          style: TextStyle(color: theme.weakTextColor, height: 1.5, fontSize: 14),
        ) : Container(height: 0,);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: hexToColor("DBDBDB"), width: 0.5))
        ),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Avatar(faceUrl: faceUrl, showName: showName)
                ],
              ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              lineOne,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400),
                            ),
                            _renderLineOneRight(lineOneRight, theme),
                          ],
                        ),
                      ),
                      _renderLineTwo(lineTwo, theme),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}