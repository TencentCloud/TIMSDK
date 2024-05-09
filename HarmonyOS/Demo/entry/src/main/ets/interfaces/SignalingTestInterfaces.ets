import { V2TIMManager } from '@tencentcloud/imsdk/src/main/ets/V2TIMManager'
import Prompt from '@system.prompt';
import { V2TIMSignalingListener } from '@tencentcloud/imsdk/src/main/ets/V2TIMListener';
import TestResult from "../pages/SignalingTestPage"
import { writeResult, onCallback } from '../pages/SignalingTestPage';
import { V2TIMSignalingInfo } from '@tencentcloud/imsdk/src/main/ets/V2TIMSignaling';
import { V2TIMOfflinePushInfo, V2TIMMessage } from '@tencentcloud/imsdk';

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
    result.promise.then(() => {
      writeResult('invite succeeded');
    })
    .catch((error: Error) => {
      writeResult('invite failed', error);
    });
  }

  static inviteInGroup(groupID: string, inviteeList: string[], data: string, onlineUserOnly: boolean, timeout: number) {
    let result = V2TIMManager.getSignalingManager()
      .inviteInGroup(groupID, inviteeList, data, onlineUserOnly, timeout);
    TestResult.inviteID = result.inviteID;
    result.promise.then(() => {
      writeResult('inviteInGroup succeeded');
    })
    .catch((error: Error) => {
      writeResult('inviteInGroup failed', error);
    });
  }

  static cancel(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager().cancel(inviteID, data)
      .then(()=>{
        writeResult('cancel succeeded');
      })
      .catch((error: Error) => {
        writeResult('cancel failed', error);
      });
  }

  static accept(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager().accept(inviteID, data).then(()=>{
      writeResult('accept succeeded');
    })
    .catch((error: Error) => {
      writeResult('accept failed', error);
    });
  }

  static reject(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager().reject(inviteID, data).then(()=>{
      writeResult('reject succeeded');
    })
    .catch((error: Error) => {
      writeResult('reject failed', error);
    });
  }

  static getSignalingInfo(msg: V2TIMMessage) {
    let signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(msg);
    TestResult.result = signalingInfo.toString();
  }

  static modifyInvitation(inviteID: string, data: string) {
    V2TIMManager.getSignalingManager().modifyInvitation(inviteID, data).then(()=>{
      writeResult('modifyInvitation succeeded');
    })
    .catch((error: Error) => {
      writeResult('modifyInvitation failed', error);
    });
  }
}

const signalingListener: V2TIMSignalingListener = {
  onReceiveNewInvitation: (inviteID: string, inviter: string, groupID: string, inviteeList: string[], data: string) => {
    onCallback('onReceiveNewInvitation', inviter, groupID, inviteeList, data);
    TestResult.inviteID = inviteID;
  },
  onInviteeAccepted: (inviteID: string, invitee: string, data: string) => {
    onCallback('onInviteeAccepted', inviteID, invitee, data);
  },
  onInviteeRejected: (inviteID: string, invitee: string, data: string) => {
    onCallback('onInviteeRejected', inviteID, invitee, data);
  },
  onInvitationCancelled: (inviteID: string, inviter: string, data: string) => {
    onCallback('onInvitationCancelled', inviteID, inviter, data);
  },
  onInvitationTimeout: (inviteID: string, inviteeList: string[]) => {
    onCallback('onInvitationTimeout', inviteID, inviteeList);
  },
  onInvitationModified: (inviteID: string, data: string) => {
    onCallback('onInvitationModified', inviteID, data);
  },
}