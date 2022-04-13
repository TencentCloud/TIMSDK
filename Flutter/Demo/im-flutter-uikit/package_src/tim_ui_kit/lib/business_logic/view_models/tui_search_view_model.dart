import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_result_item.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import '../../tim_ui_kit.dart';

enum KeywordListMatchType {
  V2TIM_KEYWORD_LIST_MATCH_TYPE_OR,
  V2TIM_KEYWORD_LIST_MATCH_TYPE_AND
}

class TUISearchViewModel extends ChangeNotifier {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final MessageService _messageService =
  serviceLocator<MessageService>();
  final ConversationService _conversationService =
  serviceLocator<ConversationService>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();

  List<V2TimFriendInfoResult>? friendList = [];

  List<V2TimMessageSearchResultItem>? msgList = [];
  int msgPage = 0;
  int totalMsgCount = 0;

  int totalMsgInConversationCount = 0;
  List<V2TimMessage> currentMsgListForConversation = [];

  List<V2TimGroupInfo>? groupList = [];

  List<V2TimConversation?> conversationList = [];

  Future<List<V2TimConversation?>?> initConversationMsg() async {
    final conversationResult = await _conversationService.getConversationList(
        nextSeq: "0", count: 500);
    final conversationListData = conversationResult?.conversationList;
    conversationList = conversationListData ?? [];
    notifyListeners();
    return conversationListData;
  }

  void initSearch() {
    friendList = [];
    msgList = [];
    totalMsgCount = 0;
    notifyListeners();
  }

  void searchFriendByKey(String searchKey) async {
    final searchResult = await _friendshipServices.searchFriends(
        searchParam: V2TimFriendSearchParam(keywordList: [searchKey]));
    friendList = searchResult;
    notifyListeners();
  }

  void searchGroupByKey(String searchKey) async {
    final searchResult = await _groupServices.searchGroups(
        searchParam: V2TimGroupSearchParam(keywordList: [searchKey]));
    groupList = searchResult.data ?? [];
    notifyListeners();
  }

  void getMsgForConversation(String keyword, String conversationId, int page) async {
    void clearData() {
      currentMsgListForConversation = [];
      totalMsgInConversationCount = 0;
    }
    if(page == 0){
      clearData();
    }
    if(keyword.isEmpty){
      clearData();
      return;
    }
    final searchResult = await _messageService.searchLocalMessages(
        searchParam: V2TimMessageSearchParam(
          keywordList: [keyword],
          pageIndex: page,
          pageSize: 30,
          searchTimePeriod: 0,
          searchTimePosition: 0,
          conversationID: conversationId,
          type: KeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR.index,
        ));
    if (searchResult.code == 0 && searchResult.data != null) {
      totalMsgInConversationCount = searchResult.data!.totalCount!;
      currentMsgListForConversation = [...currentMsgListForConversation, ...(searchResult.data!.messageSearchResultItems?[0].messageList ?? [])];
    }
    if(searchResult.code != 0){
      Fluttertoast.showToast(
        msg: searchResult.desc,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
    }
    notifyListeners();
  }

  void searchMsgByKey(String searchKey, bool isFirst) async {
    if(isFirst == true){
      msgPage = 0;
      msgList = [];
      totalMsgCount = 0;
    }
    final searchResult = await _messageService.searchLocalMessages(
        searchParam: V2TimMessageSearchParam(
      keywordList: [searchKey],
      pageIndex: msgPage,
      pageSize: 5,
      searchTimePeriod: 0,
      searchTimePosition: 0,
      type: KeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR.index,
    ));
    if (searchResult.code == 0 && searchResult.data != null) {
      msgPage++;
      msgList = [...?msgList, ...?searchResult.data!.messageSearchResultItems];
      totalMsgCount = searchResult.data!.totalCount ?? 0;
    }
    if(searchResult.code != 0){
      Fluttertoast.showToast(
        msg: searchResult.desc,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
    }
    notifyListeners();
  }

  void searchByKey(String? searchKey) async {
    if (searchKey == null || searchKey.isEmpty) {
      friendList = [];
      groupList = [];
      msgList = [];
      totalMsgCount = 0;
      notifyListeners();
    } else {
      searchFriendByKey(searchKey);
      searchMsgByKey(searchKey, true);
      searchGroupByKey(searchKey);
    }
  }
}
