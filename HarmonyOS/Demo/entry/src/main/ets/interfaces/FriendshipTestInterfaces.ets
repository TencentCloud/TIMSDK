import { V2TIMFriendshipListener, V2TIMFriendApplication, V2TIMFriendInfo, V2TIMManager, V2TIMFriendInfoResult, V2TIMSetFriendInfoParam, V2TIMFriendType, V2TIMFriendOperationResult, V2TIMFriendAddApplication, V2TIMFriendApplicationResult, V2TIMFriendAcceptType, V2TIMFriendGroup } from "@tencentcloud/imsdk";
import Prompt from "@system.prompt";
import TestResult, { info } from "../pages/FriendshipManagerTestPage";

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
    V2TIMManager.getFriendshipManager()
      .getFriendList()
      .then((info: V2TIMFriendInfo[]) => {
        TestResult.result = `getFriendList succeeded ${info}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getFriendList failed ${error}`;
      });
  }

  static getFriendsInfo() {
    V2TIMManager.getFriendshipManager()
      .getFriendsInfo([info.userID1, info.userID2])
      .then((info: V2TIMFriendInfoResult[]) => {
        TestResult.result = `getFriendList succeeded ${info}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getFriendList failed ${error}`;
      });
  }

  static setFriendInfo() {
    let param: V2TIMSetFriendInfoParam = {
      userID: info.userID3,
      friendRemark: info.friendRemark,
    };
    V2TIMManager.getFriendshipManager()
      .setFriendInfo(param)
      .then(() => {
        TestResult.result = `setFriendInfo succeeded `;
      })
      .catch((error: Error) => {
        TestResult.result = `setFriendInfo failed ${error}`;
      });
  }

  static addFriend() {
    const application: V2TIMFriendAddApplication = {
      userID: info.userID4,
      friendRemark: info.friendRemark2,
      addWording: info.addWording,
      addType: V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH,
    };
    V2TIMManager.getFriendshipManager()
      .addFriend(application)
      .then((result: V2TIMFriendOperationResult) => {
        TestResult.result = `addFriend succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `addFriend failed ${error}`;
      });
  }

  static deleteFromFriendList() {
    const deleteType = V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH;
    V2TIMManager.getFriendshipManager()
      .deleteFromFriendList([info.userID4], deleteType)
      .then((result: V2TIMFriendOperationResult[]) => {
        TestResult.result = `deleteFromFriendList succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteFromFriendList failed ${error}`;
      });
  }

  static checkFriend() {
    const checkType = V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH;
    V2TIMManager.getFriendshipManager()
      .checkFriend([info.userID4], checkType)
      .then((result: V2TIMFriendOperationResult[]) => {
        TestResult.result = `checkFriend succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `checkFriend failed ${error}`;
      });
  }

  static getFriendApplicationList() {
    V2TIMManager.getFriendshipManager()
      .getFriendApplicationList()
      .then((result: V2TIMFriendApplicationResult) => {
        TestResult.result = `getFriendApplicationList succeeded ${result}`;
        FriendshipTestInterfaces.friendApplicationList = result.applicationList;
      })
      .catch((error: Error) => {
        TestResult.result = `getFriendApplicationList failed ${error}`;
      });
  }

  static acceptFriendApplication() {
    if (FriendshipTestInterfaces.friendApplicationList.length <= 0) {
      Prompt.showToast({ message: "请先获取好友申请" });
      return;
    }
    let acceptType = V2TIMFriendAcceptType.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD;
    V2TIMManager.getFriendshipManager()
      .acceptFriendApplication(FriendshipTestInterfaces.friendApplicationList[0], acceptType)
      .then((result: V2TIMFriendOperationResult) => {
        TestResult.result = `acceptFriendApplication succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `acceptFriendApplication failed ${error}`;
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
        TestResult.result = `refuseFriendApplication succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `refuseFriendApplication failed ${error}`;
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
        TestResult.result = `deleteFriendApplication succeeded `;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteFriendApplication failed ${error}`;
      });
  }

  static setFriendApplicationRead() {
    V2TIMManager.getFriendshipManager()
      .setFriendApplicationRead()
      .then(() => {
        TestResult.result = `setFriendApplicationRead succeeded `;
      })
      .catch((error: Error) => {
        TestResult.result = `setFriendApplicationRead failed ${error}`;
      });
  }

  static getBlackList() {
    V2TIMManager.getFriendshipManager()
      .getBlackList()
      .then((result: V2TIMFriendInfo[]) => {
        TestResult.result = `getBlackList succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getBlackList failed ${error}`;
      });
  }

  static addToBlackList() {
    V2TIMManager.getFriendshipManager()
      .addToBlackList([info.userID5, info.userID6])
      .then((result: V2TIMFriendOperationResult[]) => {
        TestResult.result = `addToBlackList succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `addToBlackList failed ${error}`;
      });
  }

  static deleteFromBlackList() {
    V2TIMManager.getFriendshipManager()
      .deleteFromBlackList([info.userID5, info.userID6])
      .then((result: V2TIMFriendOperationResult[]) => {
        TestResult.result = `deleteFromBlackList succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteFromBlackList failed ${error}`;
      });
  }

  static createFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .createFriendGroup(info.friendGroup, [info.userID7, info.userID8])
      .then((result: V2TIMFriendOperationResult[]) => {
        TestResult.result = `createFriendGroup succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `createFriendGroup failed ${error}`;
      });
  }

  static addFriendsToFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .addFriendsToFriendGroup(info.friendGroup, [info.userID7, info.userID8])
      .then((result: V2TIMFriendOperationResult[]) => {
        TestResult.result = `addFriendsToFriendGroup succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `addFriendsToFriendGroup failed ${error}`;
      });
  }

  static deleteFriendsFromFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .deleteFriendsFromFriendGroup(info.friendGroup, [info.userID7, info.userID8])
      .then((result: V2TIMFriendOperationResult[]) => {
        TestResult.result = `deleteFriendsFromFriendGroup succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteFriendsFromFriendGroup failed ${error}`;
      });
  }

  static getFriendGroups() {
    V2TIMManager.getFriendshipManager()
      .getFriendGroups([info.friendGroup2, info.friendGroup3])
      .then((result: V2TIMFriendGroup[]) => {
        TestResult.result = `getFriendGroups succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getFriendGroups failed ${error}`;
      });
  }

  static deleteFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .deleteFriendGroup([info.friendGroup2, info.friendGroup3])
      .then(() => {
        TestResult.result = `deleteFriendGroup succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteFriendGroup failed ${error}`;
      });
  }

  static renameFriendGroup() {
    V2TIMManager.getFriendshipManager()
      .renameFriendGroup(info.oldFriendGroupName, info.newFriendGroupName)
      .then(() => {
        TestResult.result = `renameFriendGroup succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `renameFriendGroup failed ${error}`;
      });
  }
}

const friendshipListener: V2TIMFriendshipListener = {
  onFriendApplicationListAdded: (applicationList: V2TIMFriendApplication[]) => {
    TestResult.callbackResult = `onFriendApplicationListAdded ${applicationList}`;
  },
  onFriendApplicationListDeleted: (userIDList: string[]) => {
    TestResult.callbackResult = `onFriendApplicationListDeleted ${userIDList}`;
  },
  onFriendApplicationListRead: () => {
    TestResult.callbackResult = `onFriendApplicationListRead`;
  },
  onFriendListAdded: (userIDList: V2TIMFriendInfo[]) => {
    TestResult.callbackResult = `onFriendListAdded ${userIDList}`;
  },
  onFriendListDeleted: (userIDList: string[]) => {
    TestResult.callbackResult = `onFriendListDeleted ${userIDList}`;
  },
  onFriendInfoChanged: (infoList: V2TIMFriendInfo[]) => {
    TestResult.callbackResult = `onFriendInfoChanged ${infoList}`;
  },
};
