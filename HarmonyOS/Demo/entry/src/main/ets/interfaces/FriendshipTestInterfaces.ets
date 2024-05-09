import {
  V2TIMFriendshipListener,
  V2TIMFriendApplication,
  V2TIMFriendInfo,
  V2TIMManager,
  V2TIMFriendInfoResult,
  V2TIMSetFriendInfoParam,
  V2TIMFriendType,
  V2TIMFriendOperationResult,
  V2TIMFriendAddApplication,
  V2TIMFriendApplicationResult,
  V2TIMFriendAcceptType,
  V2TIMFriendGroup,
  V2TIMUserFullInfo,
  V2TIMOfficialAccountInfo,
  V2TIMFollowTypeCheckResult,
  V2TIMFollowOperationResult,
  V2TIMUserInfoResult,
  V2TIMFollowInfo,
} from '@tencentcloud/imsdk';
import Prompt from '@system.prompt';
import TestResult, { info } from "../pages/FriendshipManagerTestPage"

import { onCallback, writeResult } from "../pages/FriendshipManagerTestPage"

export class FriendshipTestInterfaces {
  static friendApplicationList: V2TIMFriendApplication[] = [];

  static addFriendListener() {
    V2TIMManager.getFriendshipManager().addFriendListener(friendshipListener);
    Prompt.showToast({ message: "addFriendListener" });
  }

  static removeFriendListener() {
    V2TIMManager.getFriendshipManager().removeFriendListener(friendshipListener);
    Prompt.showToast({ message: "removeFriendListener" });

  }

  static getFriendList() {
    V2TIMManager.getFriendshipManager().getFriendList()
      .then((info: V2TIMFriendInfo[]) => {
        writeResult('getFriendList succeeded', info);
      })
      .catch((error: Error) => {
        writeResult('getFriendList failed', error);
      });

  }

  static getFriendsInfo() {
    V2TIMManager.getFriendshipManager().getFriendsInfo([info.userID1, info.userID2])
      .then((info: V2TIMFriendInfoResult[]) => {
        writeResult('getFriendsInfo succeeded', info);
      })
      .catch((error: Error) => {
        writeResult('getFriendsInfo failed', error);
      });

  }

  static setFriendInfo() {
    let param: V2TIMSetFriendInfoParam = {
      userID: info.userID3,
      friendRemark: info.friendRemark,
    }
    V2TIMManager.getFriendshipManager().setFriendInfo(param)
      .then(() => {
        writeResult('setFriendInfo succeeded');
      })
      .catch((error: Error) => {
        writeResult('setFriendInfo failed', error);
      });

  }

  static addFriend() {
    const application: V2TIMFriendAddApplication = {
      userID: info.userID4,
      friendRemark: info.friendRemark2,
      addWording: info.addWording,
      addType: V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH,
    };
    V2TIMManager.getFriendshipManager().addFriend(application)
      .then((result: V2TIMFriendOperationResult) => {
        writeResult('addFriend succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('addFriend failed', error);
      });

  }

  static deleteFromFriendList() {
    const deleteType = V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH;
    V2TIMManager.getFriendshipManager().deleteFromFriendList([info.userID4], deleteType)
      .then((result: V2TIMFriendOperationResult[]) => {
        writeResult('deleteFromFriendList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('deleteFromFriendList failed', error);
      });

  }

  static checkFriend() {
    const checkType = V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH;
    V2TIMManager.getFriendshipManager().checkFriend([info.userID4], checkType)
      .then((result: V2TIMFriendOperationResult[]) => {
        writeResult('checkFriend succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('checkFriend failed', error);
      });
  }

  static getFriendApplicationList() {
    V2TIMManager.getFriendshipManager().getFriendApplicationList()
      .then((result: V2TIMFriendApplicationResult) => {
        FriendshipTestInterfaces.friendApplicationList = result.applicationList;
        writeResult('getFriendApplicationList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getFriendApplicationList failed', error);
      });
  }

  static acceptFriendApplication() {
    if (FriendshipTestInterfaces.friendApplicationList.length <= 0) {
      Prompt.showToast({ message: "请先获取好友申请" });
      return;
    }

    let friendApplication = FriendshipTestInterfaces.friendApplicationList[0];
    let acceptType = V2TIMFriendAcceptType.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD;
    let remark = friendApplication.userID + "-ohos-remark";
    V2TIMManager.getFriendshipManager()
      .acceptFriendApplication(FriendshipTestInterfaces.friendApplicationList[0], acceptType, remark)
      .then((result: V2TIMFriendOperationResult) => {
        writeResult('acceptFriendApplication succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('acceptFriendApplication failed', error);
      });
  }

  static refuseFriendApplication() {
    if (FriendshipTestInterfaces.friendApplicationList.length <= 0) {
      Prompt.showToast({ message: "请先获取好友申请" });
      return;
    }
    V2TIMManager.getFriendshipManager()
      .refuseFriendApplication(FriendshipTestInterfaces.friendApplicationList[0])
      .then((result: V2TIMFriendOperationResult) => {
        writeResult('refuseFriendApplication succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('refuseFriendApplication failed', error);
      });
  }

  static deleteFriendApplication() {
    if (FriendshipTestInterfaces.friendApplicationList.length <= 0) {
      Prompt.showToast({ message: "请先获取好友申请" });
      return;
    }
    V2TIMManager.getFriendshipManager()
      .deleteFriendApplication(FriendshipTestInterfaces.friendApplicationList[0])
      .then(() => {
        writeResult('deleteFriendApplication succeeded');
      })
      .catch((error: Error) => {
        writeResult('deleteFriendApplication failed', error);
      });
  }

  static setFriendApplicationRead() {
    V2TIMManager.getFriendshipManager()
      .setFriendApplicationRead()
      .then(() => {
        writeResult('setFriendApplicationRead succeeded');
      })
      .catch((error: Error) => {
        writeResult('setFriendApplicationRead failed', error);
      });
  }

  static getBlackList() {
    V2TIMManager.getFriendshipManager().getBlackList()
      .then((result: V2TIMFriendInfo[]) => {
        writeResult('getBlackList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getBlackList failed', error);
      });
  }

  static addToBlackList() {
    V2TIMManager.getFriendshipManager().addToBlackList([info.userID5, info.userID6])
      .then((result: V2TIMFriendOperationResult[]) => {
        writeResult('addToBlackList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('addToBlackList failed', error);
      });
  }

  static deleteFromBlackList() {
    V2TIMManager.getFriendshipManager().deleteFromBlackList([info.userID5, info.userID6])
      .then((result: V2TIMFriendOperationResult[]) => {
        writeResult('deleteFromBlackList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('deleteFromBlackList failed', error);
      });
  }

  static createFriendGroup() {
    V2TIMManager.getFriendshipManager().createFriendGroup(info.friendGroup, [info.userID7, info.userID8])
      .then((result: V2TIMFriendOperationResult[]) => {
        writeResult('createFriendGroup succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('createFriendGroup failed', error);
      });
  }

  static addFriendsToFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .addFriendsToFriendGroup(info.friendGroup, [info.userID7, info.userID8])
      .then((result: V2TIMFriendOperationResult[]) => {
        writeResult('addFriendsToFriendGroup succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('addFriendsToFriendGroup failed', error);
      });
  }

  static deleteFriendsFromFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .deleteFriendsFromFriendGroup(info.friendGroup, [info.userID7, info.userID8])
      .then((result: V2TIMFriendOperationResult[]) => {
        writeResult('deleteFriendsFromFriendGroup succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('deleteFriendsFromFriendGroup failed', error);
      });
  }

  static getFriendGroups() {
    V2TIMManager.getFriendshipManager()
      .getFriendGroups([info.friendGroup2, info.friendGroup3])
      .then((result: V2TIMFriendGroup[]) => {
        writeResult('getFriendGroups succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getFriendGroups failed', error);
      });
  }

  static deleteFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .deleteFriendGroup([info.friendGroup2, info.friendGroup3])
      .then(() => {
        writeResult('deleteFriendGroup succeeded');
      })
      .catch((error: Error) => {
        writeResult('deleteFriendGroup failed', error);
      });
  }

  static renameFriendGroup() {
    V2TIMManager.getFriendshipManager().renameFriendGroup(info.oldFriendGroupName, info.newFriendGroupName)
      .then(() => {
        writeResult('renameFriendGroup succeeded');
      })
      .catch((error: Error) => {
        writeResult('renameFriendGroup failed', error);
      });
  }

  static followUser() {
    V2TIMManager.getFriendshipManager().followUser([info.userID1, info.userID2])
      .then((resultList: V2TIMFollowOperationResult[]) => {
        writeResult('followUser succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('followUser failed', error);
      });
  }

  static unfollowUser() {
    V2TIMManager.getFriendshipManager().unfollowUser([info.userID1, info.userID2])
      .then((resultList: V2TIMFollowOperationResult[]) => {
        writeResult('unfollowUser succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('unfollowUser failed', error);
      });
  }

  static getMyFollowingList() {
    V2TIMManager.getFriendshipManager().getMyFollowingList("")
      .then((result: V2TIMUserInfoResult) => {
        writeResult('getMyFollowingList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getMyFollowingList failed', error);
      });
  }

  static getMyFollowersList() {
    V2TIMManager.getFriendshipManager().getMyFollowersList("")
      .then((result: V2TIMUserInfoResult) => {
        writeResult('getMyFollowersList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getMyFollowersList failed', error);
      });
  }

  static getMutualFollowersList() {
    V2TIMManager.getFriendshipManager().getMutualFollowersList("")
      .then((result: V2TIMUserInfoResult) => {
        writeResult('getMutualFollowersList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getMutualFollowersList failed', error);
      });
  }

  static getUserFollowInfo() {
    V2TIMManager.getFriendshipManager().getUserFollowInfo([info.userID1, info.userID2])
      .then((resultList: V2TIMFollowInfo[]) => {
        writeResult('getUserFollowInfo succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('getUserFollowInfo failed', error);
      });
  }

  static checkFollowType() {
    V2TIMManager.getFriendshipManager().checkFollowType([info.userID1, info.userID2])
      .then((resultList: V2TIMFollowTypeCheckResult[]) => {
        writeResult('checkFollowType succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('checkFollowType failed', error);
      });
  }

}


const friendshipListener: V2TIMFriendshipListener = {
  onFriendApplicationListAdded: (applicationList: V2TIMFriendApplication[]) => {
    onCallback('onFriendApplicationListAdded', applicationList);
  },
  onFriendApplicationListDeleted: (userIDList: string[]) => {
    onCallback('onFriendApplicationListDeleted', userIDList);
  },
  onFriendApplicationListRead: () => {
    onCallback('onFriendApplicationListRead');
  },
  onFriendListAdded: (userIDList: V2TIMFriendInfo[]) => {
    onCallback('onFriendListAdded', userIDList);
  },
  onFriendListDeleted: (userIDList: string[]) => {
    onCallback('onFriendListDeleted', userIDList);
  },
  onFriendInfoChanged: (infoList: V2TIMFriendInfo[]) => {
    onCallback('onFriendInfoChanged', infoList);
  },
  onOfficialAccountSubscribed: (officialAccountInfo: V2TIMOfficialAccountInfo) => {
    onCallback('onOfficialAccountSubscribed', officialAccountInfo);
  },
  onOfficialAccountUnsubscribed: (officialAccountID: string) => {
    onCallback('onOfficialAccountUnsubscribed', officialAccountID);
  },
  onOfficialAccountDeleted: (officialAccountID: string) => {
    onCallback('onOfficialAccountDeleted', officialAccountID);
  },
  onOfficialAccountInfoChanged: (officialAccountInfo: V2TIMOfficialAccountInfo) => {
    onCallback('onOfficialAccountInfoChanged', officialAccountInfo);
  },
  onMyFollowingListChanged: (userInfoList: V2TIMUserFullInfo[], isAdd: boolean) => {
    onCallback('onMyFollowingListChanged', userInfoList, isAdd);
  },
  onMyFollowersListChanged: (userInfoList: V2TIMUserFullInfo[], isAdd: boolean) => {
    onCallback('onMyFollowersListChanged', userInfoList, isAdd);
  },
  OnMutualFollowersListChanged: (userInfoList: V2TIMUserFullInfo[], isAdd: boolean) => {
    onCallback('OnMutualFollowersListChanged', userInfoList, isAdd);
  }
};