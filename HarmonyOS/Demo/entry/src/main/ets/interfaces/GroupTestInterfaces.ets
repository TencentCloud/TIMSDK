import {
  V2TIMGroupType,
  V2TIMCreateGroupInfo,
  V2TIMCreateGroupMemberInfo,
  V2TIMManager,
  V2TIMGroupInfo,
  V2TIMGroupInfoResult,
  V2TIMGroupSearchParam,
  V2TIMGroupAddOpt,
  V2TIMSetGroupInfoParam,
  V2TIMGroupMemberInfoResult,
  V2TIMGroupMemberFullInfo,
  V2TIMGroupMemberSearchParam,
  V2TIMSetGroupMemberInfo,
  V2TIMGroupMemberOperationResult,
  V2TIMGroupMemberRole,
  V2TIMGroupApplicationResult,
  V2TIMGroupApplication,
  V2TIMTopicInfo,
  V2TIMTopicOperationResult,
  V2TIMTopicInfoResult,
  V2TIMMessage
} from '@tencentcloud/imsdk';
import Prompt from '@system.prompt';

import { writeResult } from "../pages/GroupManagerTestPage"

@Observed
export class GroupInfos {
  groupType = V2TIMGroupType.Work;
  groupName = "groupName";
  groupID = "groupID";
  notification = "notification";
  introduction = "introduction";
  faceURL = "faceURL";
  userID1 = "userID1";
  userID2 = "userID2";
  // groups info
  groupID2 = "groupID2";
  groupID3 = "groupID3";
  // set group info
  groupID4 = "groupID4";
  groupName4 = "groupName4";
  groupAddOpt = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY;
  groupApproveOpt = V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY;
  groupID5 = "groupID5";
  // get group member list
  groupID6 = "group6";
  getGroupMemberListFilter = V2TIMGroupMemberRole.V2TIM_GROUP_MEMBER_UNDEFINED;
  nextSeq = 0;
  // member info
  groupID7 = "group7";
  userID7 = "userID7";
  userID8 = "userID8";
  // setGroupMemberInfo
  groupID9 = "group9";
  userID9 = "userID9";
  nameCard = "nameCard11";
  // mute group info
  groupID10 = "groupID10";
  userID10 = "userID10";
  seconds = 5;
  // set member role
  groupID11 = "groupID11";
  userID11 = "userID11";
  role = V2TIMGroupMemberRole.V2TIM_GROUP_MEMBER_UNDEFINED;
  // mark group member
  groupID12 = "groupID12";
  userID12 = "userID12";
  userID13 = "userID13";
  markType = 0;
  enableMark = false;
  // transform
  groupID14 = "groupID14";
  userID14 = "userID14";
  // group application
  groupApplication: V2TIMGroupApplication[] = [];
  //community
  communityGroupID = "communityGroupID";
}

export let groupInfo = new GroupInfos();

export class GroupTestInterfaces {
  static createWork() {
    GroupTestInterfaces.createGroup(V2TIMGroupType.Work);
  }

  static createPublic() {
    GroupTestInterfaces.createGroup(V2TIMGroupType.Public);
  }

  static createMeeting() {
    GroupTestInterfaces.createGroup(V2TIMGroupType.Meeting);
  }

  static createAVChatRoom() {
    GroupTestInterfaces.createGroup(V2TIMGroupType.AVChatRoom);
  }

  static createCommunity() {
    GroupTestInterfaces.createGroup(V2TIMGroupType.Community);
  }

  static createGroup(groupType: V2TIMGroupType) {
    const info: V2TIMCreateGroupInfo = {
      groupType: groupType,
      groupName: groupInfo.groupName,
      groupID: groupInfo.groupID,
      notification: groupInfo.notification,
      introduction: groupInfo.introduction,
      faceURL: groupInfo.faceURL,
    };
    const memberList: V2TIMCreateGroupMemberInfo[] = [
      { userID: groupInfo.userID1, },
      { userID: groupInfo.userID2 },
    ];
    V2TIMManager.getGroupManager().createGroup(info, memberList)
      .then((groupID: string) => {
        writeResult('createGroup succeeded', groupID);
      })
      .catch((error: Error) => {
        writeResult('createGroup failed', error);
      });
  }

  static getJoinedGroups() {
    V2TIMManager.getGroupManager().getJoinedGroupList()
      .then((info_list: V2TIMGroupInfo[]) => {
        writeResult('getJoinedGroupList succeeded', info_list);
      })
      .catch((error: Error) => {
        writeResult('getJoinedGroupList failed', error);
      });
  }

  static getJoinedCommunityList() {
    V2TIMManager.getCommunityManager().getJoinedCommunityList()
      .then((info_list: V2TIMGroupInfo[]) => {
        writeResult('getJoinedCommunityList succeeded', info_list);
      })
      .catch((error: Error) => {
        writeResult('getJoinedCommunityList failed', error);
      });
  }

  static getGroupsInfo() {
    V2TIMManager.getGroupManager().getGroupsInfo([groupInfo.groupID2, groupInfo.groupID3])
      .then((resultList: V2TIMGroupInfoResult[]) => {
        writeResult('getGroupsInfo succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('getGroupsInfo failed', error);
      });
  }

  static setGroupInfo() {
    const info: V2TIMSetGroupInfoParam = {
      groupID: groupInfo.groupID4,
      groupName: groupInfo.groupID4,
      groupAddOpt: groupInfo.groupAddOpt,
      groupApproveOpt: groupInfo.groupApproveOpt,
    };
    V2TIMManager.getGroupManager().setGroupInfo(info)
      .then(() => {
        writeResult('setGroupInfo succeeded');
      })
      .catch((error: Error) => {
        writeResult('setGroupInfo failed', error);
      });
  }

  static initGroupAttributes() {
    let attributes = new Map<string, string>([
      ['counter1', "1"],
      ['counter2', "2"],
      ['counter3', "3"]
    ]);

    V2TIMManager.getGroupManager().initGroupAttributes(groupInfo.groupID5, attributes)
      .then(() => {
        writeResult('initGroupAttributes succeeded');
      })
      .catch((error: Error) => {
        writeResult('initGroupAttributes failed', error);
      });
  }

  static setGroupAttributes() {
    let attributes = new Map<string, string>([
      ['counter1', "333"],
      ['counter2', "2222"],
      ['counter3', "3333"]
    ]);

    V2TIMManager.getGroupManager().setGroupAttributes(groupInfo.groupID5, attributes)
      .then(() => {
        writeResult('setGroupAttributes succeeded');
      })
      .catch((error: Error) => {
        writeResult('setGroupAttributes failed', error);
      });
  }

  static deleteGroupAttributes() {
    V2TIMManager.getGroupManager().deleteGroupAttributes(groupInfo.groupID5, ["counter1", "counter2"])
      .then(() => {
        writeResult('deleteGroupAttributes succeeded');
      })
      .catch((error: Error) => {
        writeResult('deleteGroupAttributes failed', error);
      });
  }

  static getGroupAttributes() {
    V2TIMManager.getGroupManager().getGroupAttributes(groupInfo.groupID5, ["counter1", "counter2"])
      .then((resultMap: Map<string, string>) => {
        writeResult('getGroupAttributes succeeded', resultMap);
      })
      .catch((error: Error) => {
        writeResult('getGroupAttributes failed', error);
      });
  }

  static getGroupOnlineMemberCount() {
    V2TIMManager.getGroupManager().getGroupOnlineMemberCount(groupInfo.groupID5)
      .then((result: Number) => {
        writeResult('getGroupOnlineMemberCount succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getGroupOnlineMemberCount failed', error);
      });
  }

  static setGroupCounters() {
    let counters = new Map<string, number>([
      ['counter1', 0],
      ['counter2', 0],
      ['counter3', 0]
    ]);
    V2TIMManager.getGroupManager().setGroupCounters(groupInfo.groupID5, counters)
      .then((resultMap: Map<string, number>) => {
        writeResult('setGroupCounters succeeded', resultMap);
      })
      .catch((error: Error) => {
        writeResult('setGroupCounters failed', error);
      });
  }

  static getGroupCounters() {
    V2TIMManager.getGroupManager().getGroupCounters(groupInfo.groupID5, ["counter1", "counter2"])
      .then((resultMap: Map<string, number>) => {
        writeResult('getGroupCounters succeeded', resultMap);
      })
      .catch((error: Error) => {
        writeResult('getGroupCounters failed', error);
      });
  }

  static increaseGroupCounter() {
    V2TIMManager.getGroupManager().increaseGroupCounter(groupInfo.groupID5, "counter1", 2)
      .then((resultMap: Map<string, number>) => {
        writeResult('increaseGroupCounter succeeded', resultMap);
      })
      .catch((error: Error) => {
        writeResult('increaseGroupCounter failed', error);
      });
  }

  static decreaseGroupCounter() {
    V2TIMManager.getGroupManager().decreaseGroupCounter(groupInfo.groupID5, "counter1", 1)
      .then((resultMap: Map<string, number>) => {
        writeResult('decreaseGroupCounter succeeded', resultMap);
      })
      .catch((error: Error) => {
        writeResult('decreaseGroupCounter failed', error);
      });
  }

  static getGroupMemberList() {
    V2TIMManager.getGroupManager()
      .getGroupMemberList(groupInfo.groupID6, groupInfo.getGroupMemberListFilter, groupInfo.nextSeq)
      .then((result: V2TIMGroupMemberInfoResult) => {
        writeResult('getGroupMemberList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getGroupMemberList failed', error);
      });
  }

  static inviteUserToGroup() {
    V2TIMManager.getGroupManager().inviteUserToGroup(groupInfo.groupID7, [groupInfo.userID7, groupInfo.userID8])
      .then((resultList: V2TIMGroupMemberOperationResult[]) => {
        writeResult('inviteUserToGroup succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('inviteUserToGroup failed', error);
      });
  }

  static getGroupMembersInfo() {
    V2TIMManager.getGroupManager().getGroupMembersInfo(groupInfo.groupID7, [groupInfo.userID7, groupInfo.userID8])
      .then((info_list: V2TIMGroupMemberFullInfo[]) => {
        writeResult('getGroupMembersInfo succeeded', info_list);
      })
      .catch((error: Error) => {
        writeResult('getGroupMembersInfo failed', error);
      });
  }

  static kickGroupMember() {
    V2TIMManager.getGroupManager()
      .kickGroupMember(groupInfo.groupID7, [groupInfo.userID7, groupInfo.userID8], { reason: "踢人原因 111" })
      .then((resultList: V2TIMGroupMemberOperationResult[]) => {
        writeResult('kickGroupMember succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('kickGroupMember failed', error);
      });
  }

  static setGroupMemberInfo() {
    const info: V2TIMSetGroupMemberInfo = {
      userID: groupInfo.userID9,
      nameCard: groupInfo.nameCard,
    };
    V2TIMManager.getGroupManager().setGroupMemberInfo(groupInfo.groupID9, info)
      .then(() => {
        writeResult('setGroupMemberInfo succeeded');
      })
      .catch((error: Error) => {
        writeResult('setGroupMemberInfo failed', error);
      });
  }

  static muteGroupMember() {
    V2TIMManager.getGroupManager().muteGroupMember(groupInfo.groupID10, groupInfo.userID10, groupInfo.seconds)
      .then(() => {
        writeResult('muteGroupMember succeeded');
      })
      .catch((error: Error) => {
        writeResult('muteGroupMember failed', error);
      });
  }

  static setGroupMemberRole() {
    V2TIMManager.getGroupManager().setGroupMemberRole(groupInfo.groupID11, groupInfo.userID11, groupInfo.role)
      .then(() => {
        writeResult('setGroupMemberRole succeeded');
      })
      .catch((error: Error) => {
        writeResult('setGroupMemberRole failed', error);
      });
  }

  static markGroupMemberList() {
    V2TIMManager.getGroupManager()
      .markGroupMemberList(groupInfo.groupID12, [groupInfo.userID12, groupInfo.userID13], groupInfo.markType, groupInfo.enableMark)
      .then(() => {
        writeResult('markGroupMemberList succeeded');
      })
      .catch((error: Error) => {
        writeResult('markGroupMemberList failed', error);
      });
  }

  static transferGroupOwner() {
    V2TIMManager.getGroupManager().transferGroupOwner(groupInfo.groupID14, groupInfo.userID14)
      .then(() => {
        writeResult('transferGroupOwner succeeded');
      })
      .catch((error: Error) => {
        writeResult('transferGroupOwner failed', error);
      });
  }

  static getGroupApplicationList() {
    V2TIMManager.getGroupManager().getGroupApplicationList()
      .then((result: V2TIMGroupApplicationResult) => {
        writeResult('getGroupApplicationList succeeded', result);
        if (result.applicationList) {
          groupInfo.groupApplication = result.applicationList;
        }
      })
      .catch((error: Error) => {
        writeResult('getGroupApplicationList failed', error);
      });
  }

  static setGroupApplicationRead() {
    V2TIMManager.getGroupManager().setGroupApplicationRead()
      .then(() => {
        writeResult('setGroupApplicationRead succeeded');
      })
      .catch((error: Error) => {
        writeResult('setGroupApplicationRead failed', error);
      });
  }

  static acceptGroupApplication() {
    if (groupInfo.groupApplication.length <= 0) {
      Prompt.showToast({ message: "请先获取加群申请" });
    }
    let application = groupInfo.groupApplication[0];
    V2TIMManager.getGroupManager().acceptGroupApplication(application, "同意 111")
      .then(() => {
        writeResult('setGroupApplicationRead succeeded');
      })
      .catch((error: Error) => {
        writeResult('setGroupApplicationRead failed', error);
      });
  }

  static refuseGroupApplication() {
    if (groupInfo.groupApplication.length <= 0) {
      Prompt.showToast({ message: "请先获取加群申请" });
    }
    let application = groupInfo.groupApplication[0];
    V2TIMManager.getGroupManager().refuseGroupApplication(application, "拒绝 111")
      .then(() => {
        writeResult('setGroupApplicationRead succeeded');
      })
      .catch((error: Error) => {
        writeResult('setGroupApplicationRead failed', error);
      });
  }

  static createTopicInCommunity() {
    const topicSuffix = "TOPIC_111";
    let topicInfo = new V2TIMTopicInfo();
    topicInfo.topicID = `@TGS#_@TGS#cQORJIIM62C4@TOPIC#_${topicSuffix}`;
    topicInfo.topicName = "32145";
    topicInfo.topicFaceURL = "32145";
    V2TIMManager.getCommunityManager().createTopicInCommunity(groupInfo.communityGroupID, topicInfo)
      .then((result: string) => {
        writeResult('createTopicInCommunity succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('createTopicInCommunity failed', error);
      });
  }

  static deleteTopicFromCommunity() {
    const topicSuffix = "TOPIC_111";
    let topicID = `@TGS#_@TGS#cQORJIIM62C4@TOPIC#_${topicSuffix}`;
    V2TIMManager.getCommunityManager().deleteTopicFromCommunity(groupInfo.communityGroupID, [topicID])
      .then((resultList: V2TIMTopicOperationResult[]) => {
        writeResult('deleteTopicFromCommunity succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('deleteTopicFromCommunity failed', error);
      });
  }

  static setTopicInfo() {
    const topicSuffix = "TOPIC_111";
    let topicInfo = new V2TIMTopicInfo();
    topicInfo.topicID = `@TGS#_@TGS#cQORJIIM62C4@TOPIC#_${topicSuffix}`;
    topicInfo.topicName = "321111";
    topicInfo.topicFaceURL = "321111";
    V2TIMManager.getCommunityManager().setTopicInfo(topicInfo)
      .then(() => {
        writeResult('setTopicInfo succeeded');
      })
      .catch((error: Error) => {
        writeResult('setTopicInfo failed', error);
      });
  }

  static getTopicInfoList() {
    const topicSuffix = "TOPIC_111";
    let topicID = `@TGS#_@TGS#cQORJIIM62C4@TOPIC#_${topicSuffix}`;
    V2TIMManager.getCommunityManager().getTopicInfoList(groupInfo.communityGroupID, [topicID])
      .then((resultList: V2TIMTopicInfoResult[]) => {
        writeResult('getTopicInfoList succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('getTopicInfoList failed', error);
      });
  }

  static pinGroupMessage() {
    const testgroup = "three";
    let message = V2TIMManager.getMessageManager().createTextMessage("text");
    message.seq = 10;
    V2TIMManager.getMessageManager().pinGroupMessage(testgroup, message, true)
      .then(() => {
        writeResult('pinGroupMessage succeeded');
      })
      .catch((error: Error) => {
        writeResult('pinGroupMessage failed', error);
      });
  }

  static unpinGroupMessage() {
    const testgroup = "three";
    let message = V2TIMManager.getMessageManager().createTextMessage("text");
    message.seq = 10;
    V2TIMManager.getMessageManager().pinGroupMessage(testgroup, message, false)
      .then(() => {
        writeResult('unpinGroupMessage succeeded');
      })
      .catch((error: Error) => {
        writeResult('unpinGroupMessage failed', error);
      });
  }

  static getPinedGroupMessageList() {
    const testgroup = "three";
    V2TIMManager.getMessageManager().getPinnedGroupMessageList(testgroup)
      .then((messageList: V2TIMMessage[]) => {
        writeResult('getPinedGroupMessageList succeeded', messageList[0].seq);
      })
      .catch((error: Error) => {
        writeResult('getPinedGroupMessageList failed', error);
      });
  }
}
