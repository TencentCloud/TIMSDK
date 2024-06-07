// Copyright (c) 2023 Tencent. All rights reserved.
import { V2TIMGroupAddOpt, V2TIMGroupMemberRole } from '@tencentcloud/imsdk';
import { communityInfo, CommunityTestInterfaces } from '../interfaces/CommunityInterfaces';
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
export struct CommunityManagerTestPage {
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
            DemoButton("addCommunityListener", CommunityTestInterfaces.addCommunityListener)
            DemoButton("removeCommunityListener", CommunityTestInterfaces.addCommunityListener)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: communityInfo.communityGroupID })
              .onChange((v) => {
                communityInfo.communityGroupID = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: communityInfo.groupName })
              .onChange((v) => {
                communityInfo.groupName = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: communityInfo.notification })
              .onChange((v) => {
                communityInfo.notification = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: communityInfo.introduction })
              .onChange((v) => {
                communityInfo.introduction = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: communityInfo.faceURL })
              .onChange((v) => {
                communityInfo.faceURL = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("createCommunity", CommunityTestInterfaces.createCommunity)
            DemoButton("getJoinedCommunityList", CommunityTestInterfaces.getJoinedCommunityList)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("createTopicInCommunity", CommunityTestInterfaces.createTopicInCommunity)
            DemoButton("deleteTopicFromCommunity", CommunityTestInterfaces.deleteTopicFromCommunity)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("setTopicInfo", CommunityTestInterfaces.setTopicInfo)
            DemoButton("getTopicInfoList", CommunityTestInterfaces.getTopicInfoList)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: communityInfo.communityGroupID })
              .onChange((v) => {
                communityInfo.communityGroupID = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: communityInfo.permissionGroupID })
              .onChange((v) => {
                communityInfo.permissionGroupID = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: communityInfo.permissionGroupName })
              .onChange((v) => {
                communityInfo.permissionGroupName = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: communityInfo.customData })
              .onChange((v) => {
                communityInfo.customData = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: "communityInfo.groupPermission" })
              .type(InputType.Number)
              .onChange((v) => {
                communityInfo.groupPermission = parseInt(v);
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("modifyPermissionGroupInfoInCommunity", CommunityTestInterfaces.modifyPermissionGroupInfoInCommunity)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getJoinedPermissionGroupListInCommunity", CommunityTestInterfaces.getJoinedPermissionGroupListInCommunity)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: communityInfo.permissionGroupID1 })
              .onChange((v) => {
                communityInfo.permissionGroupID1 = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: communityInfo.permissionGroupID2 })
              .onChange((v) => {
                communityInfo.permissionGroupID2 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: communityInfo.userID1 })
              .onChange((v) => {
                communityInfo.userID1 = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: communityInfo.userID2 })
              .onChange((v) => {
                communityInfo.userID2 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getPermissionGroupListInCommunity", CommunityTestInterfaces.getPermissionGroupListInCommunity)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("addCommunityMembersToPermissionGroup", CommunityTestInterfaces.addCommunityMembersToPermissionGroup)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("removeCommunityMembersFromPermissionGroup", CommunityTestInterfaces.removeCommunityMembersFromPermissionGroup)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getCommunityMemberListInPermissionGroup", CommunityTestInterfaces.getCommunityMemberListInPermissionGroup)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: communityInfo.topicPermissionMapKey1 })
              .onChange((v) => {
                communityInfo.topicPermissionMapKey1 = v;
              })
              .demoTextInputStyle().width('40%')

            TextInput({ placeholder: communityInfo.topicPermissionMapKey2 })
              .onChange((v) => {
                communityInfo.topicPermissionMapKey2 = v;
              })
              .demoTextInputStyle().width('40%')
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: "topicPermissionMapValue2" })
              .type(InputType.Number)
              .onChange((v) => {
                communityInfo.topicPermissionMapValue1 = parseInt(v);
              })
              .demoTextInputStyle().width('40%')

            TextInput({ placeholder: "topicPermissionMapValue2" })
              .type(InputType.Number)
              .onChange((v) => {
                communityInfo.topicPermissionMapValue2 = parseInt(v);
              })
              .demoTextInputStyle().width('40%')
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("addTopicPermissionToPermissionGroup", CommunityTestInterfaces.addTopicPermissionToPermissionGroup)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("deleteTopicPermissionFromPermissionGroup", CommunityTestInterfaces.deleteTopicPermissionFromPermissionGroup)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("modifyTopicPermissionInPermissionGroup", CommunityTestInterfaces.modifyTopicPermissionInPermissionGroup)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getTopicPermissionInPermissionGroup", CommunityTestInterfaces.getTopicPermissionInPermissionGroup)
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
