import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/group_profile_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/group_profile_widget.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_profile_widget.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/search.dart';
import 'package:timuikit/src/user_profile.dart';

class GroupProfilePage extends StatelessWidget {
  final String groupID;
  final sdkInstance = TIMUIKitCore.getSDKInstance();
  final coreInstance = TIMUIKitCore.getInstance();

  GroupProfilePage({Key? key, required this.groupID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    final TUISelfInfoViewModel _selfInfoViewModel =
    serviceLocator<TUISelfInfoViewModel>();
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
              // Shows navigating back to the home page.
              // You can customize the reaction here.
              if(PlatformUtils().isWeb){
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }else{
                Navigator.of(context).popUntil(ModalRoute.withName("/homePage"));
              }
            }),
            groupID: groupID,
            onClickUser: (String userID) {
              if (userID != _selfInfoViewModel.loginInfo?.userID) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(userID: userID),
                    ));
              }
            },
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
