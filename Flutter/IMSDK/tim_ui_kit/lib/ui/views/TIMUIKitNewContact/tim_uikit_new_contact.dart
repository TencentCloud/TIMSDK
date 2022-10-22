import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/new_contact_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

typedef NewContactItemBuilder = Widget Function(
    BuildContext context, V2TimFriendApplication applicationInfo);

class TIMUIKitNewContact extends StatefulWidget {
  /// the callback when accept friend request
  final void Function(V2TimFriendApplication applicationInfo)? onAccept;

  /// the callback when reject friend request
  final void Function(V2TimFriendApplication applicationInfo)? onRefuse;

  /// the widget builder when no friend request exists
  final Widget Function(BuildContext context)? emptyBuilder;

  /// the builder for the request item
  final NewContactItemBuilder? itemBuilder;

  /// the life cycle hooks for new contact business logic
  final NewContactLifeCycle? lifeCycle;

  const TIMUIKitNewContact(
      {Key? key,
      this.lifeCycle,
      this.onAccept,
      this.onRefuse,
      this.emptyBuilder,
      this.itemBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitNewContactState();
}

class _TIMUIKitNewContactState extends TIMUIKitState<TIMUIKitNewContact> {
  late TUIFriendShipViewModel model = serviceLocator<TUIFriendShipViewModel>();

  _getShowName(V2TimFriendApplication item) {
    final nickName = item.nickname ?? "";
    final userID = item.userID;
    return nickName != "" ? nickName : userID;
  }

  Widget _itemBuilder(
      BuildContext context, V2TimFriendApplication applicationInfo) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final showName = _getShowName(applicationInfo);
    final faceUrl = applicationInfo.faceUrl ?? "";
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            margin: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Avatar(faceUrl: faceUrl, showName: showName),
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.weakDividerColor ??
                            CommonColor.weakDividerColor))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showName,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                Expanded(child: Container()),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: theme.primaryColor,
                          border: Border.all(
                              width: 1,
                              color: theme.weakTextColor ??
                                  CommonColor.weakTextColor)),
                      child: Text(
                        TIM_t("同意"),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await model.acceptFriendApplication(
                        applicationInfo.userID,
                        applicationInfo.type,
                      );
                      model.loadData();
                      if (widget.onAccept != null) {
                        widget.onAccept!(applicationInfo);
                      }
                      // widget?.onAccept();
                    },
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            border: Border.all(
                                width: 1,
                                color: theme.weakTextColor ??
                                    CommonColor.weakTextColor)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: Text(
                          TIM_t("拒绝"),
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      onTap: () async {
                        await model.refuseFriendApplication(
                          applicationInfo.userID,
                          applicationInfo.type,
                        );
                        model.loadData();
                        if (widget.onRefuse != null) {
                          widget.onRefuse!(applicationInfo);
                        }
                        // refuse(context);
                      },
                    ))
              ],
            ),
          ))
        ],
      ),
    );
  }

  NewContactItemBuilder _getItemBuilder() {
    return widget.itemBuilder ?? _itemBuilder;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
        ],
        builder: (BuildContext context, Widget? w) {
          final model = Provider.of<TUIFriendShipViewModel>(context);
          model.newContactLifeCycle = widget.lifeCycle;
          final newContactList = model.friendApplicationList;
          if (newContactList != null && newContactList.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: newContactList.length,
              itemBuilder: (context, index) {
                final friendInfo = newContactList[index]!;
                final itemBuilder = _getItemBuilder();
                return itemBuilder(context, friendInfo);
              },
            );
          }

          if (widget.emptyBuilder != null) {
            return widget.emptyBuilder!(context);
          }

          return Container();
        });
  }
}
