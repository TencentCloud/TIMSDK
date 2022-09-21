import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable_for_tencent_im/flutter_slidable.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/radio_button.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class GroupProfileGroupManage extends TIMUIKitStatelessWidget {
  final TUIGroupProfileModel model;
  GroupProfileGroupManage(this.model, {Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final model = Provider.of<TUIGroupProfileModel>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupProfileGroupManagePage(
                      model: model,
                    )));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 12, left: 16, bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(
                    color: theme.weakDividerColor ??
                        CommonColor.weakDividerColor))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TIM_t("群管理"),
              style: TextStyle(fontSize: 16, color: theme.darkTextColor),
            ),
            Icon(Icons.keyboard_arrow_right, color: theme.weakTextColor)
          ],
        ),
      ),
    );
  }
}

/// 管理员设置页面
class GroupProfileGroupManagePage extends StatefulWidget {
  final TUIGroupProfileModel model;
  const GroupProfileGroupManagePage({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupProfileGroupManagePageState();
}

class _GroupProfileGroupManagePageState
    extends TIMUIKitState<GroupProfileGroupManagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: widget.model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final memberList =
              Provider.of<TUIGroupProfileModel>(context).groupMemberList;
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          final isAllMuted = widget.model.groupInfo?.isAllMuted ?? false;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                TIM_t("群管理"),
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
              shadowColor: theme.weakDividerColor,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                    theme.primaryColor ?? CommonColor.primaryColor
                  ]),
                ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              leading: IconButton(
                padding: const EdgeInsets.only(left: 16),
                constraints: const BoxConstraints(),
                icon: Image.asset(
                  'images/arrow_back.png',
                  package: 'tim_ui_kit',
                  height: 34,
                  width: 34,
                ),
                onPressed: () async {
                  if (isAllMuted != widget.model.groupInfo?.isAllMuted) {
                    widget.model.setMuteAll(isAllMuted);
                  }
                  Navigator.pop(context);
                },
              ),
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 12, left: 16, bottom: 12, right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.weakDividerColor ??
                                  CommonColor.weakDividerColor))),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupProfileSetManagerPage(
                              model: widget.model,
                            ),
                          ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(TIM_t("设置管理员"),
                            style: TextStyle(
                                fontSize: 16, color: theme.darkTextColor)),
                        Icon(Icons.keyboard_arrow_right,
                            color: theme.weakTextColor)
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      top: 12, left: 16, bottom: 12, right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.weakDividerColor ??
                                  CommonColor.weakDividerColor))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TIM_t("全员禁言"),
                        style:
                            TextStyle(fontSize: 16, color: theme.darkTextColor),
                      ),
                      CupertinoSwitch(
                          value: isAllMuted,
                          onChanged: (value) async {
                            widget.model.setMuteAll(value);
                          },
                          activeColor: theme.primaryColor)
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: theme.weakBackgroundColor,
                  alignment: Alignment.topLeft,
                  child: Text(
                    TIM_t("全员禁言开启后，只允许群主和管理员发言。"),
                    style: TextStyle(fontSize: 12, color: theme.weakTextColor),
                  ),
                ),
                if (!isAllMuted)
                  InkWell(
                    child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      color: theme.weakDividerColor ??
                                          CommonColor.weakDividerColor))),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(TIM_t("添加需要禁言的群成员"))
                            ],
                          ),
                        )),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupProfileAddAdmin(
                                    appbarTitle: TIM_t("设置禁言"),
                                    memberList: memberList.where((element) {
                                      final isMute = element?.muteUntil != 0;
                                      final isMember = element!.role ==
                                          GroupMemberRoleType
                                              .V2TIM_GROUP_MEMBER_ROLE_MEMBER;
                                      return !isMute && isMember;
                                    }).toList(),
                                    selectCompletedHandler:
                                        (context, selectedMember) async {
                                      if (selectedMember.isNotEmpty) {
                                        for (var member in selectedMember) {
                                          final userID = member!.userID;
                                          widget.model
                                              .muteGroupMember(userID, true);
                                        }
                                      }
                                    },
                                  )));
                    },
                  ),
                if (!isAllMuted)
                  ...memberList
                      .where((element) => element?.muteUntil != 0)
                      .map((e) => _buildListItem(
                          context,
                          e!,
                          ActionPane(motion: const DrawerMotion(), children: [
                            SlidableAction(
                              onPressed: (_) {
                                widget.model.muteGroupMember(e.userID, false);
                              },
                              flex: 1,
                              backgroundColor: theme.cautionColor ??
                                  CommonColor.cautionColor,
                              autoClose: true,
                              label: TIM_t("删除"),
                            )
                          ])))
                      .toList()
              ],
            ),
          );
        });
  }
}

_getShowName(V2TimGroupMemberFullInfo? item) {
  final friendRemark = item?.friendRemark ?? "";
  final nameCard = item?.nameCard ?? "";
  final nickName = item?.nickName ?? "";
  final userID = item?.userID ?? "";
  return friendRemark.isNotEmpty
      ? friendRemark
      : nameCard.isNotEmpty
          ? nameCard
          : nickName.isNotEmpty
              ? nickName
              : userID;
}

Widget _buildListItem(BuildContext context, V2TimGroupMemberFullInfo memberInfo,
    ActionPane? endActionPane) {
  final theme = Provider.of<TUIThemeViewModel>(context).theme;
  return Container(
      color: Colors.white,
      child: Slidable(
          endActionPane: endActionPane,
          child: Column(children: [
            ListTile(
              tileColor: Colors.black,
              leading: SizedBox(
                width: 36,
                height: 36,
                child: Avatar(
                  faceUrl: memberInfo.faceUrl ?? "",
                  showName: _getShowName(memberInfo),
                  type: 2,
                ),
              ),
              title: Row(
                children: [
                  Text(_getShowName(memberInfo),
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              onTap: () {},
            ),
            Divider(
                thickness: 1,
                indent: 74,
                endIndent: 0,
                color: theme.weakDividerColor,
                height: 0)
          ])));
}

/// 选择管理员
class GroupProfileSetManagerPage extends StatefulWidget {
  final TUIGroupProfileModel model;

  const GroupProfileSetManagerPage({Key? key, required this.model})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _GroupProfileSetManagerPageState();
}

class _GroupProfileSetManagerPageState
    extends TIMUIKitState<GroupProfileSetManagerPage> {
  List<V2TimGroupMemberFullInfo?> _getAdminMemberList(
      List<V2TimGroupMemberFullInfo?> memberList) {
    return memberList
        .where((member) =>
            member?.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN)
        .toList();
  }

  List<V2TimGroupMemberFullInfo?> _getOwnerList(
      List<V2TimGroupMemberFullInfo?> memberList) {
    return memberList
        .where((member) =>
            member?.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER)
        .toList();
  }

  _removeAdmin(
      BuildContext context, V2TimGroupMemberFullInfo memberFullInfo) async {
    final res = await widget.model.setMemberToNormal(memberFullInfo.userID);
    if (res.code == 0) {
      onTIMCallback(TIMCallback(
          type: TIMCallbackType.INFO,
          infoRecommendText: TIM_t("成功取消管理员身份"),
          infoCode: 6661003));
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: widget.model)],
      builder: (context, w) {
        final model = Provider.of<TUIGroupProfileModel>(context);
        final memberList = model.groupMemberList;
        final adminList = _getAdminMemberList(memberList);
        final ownerList = _getOwnerList(memberList);
        final String option2 = adminList.length.toString();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              TIM_t("设置管理员"),
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            shadowColor: theme.weakDividerColor,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                  theme.primaryColor ?? CommonColor.primaryColor
                ]),
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          body: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                color: theme.weakDividerColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Text(
                  TIM_t("群主"),
                  style: TextStyle(fontSize: 14, color: theme.weakTextColor),
                ),
              ),
              ...ownerList
                  .map(
                    (e) => _buildListItem(context, e!, null),
                  )
                  .toList(),
              Container(
                alignment: Alignment.topLeft,
                color: theme.weakDividerColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Text(
                  TIM_t_para("管理员 ({{option2}}/10)", "管理员 ($option2/10)")(
                      option2: option2),
                  style: TextStyle(fontSize: 14, color: theme.weakTextColor),
                ),
              ),
              InkWell(
                child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(
                                  color: theme.weakDividerColor ??
                                      CommonColor.weakDividerColor))),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(TIM_t("添加管理员"))
                        ],
                      ),
                    )),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupProfileAddAdmin(
                                memberList: memberList
                                    .where((element) =>
                                        element?.role ==
                                        GroupMemberRoleType
                                            .V2TIM_GROUP_MEMBER_ROLE_MEMBER)
                                    .toList(),
                                appbarTitle: TIM_t("设置管理员"),
                                selectCompletedHandler:
                                    (context, selectedMember) async {
                                  if (selectedMember.isNotEmpty) {
                                    for (var member in selectedMember) {
                                      final userID = member!.userID;
                                      widget.model.setMemberToAdmin(userID);
                                    }
                                  }
                                },
                              )));
                },
              ),
              ...adminList
                  .map((e) => _buildListItem(
                      context,
                      e!,
                      ActionPane(motion: const DrawerMotion(), children: [
                        SlidableAction(
                          onPressed: (_) {
                            _removeAdmin(context, e);
                          },
                          flex: 1,
                          backgroundColor:
                              theme.cautionColor ?? CommonColor.cautionColor,
                          autoClose: true,
                          label: TIM_t("删除"),
                        )
                      ])))
                  .toList(),
            ],
          )),
        );
      },
    );
  }
}

/// 添加管理员
class GroupProfileAddAdmin extends StatefulWidget {
  final List<V2TimGroupMemberFullInfo?> memberList;
  final String appbarTitle;
  final void Function(BuildContext context,
          List<V2TimGroupMemberFullInfo?> selectedMemberList)?
      selectCompletedHandler;

  const GroupProfileAddAdmin(
      {Key? key,
      required this.memberList,
      this.selectCompletedHandler,
      required this.appbarTitle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupProfileAddAdminState();
}

class _GroupProfileAddAdminState extends TIMUIKitState<GroupProfileAddAdmin> {
  List<V2TimGroupMemberFullInfo?> selectedMemberList = [];

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appbarTitle,
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        shadowColor: theme.weakDividerColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            TIM_t("取消"),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.selectCompletedHandler != null) {
                widget.selectCompletedHandler!(context, selectedMemberList);
              }
              Navigator.of(context).pop();
            },
            child: Text(
              TIM_t("完成"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            color: theme.weakDividerColor,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Text(
              TIM_t("群成员"),
              style: TextStyle(fontSize: 14, color: theme.weakTextColor),
            ),
          ),
          ...widget.memberList
              .map((e) => Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                color: theme.weakDividerColor ??
                                    CommonColor.weakDividerColor))),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        final isChecked = selectedMemberList.contains(e);
                        if (isChecked) {
                          selectedMemberList.add(e);
                        } else {
                          selectedMemberList.remove(e);
                        }
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          CheckBoxButton(
                            isChecked: selectedMemberList.contains(e),
                            onChanged: (value) {
                              if (value) {
                                selectedMemberList.add(e);
                              } else {
                                selectedMemberList.remove(e);
                              }
                              setState(() {});
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: Avatar(
                              faceUrl: e?.faceUrl ?? "",
                              showName: _getShowName(e),
                              type: 2,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(_getShowName(e),
                              style: const TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      )),
    );
  }
}
