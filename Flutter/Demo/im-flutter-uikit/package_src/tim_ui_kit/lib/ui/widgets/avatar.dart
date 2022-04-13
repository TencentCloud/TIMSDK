import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class Avatar extends StatelessWidget {
  final String faceUrl;
  final String showName;
  final bool isFromLocal;
  final CoreServicesImpl coreService = serviceLocator<CoreServicesImpl>();

  Avatar(
      {Key? key,
      required this.faceUrl,
      required this.showName,
      this.isFromLocal = false})
      : super(key: key);

  Widget _getFaceUrlImageWidget(BuildContext context) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
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
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(
            builder: (context, tuiTheme, child) => ClipRRect(
                  borderRadius: BorderRadius.circular(4.8),
                  child: _getFaceUrlImageWidget(context),
                )));
  }
}
