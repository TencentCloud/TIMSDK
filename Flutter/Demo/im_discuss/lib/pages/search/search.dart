import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/provider/friend.dart';
import 'package:discuss/utils/toast.dart';

class Search extends StatefulWidget {
  const Search(this.type, {Key? key}) : super(key: key);
  final int type;
  @override
  State<StatefulWidget> createState() => SearchState();
}

class Input extends StatelessWidget {
  Input(this.type, {Key? key}) : super(key: key);
  final int type;
  final TextEditingController controller = TextEditingController();
  addFriend(context, userID) async {
    if (userID == null || userID == '') {
      Utils.toast(type == 1 ? "请输入正确的userID" : "请输入正确的群ID");
      return;
    }

    if (type == 1) {
      V2TimValueCallback<V2TimFriendOperationResult> data =
          await TencentImSDKPlugin.v2TIMManager
              .getFriendshipManager()
              .addFriend(
                userID: userID,
                addType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH,
              );
      if (data.code != 0) {
        Utils.toast('${data.code}-${data.desc}');
      } else {
        controller.clear();
        getFriendList(context);
        Navigator.pop(context);
      }
    }
    if (type == 2) {
      //加群
      V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.joinGroup(
        groupID: userID,
        message: "我要加群",
      );
      if (res.code == 0) {
        Utils.toast('申请成功');
        getFriendList(context);
        Navigator.pop(context);
      } else {
        Utils.log(res.desc);
        Utils.toast(res.desc);
      }
    }
    if (type == 3) {
      // 创建群组
      V2TimValueCallback res =
          await TencentImSDKPlugin.v2TIMManager.getGroupManager().createGroup(
                groupType: GroupType.Public,
                groupID: userID,
                groupName: userID,
              );
      if (res.code == 0) {
        Utils.toast('创建成功');
        getFriendList(context);
        Navigator.pop(context);
      } else {
        Utils.log(res.desc);
        Utils.toast(res.desc);
      }
    }
  }

  getFriendList(context) async {
    V2TimValueCallback<List<V2TimFriendInfo>> data = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendList();
    if (data.code == 0 && data.data!.isNotEmpty) {
      Provider.of<FriendListModel>(context, listen: false)
          .setFriendList(data.data);
    } else {
      Provider.of<FriendListModel>(context, listen: false)
          .setFriendList(List.empty(growable: true));
    }
  }

  String getLabelText(int type) {
    if (type == 1) {
      return "请输入用户userID";
    }
    if (type == 2) {
      return "请输入群ID";
    }
    return "请输入要创建的群名称";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 90,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: getLabelText(type),
              ),
              onSubmitted: (s) {
                addFriend(context, s.trim());
              },
            ),
          )
        ],
      ),
    );
  }
}

class AddBtn extends StatelessWidget {
  const AddBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 60,
            child: ElevatedButton(
              child: const Text('添加'),
              onPressed: () {},
            ),
          ),
        )
      ],
    );
  }
}

class SearchState extends State<Search> {
  int? type;
  @override
  void initState() {
    type = widget.type;
    super.initState();
  }

  Widget getTitle(int type) {
    if (type == 1) {
      return const Text(
        '添加好友',
        style: TextStyle(color: Colors.black),
      );
    }
    if (type == 2) {
      return const Text(
        '添加群组',
        style: TextStyle(color: Colors.black),
      );
    }
    return const Text(
      '创建群组',
      style: TextStyle(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: type == 1
            ? const Text(
                '添加好友',
                style: TextStyle(color: Colors.black),
              )
            : const Text(
                '添加群组',
                style: TextStyle(color: Colors.black),
              ),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Input(type!),
            Expanded(child: Container()),
            // AddBtn(),
          ],
        ),
      ),
    );
  }
}
