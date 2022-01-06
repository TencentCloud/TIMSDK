class GetConversationListByIds {
  static formateParams(Map<String, dynamic> param) {
    List<String> list = [];
    param["conversationIDList"].forEach((element) {
      list.add(element);
    });

    return list;
  }
}
