// Copyright (c) 2023 Tencent. All rights reserved.
import { V2TIMGroupAddOpt, V2TIMGroupMemberRole } from '@tencentcloud/imsdk';
import { groupInfo, GroupTestInterfaces } from '../interfaces/GroupTestInterfaces';
import { getEnumKeys, getEnumMap} from '../tools/GetEnum'

@Observed
class Result {
  result = "";
  callbackResult = "";
}

let result = new Result();

export { result };

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

@Entry
@Component
export struct GroupManagerTestPage {
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
        .align(Alignment.TopStart)
      }
      .height('35%')
      .width('100%')
      .align(Alignment.TopStart)

      Divider()

      Scroll() {
        Column({ space: 4 }) {

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID })
              .onChange((v) => {
                groupInfo.groupID = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: groupInfo.groupName })
              .onChange((v) => {
                groupInfo.groupName = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: groupInfo.notification })
              .onChange((v) => {
                groupInfo.notification = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.introduction })
              .onChange((v) => {
                groupInfo.introduction = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.faceURL })
              .onChange((v) => {
                groupInfo.faceURL = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.userID1 })
              .onChange((v) => {
                groupInfo.userID1 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.userID2 })
              .onChange((v) => {
                groupInfo.userID2 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("createWork", GroupTestInterfaces.createWork)
            DemoButton("createPublic", GroupTestInterfaces.createPublic)
            DemoButton("createMeeting", GroupTestInterfaces.createMeeting)
            DemoButton("createAVChatRoom", GroupTestInterfaces.createAVChatRoom)
          }

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID2 })
              .onChange((v) => {
                groupInfo.groupID2 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.groupID3 })
              .onChange((v) => {
                groupInfo.groupID3 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getJoinedGroups", GroupTestInterfaces.getJoinedGroups)
            DemoButton("getJoinedCommunityList", GroupTestInterfaces.getJoinedCommunityList)
            DemoButton("getGroupsInfo", GroupTestInterfaces.getGroupsInfo)
          }

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID4 })
              .onChange((v) => {
                groupInfo.groupID4 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.groupName4 })
              .onChange((v) => {
                groupInfo.groupName4 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("groupAddOpt")
            Select(getEnumKeys("V2TIMGroupAddOpt"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                groupInfo.groupAddOpt = getEnumMap("V2TIMGroupAddOpt").get(value) as V2TIMGroupAddOpt;
              })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("groupApproveOpt")
            Select(getEnumKeys("V2TIMGroupAddOpt"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                groupInfo.groupApproveOpt = getEnumMap("V2TIMGroupAddOpt").get(value) as V2TIMGroupAddOpt;
              })
          }.DemoRowStyle()

          DemoButton("setGroupInfo", GroupTestInterfaces.setGroupInfo)
          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID5 })
              .onChange((v) => {
                groupInfo.groupID5 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("initGroupAttributes", GroupTestInterfaces.initGroupAttributes)
            DemoButton("setGroupAttributes", GroupTestInterfaces.setGroupAttributes)
            DemoButton("deleteGroupAttributes", GroupTestInterfaces.deleteGroupAttributes)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getGroupAttributes", GroupTestInterfaces.getGroupAttributes)
            DemoButton("setGroupCounters", GroupTestInterfaces.setGroupCounters)
            DemoButton("getGroupCounters", GroupTestInterfaces.getGroupCounters)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("increaseGroupCounter", GroupTestInterfaces.increaseGroupCounter)
            DemoButton("decreaseGroupCounter", GroupTestInterfaces.decreaseGroupCounter)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getGroupOnlineMemberCount", GroupTestInterfaces.getGroupOnlineMemberCount)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID6 })
              .onChange((v) => {
                groupInfo.groupID6 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: "nextSeq(0)" })
              .type(InputType.Number)
              .onChange((v) => {
                groupInfo.nextSeq = parseInt(v);
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("filter")
            Select(getEnumKeys("V2TIMGroupMemberRole"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                groupInfo.groupAddOpt = getEnumMap("V2TIMGroupMemberRole").get(value) as V2TIMGroupAddOpt;
              })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getGroupMemberList", GroupTestInterfaces.getGroupMemberList)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID7 })
              .onChange((v) => {
                groupInfo.groupID7 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.userID7 })
              .onChange((v) => {
                groupInfo.userID7 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.userID8 })
              .onChange((v) => {
                groupInfo.userID8 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("inviteUserToGroup", GroupTestInterfaces.inviteUserToGroup)
            DemoButton("kickGroupMember", GroupTestInterfaces.kickGroupMember)
          }.DemoRowStyle()

          DemoButton("getGroupMembersInfo", GroupTestInterfaces.getGroupMembersInfo)

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID9 })
              .onChange((v) => {
                groupInfo.groupID9 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.userID9 })
              .onChange((v) => {
                groupInfo.userID9 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.nameCard })
              .onChange((v) => {
                groupInfo.nameCard = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("setGroupMemberInfo", GroupTestInterfaces.setGroupMemberInfo)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID10 })
              .onChange((v) => {
                groupInfo.groupID9 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.userID10 })
              .onChange((v) => {
                groupInfo.userID9 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: "second(5)" })
              .onChange((v) => {
                groupInfo.seconds = parseInt(v);
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("muteGroupMember", GroupTestInterfaces.muteGroupMember)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID11 })
              .onChange((v) => {
                groupInfo.groupID11 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: "userID11" })
              .type(InputType.Number)
              .onChange((v) => {
                groupInfo.userID11 = (v);
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("role")
            Select(getEnumKeys("V2TIMGroupMemberRole"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                groupInfo.groupAddOpt = getEnumMap("V2TIMGroupMemberRole").get(value) as V2TIMGroupAddOpt;
              })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("setGroupMemberRole", GroupTestInterfaces.setGroupMemberRole)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID12 })
              .onChange((v) => {
                groupInfo.groupID12 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.userID12 })
              .onChange((v) => {
                groupInfo.userID12 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: groupInfo.userID13 })
              .onChange((v) => {
                groupInfo.userID13 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("enableMark")
            Checkbox().size({ width: 12, height: 12 })
              .onChange((v) => {
                groupInfo.enableMark = v;
              })
            TextInput({ placeholder: 'markType(0)' })
              .type(InputType.Number)
              .onChange((value: string) => {
                groupInfo.markType = parseInt(value);
              }).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("setGroupMemberRole", GroupTestInterfaces.setGroupMemberRole)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.groupID14 })
              .onChange((v) => {
                groupInfo.groupID14 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: "newOwner" })
              .type(InputType.Number)
              .onChange((v) => {
                groupInfo.userID14 = (v);
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("transferGroupOwner", GroupTestInterfaces.transferGroupOwner)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getGroupApplicationList", GroupTestInterfaces.getGroupApplicationList)
            DemoButton("setGroupApplicationRead", GroupTestInterfaces.setGroupApplicationRead)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("acceptGroupApplication", GroupTestInterfaces.acceptGroupApplication)
            DemoButton("refuseGroupApplication", GroupTestInterfaces.refuseGroupApplication)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: groupInfo.communityGroupID })
              .type(InputType.Number)
              .onChange((v) => {
                groupInfo.communityGroupID = (v);
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("createTopicInCommunity", GroupTestInterfaces.createTopicInCommunity)
            DemoButton("deleteTopicFromCommunity", GroupTestInterfaces.deleteTopicFromCommunity)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("setTopicInfo", GroupTestInterfaces.setTopicInfo)
            DemoButton("getTopicInfoList", GroupTestInterfaces.getTopicInfoList)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("pinGroupMessage", GroupTestInterfaces.pinGroupMessage)
            DemoButton("unpinGroupMessage", GroupTestInterfaces.unpinGroupMessage)
            DemoButton("getPinnedGroupMessageList", GroupTestInterfaces.getPinedGroupMessageList)
          }.DemoRowStyle()

        }
        .align(Alignment.TopStart)
        .alignItems(HorizontalAlign.Start)
      }
      .align(Alignment.TopStart)
      .height('65%')
      .width('100%')
      .padding(4)
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


// function getEnumKeys(enumName: any) {
//   const keys = Object.keys(enumName).filter(key => Number.isNaN(Number(key)));
//   let result = new Array<{ value: string }>();
//   for (const key of keys) {
//     result.push({ value: key });
//   }
//   return result;
// }
//
// function getEnumMap(enumName: any) {
//   const list = Object.keys(enumName);
//   const size = list.length / 2;
//   let result = new Map<string, number>();
//   for (let i = 0; i < size; ++i) {
//     result.set(list[i + size], Number(list[i]));
//   }
//   return result;
// }
