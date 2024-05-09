import { V2TIMGroupMessageReadMembersFilter, V2TIMConversationType, V2TIMReceiveMessageOpt, V2TIMMessagePriority, V2TIMGroupType, V2TIMFriendAllowType, V2TIMGroupAddOpt, V2TIMGroupMemberRole, V2TIMMessageGetType } from "@tencentcloud/imsdk";

// TODO(hiliu): 在 ArkTS 支持反射后，删掉这个文件

export function getEnumKeys(enumName: string): Array<{ value: string }> {
  switch (enumName) {
    case "V2TIMMessagePriority":
      return _getEnumKeys(V2TIMMessagePriority);
    case "V2TIMGroupType":
      return _getEnumKeys(V2TIMGroupType);
    case "V2TIMFriendAllowType":
      return _getEnumKeys(V2TIMFriendAllowType);
    case "V2TIMGroupAddOpt":
      return _getEnumKeys(V2TIMGroupAddOpt);
    case "V2TIMGroupMemberRole":
      return _getEnumKeys(V2TIMGroupMemberRole);
    case "V2TIMMessageGetType":
      return _getEnumKeys(V2TIMMessageGetType);
    case "V2TIMReceiveMessageOpt":
      return _getEnumKeys(V2TIMReceiveMessageOpt);
    case "V2TIMConversationType":
      return _getEnumKeys(V2TIMConversationType);
    case "V2TIMGroupMessageReadMembersFilter":
      return _getEnumKeys(V2TIMGroupMessageReadMembersFilter);
  }
}

export function getEnumMap(enumName: string): Map<string, number> {
  switch (enumName) {
    case "V2TIMMessagePriority":
      return _getEnumMap(V2TIMMessagePriority);
    case "V2TIMGroupType":
      return _getEnumMap(V2TIMGroupType);
    case "V2TIMFriendAllowType":
      return _getEnumMap(V2TIMFriendAllowType);
    case "V2TIMGroupAddOpt":
      return _getEnumMap(V2TIMGroupAddOpt);
    case "V2TIMGroupMemberRole":
      return _getEnumMap(V2TIMGroupMemberRole);
    case "V2TIMMessageGetType":
      return _getEnumMap(V2TIMMessageGetType);
    case "V2TIMReceiveMessageOpt":
      return _getEnumMap(V2TIMReceiveMessageOpt);
    case "V2TIMConversationType":
      return _getEnumMap(V2TIMConversationType);
    case "V2TIMGroupMessageReadMembersFilter":
      return _getEnumMap(V2TIMGroupMessageReadMembersFilter);
  }
}

function _getEnumKeys(enumName: any) {
  const keys = Object.keys(enumName).filter((key) => Number.isNaN(Number(key)));
  let result = new Array<{ value: string }>();
  for (const key of keys) {
    result.push({ value: key });
  }
  return result;
}

function _getEnumMap(enumName: any) {
  const list = Object.keys(enumName);
  const size = list.length / 2;
  let result = new Map<string, number>();
  for (let i = 0; i < size; ++i) {
    result.set(list[i + size], Number(list[i]));
  }
  return result;
}
