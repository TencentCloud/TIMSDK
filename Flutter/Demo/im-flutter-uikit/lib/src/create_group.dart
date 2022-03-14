import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateGroup();
}

class _CreateGroup extends State<CreateGroup> {
  final V2TIMManager _sdkInstance = TIMUIKitCore.getSDKInstance();
  List<V2TimFriendInfo> friendList = [];
  List<V2TimFriendInfo> selectedFriendList = [];

  _getConversationList() async {
    final res = await _sdkInstance.getFriendshipManager().getFriendList();
    if (res.code == 0) {
      friendList = res.data!;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _getConversationList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            imt("选择联系人"),
            style: const TextStyle(color: Colors.white),
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
          actions: [
            TextButton(
              onPressed: () async {
                // if (selectedFriendList.isNotEmpty) {

                // }
                // if (selectedContacter.isNotEmpty) {
                //   final userIDs =
                //       selectedContacter.map((e) => e.userID).toList();
                //   final res = await widget.model.inviteUserToGroup(userIDs);
                //   if (res.code != 0) {
                //     Fluttertoast.showToast(
                //       msg: res.desc,
                //       gravity: ToastGravity.BOTTOM,
                //       timeInSecForIosWeb: 1,
                //       textColor: Colors.white,
                //       backgroundColor: Colors.black,
                //     );
                //   }
                //   Navigator.pop(context);
                // }
              },
              child: Text(
                imt("确定"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
          iconTheme: const IconThemeData(
            color: Colors.white,
          )),
      body: ContactList(
        contactList: friendList,
        isCanSelectMemberItem: true,
        maxSelectNum: 1,
        onSelectedMemberItemChange: (selectedMember) {
          selectedFriendList = selectedMember;
          setState(() {});
        },
      ),
    );
  }
}
