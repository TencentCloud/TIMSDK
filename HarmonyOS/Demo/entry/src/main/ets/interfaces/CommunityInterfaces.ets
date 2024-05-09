import {
  V2TIMCommunityListener,
  V2TIMManager,
  V2TIMTopicInfo,
  V2TIMPermissionGroupInfo,
  V2TIMGroupType,
  V2TIMCreateGroupInfo,
  V2TIMCreateGroupMemberInfo,
  V2TIMGroupInfo,
  V2TIMTopicOperationResult,
  V2TIMTopicInfoResult,
  CreatePermissionGroupInCommunityParam,
  V2TIMPermissionGroupOperationResult,
  ModifyPermissionGroupInfoInCommunityParam,
  V2TIMPermissionGroupInfoResult,
  V2TIMPermissionGroupMemberOperationResult,
  V2TIMPermissionGroupMemberInfoResult,
  V2TIMTopicPermissionResult,
} from '@tencentcloud/imsdk';
import Prompt from '@system.prompt';

import { writeResult, onCallback } from "../pages/CommunityManagerTestPage"

export class CommunityInfos {
  groupType = V2TIMGroupType.Community;
  groupName = "groupName";
  communityGroupID = "communityGroupID";
  notification = "notification";
  introduction = "introduction";
  faceURL = "faceURL";
  userID1 = "userID1";
  userID2 = "userID2";
  permissionGroupID = "permissionGroupID";
  permissionGroupName = "permissionGroupName";
  customData = "customData";
  groupPermission = 0;
  permissionGroupID1 = "permissionGroupID1";
  permissionGroupID2 = "permissionGroupID2";
  topicPermissionMapKey1 = "topicPermissionMapKey1";
  topicPermissionMapKey2 = "topicPermissionMapKey2";
  topicPermissionMapValue1 = 0;
  topicPermissionMapValue2 = 0;
}

export let communityInfo = new CommunityInfos();

export class CommunityTestInterfaces {

  static addCommunityListener() {
    V2TIMManager.getCommunityManager().addCommunityListener(communityListener);
    Prompt.showToast({ message: "addCommunityListener" });
  }

  static removeCommunityListener() {
    V2TIMManager.getCommunityManager().removeCommunityListener(communityListener);
    Prompt.showToast({ message: "removeCommunityListener" });
  }

  static createCommunity() {
    const info: V2TIMCreateGroupInfo = {
      groupType: communityInfo.groupType,
      groupName: communityInfo.groupName,
      groupID: communityInfo.communityGroupID,
      notification: communityInfo.notification,
      introduction: communityInfo.introduction,
      faceURL: communityInfo.faceURL,
    };
    const memberList: V2TIMCreateGroupMemberInfo[] = [
      { userID: communityInfo.userID1, },
      { userID: communityInfo.userID2 },
    ];
    V2TIMManager.getCommunityManager().createCommunity(info, memberList)
      .then((groupID: string) => {
        writeResult('createCommunity succeeded', groupID);
      })
      .catch((error: Error) => {
        writeResult('createCommunity failed', error);
      });
  }

  static getJoinedCommunityList() {
    V2TIMManager.getCommunityManager().getJoinedCommunityList()
      .then((infoList: V2TIMGroupInfo[]) => {
        writeResult('createCommunity succeeded', infoList);
      })
      .catch((error: Error) => {
        writeResult('createCommunity failed', error);
      });
  }

  static createTopicInCommunity() {
    const topicSuffix = "TOPIC_111";
    let topicInfo = new V2TIMTopicInfo();
    topicInfo.topicID = `@TGS#_@TGS#cQORJIIM62C4@TOPIC#_${topicSuffix}`;
    topicInfo.topicName = "32145";
    topicInfo.topicFaceURL = "32145";
    V2TIMManager.getCommunityManager().createTopicInCommunity(communityInfo.communityGroupID, topicInfo)
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
    V2TIMManager.getCommunityManager().deleteTopicFromCommunity(communityInfo.communityGroupID, [topicID])
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
    V2TIMManager.getCommunityManager().getTopicInfoList(communityInfo.communityGroupID, [topicID])
      .then((resultList: V2TIMTopicInfoResult[]) => {
        writeResult('getTopicInfoList succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('getTopicInfoList failed', error);
      });
  }

  static createPermissionGroupInCommunity() {
    const info: CreatePermissionGroupInCommunityParam = {
      groupID: communityInfo.communityGroupID,
      permissionGroupID: communityInfo.permissionGroupID,
      permissionGroupName: communityInfo.permissionGroupName,
      customData: communityInfo.customData,
      groupPermission: communityInfo.groupPermission,
    }
    V2TIMManager.getCommunityManager().createPermissionGroupInCommunity(info)
      .then((result: string) => {
        writeResult('createPermissionGroupInCommunity succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('createPermissionGroupInCommunity failed', error);
      });
  }

  static deletePermissionGroupFromCommunity() {
    V2TIMManager.getCommunityManager().deletePermissionGroupFromCommunity(communityInfo.communityGroupID, [communityInfo.permissionGroupID1, communityInfo.permissionGroupID2])
      .then((resultList: V2TIMPermissionGroupOperationResult[]) => {
        writeResult('deletePermissionGroupFromCommunity succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('deletePermissionGroupFromCommunity failed', error);
      });
  }

  static modifyPermissionGroupInfoInCommunity() {
    const info: ModifyPermissionGroupInfoInCommunityParam = {
      groupID: communityInfo.communityGroupID,
      permissionGroupID: communityInfo.permissionGroupID,
      permissionGroupName: communityInfo.permissionGroupName,
      customData: communityInfo.customData,
      groupPermission: communityInfo.groupPermission,
    }
    V2TIMManager.getCommunityManager().modifyPermissionGroupInfoInCommunity(info)
      .then(() => {
        writeResult('modifyPermissionGroupInfoInCommunity succeeded');
      })
      .catch((error: Error) => {
        writeResult('modifyPermissionGroupInfoInCommunity failed', error);
      });
  }

  static getJoinedPermissionGroupListInCommunity() {
    V2TIMManager.getCommunityManager().getJoinedPermissionGroupListInCommunity(communityInfo.communityGroupID)
      .then((resultList: V2TIMPermissionGroupInfoResult[]) => {
        writeResult('getJoinedPermissionGroupListInCommunity succeeded', resultList);
      })
       .catch((error: Error) => {
        writeResult('getJoinedPermissionGroupListInCommunity failed', error);
      });
  }

  static getPermissionGroupListInCommunity() {
    V2TIMManager.getCommunityManager().getPermissionGroupListInCommunity(communityInfo.communityGroupID, [communityInfo.permissionGroupID1, communityInfo.permissionGroupID2])
      .then((resultList: V2TIMPermissionGroupInfoResult[]) => {
        writeResult('getPermissionGroupListInCommunity succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('getPermissionGroupListInCommunity failed', error);
      });
  }

  static addCommunityMembersToPermissionGroup() {
    V2TIMManager.getCommunityManager().addCommunityMembersToPermissionGroup(communityInfo.communityGroupID, communityInfo.permissionGroupID, [communityInfo.userID1, communityInfo.userID2])
      .then((resultList: V2TIMPermissionGroupMemberOperationResult[]) => {
        writeResult('addCommunityMembersToPermissionGroup succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('addCommunityMembersToPermissionGroup failed', error);
      });
  }

  static removeCommunityMembersFromPermissionGroup() {
    V2TIMManager.getCommunityManager().removeCommunityMembersFromPermissionGroup(communityInfo.communityGroupID, communityInfo.permissionGroupID, [communityInfo.userID1, communityInfo.userID2])
      .then((resultList: V2TIMPermissionGroupMemberOperationResult[]) => {
        writeResult('removeCommunityMembersFromPermissionGroup succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('removeCommunityMembersFromPermissionGroup failed', error);
      });
  }

  static getCommunityMemberListInPermissionGroup() {
    V2TIMManager.getCommunityManager().getCommunityMemberListInPermissionGroup(communityInfo.communityGroupID, communityInfo.permissionGroupID, "")
      .then((result: V2TIMPermissionGroupMemberInfoResult) => {
        writeResult('getCommunityMemberListInPermissionGroup succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getCommunityMemberListInPermissionGroup failed', error);
      });
  }

  static addTopicPermissionToPermissionGroup() {
    let topicPermissionMap = new Map<string, number>([
      [communityInfo.topicPermissionMapKey1, communityInfo.topicPermissionMapValue1],
      [communityInfo.topicPermissionMapKey2, communityInfo.topicPermissionMapValue2],
    ]);
    V2TIMManager.getCommunityManager().addTopicPermissionToPermissionGroup(communityInfo.communityGroupID, communityInfo.permissionGroupID, topicPermissionMap)
      .then((resultList: V2TIMTopicOperationResult[]) => {
        writeResult('addTopicPermissionToPermissionGroup succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('addTopicPermissionToPermissionGroup failed', error);
      });
  }

  static deleteTopicPermissionFromPermissionGroup() {
    V2TIMManager.getCommunityManager().deleteTopicPermissionFromPermissionGroup(communityInfo.communityGroupID, communityInfo.permissionGroupID, [])
      .then((resultList: V2TIMTopicOperationResult[]) => {
        writeResult('deleteTopicPermissionFromPermissionGroup succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('deleteTopicPermissionFromPermissionGroup failed', error);
      });
  }

  static modifyTopicPermissionInPermissionGroup() {
    let topicPermissionMap = new Map<string, number>([
      [communityInfo.topicPermissionMapKey1, communityInfo.topicPermissionMapValue1],
      [communityInfo.topicPermissionMapKey2, communityInfo.topicPermissionMapValue2],
    ]);
    V2TIMManager.getCommunityManager().modifyTopicPermissionInPermissionGroup(communityInfo.communityGroupID, communityInfo.permissionGroupID, topicPermissionMap)
      .then((resultList: V2TIMTopicOperationResult[]) => {
        writeResult('modifyTopicPermissionInPermissionGroup succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('modifyTopicPermissionInPermissionGroup failed', error);
      });
  }

  static getTopicPermissionInPermissionGroup() {
    V2TIMManager.getCommunityManager().getTopicPermissionInPermissionGroup(communityInfo.communityGroupID, communityInfo.permissionGroupID, [])
      .then((resultList: V2TIMTopicPermissionResult[]) => {
        writeResult('getTopicPermissionInPermissionGroup succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('getTopicPermissionInPermissionGroup failed', error);
      });
  }
}

const communityListener: V2TIMCommunityListener = {
  onCreateTopic: (groupID: string, TopicID: string) => {
    onCallback('onCreateTopic', groupID, TopicID);
  },
  onDeleteTopic: (groupID: string, topicIDList: string) => {
    onCallback('onDeleteTopic', groupID, topicIDList);
  },
  onChangeTopicInfo: (groupID: string, topicInfo: V2TIMTopicInfo) => {
    onCallback('onChangeTopicInfo', groupID, topicInfo);
  },
  onReceiveTopicRESTCustomData: (topicID: string, customData: ArrayBuffer) => {
    onCallback('onReceiveTopicRESTCustomData', topicID, customData);
  },
  onCreatePermissionGroup: (groupID: string, permissionGroupInfo: V2TIMPermissionGroupInfo) => {
    onCallback('onCreatePermissionGroup', groupID, permissionGroupInfo);
  },
  onDeletePermissionGroup: (groupID: string, permissionGroupIDList: string[]) => {
    onCallback('onDeletePermissionGroup', groupID, permissionGroupIDList);
  },
  onChangePermissionGroupInfo: (groupID: string, permissionGroupInfo: V2TIMPermissionGroupInfo) => {
    onCallback('onChangePermissionGroupInfo', groupID, permissionGroupInfo);
  },
  onAddMembersToPermissionGroup: (groupID: string, permissionGroupID: string, memberIDList: string[]) => {
    onCallback('onAddMembersToPermissionGroup', groupID, permissionGroupID, memberIDList);
  },
  onRemoveMembersFromPermissionGroup: (groupID: string, permissionGroupID: string, memberIDList: string[]) => {
    onCallback('onRemoveMembersFromPermissionGroup', groupID, permissionGroupID, memberIDList);
  },
  onAddTopicPermission: (groupID: string, permissionGroupID: string, topicPermissionMap: Map<string, number>) => {
    onCallback('onAddTopicPermission', groupID, permissionGroupID, topicPermissionMap);
  },
  onDeleteTopicPermission: (groupID: string, permissionGroupID: string, topicIDList: string[]) => {
    onCallback('onDeleteTopicPermission', groupID, permissionGroupID, topicIDList);
  },
  onModifyTopicPermission: (groupID: string, permissionGroupID: string, topicPermissionMap: Map<string, number>) => {
    onCallback('onModifyTopicPermission', groupID, permissionGroupID, topicPermissionMap);
  },
};