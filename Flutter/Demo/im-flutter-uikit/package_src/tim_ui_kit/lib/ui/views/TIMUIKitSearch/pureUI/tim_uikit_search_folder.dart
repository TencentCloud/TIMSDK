import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';

import '../../../utils/color.dart';

class TIMUIKitSearchFolder extends StatelessWidget {
  final String folderName;
  final List<Widget> children;

  const TIMUIKitSearchFolder({Key? key,
    required this.folderName, required this.children}
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: hexToColor("DBDBDB"), width: 0.5))
            ),
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
            child: Text(
              folderName,
              style: TextStyle(color: theme.weakTextColor, height: 1.5, fontSize: 14),
            ),
          ),
          ...children
        ],
      ),
    );
  }

}