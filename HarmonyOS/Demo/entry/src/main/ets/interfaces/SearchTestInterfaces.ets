import { Error } from "./BaseTestInterfaces";
import { writeResult } from "../pages/SearchTestPage";
import {
  V2TIMFriendSearchParam,
  V2TIMManager,
  V2TIMUserSearchParam,
  V2TIMUserSearchResult,
  V2TIMFriendInfoResult,
  V2TIMGroupInfo,
  V2TIMGroupSearchParam,
  V2TIMGroupSearchResult,
  V2TIMGroupMemberFullInfo,
  V2TIMGroupMemberSearchParam,
  V2TIMGroupMemberSearchResult,
  V2TIMMessageSearchResult,
  V2TIMMessageSearchParam,
  V2TIMKeywordListMatchType,
  V2TIMMessageSearchResultItem,
  V2TIMGender,
} from "@tencentcloud/imsdk";

@Observed
export class SearchInfo {
  // search friend
  keyword1 = "";
  keyword2 = "";
  isSearchID = false;
  isSearchNickName = false;
  isSearchRemark = false;
  // search groups
  keyword3 = "";
  keyword4 = "";
  isSearchGroupID = false;
  isSearchGroupName = false;
  // search group members
  groupID1 = "";
  groupID2 = "";
  keyword5 = "";
  keyword6 = "";
  isSearchMemberUserID = false;
  isSearchMemberNickName = false;
  isSearchMemberRemark = false;
  isSearchMemberNameCard = false;
  // search local message
  keyword7 = "";
  keyword8 = "";
  keywordsMatchType = V2TIMKeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR;
  senderID1 = "";
  senderID2 = "";
  conversationID = "";
  searchTimeStart = 0;
  searchTimePeriod = 0;
  pageIndex = 0;
  pageSize = 10;
}

export let searchInfo = new SearchInfo();

export class SearchTestInterfaces {
  static searchUsers() {
    const searchParam: V2TIMUserSearchParam = {
      gender: V2TIMGender.V2TIM_GENDER_UNKNOWN,
      // minBirthday: 0,
      // maxBirthday:1730774350,
      keywordList: ["abc"],
      keywordListMatchType: V2TIMKeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR,
      searchCount: 20,
      searchCursor: "",
    };
    V2TIMManager.getInstance()
      .searchUsers(searchParam)
      .then((result: V2TIMUserSearchResult) => {
        writeResult("searchUsers succeeded", result);
      })
      .catch((error: Error) => {
        writeResult("searchUsers failed", error.code, error.message);
      });
  }

  static searchFriends() {
    const searchParam: V2TIMFriendSearchParam = {
      keywordList: [searchInfo.keyword1, searchInfo.keyword2],
      isSearchUserID: searchInfo.isSearchID,
      isSearchNickName: searchInfo.isSearchNickName,
      isSearchRemark: searchInfo.isSearchRemark,
    };
    V2TIMManager.getFriendshipManager()
      .searchFriends(searchParam)
      .then((result: V2TIMFriendInfoResult[]) => {
        writeResult("searchFriends succeeded", result);
      })
      .catch((error: Error) => {
        writeResult("searchFriends failed", error.code, error.message);
      });
  }

  static searchGroups() {
    const searchParam: V2TIMGroupSearchParam = {
      keywordList: [searchInfo.keyword3, searchInfo.keyword4],
      isSearchGroupID: searchInfo.isSearchGroupID,
      isSearchGroupName: searchInfo.isSearchGroupName,
    };
    V2TIMManager.getGroupManager()
      .searchGroups(searchParam)
      .then((resultList: V2TIMGroupInfo[]) => {
        writeResult("searchGroups succeeded", resultList);
      })
      .catch((error: Error) => {
        writeResult("searchGroups failed", error.code, error.message);
      });
  }

  static searchCloudGroups() {
    const searchParam: V2TIMGroupSearchParam = {
      keywordList: ["啊"],
      keywordListMatchType: V2TIMKeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR,
      searchCount: 20,
      searchCursor: "",
    };
    V2TIMManager.getGroupManager()
      .searchCloudGroups(searchParam)
      .then((result: V2TIMGroupSearchResult) => {
        writeResult("searchCloudGroups succeeded", result);
      })
      .catch((error: Error) => {
        writeResult("searchCloudGroups failed", error.code, error.message);
      });
  }

  static searchGroupMembers() {
    const searchParam: V2TIMGroupMemberSearchParam = {
      groupIDList: [searchInfo.groupID1, searchInfo.groupID2],
      keywordList: [searchInfo.keyword5, searchInfo.keyword6],
      isSearchMemberUserID: searchInfo.isSearchMemberUserID,
      isSearchMemberNickName: searchInfo.isSearchMemberNickName,
      isSearchMemberRemark: searchInfo.isSearchMemberRemark,
      isSearchMemberNameCard: searchInfo.isSearchMemberNameCard,
    };
    V2TIMManager.getGroupManager()
      .searchGroupMembers(searchParam)
      .then((resultMap: Map<string, V2TIMGroupMemberFullInfo[]>) => {
        writeResult("searchGroupMembers succeeded", resultMap);
      })
      .catch((error: Error) => {
        writeResult("searchGroupMembers failed", error.code, error.message);
      });
  }

  static searchCloudGroupMembers() {
    const searchParam: V2TIMGroupMemberSearchParam = {
      keywordList: ["a"],
      keywordListMatchType: V2TIMKeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR,
      searchCount: 20,
      searchCursor: "",
    };
    V2TIMManager.getGroupManager()
      .searchCloudGroupMembers(searchParam)
      .then((result: V2TIMGroupMemberSearchResult) => {
        writeResult("searchCloudGroupMembers succeeded", result);
      })
      .catch((error: Error) => {
        writeResult("searchCloudGroupMembers failed", error.code, error.message);
      });
  }

  static searchLocalMessages() {
    let searchParam: V2TIMMessageSearchParam = {
      keywordList: [searchInfo.keyword7, searchInfo.keyword8],
      keywordListMatchType: searchInfo.keywordsMatchType,
      senderUserIDList: [],
      messageTypeList: [],
      conversationID: searchInfo.conversationID,
      searchTimePosition: searchInfo.searchTimeStart,
      searchTimePeriod: searchInfo.searchTimePeriod,
      pageIndex: searchInfo.pageIndex,
      pageSize: searchInfo.pageSize,
      searchCount: 20,
      searchCursor: "",
    };

    if (searchInfo.senderID1.length > 0) {
      searchParam.senderUserIDList.push(searchInfo.senderID1);
    }

    if (searchInfo.senderID2.length > 0) {
      searchParam.senderUserIDList.push(searchInfo.senderID2);
    }

    V2TIMManager.getMessageManager()
      .searchLocalMessages(searchParam)
      .then((result: V2TIMMessageSearchResult) => {
        let resultDescription = "";
        resultDescription += "searchLocalMessages succeeded, total count:" + result.totalCount;
        resultDescription += ", search cursor:" + result.searchCursor;
        result.messageSearchResultItems.forEach((value: V2TIMMessageSearchResultItem) => {
          resultDescription += ",   ResultItem, convID:" + value.conversationID;
          resultDescription += ", messageCount:" + value.messageCount;
          if (value.messageList.length > 0) {
            let message = value.messageList[0];
            resultDescription += ", messageID:" + message.msgID;
          }
        });

        writeResult("searchLocalMessages succeeded, ", resultDescription);
      })
      .catch((error: Error) => {
        writeResult("searchLocalMessages failed", error.code, error.message);
      });
  }
}
