import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_new_contact_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

import '../../../i18n/i18n_utils.dart';

typedef NewContactItemBuilder = Widget Function(
    BuildContext context, V2TimFriendApplication applicationInfo);

class TIMUIKitNewContact extends StatefulWidget {
  /// 接受
  final void Function(V2TimFriendApplication applicationInfo)? onAccept;

  /// 拒绝
  final void Function(V2TimFriendApplication applicationInfo)? onRefuse;

  /// 没有申请时构造器
  final Widget Function(BuildContext context)? emptyBuilder;

  /// 列表项构造
  final NewContactItemBuilder? itemBuilder;

  const TIMUIKitNewContact(
      {Key? key,
      this.onAccept,
      this.onRefuse,
      this.emptyBuilder,
      this.itemBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitNewContactState();
}

class _TIMUIKitNewContactState extends State<TIMUIKitNewContact> {
  late TUINewContactViewModel model = serviceLocator<TUINewContactViewModel>();

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
    final I18nUtils ttBuild = I18nUtils(context);
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 16),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 12),
            child: Avatar(faceUrl: faceUrl, showName: showName),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 19),
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
                        ttBuild.imt("同意"),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await model
                          .acceptFriendApplication(applicationInfo.userID);
                      model.loadData();
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
                          ttBuild.imt("拒绝"),
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      onTap: () async {
                        await model
                            .refuseFriendApplication(applicationInfo.userID);
                        model.loadData();
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
    model.loadData();
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
          final newContactList = Provider.of<TUINewContactViewModel>(context)
              .friendApplicationList;
          if (newContactList != null && newContactList.isNotEmpty) {
            return ListView.builder(
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
