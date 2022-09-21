import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/contact_list.dart';

class AddGroupMemberPage extends StatefulWidget {
  final TUIGroupProfileModel model;

  const AddGroupMemberPage({Key? key, required this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddGroupMemberPageState();
}

class _AddGroupMemberPageState extends TIMUIKitState<AddGroupMemberPage> {
  List<V2TimFriendInfo> selectedContacter = [];

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Scaffold(
        appBar: AppBar(
            title: Text(
              TIM_t("添加群成员"),
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedContacter.isNotEmpty) {
                    final userIDs =
                        selectedContacter.map((e) => e.userID).toList();
                    await widget.model.inviteUserToGroup(userIDs);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  TIM_t("确定"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
            ],
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
            )),
        body: ContactList(
          groupMemberList: widget.model.groupMemberList,
          contactList: widget.model.contactList,
          isCanSelectMemberItem: true,
          onSelectedMemberItemChange: (selectedMember) {
            selectedContacter = selectedMember;
          },
        ));
  }
}
