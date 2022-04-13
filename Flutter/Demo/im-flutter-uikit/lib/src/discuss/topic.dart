import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:convert';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/utils/discuss.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

import '../chat.dart';
import 'create_topic.dart';

class Topic extends StatefulWidget {
  const Topic(this.imGroupId, {Key? key}) : super(key: key);
  final String imGroupId;
  @override
  State<StatefulWidget> createState() => TopicState();
}

class TopicState extends State<Topic> {
  Map<String, dynamic>? disscussInfo;
  V2TimGroupInfo? groupInfo;
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  final Connectivity _connectivity = Connectivity();
  var subscription;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    init();
    subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          hasInternet = false;
        });
      } else {
        setState(() {
          hasInternet = true;
        });
      }
    });
  }

  init() {
    getDissInfo();
    getGroupInfo();
  }

  getDissInfo() async {
    Map<String, dynamic> data =
        await DisscussApi.getDisscussInfo(imGroupId: widget.imGroupId);
    if (data['data'] != null && data['data']['uuid'] != null) {
      setState(() {
        disscussInfo = data['data'];
      });
    }
  }

  getGroupInfo() async {
    V2TimValueCallback<List<V2TimGroupInfoResult>> res = await sdkInstance
        .getGroupManager()
        .getGroupsInfo(groupIDList: List.from([widget.imGroupId]));
    if (res.code == 0 && res.data![0].resultCode == 0) {
      setState(() {
        groupInfo = res.data![0].groupInfo;
      });
    } else {
      // Utils.toast("${res.desc} ${res.data![0].resultMessage}");
    }
  }

  List<Widget>? getAction(BuildContext context) {
    if (groupInfo != null) {
      return [
        groupInfo!.role == 300 || groupInfo!.role == 400
            ? IconButton(onPressed: openCreate, icon: const Icon(Icons.add))
            : Container(),
      ];
    }
    return [];
  }

  openCreate() {
    String? disscussId = disscussInfo!['imGroupId'];
    if (disscussId == null) {
      Utils.toast(imt("讨论区参数异常"));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTopic(
          disscussId: disscussId,
          message: "",
          messageIdList: const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          shadowColor: theme.weakBackgroundColor,
          elevation: 1,
          actions: getAction(context),
          bottom: TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(
                text: imt("全部"),
              ),
              Tab(
                text: imt("已加入"),
              ),
            ],
          ),
          title: Column(
            children: [
              Text(
                hasInternet ? imt("话题") : imt("话题（未连接）"),
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
              Text(
                "# ${disscussInfo == null ? '' : disscussInfo!['name']}",
                style: const TextStyle(fontSize: 10, color: Colors.white),
              )
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
        ),
        body: disscussInfo != null && groupInfo != null
            ? TabBarView(
                children: [
                  TopicList(1, disscussInfo!, groupInfo),
                  TopicList(0, disscussInfo!, groupInfo),
                ],
              )
            : Container(),
      ),
    );
  }
}

class TopicList extends StatefulWidget {
  final int type;
  final Map<String, dynamic> disscussInfo;
  final V2TimGroupInfo? groupInfo;
  const TopicList(this.type, this.disscussInfo, this.groupInfo, {Key? key})
      : super(key: key);
  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => TopicListState(type);
}

class TopicListState extends State<TopicList> {
  final int type;
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  TopicListState(this.type);
  bool loading = false;
  List list = List.from([]);
  var subscription;
  final Connectivity _connectivity = Connectivity();

  getlist() async {
    setState(() {
      loading = true;
    });
    String disscussImGroupId = widget.disscussInfo['imGroupId'];
    String userId = '';
    if (type == 0) {
      V2TimValueCallback<String> logindata = await sdkInstance.getLoginUser();
      userId = logindata.data!;
    }
    Map<String, dynamic> res = await DisscussApi.getTopicList(
      disscussImGroupId: disscussImGroupId,
      type: type,
      userId: userId,
    );
    int code = res['code'];
    // String message = res['message'];
    Map<String, dynamic> data = res['data'];
    if (code == 0) {
      setState(() {
        list = data['rows'];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
    // Utils.log(res);
  }

  openCreate() {
    String? disscussId = widget.disscussInfo['imGroupId'];
    if (disscussId == null) {
      Utils.toast(imt("讨论区参数异常"));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTopic(
          disscussId: disscussId,
          message: "",
          messageIdList: const [],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getlist();
    subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        getlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int role = widget.groupInfo!.role!;
    return Container(
      child: list.isNotEmpty
          ? ListView(
              children: list.map((e) => TopicItem(e, sdkInstance)).toList(),
            )
          : loading
              ? Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineSpinFadeLoader,
                      color: Colors.black26,
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type == 1 ? imt("该讨论区下暂无话题") : imt("暂未加入任何话题"),
                        style: const TextStyle(color: Colors.black26),
                      ),
                      type == 1 && (role == 300 || role == 400)
                          ? Container(
                              padding: const EdgeInsets.all(40),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: openCreate,
                                      child: Text(imt("创建话题")),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
    );
  }
}

class TopicItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final V2TIMManager sdkInstance;
  const TopicItem(this.item, this.sdkInstance, {Key? key}) : super(key: key);
  Future<V2TimConversation> getConversion(String conversationID) async {
    final data = await sdkInstance.getConversationManager().getConversation(
          conversationID: conversationID,
        );
    return data.data!;
  }

  openTopic(context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      String topicGroupId = item["imGroupId"];
      V2TimCallback res = await sdkInstance.joinGroup(
        groupID: topicGroupId,
        message: imt("大家好"),
      );
      V2TimConversation conversation =
          await getConversion('group_$topicGroupId');
      if (res.code == 0 || res.code == 10013) {
        V2TimValueCallback<String> loginUser = await sdkInstance.getLoginUser();
        String userId = loginUser.data!;
        await DisscussApi.joinTopic(
          userId: userId,
          imGroupId: topicGroupId,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(selectedConversation: conversation),
          ),
        );
      }
    } else {
      Utils.toast("无网络连接，进入话题失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        openTopic(context);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
        child: Column(
          children: [
            TopicItemTitle(item),
            TopicItemTag(item),
            TopicItemTime(item),
          ],
        ),
      ),
    );
  }
}

class TopicItemTitle extends StatelessWidget {
  final Map<String, dynamic> item;
  const TopicItemTitle(this.item, {Key? key}) : super(key: key);
  getStatus() {
    Color c = Colors.grey;
    switch (item['status']) {
      case 0:
        c = Colors.green;
        break;
      case 1:
        c = Colors.red;
        break;
      case 1000:
        c = Colors.orange;
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.fromLTRB(12, 0, 8, 0),
            decoration: BoxDecoration(
              color: getStatus(),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(width: 0, style: BorderStyle.none),
            ),
          ), //状态
          Expanded(
            child: Text(
              item['name'],
              style: const TextStyle(
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class TopicItemTag extends StatelessWidget {
  final Map<String, String> tagColors = {
    "bug": "b61903",
    imt("性能"): "229800",
    "flutter": "5fe5f4",
    "trtc": "0279a4",
    "pc": "fbca05",
    "default": "006fff",
    "Electron": "d4c5fa",
    "iOS": "2b2b2b",
    "Android": "e4f0fe"
  };
  final Map<String, dynamic> item;
  TopicItemTag(this.item, {Key? key}) : super(key: key);
  List<Widget> getTags() {
    List<String> tags = List.from(jsonDecode(item['tags']));
    if (tags.isEmpty) {
      return [];
    }
    return tags.map(
      (e) {
        late String color;
        if (tagColors[e.toLowerCase()] == null) {
          color = tagColors['default']!;
        } else {
          color = tagColors[e.toLowerCase()]!;
        }
        return Container(
          alignment: Alignment.center,
          height: 20,
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
          decoration: BoxDecoration(
            color: Color(int.parse(color, radix: 16)).withAlpha(255),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(width: 0, style: BorderStyle.none),
          ),
          child: Text(
            e,
            style: const TextStyle(
              fontSize: 10,
              textBaseline: TextBaseline.alphabetic,
              color: Colors.white,
              backgroundColor: Colors.transparent,
              height: 1,
            ),
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        children: getTags(),
      ),
    );
  }
}

class TopicItemTime extends StatelessWidget {
  final Map<String, dynamic> item;
  String getFormatTime() {
    String time = item['created_at'];
    var ftime = DateTime.parse(time);
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    return formatter.format(ftime);
  }

  const TopicItemTime(this.item, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.only(left: 24),
      alignment: Alignment.centerLeft,
      child: Text(
        getFormatTime(),
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Color(int.parse("808080", radix: 16)).withAlpha(255),
          fontSize: 10,
        ),
      ),
    );
  }
}
