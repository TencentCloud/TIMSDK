// ignore_for_file: unnecessary_import, unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import '../../../business_logic/view_models/tui_theme_view_model.dart';
import '../../../tim_ui_kit.dart';
import '../../widgets/avatar.dart';

enum ApplicationStatus {
  none,
  accept,
  refuse,
}

class TIMUIKitGroupApplicationListItem extends StatefulWidget {
  final V2TimGroupApplication applicationInfo;

  const TIMUIKitGroupApplicationListItem(
      {Key? key, required this.applicationInfo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      TIMUIKitGroupApplicationListItemState();
}

class TIMUIKitGroupApplicationListItemState
    extends State<TIMUIKitGroupApplicationListItem> {
  ApplicationStatus applicationStatus = ApplicationStatus.none;

  @override
  void initState() {
    super.initState();
  }

  String _getUserName() {
    if (widget.applicationInfo.fromUserNickName != null &&
        widget.applicationInfo.fromUserNickName!.isNotEmpty &&
        widget.applicationInfo.fromUserNickName !=
            widget.applicationInfo.fromUser) {
      return "${widget.applicationInfo.fromUserNickName} (${widget.applicationInfo.fromUser})";
    } else {
      return "${widget.applicationInfo.fromUser}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Avatar(
                  faceUrl: widget.applicationInfo.fromUserFaceUrl ?? "",
                  showName: widget.applicationInfo.fromUserNickName ??
                      widget.applicationInfo.fromUser ??
                      ""),
            ),
          ),
          Column(
            children: [
              Text(
                _getUserName(),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.darkTextColor),
              ),
              Text(
                _getUserName(),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.darkTextColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}
