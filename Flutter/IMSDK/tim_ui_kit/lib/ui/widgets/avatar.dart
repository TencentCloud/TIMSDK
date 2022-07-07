import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class Avatar extends TIMUIKitStatelessWidget {
  final String faceUrl;
  final String showName;
  final bool isFromLocal;
  final CoreServicesImpl coreService = serviceLocator<CoreServicesImpl>();
  final BorderRadius? borderRadius;

  Avatar(
      {Key? key,
      required this.faceUrl,
      required this.showName,
      this.isFromLocal = false,
      this.borderRadius})
      : super(key: key);

  Widget _getFaceUrlImageWidget(BuildContext context, TUITheme theme) {
    final emptyAvatarBuilder = coreService.emptyAvatarBuilder;
    if (faceUrl != "") {
      if (isFromLocal) {
        return Image.asset(faceUrl);
      }
      return CachedNetworkImage(
        imageUrl: faceUrl,
        fadeInDuration: const Duration(milliseconds: 0),
      );
    } else {
      if (emptyAvatarBuilder != null) {
        return emptyAvatarBuilder(context);
      }
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primaryColor,
        ),
        child: Text(
          showName.length <= 2 ? showName : showName.substring(0, 2),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(4.8),
      child: _getFaceUrlImageWidget(context, theme),
    );
  }
}
