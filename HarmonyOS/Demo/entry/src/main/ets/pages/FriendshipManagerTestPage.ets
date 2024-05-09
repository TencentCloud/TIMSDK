// Copyright (c) 2023 Tencent. All rights reserved.

import {
  V2TIMFriendAcceptType,
  V2TIMFriendAddApplication,
  V2TIMFriendAllowType,
  V2TIMFriendApplication,
  V2TIMFriendApplicationResult,
  V2TIMFriendApplicationType,
  V2TIMFriendCheckResult,
  V2TIMFriendGroup,
  V2TIMFriendInfo,
  V2TIMFriendInfoModifyFlag,
  V2TIMFriendInfoResult,
  V2TIMFriendOperationResult,
  V2TIMFriendRelationType,
  V2TIMFriendSearchParam,
  V2TIMManager,
} from '@tencentcloud/imsdk'

import buffer from '@ohos.buffer';

import { FriendshipTestInterfaces } from '../interfaces/FriendshipTestInterfaces';

@Observed
class Result {
  result = "";
  callbackResult = "";
}

let result = new Result();

export default result;

export function writeResult(...args: ESObject[]) {
  let resultList = new Array<string>();
  args.forEach((value: ESObject) => {
    resultList.push(JSON.stringify(value));
  });
  let currentResult = resultList.join(" ");
  result.result = "\n" + currentResult;
}

export function onCallback(...args: ESObject[]) {
  let resultList = new Array<string>();
  args.forEach((value: ESObject) => {
    resultList.push(JSON.stringify(value));
  });
  let currentResult = resultList.join(" ");
  result.callbackResult = "\n" + currentResult;
}

class FriendTestInfo {
  userID1 = "";
  userID2 = "";
  userID3 = "";
  friendRemark = "";
  // add friend
  userID4 = "";
  friendRemark2 = "";
  addWording = "";
  // black list
  userID5 = "";
  userID6 = "";
  // friend group
  userID7 = "";
  userID8 = "";
  friendGroup = "";
  friendGroup2 = "";
  friendGroup3 = "";
  oldFriendGroupName = "";
  newFriendGroupName = "";
}

export let info = new FriendTestInfo();

@Entry
@Component
export struct FriendshipManagerTestPage {
  @State result: Result = result;

  build() {
    Column() {

      Scroll() {
        Column({ space: 4 }) {
          DemoButton("清空", () => {
            this.result.result = "";
            this.result.callbackResult = "";
          })
          DemoTitle("接口调用结果：")
          DemoText({ name: this.result.result })
          DemoTitle("回调结果：")
          DemoText({ name: this.result.callbackResult })
        }.alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('35%')
      .align(Alignment.TopStart)

      Divider()

      Scroll() {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            DemoButton("addFriendListener", FriendshipTestInterfaces.addFriendListener);
            DemoButton("removeFriendListener", FriendshipTestInterfaces.removeFriendListener);
          }.DemoRowStyle()

          DemoButton("getFriendList", FriendshipTestInterfaces.getFriendList);

          Row({ space: 4 }) {
            TextInput({ placeholder: 'userID1' })
              .onChange((value: string) => {
                info.userID1 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'userID2' })
              .onChange((value: string) => {
                info.userID2 = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          DemoButton("getFriendsInfo", FriendshipTestInterfaces.getFriendsInfo);

          Row({ space: 4 }) {
            TextInput({ placeholder: 'userID3' })
              .onChange((value: string) => {
                info.userID3 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'friendRemark' })
              .onChange((value: string) => {
                info.friendRemark = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          DemoButton("setFriendInfo", FriendshipTestInterfaces.setFriendInfo);

          // searchFriends()

          Row({ space: 4 }) {
            TextInput({ placeholder: 'userID4' })
              .onChange((value: string) => {
                info.userID4 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'friendRemark2' })
              .onChange((value: string) => {
                info.friendRemark2 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'addWording' })
              .onChange((value: string) => {
                info.addWording = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("addFriend", FriendshipTestInterfaces.addFriend)
            DemoButton("deleteFriend", FriendshipTestInterfaces.deleteFromFriendList)
            DemoButton("checkFriend", FriendshipTestInterfaces.checkFriend)
          }.DemoRowStyle()

          DemoButton("getFriendApplicationList", FriendshipTestInterfaces.getFriendApplicationList)
          Row({ space: 4 }) {
            DemoButton("acceptFriendApplication", FriendshipTestInterfaces.acceptFriendApplication)
            DemoButton("refuseFriendApplication", FriendshipTestInterfaces.refuseFriendApplication)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("deleteFriendApplication", FriendshipTestInterfaces.deleteFriendApplication)
            DemoButton("setFriendApplicationRead", FriendshipTestInterfaces.setFriendApplicationRead)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: 'userID5' })
              .onChange((value: string) => {
                info.userID5 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'userID6' })
              .onChange((value: string) => {
                info.userID6 = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getBlackList", FriendshipTestInterfaces.getBlackList)
            DemoButton("addToBlackList", FriendshipTestInterfaces.addToBlackList)
            DemoButton("deleteFromBlackList", FriendshipTestInterfaces.deleteFromBlackList)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: 'userID7' })
              .onChange((value: string) => {
                info.userID7 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'userID8' })
              .onChange((value: string) => {
                info.userID8 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'friendGroup' })
              .onChange((value: string) => {
                info.friendGroup = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          DemoButton("createFriendGroup", FriendshipTestInterfaces.createFriendGroup)
          Row({ space: 4 }) {
            DemoButton("addFriendsToFriendGroup", FriendshipTestInterfaces.addFriendsToFriendGroup)
            DemoButton("deleteFriendsFromFriendGroup", FriendshipTestInterfaces.deleteFriendsFromFriendGroup)
          }.DemoRowStyle()


          Row({ space: 4 }) {
            TextInput({ placeholder: 'friendGroup2' })
              .onChange((value: string) => {
                info.friendGroup2 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'friendGroup3' })
              .onChange((value: string) => {
                info.friendGroup3 = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getFriendGroups", FriendshipTestInterfaces.getFriendGroups)
            DemoButton("deleteFriendGroup", FriendshipTestInterfaces.deleteFriendGroup)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: 'oldFriendGroupName' })
              .onChange((value: string) => {
                info.oldFriendGroupName = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'newFriendGroupName' })
              .onChange((value: string) => {
                info.newFriendGroupName = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          DemoButton("renameFriendGroup", FriendshipTestInterfaces.renameFriendGroup)

          Row({ space: 4 }) {
            TextInput({ placeholder: 'userID1' })
              .onChange((value: string) => {
                info.userID1 = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'userID2' })
              .onChange((value: string) => {
                info.userID2 = value;
              }).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("followUser", FriendshipTestInterfaces.followUser)
            DemoButton("unfollowUser", FriendshipTestInterfaces.unfollowUser)
            DemoButton("getMyFollowingList", FriendshipTestInterfaces.getMyFollowingList)
            DemoButton("getMyFollowersList", FriendshipTestInterfaces.getMyFollowersList)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getMutualFollowersList", FriendshipTestInterfaces.getMutualFollowersList)
            DemoButton("getUserFollowInfo", FriendshipTestInterfaces.getUserFollowInfo)
            DemoButton("checkFollowType", FriendshipTestInterfaces.checkFollowType)
          }.DemoRowStyle()
        }
        .alignItems(HorizontalAlign.Start)
        .align(Alignment.TopStart)
      }
      .height('65%')
      .width('100%')
      .padding(16)
    }
  }
}

@Builder function DemoButton(name: string, onclickEvent?: (event?: ClickEvent) => void) {
  Button({ stateEffect: true, type: ButtonType.Normal }) {
    Text(name).fontSize(12).fontColor(Color.White)
  }
  .padding(4)
  .borderRadius(4)
  .onClick(onclickEvent)
}

interface DemoTextParam {
  name: string;
}
@Builder function DemoText(param: DemoTextParam) {
  Text(param.name).fontSize(11).fontWeight(FontWeight.Bold)
}

@Builder function DemoTitle(name: string) {
  Text(name).fontSize(12).margin(10).fontWeight(FontWeight.Bold)
}

@Builder function DemoLabel(name: string) {
  Text(name + ":").fontSize(10).margin(10)
}

@Extend(TextInput) function demoTextInputStyle() {
  .width('30%')
  .padding(8)
  .borderRadius(4)
  .fontSize(10)
  .placeholderFont({ size: 10 })
}

@Extend(Row) function DemoRowStyle() {
  .width('100%')
  .justifyContent(FlexAlign.Start)
}
