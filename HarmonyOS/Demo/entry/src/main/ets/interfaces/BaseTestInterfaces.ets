import { SDKAPPID, genTestUserSig } from "../tools/GenerateTestUserSig";
import TestResult from "../pages/BaseManagerTestPage";
import buffer from "@ohos.buffer";
import { V2TIMManager, V2TIMSDKConfig, V2TIMLogLevel, V2TIMLoginStatus, V2TIMMessage, V2TIMMessagePriority, V2TIMGroupType, V2TIMUserFullInfo, V2TIMFriendAllowType, V2TIMSetSelfInfoParam, V2TIMUserStatus, V2TIMSetSelfStatusParam, V2TIMUserInfo, V2TIMSimpleMsgListener, V2TIMSDKListener, V2TIMGroupMemberInfo, V2TIMGroupMemberChangeInfo, V2TIMGroupListener, V2TIMGroupChangeInfo } from "@tencentcloud/imsdk";
import Prompt from "@system.prompt";

export class BaseTestInterfaces {
  static addSDKListener() {
    V2TIMManager.getInstance().addSDKListener(sdkListener);
    Prompt.showToast({ message: "addSDKListener" });
  }

  static removeSDKListener() {
    V2TIMManager.getInstance().removeSDKListener(sdkListener);
    Prompt.showToast({ message: "removeSDKListener" });
  }

  static initSDK() {
    const sdkConfig: V2TIMSDKConfig = {
      logLevel: V2TIMLogLevel.V2TIM_LOG_DEBUG,
      logListener: (logLevel: V2TIMLogLevel, logContent: string) => {
        // Test.log('logListener', logLevel, logContent);
      },
    };
    V2TIMManager.getInstance().initSDK(SDKAPPID, sdkConfig);
    Prompt.showToast({ message: "initSDK" });
  }

  static unInitSDK() {
    V2TIMManager.getInstance().unInitSDK();
    Prompt.showToast({ message: "unInitSDK" });
  }

  static getVersion() {
    const result = V2TIMManager.getInstance().getVersion();
    TestResult.interfaceResult = `getVersion ${result}`;
  }

  static getServerTime() {
    const result = V2TIMManager.getInstance().getServerTime();
    TestResult.interfaceResult = `getServerTime ${result}`;
  }

  static login(userID: string) {
    const userSig = genTestUserSig(userID);
    V2TIMManager.getInstance()
      .login(userID, userSig)
      .then(() => {
        TestResult.interfaceResult = "login succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = "login failed " + error;
      });
  }

  static logout() {
    V2TIMManager.getInstance()
      .logout()
      .then(() => {
        TestResult.interfaceResult = "logout succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = "logout failed " + error;
      });
  }

  static getLoginUser() {
    const result = V2TIMManager.getInstance().getLoginUser();
    TestResult.interfaceResult = "getLoginUser " + result;
  }

  static getLoginStatus() {
    const result = V2TIMManager.getInstance().getLoginStatus();
    TestResult.interfaceResult = "getLoginStatus " + V2TIMLoginStatus[result];
  }

  static addSimpleMsgListener() {
    V2TIMManager.getInstance().addSimpleMsgListener(simpleMsgListener);
  }

  static removeSimpleMsgListener() {
    V2TIMManager.getInstance().removeSimpleMsgListener(simpleMsgListener);
  }

  static sendC2CTextMessage(toUser: string, text = "textMsg") {
    const result = V2TIMManager.getInstance().sendC2CTextMessage(text, toUser);
    const msgID = result.msgID;
    const promise = result.promise;
    promise
      .then((message: V2TIMMessage) => {
        TestResult.interfaceResult = `sendC2CTextMessage success,\n ${message.msgID} `;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `sendC2CTextMessage failed,\n ${msgID} \n ${error}}`;
      });
  }

  static sendC2CCustomMessage(toUser: string, customText = "customMsg") {
    const customData = buffer.from(customText).buffer;
    const result = V2TIMManager.getInstance().sendC2CCustomMessage(customData, toUser);
    const msgID = result.msgID;
    const promise = result.promise;
    promise
      .then((message: V2TIMMessage) => {
        TestResult.interfaceResult = `sendC2CCustomMessage success,\n ${message.msgID} `;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `sendC2CCustomMessage failed,\n ${msgID} \n ${error}}`;
      });
  }

  static sendGroupTextMessage(toGroupID: string, text = "textMsg", priority = V2TIMMessagePriority.V2TIM_PRIORITY_DEFAULT) {
    const result = V2TIMManager.getInstance().sendGroupTextMessage(text, toGroupID, priority);
    const msgID = result.msgID;
    const promise = result.promise;
    promise
      .then((message: V2TIMMessage) => {
        TestResult.interfaceResult = `sendGroupTextMessage success,\n ${message.msgID} `;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `sendGroupTextMessage failed,\n ${msgID} \n ${error}}`;
      });
  }

  static sendGroupCustomMessage(toGroupID: string, text = "customMsg", priority = V2TIMMessagePriority.V2TIM_PRIORITY_DEFAULT) {
    const customData = buffer.from(text).buffer;
    const result = V2TIMManager.getInstance().sendGroupCustomMessage(customData, toGroupID, priority);
    const msgID = result.msgID;
    const promise = result.promise;
    promise
      .then((message: V2TIMMessage) => {
        TestResult.interfaceResult = `sendGroupCustomMessage success,\n ${message.msgID} `;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `sendGroupCustomMessage failed,\n ${msgID} \n ${error}}`;
      });
  }

  static addGroupListener() {
    V2TIMManager.getInstance().addGroupListener(groupListener);
  }

  static removeGroupListener() {
    V2TIMManager.getInstance().removeGroupListener(groupListener);
  }

  static createGroup(groupType: V2TIMGroupType, groupName: string, groupID: string) {
    V2TIMManager.getInstance()
      .createGroup(groupType, groupName, groupID)
      .then((groupID: string) => {
        TestResult.interfaceResult = `createGroup succeeded  ${groupID}`;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `createGroup failed  ${error}`;
      });
  }

  static joinGroup(groupID: string) {
    V2TIMManager.getInstance()
      .joinGroup(groupID)
      .then(() => {
        TestResult.interfaceResult = "joinGroup succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `joinGroup failed ${error}`;
      });
  }

  static quitGroup(groupID: string) {
    V2TIMManager.getInstance()
      .quitGroup(groupID)
      .then(() => {
        TestResult.interfaceResult = "quitGroup succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `quitGroup failed ${error}`;
      });
  }

  static dismissGroup(groupID: string) {
    V2TIMManager.getInstance()
      .dismissGroup(groupID)
      .then(() => {
        TestResult.interfaceResult = "dismissGroup succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `dismissGroup failed ${error}`;
      });
  }

  static getUsersInfo(userID1: string, userID2: string) {
    V2TIMManager.getInstance()
      .getUsersInfo([userID1, userID2])
      .then((userFullInfoList: V2TIMUserFullInfo[]) => {
        TestResult.interfaceResult = `getUsersInfo succeeded ${userFullInfoList}`;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `getUsersInfo failed ${error}`;
      });
  }

  static setSelfInfo(nickName: string, allowType: V2TIMFriendAllowType | undefined) {
    const info: V2TIMSetSelfInfoParam = {
      nickName: nickName,
      allowType: allowType,
    };
    V2TIMManager.getInstance()
      .setSelfInfo(info)
      .then(() => {
        TestResult.interfaceResult = `setSelfInfo succeeded`;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `setSelfInfo failed ${error}`;
      });
  }

  static getUserStatus(userID3: string, userID4: string) {
    V2TIMManager.getInstance()
      .getUserStatus([userID3, userID4])
      .then((userStatusList: V2TIMUserStatus[]) => {
        TestResult.interfaceResult = `getUserStatus succeeded ${userStatusList}`;
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `getUserStatus failed ${error}`;
      });
  }

  static setSelfStatus(selfStatus: string) {
    const status: V2TIMSetSelfStatusParam = {
      customStatus: selfStatus,
    };
    V2TIMManager.getInstance()
      .setSelfStatus(status)
      .then(() => {
        TestResult.interfaceResult = "setSelfStatus succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `setSelfStatus failed ${error}`;
      });
  }

  static subscribeUserStatus(userID5: string, userID6: string) {
    V2TIMManager.getInstance()
      .subscribeUserStatus([userID5, userID6])
      .then(() => {
        TestResult.interfaceResult = "subscribeUserStatus succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `subscribeUserStatus failed ${error}`;
      });
  }

  static unsubscribeUserStatus(userID5: string, userID6: string) {
    V2TIMManager.getInstance()
      .unsubscribeUserStatus([userID5, userID6])
      .then(() => {
        TestResult.interfaceResult = "unsubscribeUserStatus succeeded";
      })
      .catch((error: Error) => {
        TestResult.interfaceResult = `unsubscribeUserStatus failed ${error}`;
      });
  }
}

const sdkListener: V2TIMSDKListener = {
  onConnecting: () => (TestResult.sdkResult = "onConnecting"),
  onConnectSuccess: () => (TestResult.sdkResult = "onConnectSuccess"),
  onConnectFailed: (code: number, message: string) => (TestResult.sdkResult = `onConnectSuccess ${code} ${message}`),
  onKickedOffline: () => (TestResult.sdkResult = "onKickedOffline"),
  onUserSigExpired: () => (TestResult.sdkResult = "onUserSigExpired"),
  onSelfInfoUpdated: (info: V2TIMUserFullInfo) => (TestResult.sdkResult = `onSelfInfoUpdated ${info}`),
  onUserStatusChanged: (userStatusList: V2TIMUserStatus[]) => (TestResult.sdkResult = `onSelfInfoUpdated ${userStatusList}`),
};

const simpleMsgListener: V2TIMSimpleMsgListener = {
  onRecvC2CTextMessage: (msgID: string, sender: V2TIMUserInfo, text: string) => {
    TestResult.simpleMessageReceive = `onRecvC2CTextMessage ${msgID}  ${sender}  ${text}`;
  },
  onRecvC2CCustomMessage: (msgID: string, sender: V2TIMUserInfo, customData: ArrayBuffer) => {
    TestResult.simpleMessageReceive = `onRecvC2CCustomMessage ${msgID}  ${sender}  ${buffer.from(customData).toString()}`;
  },
  onRecvGroupTextMessage: (msgID: string, groupID: string, sender: V2TIMGroupMemberInfo, text: string) => {
    TestResult.simpleMessageReceive = `onRecvGroupTextMessage ${msgID} ${groupID} ${sender}  ${text}`;
  },
  onRecvGroupCustomMessage: (msgID: string, groupID: string, sender: V2TIMGroupMemberInfo, customData: ArrayBuffer) => {
    TestResult.simpleMessageReceive = `onRecvGroupCustomMessage ${msgID} ${groupID} ${sender}  ${buffer.from(customData).toString()}`;
  },
};

export const groupListener: V2TIMGroupListener = {
  onMemberEnter: (groupID: string, memberList: V2TIMGroupMemberInfo[]) => {
    TestResult.groupCallback = `onMemberEnter ${groupID} ${memberList}`;
  },
  onMemberLeave: (groupID: string, member: V2TIMGroupMemberInfo) => {
    TestResult.groupCallback = `onMemberLeave ${groupID}  ${member}`;
  },
  onMemberInvited: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    TestResult.groupCallback = `onMemberInvited ${groupID} ${opUser} ${memberList}`;
  },
  onMemberKicked: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    TestResult.groupCallback = `onMemberKicked ${groupID} ${opUser} ${memberList}`;
  },
  onMemberInfoChanged: (groupID: string, v2TIMGroupMemberChangeInfoList: V2TIMGroupMemberChangeInfo[]) => {
    TestResult.groupCallback = `onMemberInfoChanged ${groupID} ${v2TIMGroupMemberChangeInfoList}`;
  },
  onGroupCreated: (groupID: string) => {
    TestResult.groupCallback = `onGroupCreated' ${groupID}`;
  },
  onGroupDismissed: (groupID: string, opUser: V2TIMGroupMemberInfo) => {
    TestResult.groupCallback = `onGroupDismissed ${groupID} ${opUser}`;
  },
  onGroupRecycled: (groupID: string, opUser: V2TIMGroupMemberInfo) => {
    TestResult.groupCallback = `onGroupRecycled ${groupID} ${opUser}`;
  },
  onGroupInfoChanged: (groupID: string, changeInfos: V2TIMGroupChangeInfo[]) => {
    TestResult.groupCallback = `onGroupInfoChanged ${groupID} ${changeInfos}`;
  },
  onReceiveJoinApplication: (groupID: string, member: V2TIMGroupMemberInfo, opReason: string) => {
    TestResult.groupCallback = `onReceiveJoinApplication ${groupID} ${member} ${opReason}`;
  },
  onApplicationProcessed: (groupID: string, opUser: V2TIMGroupMemberInfo, isAgreeJoin: boolean, opReason: string) => {
    TestResult.groupCallback = `onApplicationProcessed ${groupID} ${opUser} ${isAgreeJoin} ${opReason}`;
  },
  onGrantAdministrator: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    TestResult.groupCallback = `onGrantAdministrator ${groupID} ${opUser} ${memberList}`;
  },
  onRevokeAdministrator: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    TestResult.groupCallback = `onRevokeAdministrator ${groupID} ${opUser} ${memberList}`;
  },
  onQuitFromGroup: (groupID: string) => {
    TestResult.groupCallback = `onQuitFromGroup ${groupID}`;
  },
  onReceiveRESTCustomData: (groupID: string, customData: ArrayBuffer) => {
    TestResult.groupCallback = `onReceiveRESTCustomData ${groupID} ${customData}`;
  },
};
