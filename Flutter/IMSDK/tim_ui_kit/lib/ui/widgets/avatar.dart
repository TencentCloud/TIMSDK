import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class Avatar extends TIMUIKitStatelessWidget {
  final String faceUrl;
  final String showName;
  final bool isFromLocal;
  final CoreServicesImpl coreService = serviceLocator<CoreServicesImpl>();
  final BorderRadius? borderRadius;
  final V2TimUserStatus? onlineStatus;
  final int? type; // 1 c2c 2 group
  Avatar(
      {Key? key,
      required this.faceUrl,
      this.onlineStatus,
      required this.showName,
      this.isFromLocal = false,
      this.borderRadius,
      this.type = 1})
      : super(key: key);

  Widget _getFaceUrlImageWidget(BuildContext context, TUITheme theme) {
    Widget defaultAvatar() {
      if (type == 1) {
        return Image.asset('images/default_c2c_head.png',
            package: 'tim_ui_kit');
      } else {
        return Image.asset('images/default_group_head.png',
            package: 'tim_ui_kit');
      }
    }

    // final emptyAvatarBuilder = coreService.emptyAvatarBuilder;
    if (faceUrl != "") {
      if (isFromLocal) {
        return Image.asset(faceUrl);
      }
      return CachedNetworkImage(
        imageUrl: faceUrl,
        fadeInDuration: const Duration(milliseconds: 0),
        errorWidget: (BuildContext context, String c, dynamic s) {
          return defaultAvatar();
          // if (emptyAvatarBuilder != null) {
          //   return emptyAvatarBuilder(context);
          // }
          // return Container(
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     color: theme.primaryColor,
          //   ),
          //   child: Text(
          //     showName.length <= 2 ? showName : showName.substring(0, 2),
          //     style: const TextStyle(color: Colors.white, fontSize: 14),
          //   ),
          // );
        },
      );
    } else {
      return defaultAvatar();
      // return Container(
      //   alignment: Alignment.center,
      //   decoration: BoxDecoration(
      //     color: theme.primaryColor,
      //   ),
      //   child: Text(
      //     showName.length <= 2 ? showName : showName.substring(0, 2),
      //     style: const TextStyle(color: Colors.white, fontSize: 14),
      //   ),
      // );
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(4.8),
          child: _getFaceUrlImageWidget(context, theme),
        ),
        if (onlineStatus?.statusType != null && onlineStatus?.statusType != 0)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 12,
              height: 12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                color: onlineStatus?.statusType == 1
                    ? hexToColor("43db2b")
                    : hexToColor("b3b8ba"),
              ),
              child: null,
            ),
          ),
      ],
    );
  }
}
