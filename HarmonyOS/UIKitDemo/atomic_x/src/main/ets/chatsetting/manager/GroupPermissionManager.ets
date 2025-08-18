import { GroupType, GroupMemberRole } from 'chatengine';
export enum GroupPermission {
  SET_GROUP_NAME = 'setGroupName', 
  SET_GROUP_AVATAR = 'setGroupAvatar', 
  SEND_MESSAGE = 'sendMessage', // Send message
  SET_DO_NOT_DISTURB = 'setDoNotDisturb', 
  PIN_GROUP = 'pinGroup', 
  SET_GROUP_NOTICE = 'setGroupNotice', 
  SET_GROUP_MANAGEMENT = 'setGroupManagement', 
  GET_GROUP_TYPE = 'getGroupType', 
  SET_JOIN_GROUP_APPROVAL_TYPE = 'setJoinGroupApprovalType', 
  SET_INVITE_TO_GROUP_APPROVAL_TYPE = 'setInviteToGroupApprovalType', 
  SET_GROUP_REMARK = 'setGroupRemark', 
  SET_BACKGROUND = 'setBackground', 
  GET_GROUP_MEMBER_LIST = 'getGroupMemberList', 
  SET_GROUP_MEMBER_ROLE = 'setGroupMemberRole', 
  GET_GROUP_MEMBER_INFO = 'getGroupMemberInfo', 
  REMOVE_GROUP_MEMBER = 'removeGroupMember', 
  ADD_GROUP_MEMBER = 'addGroupMember', 
  CLEAR_HISTORY_MESSAGES = 'clearHistoryMessages', 
  DELETE_AND_QUIT = 'deleteAndQuit', 
  TRANSFER_OWNER = 'transferOwner', 
  DISMISS_GROUP = 'dismissGroup', 
  REPORT_GROUP = 'reportGroup' 
}
interface PermissionMap {
  setGroupName: boolean;
  setGroupAvatar: boolean;
  sendMessage: boolean;
  setDoNotDisturb: boolean;
  pinGroup: boolean;
  setGroupNotice: boolean;
  setGroupManagement: boolean;
  getGroupType: boolean;
  setJoinGroupApprovalType: boolean;
  setInviteToGroupApprovalType: boolean;
  setGroupRemark: boolean;
  setBackground: boolean;
  getGroupMemberList: boolean;
  setGroupMemberRole: boolean;
  getGroupMemberInfo: boolean;
  removeGroupMember: boolean;
  addGroupMember: boolean;
  clearHistoryMessages: boolean;
  deleteAndQuit: boolean;
  transferOwner: boolean;
  dismissGroup: boolean;
  reportGroup: boolean;
}
export class GroupPermissionManager {
  
  private static readonly permissionMatrix = GroupPermissionManager.buildPermissionMatrix();

  
  public static hasPermission(
    groupType: GroupType,
    memberRole: GroupMemberRole,
    permission: GroupPermission
  ): boolean {
    const groupRoleMap = GroupPermissionManager.permissionMatrix.get(groupType);
    if (!groupRoleMap) {
      return false;
    }

    const permissionMap = groupRoleMap.get(memberRole);
    if (!permissionMap) {
      return false;
    }

    return GroupPermissionManager.getPermissionValue(permissionMap, permission);
  }

  
  public static getAvailablePermissions(
    groupType: GroupType,
    memberRole: GroupMemberRole
  ): GroupPermission[] {
    const groupRoleMap = GroupPermissionManager.permissionMatrix.get(groupType);
    if (!groupRoleMap) {
      return [];
    }

    const permissionMap = groupRoleMap.get(memberRole);
    if (!permissionMap) {
      return [];
    }

    const availablePermissions: GroupPermission[] = [];

    
    const allPermissions = [
      GroupPermission.SET_GROUP_NAME,
      GroupPermission.SET_GROUP_AVATAR,
      GroupPermission.SEND_MESSAGE,
      GroupPermission.SET_DO_NOT_DISTURB,
      GroupPermission.PIN_GROUP,
      GroupPermission.SET_GROUP_NOTICE,
      GroupPermission.SET_GROUP_MANAGEMENT,
      GroupPermission.GET_GROUP_TYPE,
      GroupPermission.SET_JOIN_GROUP_APPROVAL_TYPE,
      GroupPermission.SET_INVITE_TO_GROUP_APPROVAL_TYPE,
      GroupPermission.SET_GROUP_REMARK,
      GroupPermission.SET_BACKGROUND,
      GroupPermission.GET_GROUP_MEMBER_LIST,
      GroupPermission.SET_GROUP_MEMBER_ROLE,
      GroupPermission.GET_GROUP_MEMBER_INFO,
      GroupPermission.REMOVE_GROUP_MEMBER,
      GroupPermission.ADD_GROUP_MEMBER,
      GroupPermission.CLEAR_HISTORY_MESSAGES,
      GroupPermission.DELETE_AND_QUIT,
      GroupPermission.TRANSFER_OWNER,
      GroupPermission.DISMISS_GROUP,
      GroupPermission.REPORT_GROUP
    ];

    for (let i = 0; i < allPermissions.length; i++) {
      const permission = allPermissions[i];
      if (GroupPermissionManager.getPermissionValue(permissionMap, permission)) {
        availablePermissions.push(permission);
      }
    }

    return availablePermissions;
  }

  
  public static canPerformAction(
    groupType: GroupType,
    memberRole: GroupMemberRole,
    action: GroupPermission
  ): boolean {
    return GroupPermissionManager.hasPermission(groupType, memberRole, action);
  }

  
  private static buildPermissionMatrix(): Map<GroupType, Map<GroupMemberRole, PermissionMap>> {
    const matrix = new Map<GroupType, Map<GroupMemberRole, PermissionMap>>();

    
    const workGroupMap = new Map<GroupMemberRole, PermissionMap>();
    workGroupMap.set(GroupMemberRole.OWNER, {
      setGroupName: true,
      setGroupAvatar: true,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: true,
      setInviteToGroupApprovalType: true,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: true,
      addGroupMember: true,
      clearHistoryMessages: true,
      deleteAndQuit: true,
      transferOwner: true,
      dismissGroup: false,
      reportGroup: true
    });
    workGroupMap.set(GroupMemberRole.ADMIN, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: false,
      setGroupManagement: false,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: false,
      addGroupMember: true,
      clearHistoryMessages: true,
      deleteAndQuit: true,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    workGroupMap.set(GroupMemberRole.MEMBER, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: false,
      setGroupManagement: false,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: false,
      addGroupMember: true,
      clearHistoryMessages: true,
      deleteAndQuit: true,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    matrix.set(GroupType.WORK, workGroupMap);

    
    const publicGroupMap = new Map<GroupMemberRole, PermissionMap>();
    publicGroupMap.set(GroupMemberRole.OWNER, {
      setGroupName: true,
      setGroupAvatar: true,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: true,
      setInviteToGroupApprovalType: true,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: true,
      getGroupMemberInfo: true,
      removeGroupMember: true,
      addGroupMember: true,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: true,
      dismissGroup: true,
      reportGroup: true
    });
    publicGroupMap.set(GroupMemberRole.ADMIN, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: true,
      setInviteToGroupApprovalType: true,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: true,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    publicGroupMap.set(GroupMemberRole.MEMBER, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: false,
      setGroupManagement: false,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: false,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    matrix.set(GroupType.PUBLIC, publicGroupMap);

    
    const meetingGroupMap = new Map<GroupMemberRole, PermissionMap>();
    meetingGroupMap.set(GroupMemberRole.OWNER, {
      setGroupName: true,
      setGroupAvatar: true,
      sendMessage: true,
      setDoNotDisturb: false,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: true,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: true,
      getGroupMemberInfo: true,
      removeGroupMember: true,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: true,
      dismissGroup: true,
      reportGroup: true
    });
    meetingGroupMap.set(GroupMemberRole.ADMIN, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: false,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: true,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: true,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    meetingGroupMap.set(GroupMemberRole.MEMBER, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: false,
      pinGroup: true,
      setGroupNotice: false,
      setGroupManagement: false,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: false,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    matrix.set(GroupType.MEETING, meetingGroupMap);

    
    const communityGroupMap = new Map<GroupMemberRole, PermissionMap>();
    communityGroupMap.set(GroupMemberRole.OWNER, {
      setGroupName: true,
      setGroupAvatar: true,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: true,
      setInviteToGroupApprovalType: true,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: true,
      getGroupMemberInfo: true,
      removeGroupMember: true,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: true,
      dismissGroup: true,
      reportGroup: true
    });
    communityGroupMap.set(GroupMemberRole.ADMIN, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: true,
      setInviteToGroupApprovalType: true,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: true,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    communityGroupMap.set(GroupMemberRole.MEMBER, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: false,
      setGroupManagement: false,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: true,
      setGroupMemberRole: false,
      getGroupMemberInfo: true,
      removeGroupMember: false,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    matrix.set(GroupType.COMMUNITY, communityGroupMap);

    
    const avChatRoomMap = new Map<GroupMemberRole, PermissionMap>();
    avChatRoomMap.set(GroupMemberRole.OWNER, {
      setGroupName: true,
      setGroupAvatar: true,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: true,
      setGroupManagement: true,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: false,
      setGroupMemberRole: false,
      getGroupMemberInfo: false,
      removeGroupMember: false,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    avChatRoomMap.set(GroupMemberRole.ADMIN, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: false,
      setGroupManagement: false,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: false,
      setGroupMemberRole: false,
      getGroupMemberInfo: false,
      removeGroupMember: false,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    avChatRoomMap.set(GroupMemberRole.MEMBER, {
      setGroupName: false,
      setGroupAvatar: false,
      sendMessage: true,
      setDoNotDisturb: true,
      pinGroup: true,
      setGroupNotice: false,
      setGroupManagement: false,
      getGroupType: true,
      setJoinGroupApprovalType: false,
      setInviteToGroupApprovalType: false,
      setGroupRemark: true,
      setBackground: true,
      getGroupMemberList: false,
      setGroupMemberRole: false,
      getGroupMemberInfo: false,
      removeGroupMember: false,
      addGroupMember: false,
      clearHistoryMessages: true,
      deleteAndQuit: false,
      transferOwner: false,
      dismissGroup: false,
      reportGroup: true
    });
    matrix.set(GroupType.AVCHATROOM, avChatRoomMap);

    return matrix;
  }

  
  private static getPermissionValue(permissionMap: PermissionMap, permission: GroupPermission): boolean {
    switch (permission) {
      case GroupPermission.SET_GROUP_NAME:
        return permissionMap.setGroupName;
      case GroupPermission.SET_GROUP_AVATAR:
        return permissionMap.setGroupAvatar;
      case GroupPermission.SEND_MESSAGE:
        return permissionMap.sendMessage;
      case GroupPermission.SET_DO_NOT_DISTURB:
        return permissionMap.setDoNotDisturb;
      case GroupPermission.PIN_GROUP:
        return permissionMap.pinGroup;
      case GroupPermission.SET_GROUP_NOTICE:
        return permissionMap.setGroupNotice;
      case GroupPermission.SET_GROUP_MANAGEMENT:
        return permissionMap.setGroupManagement;
      case GroupPermission.GET_GROUP_TYPE:
        return permissionMap.getGroupType;
      case GroupPermission.SET_JOIN_GROUP_APPROVAL_TYPE:
        return permissionMap.setJoinGroupApprovalType;
      case GroupPermission.SET_INVITE_TO_GROUP_APPROVAL_TYPE:
        return permissionMap.setInviteToGroupApprovalType;
      case GroupPermission.SET_GROUP_REMARK:
        return permissionMap.setGroupRemark;
      case GroupPermission.SET_BACKGROUND:
        return permissionMap.setBackground;
      case GroupPermission.GET_GROUP_MEMBER_LIST:
        return permissionMap.getGroupMemberList;
      case GroupPermission.SET_GROUP_MEMBER_ROLE:
        return permissionMap.setGroupMemberRole;
      case GroupPermission.GET_GROUP_MEMBER_INFO:
        return permissionMap.getGroupMemberInfo;
      case GroupPermission.REMOVE_GROUP_MEMBER:
        return permissionMap.removeGroupMember;
      case GroupPermission.ADD_GROUP_MEMBER:
        return permissionMap.addGroupMember;
      case GroupPermission.CLEAR_HISTORY_MESSAGES:
        return permissionMap.clearHistoryMessages;
      case GroupPermission.DELETE_AND_QUIT:
        return permissionMap.deleteAndQuit;
      case GroupPermission.TRANSFER_OWNER:
        return permissionMap.transferOwner;
      case GroupPermission.DISMISS_GROUP:
        return permissionMap.dismissGroup;
      case GroupPermission.REPORT_GROUP:
        return permissionMap.reportGroup;
      default:
        return false;
    }
  }
} 