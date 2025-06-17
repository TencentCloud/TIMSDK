import {
  UserInfo,
  V2TIMFriendInfo,
  V2TIMGroupMemberFullInfo,
  V2TIMGroupMemberInfo,
  V2TIMUserFullInfo,
  V2TIMUserInfo
} from 'chatengine'
import CommonData from 'chatengine/src/main/ets/datasource/CommonData';

export default class UserData extends CommonData {
  faceUrl?: string;
  groupNameCard?: string;
  friendRemark?: string;
  nickName?: string;
  signature?: string;

  get displayName() {
    if (this.groupNameCard && this.groupNameCard.length > 0) {
      return this.groupNameCard;
    } else if (this.friendRemark && this.friendRemark.length > 0) {
      return this.friendRemark;
    } else if (this.nickName && this.nickName.length > 0) {
      return this.nickName;
    } else {
      return this.ID;
    }
  }

  static parseUserData(timUserInfo: V2TIMUserInfo | V2TIMUserFullInfo
    | V2TIMGroupMemberInfo | V2TIMGroupMemberFullInfo | V2TIMFriendInfo | UserInfo | undefined): UserData | undefined {
    if (!timUserInfo) {
      return;
    }
    let userData = new UserData();
    userData.ID = timUserInfo.userID ? timUserInfo.userID : "";
    if ((timUserInfo instanceof V2TIMFriendInfo)) {
      userData.faceUrl = timUserInfo.userFullInfo.faceURL;
      userData.nickName = timUserInfo.userFullInfo.nickName;

    } else if (timUserInfo instanceof UserInfo) {
      userData.faceUrl = timUserInfo.faceUrl;
      userData.nickName = timUserInfo.nickName;
    } else {
      userData.faceUrl = timUserInfo.faceURL;
      userData.nickName = timUserInfo.nickName;
    }
    if (timUserInfo instanceof V2TIMUserFullInfo) {
      userData.signature = timUserInfo.selfSignature
    }
    return userData;
  }

  static parseUserDataArray(timUserInfoArray: V2TIMUserInfo[] | V2TIMUserFullInfo[]
    | V2TIMGroupMemberInfo[] | V2TIMGroupMemberFullInfo[] | V2TIMFriendInfo[]) {
    let userDataArray: UserData[] = [];
    for (let timUserInfo of timUserInfoArray) {
      let userData = UserData.parseUserData(timUserInfo);
      if (userData) {
        userDataArray.push(userData);
      }
    }
    return userDataArray;
  }
}