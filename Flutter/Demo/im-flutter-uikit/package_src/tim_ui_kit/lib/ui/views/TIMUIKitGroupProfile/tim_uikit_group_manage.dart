import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/radio_button.dart';

import '../../../i18n/i18n_utils.dart';

class GroupProfileGroupManage extends StatelessWidget {
  const GroupProfileGroupManage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final I18nUtils ttBuild = I18nUtils(context);
          final theme = value.theme;
          final model = SharedDataWidget.of(context)?.model;
          if (model == null) {
            return Container();
          }
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
                    ttBuild.imt("群管理"),
                    style: TextStyle(fontSize: 16, color: theme.darkTextColor),
                  ),
                  Icon(Icons.keyboard_arrow_right, color: theme.weakTextColor)
                ],
              ),
            ),
          );
        }));
  }
}

/// 管理员设置页面
class GroupProfileGroupManagePage extends StatefulWidget {
  final TUIGroupProfileViewModel model;
  const GroupProfileGroupManagePage({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupProfileGroupManagePageState();
}

class _GroupProfileGroupManagePageState
    extends State<GroupProfileGroupManagePage> {
  bool isAllMuted = false;

  @override
  void initState() {
    setState(() {
      isAllMuted = widget.model.groupInfo?.isAllMuted ?? false;
    });
    super.initState();
  }

  showNoNetwork() {
    final I18nUtils ttBuild = I18nUtils(context);
    Fluttertoast.showToast(
      msg: ttBuild.imt("无网络连接，无法修改"),
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: widget.model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final I18nUtils ttBuild = I18nUtils(context);
          final memberList =
              Provider.of<TUIGroupProfileViewModel>(context).groupMemberList ??
                  [];
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                ttBuild.imt("群管理"),
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
                    final res = await widget.model.setMuteAll(isAllMuted);
                    if (res != null) {
                      if (res.code != 0) {
                        Fluttertoast.showToast(
                          msg: res.desc,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                        );
                      }
                    }
                  }
                  Navigator.pop(context);
                },
              ),
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 12, left: 16, bottom: 12),
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
                        Text(ttBuild.imt("设置管理员"),
                            style: TextStyle(
                                fontSize: 16, color: theme.darkTextColor)),
                        Icon(Icons.keyboard_arrow_right,
                            color: theme.weakTextColor)
                      ],
                    ),
                  ),
                ),
                Container(
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
                        ttBuild.imt("全员禁言"),
                        style:
                            TextStyle(fontSize: 16, color: theme.darkTextColor),
                      ),
                      CupertinoSwitch(
                          value: isAllMuted,
                          onChanged: (value) async {
                            setState(() {
                              isAllMuted = value;
                            });
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
                    ttBuild.imt("全员禁言开启后，只允许群主和管理员发言。"),
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
                              Text(ttBuild.imt("添加需要禁言的群成员"))
                            ],
                          ),
                        )),
                    onTap: () async {
                      final connectivityResult =
                          await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.none) {
                        showNoNetwork();
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupProfileAddAdmin(
                                    appbarTitle: ttBuild.imt("设置禁言"),
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
                                          final res = await widget.model
                                              .muteGroupMember(userID, true);
                                          if (res != null && res.code != 0) {
                                            Fluttertoast.showToast(
                                              msg: res.desc,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              textColor: Colors.white,
                                              backgroundColor: Colors.black,
                                            );
                                          }
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
                              label: ttBuild.imt("删除"),
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
                    showName: _getShowName(memberInfo)),
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
  final TUIGroupProfileViewModel model;

  const GroupProfileSetManagerPage({Key? key, required this.model})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _GroupProfileSetManagerPageState();
}

class _GroupProfileSetManagerPageState
    extends State<GroupProfileSetManagerPage> {
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
    final I18nUtils ttBuild = I18nUtils(context);
    if (res.code != 0) {
      Fluttertoast.showToast(
        msg: res.desc,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
    } else {
      Fluttertoast.showToast(
        msg: ttBuild.imt("成功取消管理员身份"),
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
    }
  }

  showNoNetwork() {
    final I18nUtils ttBuild = I18nUtils(context);
    Fluttertoast.showToast(
      msg: ttBuild.imt("无网络连接，无法修改"),
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final I18nUtils ttBuild = I18nUtils(context);
          final theme = value.theme;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                ttBuild.imt("设置管理员"),
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
            body: ChangeNotifierProvider.value(
              value: widget.model,
              child: Consumer<TUIGroupProfileViewModel>(
                builder: (context, value, child) {
                  final memberList = value.groupMemberList ?? [];
                  final adminList = _getAdminMemberList(memberList);
                  final ownerList = _getOwnerList(memberList);
                  final String adminNum = adminList.length.toString();
                  return SingleChildScrollView(
                      child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        color: theme.weakDividerColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        child: Text(
                          ttBuild.imt("群主"),
                          style: TextStyle(
                              fontSize: 14, color: theme.weakTextColor),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        child: Text(
                          ttBuild.imt_para("管理员 ({{adminNum}}/10)",
                              "管理员 ($adminNum/10)")(adminNum: adminNum),
                          style: TextStyle(
                              fontSize: 14, color: theme.weakTextColor),
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
                                  Text(ttBuild.imt("添加管理员"))
                                ],
                              ),
                            )),
                        onTap: () async {
                          final connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.none) {
                            showNoNetwork();
                            return;
                          }
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
                                        appbarTitle: ttBuild.imt("设置管理员"),
                                        selectCompletedHandler:
                                            (context, selectedMember) async {
                                          if (selectedMember.isNotEmpty) {
                                            for (var member in selectedMember) {
                                              final userID = member!.userID;
                                              final res = await widget.model
                                                  .setMemberToAdmin(userID);
                                              if (res.code != 0) {
                                                Fluttertoast.showToast(
                                                  msg: res.desc,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  textColor: Colors.white,
                                                  backgroundColor: Colors.black,
                                                );
                                              }
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
                              ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) {
                                        _removeAdmin(context, e);
                                      },
                                      flex: 1,
                                      backgroundColor: theme.cautionColor ??
                                          CommonColor.cautionColor,
                                      autoClose: true,
                                      label: ttBuild.imt("删除"),
                                    )
                                  ])))
                          .toList(),
                    ],
                  ));
                },
              ),
            ),
          );
        }));
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

class _GroupProfileAddAdminState extends State<GroupProfileAddAdmin> {
  List<V2TimGroupMemberFullInfo?> selectedMemberList = [];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final I18nUtils ttBuild = I18nUtils(context);
          final theme = value.theme;
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
                  ttBuild.imt("取消"),
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
                      widget.selectCompletedHandler!(
                          context, selectedMemberList);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    ttBuild.imt("完成"),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Text(
                    ttBuild.imt("群成员"),
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
                                      showName: _getShowName(e)),
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
        }));
  }
}
