import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_new_contact_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/widgets/unread_message.dart';

class TIMUIKitUnreadCount extends StatefulWidget {
  final double width;
  final double height;

  const TIMUIKitUnreadCount({Key? key, this.width = 22.0, this.height = 22.0})
      : super(key: key);

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
  void dispose() {
    super.dispose();
    model.removeFriendShipListener();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: model,
        child:
            Consumer<TUINewContactViewModel>(builder: (context, value, child) {
          final unreadCount = value.unreadCount;
          if (unreadCount > 0) {
            return UnreadMessage(
                width: widget.width,
                height: widget.height,
                unreadCount: unreadCount);
          }
          return Container();
        }));
  }
}
