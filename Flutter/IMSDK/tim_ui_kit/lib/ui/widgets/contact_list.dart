import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/az_list_view.dart';
import 'package:tim_ui_kit/ui/widgets/radio_button.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class ContactList extends StatefulWidget {
  final List<V2TimFriendInfo> contactList;
  final bool isCanSelectMemberItem;
  final bool isCanSlidableDelete;
  final Function(List<V2TimFriendInfo> selectedMember)?
      onSelectedMemberItemChange;
  final Function()? handleSlidableDelte;

  /// tap联系人列表项回调
  final void Function(V2TimFriendInfo item)? onTapItem;

  /// 顶部列表
  final List<TopListItem>? topList;

  /// 顶部列表项构造器
  final Widget? Function(TopListItem item)? topListItemBuilder;

  final int? maxSelectNum;

  const ContactList(
      {Key? key,
      required this.contactList,
      this.isCanSelectMemberItem = false,
      this.onSelectedMemberItemChange,
      this.isCanSlidableDelete = false,
      this.handleSlidableDelte,
      this.onTapItem,
      this.topList,
      this.topListItemBuilder,
      this.maxSelectNum})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactListState();
}

class _ContactListState extends TIMUIKitState<ContactList> {
  List<V2TimFriendInfo> selectedMember = [];

  _getShowName(V2TimFriendInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.userProfile?.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  List<ISuspensionBeanImpl> _getShowList(List<V2TimFriendInfo> memberList) {
    final List<ISuspensionBeanImpl> showList = List.empty(growable: true);
    for (var i = 0; i < memberList.length; i++) {
      final item = memberList[i];
      final showName = _getShowName(item);
      String pinyin = PinyinHelper.getPinyinE(showName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      if (RegExp("[A-Z]").hasMatch(tag)) {
        showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: tag));
      } else {
        showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: "#"));
      }
    }

    SuspensionUtil.sortListBySuspensionTag(showList);

    return showList;
  }

  bool selectedMemberIsOverFlow() {
    if (widget.maxSelectNum == null) {
      return false;
    }

    return selectedMember.length >= widget.maxSelectNum!;
  }

  Widget _buildItem(TUITheme theme, V2TimFriendInfo item) {
    final showName = _getShowName(item);
    final faceUrl = item.userProfile?.faceUrl ?? "";

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 12),
      child: Row(
        children: [
          if (widget.isCanSelectMemberItem)
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: CheckBoxButton(
                isChecked: selectedMember.contains(item),
                onChanged: (isChecked) {
                  if (isChecked) {
                    if (selectedMemberIsOverFlow()) {
                      return;
                    }
                    selectedMember.add(item);
                  } else {
                    selectedMember.remove(item);
                  }
                  if (widget.onSelectedMemberItemChange != null) {
                    widget.onSelectedMemberItemChange!(selectedMember);
                  }
                  setState(() {});
                },
              ),
            ),
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
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 10, bottom: 20, right: 28),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.weakDividerColor ??
                            CommonColor.weakDividerColor))),
            child: Text(
              showName,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final showList = _getShowList(widget.contactList);

    if (widget.topList != null && widget.topList!.isNotEmpty) {
      final topList = widget.topList!
          .map((e) => ISuspensionBeanImpl(memberInfo: e, tagIndex: '@'))
          .toList();
      showList.insertAll(0, topList);
    }

    return AZListViewContainer(
      memberList: showList,
      itemBuilder: (context, index) {
        final memberInfo = showList[index].memberInfo;
        if (memberInfo is TopListItem) {
          if (widget.topListItemBuilder != null) {
            final customWidget = widget.topListItemBuilder!(memberInfo);
            if (customWidget != null) {
              return customWidget;
            }
          }
          return InkWell(
              onTap: () {
                if (memberInfo.onTap != null) {
                  memberInfo.onTap!();
                }
              },
              child: Container(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      margin: const EdgeInsets.only(right: 12, bottom: 12),
                      child: memberInfo.icon,
                    ),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: hexToColor("DBDBDB")))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            memberInfo.name,
                            style: TextStyle(
                                color: hexToColor("111111"), fontSize: 18),
                          ),
                          Expanded(child: Container()),
                          // if (item.id == "newContact")
                          //   const TIMUIKitUnreadCount(),
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              color: hexToColor('BBBBBB'),
                            ),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ));
        } else {
          return InkWell(
            onTap: () {
              if (widget.isCanSelectMemberItem) {
                if (selectedMember.contains(memberInfo)) {
                  selectedMember.remove(memberInfo);
                } else {
                  if (selectedMemberIsOverFlow()) {
                    return;
                  }
                  selectedMember.add(memberInfo);
                }
                if (widget.onSelectedMemberItemChange != null) {
                  widget.onSelectedMemberItemChange!(selectedMember);
                }
                setState(() {});
                return;
              }
              if (widget.onTapItem != null) {
                widget.onTapItem!(memberInfo);
              }
            },
            child: _buildItem(theme, memberInfo),
          );
        }
      },
    );
  }
}

class TopListItem {
  final String name;
  final String id;
  final Widget? icon;
  final Function()? onTap;
  TopListItem({required this.name, required this.id, this.icon, this.onTap});
}
