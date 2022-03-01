import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:timuikit/utils/discuss.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:expandable/expandable.dart';
import 'chat.dart';
import 'provider/discuss.dart';
import 'package:provider/provider.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class Channel extends StatelessWidget {
  const Channel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
          color: CommonColor.weakBackgroundColor,
        ),
        Expanded(
            child: Row(
          children: const [
            ChannelSection(),
            CurrentSelectChannel(),
          ],
        ))
      ],
    );
  }
}

class ChannelSection extends StatelessWidget {
  const ChannelSection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      color: CommonColor.weakBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 22, bottom: 12),
            child: const ChannelAvatar(),
          ), // 头像
          Container(
            width: 36,
            height: 1,
            color: CommonColor.weakDividerColor,
          ), // 分割线
          const ChannelList(), // 频道列表
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: const AddChannel(), //创建 ICON,
          )
        ],
      ),
    );
  }
}

class ChannelAvatar extends StatefulWidget {
  const ChannelAvatar({Key? key}) : super(key: key);

  @override
  _ChannelAvatarState createState() => _ChannelAvatarState();
}

class _ChannelAvatarState extends State<ChannelAvatar> {
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  V2TimUserFullInfo userInfo = V2TimUserFullInfo();

  getLoginUserInfo() async {
    final res = await sdkInstance.getLoginUser();
    if (res.code == 0) {
      final result = await sdkInstance.getUsersInfo(userIDList: [res.data!]);
      if (result.code == 0) {
        setState(() {
          userInfo = result.data![0];
        });
      }
    }
  }

  @override
  void initState() {
    getLoginUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final faceUrl = userInfo.faceUrl ?? "";
    final nickName = userInfo.nickName ?? "";
    final showName = nickName != "" ? nickName : userInfo.userID ?? "";
    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: null,
        child: SizedBox(
          height: 44,
          width: 44,
          child: Avatar(faceUrl: faceUrl, showName: showName),
        ),
      ),
    );
  }
}

class ChannelList extends StatefulWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChannelListState();
}

class ChannelListState extends State<ChannelList> {
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
  );

  @override
  void initState() {
    super.initState();
    getChannelList();
  }

  getChannelList() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    final listFromLocal = prefs.getString("channelListMain") ?? "";
    if(listFromLocal.isNotEmpty){
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(jsonDecode(listFromLocal));
      Provider.of<DiscussData>(context, listen: false).updateChannelList(list);
    }

    Map<String, dynamic> data = await DisscussApi.getChannelList();
    if (data['code'] == 0) {
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(data['data']['rows']);
      Provider.of<DiscussData>(context, listen: false).updateChannelList(list);
      prefs.setString('channelListMain', jsonEncode(list));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> channelList =
        Provider.of<DiscussData>(context).channelList;
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: scrollController,
        reverse: false,
        child: Column(
          children: channelList
              .map(
                (e) => ChannelItem(
                  data: e,
                  index: channelList.indexWhere((element) => element == e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class ChannelItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  const ChannelItem({
    Key? key,
    required this.data,
    required this.index,
  }) : super(key: key);
  setSelectedIndex(context) {
    Provider.of<DiscussData>(context, listen: false)
        .updateCurrentSelectedChannel(index);
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = Provider.of<DiscussData>(context).currentSelectedChannel;
    return GestureDetector(
      onTap: () {
        setSelectedIndex(context);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhysicalModel(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: currentIndex == index
                        ? hexToColor("0196ff")
                        : hexToColor("ffffff"),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      data['icon'],
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddChannel extends StatelessWidget {
  const AddChannel({Key? key}) : super(key: key);
  Future<bool?> showWarning(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: null,
          content: Text(imt("我们还在内测中，暂不支持创建频道。")),
          actions: <Widget>[
            TextButton(
              child: Text(imt("取消")),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: Text(imt("确定")),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PhysicalModel(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(23),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: () {
              showWarning(context);
            },
            child: Container(
              height: 46,
              width: 46,
              color: Colors.white,
              child: const Icon(
                Icons.add,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CurrentSelectChannel extends StatelessWidget {
  const CurrentSelectChannel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> infos =
        Provider.of<DiscussData>(context).currentChannelInfo ?? Map.from({});
    return Expanded(
      child: Container(
        color: CommonColor.weakBackgroundColor,
        child: Column(
          children: [
            ChannelBanner(info: infos),
            DisscussList(info: infos),
          ],
        ),
      ),
    );
  }
}

class ChannelBanner extends StatelessWidget {
  final Map<String, dynamic> info;

  const ChannelBanner({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = info['name'] ?? "";
    // String icon = info['icon'] ?? "";
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 145,
            padding: const EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              image: DecorationImage(
                image: name == imt("实时音视频 TRTC") // 暂时先这么写，后面配置到后台
                    ? const AssetImage("assets/trtc_banner.png")
                    : const AssetImage("assets/im_banner.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class DisscussList extends StatelessWidget {
  final Map<String, dynamic> info;
  const DisscussList({
    Key? key,
    required this.info,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String catString = info['category'] ?? "";
    List<String> catList = catString.split("|");
    String chanelId = info['uuid'] ?? "";
    return Expanded(
      child: Container(
        color: Colors.white,
        child: DisscussListScroller(catList, chanelId),
      ),
    );
  }
}

class DisscussListScroller extends StatefulWidget {
  final List<String> catList;

  final String channelId;

  const DisscussListScroller(this.catList, this.channelId, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DisscussListScrollerState();
}

class _DisscussListScrollerState extends State<DisscussListScroller> {
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
  );
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();

  @override
  initState() {
    sdkInstance.getConversationManager().setConversationListener(
            listener: V2TimConversationListener(
                onConversationChanged: (conversationList) {
          onConversationChanged(conversationList);
        }, onNewConversation: (conversationList) {
          onNewConversation(conversationList);
        }));
    super.initState();
  }

  onConversationChanged(conversationList) {
    Provider.of<DiscussData>(context, listen: false)
        .conversationItemChange(conversationList);
  }

  onNewConversation(conversationList) {
    Provider.of<DiscussData>(context, listen: false)
        .addNewConversation(conversationList);
  }

  @override
  Widget build(BuildContext context) {
    List<V2TimConversation> conversationList =
        Provider.of<DiscussData>(context).conversationList;
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: widget.catList
              .map(
                (e) => DisscussListByCategory(
                    e, widget.channelId, conversationList),
              )
              .toList(),
        ),
      ),
    );
  }
}

class DisscussListByCategory extends StatefulWidget {
  final String category;
  final String channelId;
  final List<V2TimConversation?> conversationList;
  const DisscussListByCategory(
      this.category, this.channelId, this.conversationList,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DisscussListByCategoryState();
}

class _DisscussListByCategoryState extends State<DisscussListByCategory> {
  ExpandableController controller = ExpandableController();

  getDiscussList() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    final listFromLocal = prefs.getString("discussListMain") ?? "";
    if(listFromLocal.isNotEmpty){
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(jsonDecode(listFromLocal));
      Provider.of<DiscussData>(context, listen: false).updateDiscussList(list);
    }

    Map<String, dynamic> data =
        await DisscussApi.getDiscussList(offset: 0, limit: 100);
    if (data['code'] == 0) {
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(data['data']['rows']);
      Provider.of<DiscussData>(context, listen: false).updateDiscussList(list);
      prefs.setString('discussListMain', jsonEncode(list));
    }
  }

  @override
  void initState() {
    getDiscussList();
    controller.toggle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> disList = Provider.of<DiscussData>(context)
        .discussList
        .where(
          (ele) =>
              ele['category'] == widget.category &&
              ele['chanelId'] == widget.channelId,
        )
        .toList();
    if (widget.conversationList.isNotEmpty) {
      for (var discuss in disList) {
        var conversationIdx = widget.conversationList
            .indexWhere((ele) => ele?.groupID == discuss["imGroupId"]);
        if (conversationIdx > -1 &&
            (widget.conversationList[conversationIdx]?.unreadCount ?? 0) > 0) {
          discuss['unread'] =
              widget.conversationList[conversationIdx]?.unreadCount;
        } else {
          discuss['unread'] = null;
        }
      }
    }

    return ExpandablePanel(
      controller: controller,
      theme: ExpandableThemeData(
        headerAlignment: ExpandablePanelHeaderAlignment.center,
        tapBodyToCollapse: true,
        iconPlacement: ExpandablePanelIconPlacement.left,
        iconColor: hexToColor("acacac"),
        iconPadding: const EdgeInsets.all(0),
        expandIcon: Icons.arrow_right_outlined,
        collapseIcon: Icons.arrow_drop_down_outlined,
        iconRotationAngle: 1.5,
      ),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Text(
          widget.category,
          style: TextStyle(
            color: hexToColor('333333'),
            fontSize: 13,
          ),
        ),
      ),
      collapsed: Container(),
      expanded: Container(
        padding: const EdgeInsets.only(left: 6, right: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var _ in disList)
              DiscussList(
                  Map<String, dynamic>.from(_), widget.conversationList),
          ],
        ),
      ),
    );
  }
}

class DiscussList extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<V2TimConversation?> conversationList;
  const DiscussList(this.data, this.conversationList, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscussListState();
}

class _DiscussListState extends State<DiscussList> {
  List topicList = List.from([]);
  getlist() async {
    String disscussImGroupId = widget.data['imGroupId'];
    Map<String, dynamic> res = await DisscussApi.getTopicList(
      disscussImGroupId: disscussImGroupId,
      type: 1,
    );
    int code = res['code'];
    Map<String, dynamic> data = res['data'];
    if (code == 0) {
      setState(() {
        topicList = data['rows'];
      });
    } else {
      // Utils.toast(imt_para("获取列表失败 {{message}}", "获取列表失败 ${message}")(message: message));
    }
  }

  @override
  void initState() {
    getlist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List unreadTopicList = List.from([]);
    if (widget.conversationList.isNotEmpty) {
      for (var topic in topicList) {
        var conversationIdx = widget.conversationList
            .indexWhere((ele) => ele?.groupID == topic["imGroupId"]);
        if (conversationIdx > -1 &&
            (widget.conversationList[conversationIdx]?.unreadCount ?? 0) > 0) {
          topic['unread'] =
              widget.conversationList[conversationIdx]!.unreadCount!;
          unreadTopicList.add(topic);
        }
      }
      if (unreadTopicList.isNotEmpty) {
        unreadTopicList[unreadTopicList.length - 1]['isFinished'] = true;
      }
    }
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DiscussListItem(widget.data),
          for (var _ in unreadTopicList)
            TopicListItem(Map<String, dynamic>.from(_)),
        ],
      ),
    );
  }
}

class DiscussListItem extends StatefulWidget {
  final Map<String, dynamic> data;
  const DiscussListItem(this.data, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscussListItemState();
}

class _DiscussListItemState extends State<DiscussListItem> {
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  bool isActive = false;

  Future<V2TimConversation> getConversion(String conversationID) async {
    final data = await sdkInstance.getConversationManager().getConversation(
          conversationID: conversationID,
        );
    return data.data!;
  }

  toDiscuss() async {
    String groupId = widget.data['imGroupId'];
    V2TimCallback res = await sdkInstance.joinGroup(
      groupID: groupId,
      message: imt("大家好"),
    );
    V2TimConversation conversation = await getConversion('group_$groupId');
    // 加群成功或者已经是群成员直接进入
    if (res.code == 0 || res.code == 10013) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(selectedConversation: conversation)),
      );
    } else {
    }
  }

  active() {
    setState(() {
      isActive = true;
    });
  }

  unActive() {
    setState(() {
      isActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toDiscuss,
      onTapDown: (detail) {
        active();
      },
      onPanEnd: (detail) {
        unActive();
      },
      onTapUp: (detail) {
        unActive();
      },
      onLongPressDown: (detail) {
        active();
      },
      onLongPressUp: unActive,
      onLongPressEnd: (detail) {
        unActive();
      },
      onLongPressCancel: unActive,
      onTapCancel: unActive,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          ),
          color: isActive ? hexToColor('ececec') : hexToColor('ffffff'),
        ),
        padding: const EdgeInsets.all(4),
        height: 36,
        child: Row(
          children: [
            const Image(
              width: 18,
              height: 18,
              image: AssetImage('assets/topic_icon.png'),
            ),
            Expanded(
              child: Text(
                widget.data['name'],
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(child: Container()),
            if ((widget.data['unread'] ?? 0) > 0)
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CommonColor.primaryColor,
                ),
                child: Text(
                    widget.data['unread'] > 99
                        ? '99+'
                        : widget.data['unread'].toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              )
          ],
        ),
      ),
    );
  }
}

class TopicListItem extends StatefulWidget {
  final Map<String, dynamic> data;
  const TopicListItem(this.data, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TopicListItemState();
}

class _TopicListItemState extends State<TopicListItem> {
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  bool isActive = false;

  Future<V2TimConversation> getConversion(String conversationID) async {
    final data = await sdkInstance.getConversationManager().getConversation(
          conversationID: conversationID,
        );
    return data.data!;
  }

  openTopic(context) async {
    String topicGroupId = widget.data['imGroupId'];
    V2TimCallback res = await sdkInstance.joinGroup(
      groupID: topicGroupId,
      message: imt("大家好"),
    );
    V2TimConversation conversation = await getConversion('group_$topicGroupId');
    // 加群成功或者已经是群成员直接进入
    if (res.code == 0 || res.code == 10013) {
      final loginUser = await sdkInstance.getLoginUser();
      String userId = loginUser.data!;
      await DisscussApi.joinTopic(
        userId: userId,
        imGroupId: topicGroupId,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(selectedConversation: conversation)),
      );
    } else {
    }
  }

  active() {
    setState(() {
      isActive = true;
    });
  }

  unActive() {
    setState(() {
      isActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openTopic(context);
      },
      onTapDown: (detail) {
        active();
      },
      onTapUp: (detail) {
        unActive();
      },
      onPanEnd: (detail) {
        unActive();
      },
      onLongPressDown: (detail) {
        active();
      },
      onLongPressUp: unActive,
      onLongPressEnd: (detail) {
        unActive();
      },
      onLongPressCancel: unActive,
      onTapCancel: unActive,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(6),
            ),
            color: isActive ? hexToColor('ececec') : hexToColor('ffffff'),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
          height: 36,
          child: Row(
            children: [
              widget.data['isFinished'] == true
                  ? const VerticalDivider(
                      width: 2,
                      thickness: 2,
                      indent: 0,
                      endIndent: 17,
                      color: Colors.black12)
                  : const VerticalDivider(
                      width: 2,
                      thickness: 2,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.black12),
              const SizedBox(
                width: 20,
                child: Divider(
                    thickness: 2,
                    indent: 0,
                    endIndent: 10,
                    color: Colors.black12),
              ),
              Expanded(
                child: Text(
                  widget.data['name'],
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              Expanded(child: Container()),
              if ((widget.data['unread'] ?? 0) > 0)
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CommonColor.primaryColor,
                  ),
                  child: Text(
                      widget.data['unread'] > 99
                          ? '99+'
                          : widget.data['unread'].toString(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                )
            ],
          )),
    );
  }
}
