import { V2TIMManager } from "@tencentcloud/imsdk/src/main/ets/V2TIMManager";
import Prompt from "@system.prompt";
import { V2TIMSignalingListener } from "@tencentcloud/imsdk/src/main/ets/V2TIMListener";
import TestResult from "../pages/SignalingTestPage";
import { V2TIMSignalingInfo } from "@tencentcloud/imsdk/src/main/ets/V2TIMSignaling";
import { V2TIMOfflinePushInfo, V2TIMMessage } from "@tencentcloud/imsdk";

export class SignalingTestInterfaces {
  static addSignalingListener() {
    V2TIMManager.getSignalingManager().addSignalingListener(signalingListener);
    Prompt.showToast({ message: "addSignalingListener" });
  }

  static removeSignalingListener() {
    V2TIMManager.getSignalingManager().removeSignalingListener(signalingListener);
    Prompt.showToast({ message: "removeSignalingListener" });
  }

  static invite(invitee: string, data: string, onlineUserOnly: boolean, offlinePushInfo: V2TIMOfflinePushInfo, timeout: number) {
    let result = V2TIMManager.getSignalingManager().invite(invitee, data, onlineUserOnly, offlinePushInfo, timeout);
    TestResult.inviteID = result.inviteID;
    result.promise
      .then(() => {
        TestResult.result = `invite ${invitee} success`;
      })
      .catch(() => {
        TestResult.result = `invite ${invitee} failed`;
      });
  }

  static inviteInGroup(groupID: string, inviteeList: string[], data: string, onlineUserOnly: boolean, timeout: number) {
    let result = V2TIMManager.getSignalingManager().inviteInGroup(groupID, inviteeList, data, onlineUserOnly, timeout);
    TestResult.inviteID = result.inviteID;
    result.promise
      .then(() => {
        TestResult.result = `invite ${inviteeList} in ${groupID} success`;
      })
      .catch(() => {
        TestResult.result = `invite ${inviteeList} in ${groupID} failed`;
      });
  }

  static cancel(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager()
      .cancel(inviteID, data)
      .then(() => {
        TestResult.result = `cancel ${inviteID} success`;
      })
      .catch(() => {
        TestResult.result = `cancel ${inviteID} failed`;
      });
  }

  static accept(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager()
      .accept(inviteID, data)
      .then(() => {
        TestResult.result = `accept ${inviteID} success`;
      })
      .catch(() => {
        TestResult.result = `accept ${inviteID} failed`;
      });
  }

  static reject(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager()
      .reject(inviteID, data)
      .then(() => {
        TestResult.result = `reject ${inviteID} success`;
      })
      .catch(() => {
        TestResult.result = `reject ${inviteID} failed`;
      });
  }

  static getSignalingInfo(msg: V2TIMMessage) {
    let signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(msg);
    TestResult.result = signalingInfo.toString();
  }

  static modifyInvitation(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager()
      .modifyInvitation(inviteID, data)
      .then(() => {
        TestResult.result = `modifyInvitation ${inviteID} ${data} success`;
      })
      .catch(() => {
        TestResult.result = `modifyInvitation ${inviteID} failed`;
      });
  }
}

const signalingListener: V2TIMSignalingListener = {
  onReceiveNewInvitation: (inviteID: string, inviter: string, groupID: string, inviteeList: string[], data: string) => {
    TestResult.callBackResult = `onReceiveNewInvitation inviteID:${inviteID}, inviter:${inviter},groupID:${groupID},inviteeList:${inviteeList},data:${data}`;
    TestResult.inviteID = inviteID;
  },
  onInviteeAccepted: (inviteID: string, invitee: string, data: string) => {
    TestResult.callBackResult = `onInviteeAccepted inviteID:${inviteID}, invitee:${invitee},data:${data}`;
  },
  onInviteeRejected: (inviteID: string, invitee: string, data: string) => {
    TestResult.callBackResult = `onInviteeRejected inviteID:${inviteID}, invitee:${invitee},data:${data}`;
  },
  onInvitationCancelled: (inviteID: string, inviter: string, data: string) => {
    TestResult.callBackResult = `onInvitationCancelled inviteID:${inviteID}, inviter:${inviter},data:${data}`;
  },
  onInvitationTimeout: (inviteID: string, inviteeList: string[]) => {
    TestResult.callBackResult = `onInvitationTimeout inviteID:${inviteID}, inviteeList:${inviteeList}`;
  },
  onInvitationModified: (inviteID: string, data: string) => {
    TestResult.callBackResult = `onInvitationModified inviteID:${inviteID}, data:${data}`;
  },
};
