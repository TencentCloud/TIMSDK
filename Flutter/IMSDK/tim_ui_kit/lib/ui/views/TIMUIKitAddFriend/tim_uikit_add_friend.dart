import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/add_friend_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitAddFriend/tim_uikit_send_application.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class TIMUIKitAddFriend extends StatefulWidget {
  final bool? isShowDefaultGroup;

  /// You may navigate to user profile page, if friendship relationship exists.
  final Function(String userID) onTapAlreadyFriendsItem;

  /// The life cycle hooks for adding friends and contact business logic
  final AddFriendLifeCycle? lifeCycle;
  const TIMUIKitAddFriend(
      {Key? key, this.isShowDefaultGroup = false, this.lifeCycle, required this.onTapAlreadyFriendsItem})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitAddFriendState();
}

class _TIMUIKitAddFriendState extends TIMUIKitState<TIMUIKitAddFriend> {
  final TextEditingController _controller = TextEditingController();
  final CoreServicesImpl _coreServicesImpl = serviceLocator<CoreServicesImpl>();
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final TUISelfInfoViewModel _selfInfoViewModel = serviceLocator<TUISelfInfoViewModel>();
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;
  bool showResult = false;
  List<V2TimUserFullInfo>? searchResult;

  Widget _searchResultItemBuilder(
      V2TimUserFullInfo friendInfo, TUITheme theme) {
    final faceUrl = friendInfo.faceUrl ?? "";
    final userID = friendInfo.userID ?? "";
    final showName = friendInfo.nickName ?? userID;
    return InkWell(
      onTap: () async {
        final checkFriend = await _friendshipServices.checkFriend(
            userIDList: [userID],
            checkType: FriendTypeEnum.V2TIM_FRIEND_TYPE_SINGLE);
        if (checkFriend != null) {
          final res = checkFriend.first;
          if (res.resultCode == 0 && res.resultType != 0) {
            onTIMCallback(TIMCallback(
                type: TIMCallbackType.INFO,
                infoRecommendText: TIM_t("该用户已是好友"),
                infoCode: 6660102));
            widget.onTapAlreadyFriendsItem(userID);
            return;
          }
        }

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SendApplication(
                    lifeCycle: widget.lifeCycle,
                    isShowDefaultGroup: widget.isShowDefaultGroup ?? false,
                    friendInfo: friendInfo,
                    model: _selfInfoViewModel)));
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(right: 12),
              child: Avatar(faceUrl: faceUrl, showName: showName),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showName,
                  style: TextStyle(color: theme.darkTextColor, fontSize: 18),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "ID: $userID",
                  style: TextStyle(fontSize: 12, color: theme.weakTextColor),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _searchResultBuilder(
      List<V2TimUserFullInfo>? searchResult, TUITheme theme) {
    final noResult = searchResult == null || searchResult.isEmpty;
    if (noResult) {
      return [
        Center(
          child: Text(TIM_t("用户不存在")),
        )
      ];
    }
    return searchResult.map((e) => _searchResultItemBuilder(e, theme)).toList();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final _isFocused = _focusNode.hasFocus;
      isFocused = _isFocused;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  searchFriend(String params) async {
    final response = await _coreServicesImpl.getUsersInfo(userIDList: [params]);
    if (response.code == 0) {
      setState((){
        searchResult = response.data;
      });
    } else {
      setState((){
        searchResult = null;
      });
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _selfInfoViewModel),
      ],
      builder: (BuildContext context, Widget? w) {
        final selfInfoModel = Provider.of<TUISelfInfoViewModel>(context);
        final userID = selfInfoModel.loginInfo?.userID ?? "";
        String option2 = userID;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        setState(() {
                          showResult = false;
                        });
                      }
                    },
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      final searchParams = _controller.text;
                      if (searchParams.trim().isNotEmpty) {
                        searchFriend(searchParams);
                        showResult = true;
                        _focusNode.requestFocus();
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_outlined,
                          color: theme.weakTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        hintStyle: const TextStyle(
                          color: Color(0xffAEA4A3),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: TIM_t("搜索用户 ID")),
                  )),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isFocused ? 50 : 0,
                    child: TextButton(
                        onPressed: () {
                          final searchParams = _controller.text;
                          if (searchParams.trim().isNotEmpty) {
                            searchFriend(searchParams);
                            showResult = true;
                            setState(() {});
                          }
                        },
                        child: Text(
                          TIM_t("搜索"),
                          softWrap: false,
                          style: const TextStyle(color: Colors.black),
                        )),
                  )
                ],
              ),
            ),
            if (!isFocused)
              Center(
                child: Text(
                    TIM_t_para("我的用户ID: {{option2}}", "我的用户ID: $option2")(
                        option2: option2)),
              ),
            if (showResult)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _searchResultBuilder(searchResult, theme),
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
