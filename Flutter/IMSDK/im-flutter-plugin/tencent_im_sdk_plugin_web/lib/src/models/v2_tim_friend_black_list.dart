class FriendBlackList {
  static formateBlackListItem(userID) {
    return {
      "userID": userID,
      "friendRemark": null,
      "friendGroups": [],
      "friendCustomInfo": {},
      "userProfile": {
        "userID": userID,
      },
    };
  }

  static List<dynamic> formateBlackList(list) {
    final resultArr = [];
    list.forEach((item) => resultArr.add(formateBlackListItem(item)));
    return resultArr;
  }

  static List<dynamic> formateDeleteBlackListRes(list) {
    final resultArr = [];
    list.forEach(
        (userID) => resultArr.add({"userID": userID, "resultCode": 0}));
    return resultArr;
  }
}
