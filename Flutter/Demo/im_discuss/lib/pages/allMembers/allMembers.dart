import 'package:azlistview/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';

import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/utils/toast.dart';

class AllMembers extends StatefulWidget {
  final V2TimGroupInfoResult groupInfo;
  const AllMembers(this.groupInfo, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AllMembersState();
}

class AllMembersState extends State<AllMembers> {
  List<MemberInfo>? memberList;
  List<MemberInfo>? searchedMemberList;
  bool hasFocusOnSearch = false;
  @override
  void initState() {
    super.initState();
    getAllgroupMember();
    // Utils.toast("长按可进行群成员踢出");
  }

  MemberInfo _handleMemberInfo(V2TimGroupMemberFullInfo m) {
    if (m.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER ||
        m.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
      return MemberInfo(memberInfo: m, tagIndex: '@');
    }
    String pinyin = PinyinHelper.getPinyinE(m.nickName ?? m.userID);
    String tag = pinyin.substring(0, 1).toUpperCase();
    if (RegExp("[A-Z]").hasMatch(tag)) {
      return MemberInfo(memberInfo: m, tagIndex: tag);
    }
    return MemberInfo(memberInfo: m, tagIndex: '#');
  }

  getAllgroupMember() async {
    List<MemberInfo>? curList = [];
    String nextSeq = "";
    try {
      while (nextSeq != "0") {
        final res = await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: widget.groupInfo.groupInfo!.groupID,
              filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
              nextSeq: nextSeq == "" ? "0" : nextSeq, //第一次拉填0
            );
        curList = res.data!.memberInfoList!
            .map((m) => _handleMemberInfo(m!))
            .toList();
        curList.sort((a, b) {
          if (a.memberInfo.role ==
              GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER) {
            return -1;
          }
          if (b.memberInfo.role ==
              GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER) {
            return 1;
          }
          String aName =
              (a.memberInfo.nickName ?? a.memberInfo.userID).toLowerCase();
          String bName =
              (b.memberInfo.nickName ?? b.memberInfo.userID).toLowerCase();
          return aName.compareTo(bName);
        });
        SuspensionUtil.sortListBySuspensionTag(curList);
        nextSeq = res.data!.nextSeq!;
      }
    } catch (e) {
      Utils.toast('获取成员列表失败');
    }
    setState(() {
      memberList = curList;
      searchedMemberList = curList;
    });
  }

  Future<bool?> showDeleteConfirmDialog(context, userID) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: const SizedBox(
              height: 64,
              child: Center(
                  child: Text("确定删除该成员", style: TextStyle(fontSize: 18)))),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            CupertinoDialogAction(
              child:
                  const Text("删除", style: TextStyle(color: Color(0xFFFF584C))),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop();
                TencentImSDKPlugin.v2TIMManager
                    .getGroupManager()
                    .kickGroupMember(
                  groupID: widget.groupInfo.groupInfo!.groupID,
                  memberList: [userID],
                ).then((res) {
                  if (res.code == 0) {
                    getAllgroupMember();
                  } else {
                    Utils.toast("踢人出群失败 ${res.code} ${res.desc}");
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  // isShowSuspension 是AzList里用来判断是否需要加suspension隔断用以区分群组的，只在每个群首的项目标记就行
  addShowSuspension(List<MemberInfo> curList) {
    for (int i = 0; i < curList.length; i++) {
      if (i == 0 || curList[i].tagIndex != curList[i - 1].tagIndex) {
        curList[i].isShowSuspension = true;
      }
    }
    return curList;
  }

  filterMemberList(String input) {
    var filteredList = memberList;
    if (memberList != null && input.isNotEmpty) {
      filteredList = memberList!.where((member) {
        String userName =
            member.memberInfo.nickName ?? member.memberInfo.userID;
        return userName.toLowerCase().contains(input.toLowerCase());
      }).toList();
    }
    setState(() {
      searchedMemberList = filteredList;
    });
  }

  static Widget getSusItem(BuildContext context, String tag,
      {double susHeight = 40}) {
    if (tag == '@') {
      tag = '群主、管理员';
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16.0),
      color: const Color(0xFFF3F4F5),
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: true,
        style: const TextStyle(
          fontSize: 14.0,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, MemberInfo model) {
    V2TimGroupMemberFullInfo memberInfo = model.memberInfo;
    return Container(
        color: Colors.white,
        child: Slidable(
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '删除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  showDeleteConfirmDialog(context, memberInfo.userID);
                },
                closeOnTap: true,
              ),
            ],
            actionPane: const SlidableDrawerActionPane(),
            child: Column(children: [
              ListTile(
                tileColor: Colors.black,
                leading: Avatar(
                  width: 36,
                  height: 36,
                  avtarUrl:
                      memberInfo.faceUrl == null || memberInfo.faceUrl == ''
                          ? 'images/logo.png'
                          : memberInfo.faceUrl,
                  radius: 4.0,
                ),
                title: Row(
                  children: [
                    Text(memberInfo.nickName ?? memberInfo.userID,
                        style: const TextStyle(fontSize: 16)),
                    model.memberInfo.role ==
                            GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER
                        ? Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: const Text('群主',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                )),
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.orange, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                          )
                        : model.memberInfo.role ==
                                GroupMemberRoleType
                                    .V2TIM_GROUP_MEMBER_ROLE_ADMIN
                            ? Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: const Text('管理员',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                    )),
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blue, width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                              )
                            : Container()
                  ],
                ),
                onTap: () {},
              ),
              const Divider(
                  thickness: 1,
                  indent: 74,
                  endIndent: 0,
                  color: Color(0xFFEDEDED),
                  height: 0)
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: const Color(0xFFECECEC),
        elevation: 0,
        title: Text(
          '群成员 (${memberList?.length ?? 0})',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: GestureDetector(
          onTap: () {
            setState(() {
              hasFocusOnSearch = false;
            });
          },
          child: Container(
              color: const Color(0xFFF2F3F5),
              child: SafeArea(
                  child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      color: const Color(0xFFEBF0F6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            hasFocusOnSearch = true;
                          });
                          filterMemberList('');
                        },
                        child: Container(
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: hasFocusOnSearch
                                ? TextField(
                                    decoration:
                                        const InputDecoration(hintText: '搜索成员'),
                                    autofocus: true,
                                    // TODO: debounce
                                    onChanged: filterMemberList,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                        Icon(Icons.search,
                                            color: Colors.black26),
                                        Text('搜索',
                                            style: TextStyle(
                                                color: Colors.black26))
                                      ])),
                      )),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      if (hasFocusOnSearch) {
                        setState(() {
                          hasFocusOnSearch = false;
                        });
                      }
                    },
                    child: Center(
                        child: searchedMemberList?.isNotEmpty ?? false
                            ? AzListView(
                                data: addShowSuspension(searchedMemberList!),
                                itemCount: searchedMemberList!.length,
                                indexBarData: SuspensionUtil.getTagIndexList(
                                        searchedMemberList!)
                                    .skipWhile((tagIndex) => tagIndex == '@')
                                    .toList(),
                                itemBuilder: (BuildContext context, int index) {
                                  return _buildListItem(
                                      context, searchedMemberList![index]);
                                },
                                susItemBuilder:
                                    (BuildContext context, int index) {
                                  MemberInfo model = searchedMemberList![index];
                                  return getSusItem(
                                      context, model.getSuspensionTag());
                                },
                              )
                            : const Text('暂无成员',
                                style: TextStyle(
                                    color: Colors.black26, fontSize: 20))),
                  ))
                ],
              )))),
    );
  }
}

class MemberInfo extends ISuspensionBean {
  late V2TimGroupMemberFullInfo memberInfo;
  String tagIndex;
  MemberInfo({required this.memberInfo, required this.tagIndex});

  @override
  String getSuspensionTag() => tagIndex;
}
