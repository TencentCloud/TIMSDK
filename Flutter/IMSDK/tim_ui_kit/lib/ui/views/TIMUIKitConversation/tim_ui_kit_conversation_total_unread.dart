// ignore_for_file: camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/widgets/unread_message.dart';

typedef unreadCountBuilder = Widget Function(int unreadCount);

class TIMUIKitConversationTotalUnread extends TIMUIKitStatelessWidget {
  final TUIConversationViewModel model =
      serviceLocator<TUIConversationViewModel>();
  final int? unreadCount;
  final unreadCountBuilder? builder;
  final double? width;
  final double? height;

  TIMUIKitConversationTotalUnread(
      {this.width = 22.0,
      this.height = 22.0,
      this.unreadCount,
      this.builder,
      Key? key})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: model),
      ],
      child: Consumer<TUIConversationViewModel>(
        builder: (context, value, child) {
          if (value.totalUnReadCount == 0) {
            return Container();
          }

          if (builder != null) {
            return builder!(value.totalUnReadCount);
          }
          return UnreadMessage(
              unreadCount: unreadCount ?? value.totalUnReadCount,
              width: width,
              height: height);
        },
      ),
    );
  }
}
