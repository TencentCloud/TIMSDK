import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/az_list_view.dart';

import '../../../i18n/i18n_utils.dart';

class GroupProfileMemberList extends StatefulWidget {
  final List<V2TimGroupMemberFullInfo?> memberList;
  final Function(String userID) removeMember;

  const GroupProfileMemberList(
      {Key? key, required this.memberList, required this.removeMember})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupProfileMemberListState();
}

class _GroupProfileMemberListState extends State<GroupProfileMemberList> {
  bool isTextFieldFocued = false;

  _getShowName(V2TimGroupMemberFullInfo? item) {
    return item?.friendRemark ??
        item?.nameCard ??
        item?.nickName ??
        item?.userID ??
        "";
  }

  List<ISuspensionBeanImpl> _getShowList(
      List<V2TimGroupMemberFullInfo?> memberList) {
    final List<ISuspensionBeanImpl> showList = List.empty(growable: true);
    for (var i = 0; i < memberList.length; i++) {
      final item = memberList[i];
      final showName = _getShowName(item);
      if (item?.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER ||
          item?.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
        showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: "@"));
      } else {
        String pinyin = PinyinHelper.getPinyinE(showName);
        String tag = pinyin.substring(0, 1).toUpperCase();
        if (RegExp("[A-Z]").hasMatch(tag)) {
          showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: tag));
        } else {
          showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: "#"));
        }
      }
    }

    SuspensionUtil.sortListBySuspensionTag(showList);

    return showList;
  }

  Widget _buildListItem(
      BuildContext context, V2TimGroupMemberFullInfo memberInfo) {
    final I18nUtils ttBuild = I18nUtils(context);
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    return Container(
        color: Colors.white,
        child: Slidable(
            endActionPane: memberInfo.role ==
                    GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER
                ? ActionPane(motion: const DrawerMotion(), children: [
                    SlidableAction(
                      onPressed: (_) {
                        widget.removeMember(memberInfo.userID);
                      },
                      flex: 1,
                      backgroundColor:
                          theme.cautionColor ?? CommonColor.cautionColor,
                      autoClose: true,
                      label: ttBuild.imt("删除"),
                    )
                  ])
                : null,
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
                    memberInfo.role ==
                            GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER
                        ? Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Text(ttBuild.imt("群主"),
                                style: TextStyle(
                                  color: theme.ownerColor,
                                  fontSize: 12,
                                )),
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: theme.ownerColor ??
                                      CommonColor.ownerColor,
                                  width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                          )
                        : memberInfo.role ==
                                GroupMemberRoleType
                                    .V2TIM_GROUP_MEMBER_ROLE_ADMIN
                            ? Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Text(ttBuild.imt("管理员"),
                                    style: TextStyle(
                                      color: theme.adminColor,
                                      fontSize: 12,
                                    )),
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.adminColor ??
                                          CommonColor.adminColor,
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                              )
                            : Container()
                  ],
                ),
                onTap: () {},
              ),
              Divider(
                  thickness: 1,
                  indent: 74,
                  endIndent: 0,
                  color: theme.weakBackgroundColor,
                  height: 0)
            ])));
  }

  static Widget getSusItem(BuildContext context, String tag,
      {double susHeight = 40}) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final I18nUtils ttBuild = I18nUtils(context);
    if (tag == '@') {
      tag = ttBuild.imt("群主、管理员");
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16.0),
      color: theme.weakBackgroundColor,
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: true,
        style: TextStyle(
          fontSize: 14.0,
          color: theme.darkTextColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          // TODO: implement build
          // throw UnimplementedError();
          final theme = value.theme;
          final showList = _getShowList(widget.memberList);
          return Container(
            color: theme.weakBackgroundColor,
            child: SafeArea(
                child: Column(
              children: [
                // TextField(
                //   textAlign: isTextFieldFocued ? TextAlign.start : TextAlign.center,
                //   decoration: const InputDecoration(hintText: ttBuild.imt("搜索")),
                //   onTap: () {
                //     setState(() {
                //       isTextFieldFocued = true;
                //     });
                //   },
                // ),
                Expanded(
                  child: AZListViewContainer(
                      memberList: showList,
                      susItemBuilder: (context, index) {
                        final model = showList[index];
                        return getSusItem(context, model.getSuspensionTag());
                      },
                      itemBuilder: (context, index) {
                        final memberInfo = showList[index].memberInfo
                            as V2TimGroupMemberFullInfo;

                        return _buildListItem(context, memberInfo);
                      }),
                )
              ],
            )),
          );
        }));
  }
}

class GroupProfileMemberListPage extends StatelessWidget {
  final List<V2TimGroupMemberFullInfo?> memberList;
  final TUIGroupProfileViewModel model;

  const GroupProfileMemberListPage(
      {Key? key, required this.memberList, required this.model})
      : super(key: key);

  _kickedOffMember(String userID) async {
    final response = await model.kickOffMember(userID);
    if (response.code != 0) {
      Fluttertoast.showToast(
        msg: response.desc,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          String groupMemberNum = memberList.length.toString();
          final I18nUtils ttBuild = I18nUtils(context);
          final theme = value.theme;
          return Scaffold(
              appBar: AppBar(
                  title: Text(
                    ttBuild.imt_para("群成员({{groupMemberNum}}人)", "群成员(${groupMemberNum}人)")(groupMemberNum: groupMemberNum),
                    style: const TextStyle(color: Colors.black),
                  ),
                  shadowColor: Colors.white,
                  backgroundColor: theme.lightPrimaryColor,
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  )),
              body: ChangeNotifierProvider.value(
                  value: model,
                  child: Consumer<TUIGroupProfileViewModel>(
                      builder: ((context, value, child) {
                    return GroupProfileMemberList(
                        memberList: value.groupMemberList ?? [],
                        removeMember: _kickedOffMember);
                  }))));
        }));
  }
}
