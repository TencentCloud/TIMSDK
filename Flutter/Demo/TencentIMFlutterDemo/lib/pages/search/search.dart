import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friend.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class Search extends StatefulWidget {
  Search(this.type);
  final int type;
  @override
  State<StatefulWidget> createState() => SearchState();
}

class Input extends StatelessWidget {
  Input(this.type);
  final int type;
  final TextEditingController controller = new TextEditingController();
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
                addType: 1,
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
      V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
          .joinGroup(groupID: userID, message: "我要加群");
      if (res.code == 0) {
        Utils.toast('申请成功');
        getFriendList(context);
        Navigator.pop(context);
      } else {
        print(res.desc);
        Utils.toast(res.desc);
      }
    }
  }

  getFriendList(context) async {
    V2TimValueCallback<List<V2TimFriendInfo>> data = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendList();
    if (data.code == 0 && data.data!.length > 0) {
      Provider.of<FriendListModel>(context, listen: false)
          .setFriendList(data.data);
    } else {
      Provider.of<FriendListModel>(context, listen: false)
          .setFriendList(List.empty(growable: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 90,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: type == 1 ? '请输入用户userID' : '请输入群ID',
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            height: 60,
            child: ElevatedButton(
              child: Text('添加'),
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
  void initState() {
    this.type = widget.type;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: type == 1 ? Text('添加好友') : Text('添加群组'),
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
