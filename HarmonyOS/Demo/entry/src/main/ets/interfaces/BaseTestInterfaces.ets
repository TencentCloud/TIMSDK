import { SDKAPPID, genTestUserSig } from '../tools/GenerateTestUserSig';
import TestResult from '../pages/BaseManagerTestPage';
import buffer from '@ohos.buffer';
import { onGroupCallback, onSimpleMessageReceive, writeResult, onSDKCallback } from  "../pages/BaseManagerTestPage"

import {
  V2TIMManager,
  V2TIMSDKConfig,
  V2TIMLogLevel,
  V2TIMLoginStatus,
  V2TIMMessage,
  V2TIMMessagePriority,
  V2TIMGroupType,
  V2TIMUserFullInfo,
  V2TIMFriendAllowType,
  V2TIMSetSelfInfoParam,
  V2TIMUserStatus,
  V2TIMSetSelfStatusParam,
  V2TIMUserInfo,
  V2TIMSimpleMsgListener,
  V2TIMSDKListener,
  V2TIMGroupMemberInfo,
  V2TIMGroupMemberChangeInfo,
  V2TIMGroupListener,
  V2TIMGroupChangeInfo,
} from '@tencentcloud/imsdk';
import Prompt from '@system.prompt';

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
      }
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
    writeResult('getVersion succeeded', result);
  }

  static getServerTime() {
    const result = V2TIMManager.getInstance().getServerTime();
    writeResult('getServerTime succeeded', result);
  }

  static login(userID: string) {
    const userSig = genTestUserSig(userID);
    V2TIMManager.getInstance().login(userID, userSig)
      .then(() => {
        writeResult('login succeeded');
      })
      .catch((error: Error) => {
        writeResult('login failed', error);
      });
  }

  static logout() {
    V2TIMManager.getInstance().logout()
      .then(() => {
        writeResult('logout succeeded');
      })
      .catch((error: Error) => {
        writeResult('logout failed', error);
      });
  }

  static getLoginUser() {
    const result = V2TIMManager.getInstance().getLoginUser();
    writeResult('getLoginUser succeeded', result);
  }

  static getLoginStatus() {
    const result = V2TIMManager.getInstance().getLoginStatus();
    writeResult('getLoginUser succeeded', result);
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
        writeResult('sendC2CTextMessage succeeded', message);
      })
      .catch((error: Error) => {
        writeResult('sendC2CTextMessage failed', error);
      });
  }

  static sendC2CCustomMessage(toUser: string, customText = "customMsg") {
    const customData = buffer.from(customText).buffer;
    const result = V2TIMManager.getInstance().sendC2CCustomMessage(customData, toUser);
    const msgID = result.msgID;
    const promise = result.promise;
    promise
      .then((message: V2TIMMessage) => {
        writeResult('sendC2CCustomMessage succeeded', message);
      })
      .catch((error: Error) => {
        writeResult('sendC2CCustomMessage failed', error);
      });
  }

  static sendGroupTextMessage(toGroupID: string, text = "textMsg", priority = V2TIMMessagePriority.V2TIM_PRIORITY_DEFAULT) {
    const result = V2TIMManager.getInstance().sendGroupTextMessage(text, toGroupID, priority);
    const msgID = result.msgID;
    const promise = result.promise;
    promise
      .then((message: V2TIMMessage) => {
        writeResult('sendGroupTextMessage succeeded', message);
      })
      .catch((error: Error) => {
        writeResult('sendGroupTextMessage failed', error);
      });
  }

  static sendGroupCustomMessage(toGroupID: string, text = "customMsg", priority = V2TIMMessagePriority.V2TIM_PRIORITY_DEFAULT) {
    const customData = buffer.from(text).buffer;
    const result = V2TIMManager.getInstance()
      .sendGroupCustomMessage(customData, toGroupID, priority);
    const msgID = result.msgID;
    const promise = result.promise;
    promise
      .then((message: V2TIMMessage) => {
        writeResult('sendGroupCustomMessage succeeded', message);
      })
      .catch((error: Error) => {
        writeResult('sendGroupCustomMessage failed', error);
      });
  }

  static addGroupListener() {
    V2TIMManager.getInstance().addGroupListener(groupListener);
  }

  static removeGroupListener() {
    V2TIMManager.getInstance().removeGroupListener(groupListener);
  }

  static createGroup(groupType: V2TIMGroupType, groupName: string, groupID: string) {
    V2TIMManager.getInstance().createGroup(groupType, groupName, groupID)
      .then((groupID: string) => {
        writeResult('createGroup succeeded', groupID);
      })
      .catch((error: Error) => {
        writeResult('createGroup failed', error);
      });
  }

  static joinGroup(groupID: string) {
    V2TIMManager.getInstance().joinGroup(groupID)
      .then(() => {
        writeResult('joinGroup succeeded');
      })
      .catch((error: Error) => {
        writeResult('joinGroup failed', error);
      });
  }

  static quitGroup(groupID: string) {
    V2TIMManager.getInstance().quitGroup(groupID)
      .then(() => {
        writeResult('quitGroup succeeded');
      })
      .catch((error: Error) => {
        writeResult('quitGroup failed', error);
      });
  }

  static dismissGroup(groupID: string) {
    V2TIMManager.getInstance().dismissGroup(groupID)
      .then(() => {
        writeResult('dismissGroup succeeded');
      })
      .catch((error: Error) => {
        writeResult('dismissGroup failed', error);
      });
  }

  static getUsersInfo(userID1: string, userID2: string) {
    V2TIMManager.getInstance().getUsersInfo([userID1, userID2])
      .then((userFullInfoList: V2TIMUserFullInfo[]) => {
        writeResult('getUsersInfo succeeded', userFullInfoList);
      })
      .catch((error: Error) => {
        writeResult('getUsersInfo failed', error);
      });
  }

  static setSelfInfo(nickName: string, allowType: V2TIMFriendAllowType | undefined) {
    const info: V2TIMSetSelfInfoParam = {
      nickName: nickName,
      allowType: allowType,
    };
    V2TIMManager.getInstance().setSelfInfo(info)
      .then(() => {
        writeResult('setSelfInfo succeeded');
      })
      .catch((error: Error) => {
        writeResult('setSelfInfo failed', error);
      });
  }

  static getUserStatus(userID3: string, userID4: string) {
    V2TIMManager.getInstance().getUserStatus([userID3, userID4])
      .then((userStatusList: V2TIMUserStatus[]) => {
        writeResult('getUserStatus succeeded', userStatusList);
      })
      .catch((error: Error) => {
        writeResult('getUserStatus failed', error);
      });
  }

  static setSelfStatus(selfStatus: string) {
    const status: V2TIMSetSelfStatusParam = {
      customStatus: selfStatus,
    };
    V2TIMManager.getInstance().setSelfStatus(status)
      .then(() => {
        writeResult('setSelfStatus succeeded');
      })
      .catch((error: Error) => {
        writeResult('setSelfStatus failed', error);
      });
  }

  static subscribeUserStatus(userID5: string, userID6: string) {
    V2TIMManager.getInstance().subscribeUserStatus([userID5, userID6])
      .then(() => {
        writeResult('subscribeUserStatus succeeded');
      })
      .catch((error: Error) => {
        writeResult('subscribeUserStatus failed', error);
      });
  }

  static unsubscribeUserStatus(userID5: string, userID6: string) {
    V2TIMManager.getInstance().unsubscribeUserStatus([userID5, userID6])
      .then(() => {
        writeResult('unsubscribeUserStatus succeeded');
      })
      .catch((error: Error) => {
        writeResult('unsubscribeUserStatus failed', error);
      });
  }

  // static getEnumKeys(enumName: ESObject) {
  //   const keys = Object.keys(enumName).filter(key => Number.isNaN(Number(key)));
  //   let result = new Array<string>();
  //   for (const key of keys) {
  //     result.push({ value: key });
  //   }
  //   return result;
  // }
  //
  // static getEnumMap(enumName: any) {
  //   const list = Object.keys(enumName);
  //   const size = list.length / 2;
  //   let result = new Map<string, number>();
  //   for (let i = 0; i < size; ++i) {
  //     result.set(list[i + size], Number(list[i]));
  //   }
  //   return result;
  // }
}

const sdkListener: V2TIMSDKListener = {
  onConnecting: () => {
    onSDKCallback('onConnecting');
  },
  onConnectSuccess: () => {
    onSDKCallback('onConnectSuccess');
  },
  onConnectFailed: (code: number, message: string) => {
    onSDKCallback('onConnectFailed', code, message);
  },
  onKickedOffline: () => {
    onSDKCallback('onKickedOffline');
  },
  onUserSigExpired: () => {
    onSDKCallback('onUserSigExpired');
  },
  onSelfInfoUpdated: (info: V2TIMUserFullInfo) => {
    onSDKCallback('onSelfInfoUpdated', info);
  },
  onUserStatusChanged: (userStatusList: V2TIMUserStatus[]) => {
    onSDKCallback('onUserStatusChanged', userStatusList);
  },
};

const simpleMsgListener: V2TIMSimpleMsgListener = {
  onRecvC2CTextMessage: (msgID: string, sender: V2TIMUserInfo, text: string) => {
    onSimpleMessageReceive('onRecvC2CTextMessage', msgID, sender, text);
  },
  onRecvC2CCustomMessage: (msgID: string, sender: V2TIMUserInfo, customData: ArrayBuffer) => {
    onSimpleMessageReceive('onRecvC2CCustomMessage', msgID, sender, customData);
  },
  onRecvGroupTextMessage: (msgID: string, groupID: string, sender: V2TIMGroupMemberInfo, text: string) => {
    onSimpleMessageReceive('onRecvGroupTextMessage', msgID, groupID, sender, text);
  },
  onRecvGroupCustomMessage: (msgID: string, groupID: string, sender: V2TIMGroupMemberInfo, customData: ArrayBuffer) => {
    onSimpleMessageReceive('onRecvGroupCustomMessage', msgID, groupID, sender, customData);
  },
};

export const groupListener: V2TIMGroupListener = {
  onMemberEnter: (groupID: string, memberList: V2TIMGroupMemberInfo[]) => {
    onGroupCallback('onMemberEnter', groupID, memberList);
  },
  onMemberLeave: (groupID: string, member: V2TIMGroupMemberInfo) => {
    onGroupCallback('onMemberLeave', groupID, member);
  },
  onMemberInvited: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    onGroupCallback('onMemberInvited', groupID, opUser, memberList);
  },
  onMemberKicked: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    onGroupCallback('onMemberKicked', groupID, opUser, memberList);
  },
  onMemberInfoChanged: (groupID: string, v2TIMGroupMemberChangeInfoList: V2TIMGroupMemberChangeInfo[]) => {
    onGroupCallback('onMemberInfoChanged', groupID, v2TIMGroupMemberChangeInfoList);
  },
  onGroupCreated: (groupID: string) => {
    onGroupCallback('onGroupCreated', groupID);
  },
  onGroupDismissed: (groupID: string, opUser: V2TIMGroupMemberInfo) => {
    onGroupCallback('onGroupDismissed', groupID, opUser);
  },
  onGroupRecycled: (groupID: string, opUser: V2TIMGroupMemberInfo) => {
    onGroupCallback('onGroupRecycled', groupID, opUser);
  },
  onGroupInfoChanged: (groupID: string, changeInfos: V2TIMGroupChangeInfo[]) => {
    onGroupCallback('onGroupInfoChanged', groupID, changeInfos);
  },
  onReceiveJoinApplication: (groupID: string, member: V2TIMGroupMemberInfo, opReason: string) => {
    onGroupCallback('onReceiveJoinApplication', groupID, member, opReason);
  },
  onApplicationProcessed: (groupID: string, opUser: V2TIMGroupMemberInfo, isAgreeJoin: boolean, opReason: string) => {
    onGroupCallback('onApplicationProcessed', groupID, opUser, isAgreeJoin, opReason);
  },
  onGrantAdministrator: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    onGroupCallback('onGrantAdministrator', groupID, opUser, memberList);
  },
  onRevokeAdministrator: (groupID: string, opUser: V2TIMGroupMemberInfo, memberList: V2TIMGroupMemberInfo[]) => {
    onGroupCallback('onRevokeAdministrator', groupID, opUser, memberList);
  },
  onQuitFromGroup: (groupID: string) => {
    onGroupCallback('onQuitFromGroup', groupID);
  },
  onReceiveRESTCustomData: (groupID: string, customData: ArrayBuffer) => {
    onGroupCallback('onReceiveRESTCustomData', groupID, customData);
  },
};

