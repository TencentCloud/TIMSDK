// Copyright (c) 2023 Tencent. All rights reserved.

import {
  V2TIMAdvancedMsgListener,
  V2TIMConversation,
  V2TIMConversationListFilter,
  V2TIMConversationListener,
  V2TIMConversationManager,
  V2TIMConversationMarkType,
  V2TIMConversationOperationResult,
  V2TIMConversationResult,
  V2TIMConversationType,
  V2TIMCreateGroupInfo,
  V2TIMCreateGroupMemberInfo,
  V2TIMCustomElem,
  V2TIMDownloadCallback,
  V2TIMElem,
  V2TIMElemType,
  V2TIMErrorCode,
  V2TIMFaceElem,
  V2TIMFileElem,
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
  V2TIMFriendType,
  V2TIMFriendshipListener,
  V2TIMFriendshipManager,
  V2TIMGender,
  V2TIMGroupAddOpt,
  V2TIMGroupApplication,
  V2TIMGroupApplicationHandleResult,
  V2TIMGroupApplicationHandleStatus,
  V2TIMGroupApplicationResult,
  V2TIMGroupApplicationType,
  V2TIMGroupAtInfo,
  V2TIMGroupAtType,
  V2TIMGroupChangeInfo,
  V2TIMGroupInfo,
  V2TIMGroupInfoChangeType,
  V2TIMGroupInfoModifyFlag,
  V2TIMGroupInfoResult,
  V2TIMGroupListener,
  V2TIMGroupManager,
  V2TIMGroupMemberChangeInfo,
  V2TIMGroupMemberFilter,
  V2TIMGroupMemberFullInfo,
  V2TIMGroupMemberInfo,
  V2TIMGroupMemberInfoModifyFlag,
  V2TIMGroupMemberInfoResult,
  V2TIMGroupMemberOperationResult,
  V2TIMGroupMemberResult,
  V2TIMGroupMemberRole,
  V2TIMGroupMemberSearchParam,
  V2TIMGroupMessageReadMemberList,
  V2TIMGroupMessageReadMembersFilter,
  V2TIMGroupSearchParam,
  V2TIMGroupTipsElem,
  V2TIMGroupTipsType,
  V2TIMGroupType,
  V2TIMIOSOfflinePushType,
  V2TIMImage,
  V2TIMImageElem,
  V2TIMImageType,
  V2TIMKeywordListMatchType,
  V2TIMLocationElem,
  V2TIMLogLevel,
  V2TIMLogListener,
  V2TIMLoginStatus,
  V2TIMManager,
  V2TIMMergerElem,
  V2TIMMessage,
  V2TIMMessageExtension,
  V2TIMMessageExtensionResult,
  V2TIMMessageGetType,
  V2TIMMessageListGetOption,
  V2TIMMessageManager,
  V2TIMMessagePriority,
  V2TIMMessageReceipt,
  V2TIMMessageSearchParam,
  V2TIMMessageSearchResult,
  V2TIMMessageSearchResultItem,
  V2TIMMessageStatus,
  V2TIMOfflinePushConfig,
  V2TIMOfflinePushFlag,
  V2TIMOfflinePushInfo,
  V2TIMOfflinePushManager,
  V2TIMOfflinePushTokenType,
  V2TIMReceiveMessageOpt,
  V2TIMReceiveMessageOptInfo,
  V2TIMSDKConfig,
  V2TIMSDKListener,
  V2TIMSetFriendInfoParam,
  V2TIMSetGroupInfoParam,
  V2TIMSetGroupMemberInfo,
  V2TIMSetSelfInfoParam,
  V2TIMSetSelfStatusParam,
  V2TIMSignalingActionType,
  V2TIMSignalingInfo,
  V2TIMSignalingListener,
  V2TIMSignalingManager,
  V2TIMSimpleMsgListener,
  V2TIMSoundElem,
  V2TIMTextElem,
  V2TIMTopicInfo,
  V2TIMTopicInfoResult,
  V2TIMTopicOperationResult,
  V2TIMUserFullInfo,
  V2TIMUserInfo,
  V2TIMUserInfoModifyFlag,
  V2TIMUserStatus,
  V2TIMUserStatusType,
  V2TIMUploadCallback,
  V2TIMVideoElem,
} from '@tencentcloud/imsdk'

import buffer from '@ohos.buffer';

import { BaseTestInterfaces } from '../interfaces/BaseTestInterfaces';

import { getEnumKeys, getEnumMap } from "../tools/GetEnum";

@Observed
class Result {
  interfaceResult = "";
  sdkCallback = ""
  simpleMessageReceive = ""
  groupCallback = ""
}

let result = new Result();

export default result;

export function writeResult(...args: ESObject[]) {
  let resultList = new Array<string>();
  args.forEach((value: ESObject) => {
    resultList.push(JSON.stringify(value));
  });
  let currentResult = resultList.join(" ");
  result.interfaceResult = "\n" + currentResult;
}

export function onSDKCallback(...args: ESObject[]) {
  let resultList = new Array<string>();
  args.forEach((value: ESObject) => {
    resultList.push(JSON.stringify(value));
  });
  let currentResult = resultList.join(" ");
  result.sdkCallback = "\n" + currentResult;
}

export function onGroupCallback(...args: ESObject[]) {
  let resultList = new Array<string>();
  args.forEach((value: ESObject) => {
    resultList.push(JSON.stringify(value));
  });
  let currentResult = resultList.join(" ");
  result.groupCallback = "\n" + currentResult;
}

export function onSimpleMessageReceive(...args: ESObject[]) {
  let resultList = new Array<string>();
  args.forEach((value: ESObject) => {
    resultList.push(JSON.stringify(value));
  });
  let currentResult = resultList.join(" ");
  result.simpleMessageReceive = "\n" + currentResult;
}

@Entry
@Component
export struct BaseManagerTestPage {
  private userID = "xlmzz";
  private toUserID = "xlm";
  private msgContent = "msgContent";
  private toGroupID = "test123groupID";
  private priority = V2TIMMessagePriority.V2TIM_PRIORITY_DEFAULT;
  private groupType = V2TIMGroupType.Work;
  private groupName = "测试群";
  private groupID = "";
  private userID1 = "userID1";
  private userID2 = "userID2";
  private allowType: V2TIMFriendAllowType | undefined;
  private selfNickName = "nickName";
  private userID3 = "userID3";
  private userID4 = "userID4";
  private customStatus = "customStatus";
  private userID5 = "userID5";
  private userID6 = "userID6";
  @State result: Result = result;

  build() {
    Column() {
      Column() {
        Scroll() {
          Column({ space: 5 }) {
            DemoButton("清空", () => {
              this.result.interfaceResult = "";
              this.result.sdkCallback = "";
              this.result.simpleMessageReceive = "";
              this.result.groupCallback = "";
            })
            DemoTitle("接口调用结果：")
            DemoText({ name: this.result.interfaceResult })
            DemoTitle("SDK状态回调：")
            DemoText({ name: this.result.sdkCallback })
            DemoTitle("简单消息接收：")
            DemoText({ name: this.result.simpleMessageReceive })
            DemoTitle("群组回调：")
            DemoText({ name: this.result.groupCallback })
          }.alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .align(Alignment.TopStart)

      }
      .height('35%')
      .width('100%')

      Divider()

      Scroll() {
        Column({ space: 10 }) {
          Row() {
            DemoLabel("UserID")
            TextInput({ placeholder: "xlmzz" })
              .onChange((value: string) => this.userID = value)
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 10 }) {
            DemoButton("addSDKListener", BaseTestInterfaces.addSDKListener)
            DemoButton("removeSDKListener", BaseTestInterfaces.removeSDKListener)
          }.DemoRowStyle()

          Row({ space: 10 }) {
            DemoButton("initSDK", BaseTestInterfaces.initSDK)
            DemoButton("unInitSDK", BaseTestInterfaces.unInitSDK)
            DemoButton("getVersion", BaseTestInterfaces.getVersion)
            DemoButton("getServerTime", BaseTestInterfaces.getServerTime)
          }.DemoRowStyle()

          Row({ space: 10 }) {
            DemoButton("login", (): void => BaseTestInterfaces.login(this.userID))
            DemoButton("logout", BaseTestInterfaces.logout)
            DemoButton("getLoginUser", BaseTestInterfaces.getLoginUser)
            DemoButton("getLoginStatus", BaseTestInterfaces.getLoginStatus)
          }.DemoRowStyle()

          Row({ space: 10 }) {
            DemoButton("addSimpleMsgListener", BaseTestInterfaces.addSimpleMsgListener)
            DemoButton("removeSimpleMsgListener", BaseTestInterfaces.removeSimpleMsgListener)
          }.DemoRowStyle()

          Row({ space: 10 }) {
            DemoLabel("MSG")
            TextInput({ placeholder: "msgContent" })
              .onChange((value: string) => this.msgContent = value)
              .demoTextInputStyle()

            DemoLabel("ToUserID:")
            TextInput({ placeholder: "xlm" })
              .onChange((value: string) => this.toUserID = value)
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 10 }) {
            DemoButton("sendC2CTextMessage", (): void => BaseTestInterfaces.sendC2CTextMessage(this.toUserID, this.msgContent))
            DemoButton("sendC2CCustomMessage", (): void => BaseTestInterfaces.sendC2CCustomMessage(this.toUserID))
          }.DemoRowStyle()

          Row({ space: 10 }) {
            DemoLabel("ToGroupID")
            TextInput({ placeholder: "test123groupID" })
              .onChange((value: string) => this.toGroupID = value)
              .demoTextInputStyle()
            DemoLabel("Priority")
            Select(getEnumKeys("V2TIMMessagePriority"))
              .font({ size: 10 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                this.priority = getEnumMap("V2TIMMessagePriority").get(value) as V2TIMMessagePriority;
              })
          }

          Row({ space: 10 }) {
            DemoButton("sendGroupTextMessage", (): void => BaseTestInterfaces.sendGroupTextMessage(this.toGroupID, this.msgContent, this.priority))
            DemoButton("sendGroupCustomMessage", (): void => BaseTestInterfaces.sendGroupCustomMessage(this.toGroupID, this.msgContent, this.priority))
          }

          Row({ space: 10 }) {
            DemoButton("addGroupListener", BaseTestInterfaces.addGroupListener)
            DemoButton("removeGroupListener", BaseTestInterfaces.removeGroupListener)
          }

          Row({ space: 10 }) {
            DemoLabel("groupType")
            Select(getEnumKeys("V2TIMGroupType"))
              .font({ size: 10 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                this.groupType = value as V2TIMGroupType;
              })
            DemoLabel("groupName")
            TextInput({ placeholder: '测试群' })
              .onChange((value: string) => this.groupName = value)
              .demoTextInputStyle()
          }

          Row() {
            DemoLabel("groupID")
            TextInput({ placeholder: '' })
              .onChange((value: string) => this.groupID = value)
              .demoTextInputStyle()
          }

          Row({ space: 10 }) {
            DemoButton("createGroup", (): void => BaseTestInterfaces.createGroup(this.groupType, this.groupName, this.groupID));
            DemoButton("joinGroup", (): void => BaseTestInterfaces.joinGroup(this.groupID));
            DemoButton("quitGroup", (): void => BaseTestInterfaces.quitGroup(this.groupID));
            DemoButton("dismissGroup", (): void => BaseTestInterfaces.dismissGroup(this.groupID));
          }

          Row({ space: 10 }) {
            TextInput({ placeholder: "userID1" })
              .onChange((value) => this.userID1 = value)
              .demoTextInputStyle()
            TextInput({ placeholder: "userID2" })
              .onChange((value) => this.userID2 = value)
              .demoTextInputStyle()
            DemoButton("getUsersInfo", (): void => BaseTestInterfaces.getUsersInfo(this.userID1, this.userID2));
          }

          Row({ space: 10 }) {
            TextInput({ placeholder: "nickName" })
              .onChange((value) => this.selfNickName = value)
              .demoTextInputStyle()
            Select(getEnumKeys("V2TIMFriendAllowType"))
              .font({ size: 10 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                this.allowType = getEnumMap("V2TIMFriendAllowType").get(value);
              })
            Checkbox()
              .size({ width: 14 })
              .onChange((value: boolean) => {
                if (!value) {
                  this.allowType = undefined;
                } else if (!this.allowType) {
                  this.allowType = V2TIMFriendAllowType.V2TIM_FRIEND_DENY_ANY;
                }
              })
          }

          Row() {
            DemoButton("setSelfInfo", (): void => BaseTestInterfaces.setSelfInfo(this.selfNickName, this.allowType))
          }

          Row({ space: 10 }) {
            TextInput({ placeholder: "userID3" })
              .onChange((value) => this.userID3 = value)
              .demoTextInputStyle()
            TextInput({ placeholder: "userID4" })
              .onChange((value) => this.userID4 = value)
              .demoTextInputStyle()
            DemoButton("getUserStatus", (): void => BaseTestInterfaces.getUserStatus(this.userID3, this.userID4));
          }

          Row() {
            TextInput({ placeholder: 'customStatus' })
              .onChange((value: string) => this.customStatus = value)
              .demoTextInputStyle()
            DemoButton("setSelfStatus", (): void => BaseTestInterfaces.setSelfStatus(this.customStatus));
          }

          Row({ space: 10 }) {
            TextInput({ placeholder: 'userID5' })
              .onChange((value: string) => this.userID5 = value)
              .demoTextInputStyle()
            TextInput({ placeholder: 'userID6' })
              .onChange((value: string) => this.userID6 = value)
              .demoTextInputStyle()
          }

          Row({ space: 10 }) {
            DemoButton("subscribeUserStatus", (): void => BaseTestInterfaces.subscribeUserStatus(this.userID5, this.userID6));
            DemoButton("unsubscribeUserStatus", (): void => BaseTestInterfaces.unsubscribeUserStatus(this.userID5, this.userID6));
          }

        }.alignItems(HorizontalAlign.Start)
      }
      .height('65%')
      .width('100%')
      .padding(4)
      .scrollBar(BarState.On)
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
