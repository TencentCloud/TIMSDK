import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/group_profile_life_cycle.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/group_profile_widget.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_profile_widget.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/search.dart';

class GroupProfilePage extends StatelessWidget {
  final String groupID;
  final sdkInstance = TIMUIKitCore.getSDKInstance();
  final coreInstance = TIMUIKitCore.getInstance();

  GroupProfilePage({Key? key, required this.groupID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
        appBar: AppBar(
            title: Text(
              imt("群聊"),
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            shadowColor: Colors.white,
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
        body: SafeArea(
          child: TIMUIKitGroupProfile(
            lifeCycle: GroupProfileLifeCycle(didLeaveGroup: () async {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePage(
                            pageIndex: 1,
                          )),
                  (route) => false);
            }),
            groupID: groupID,
            profileWidgetBuilder: GroupProfileWidgetBuilder(searchMessage: () {
              return TIMUIKitGroupProfileWidget.searchMessage(
                  (V2TimConversation? conversation) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Search(
                              onTapConversation:
                                  (V2TimConversation conversation,
                                      V2TimMessage? targetMsg) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Chat(
                                        selectedConversation: conversation,
                                        initFindingMsg: targetMsg,
                                      ),
                                    ));
                              },
                              conversation: conversation,
                            )));
              });
            }),
          ),
        ));
  }
}
