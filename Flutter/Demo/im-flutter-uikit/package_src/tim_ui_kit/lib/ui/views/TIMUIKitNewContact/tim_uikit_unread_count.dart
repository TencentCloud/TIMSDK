import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_new_contact_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

class TIMUIKitUnreadCount extends StatefulWidget {
  const TIMUIKitUnreadCount({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitUnreadCountState();
}

class _TIMUIKitUnreadCountState extends State<TIMUIKitUnreadCount> {
  final TUINewContactViewModel model = serviceLocator<TUINewContactViewModel>();

  @override
  void initState() {
    model.setFriendshipListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (BuildContext context, Widget? w) {
          final unreadCount =
              Provider.of<TUINewContactViewModel>(context).unreadCount;
          final theme = Provider.of<TUIThemeViewModel>(context).theme;

          if (unreadCount > 0) {
            return Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.cautionColor ?? CommonColor.cautionColor,
              ),
              child: Text(unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            );
          }
          return Container();
        });
  }
}
