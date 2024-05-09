// Copyright (c) 2023 Tencent. All rights reserved.

import {
  V2TIMElemType,
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
} from '@tencentcloud/imsdk'

import buffer from '@ohos.buffer';

import { MessageTestInterfaces } from '../interfaces/MessageTestInterfaces';

import { getEnumKeys, getEnumMap } from '../tools/GetEnum';

@Observed
class Result {
  callbackResult = "";
  result = "";
  messageID = "";
  progress = 0
  progress2 = 0
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

@Observed
class Info {
  receiver = "xlm";
  groupID = "@TGS#_@TGS#cMRYAIIM62CZ@TOPIC#_@TOPIC#cORYAIIM62C5";
  text = "test_text";
  customData = buffer.from("customData").buffer;
  customDesc = "customDesc";
  customExt = "customExt";
  atUsers = ["xlm", "xlmzz"];
  needReadReceipt = true;
  onlineUserOnly = false;
  priority = V2TIMMessagePriority.V2TIM_PRIORITY_DEFAULT;
  offlinePushInfo: null | V2TIMOfflinePushInfo = null;
  excludeLastMessage = false;
  excludeUnreadCount = false;
  excludeSecurityCheck = false;
  imagePath = "imagePath";
  soundPath = "soundPath";
  videoPath = "videoPath";
  snapshotPath = "snapshotPath";
  groupTargetReceivers = ["xlm", "100480"];
  // set receive opt
  userID1 = "xlm";
  userID2 = "100480";
  groupID2 = "@TGS#_@TGS#cMRYAIIM62CZ@TOPIC#_@TOPIC#cORYAIIM62C5";
  recvOpt = V2TIMReceiveMessageOpt.V2TIM_RECEIVE_MESSAGE;
  startHour: number = 0;
  startMinute: number = 0;
  startSecond: number = 0;
  startTimeStamp: number = 0;
  duration: number = 0;
  recvOpt2 = V2TIMReceiveMessageOpt.V2TIM_RECEIVE_MESSAGE;
  // get msg
  getType = V2TIMMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG;
  count = 10;
  userID3?: string;
  groupID3?: string;
  messageTypeList?: V2TIMElemType[];
  lastMsg?: V2TIMMessage;
  lastMsgSeq?: number;
  getTimeBegin?: number;
  getTimePeriod?: number;
  messageSeqList?: number[];
  //clear message
  userID4 = "xlm";
  groupID4 = "";
  //insert message
  userID5 = "xlm";
  groupID5 = "";
  sender = "";
  //translate message
  sourceText1 = "";
  sourceText2 = "";
  sourceLanguage = "";
  targetLanguage = "";
  // find Message
  messageID1 = "";
  messageID2 = "";
  // read member
  isUnread = true;
}

export let info = new Info;

@Entry
@Component
export struct MessageManagerTestPage {
  @State result: Result = result;

  build() {
    Column() {
      Column() {
        Row({ space: 4 }) {
          DemoButton("清空", () => {
            this.result.callbackResult = "";
            this.result.result = "";
            this.result.progress = 0;
            this.result.progress2 = 0;
          })

          DemoButton("清空消息列表", () => {
            MessageTestInterfaces.clearMessageList();
          })
        }.DemoRowStyle()

        Scroll() {
          Column() {
            DemoTitle("接口调用结果：")
            DemoText({ name: this.result.result })
            DemoTitle("messageID：")
            DemoText({ name: this.result.messageID })
            DemoTitle("回调结果：")
            DemoText({ name: this.result.callbackResult })
          }.alignItems(HorizontalAlign.Start)
          .align(Alignment.TopStart)
        }.width('100%')
        .height('85%')
        .align(Alignment.TopStart)

        Column() {
          Progress({ value: this.result.progress }).alignSelf(ItemAlign.End)
          Progress({ value: this.result.progress2 }).alignSelf(ItemAlign.End)
        }.align(Alignment.BottomStart)
        .alignItems(HorizontalAlign.Start)
        .height('15%')

      }.width('100%')
      .height('35%')
      .alignItems(HorizontalAlign.Start)
      .align(Alignment.TopStart)

      Divider()

      Scroll() {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            DemoButton("addAdvancedMsgListener", () => {
              MessageTestInterfaces.addAdvancedMsgListener()
            })
            DemoButton("removeAdvancedMsgListener", () => {
              MessageTestInterfaces.removeAdvancedMsgListener()
            })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: info.text })
              .onChange((v) => {
                info.text = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: info.receiver })
              .onChange((v) => {
                info.receiver = v;
              })
              .demoTextInputStyle()
              .width('20%')

            TextInput({ placeholder: info.groupID })
              .onChange((v) => {
                info.groupID = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: info.imagePath })
              .onChange((v) => {
                info.imagePath = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: info.soundPath })
              .onChange((v) => {
                info.soundPath = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: info.videoPath })
              .onChange((v) => {
                info.videoPath = v;
              })
              .demoTextInputStyle()

            TextInput({ placeholder: info.snapshotPath })
              .onChange((v) => {
                info.snapshotPath = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("excludeFromUnreadCount")
            Checkbox()
              .onChange((v) => {
                info.excludeUnreadCount = v;
              })
              .width(14)
              .height(14)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("excludeFromLastMsg")
            Checkbox()
              .onChange((v) => {
                info.excludeLastMessage = v;
              })
              .width(14)
              .height(14)

            DemoLabel("onlineUserOnly")
            Checkbox()
              .onChange((v) => {
                info.onlineUserOnly = v;
              })
              .width(14)
              .height(14)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("excludeFromSecurityCheck")
            Checkbox()
              .onChange((v) => {
                info.excludeSecurityCheck = v;
              })
              .width(14)
              .height(14)
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("needReadReceipt")
            Checkbox()
              .onChange((v) => {
                info.needReadReceipt = v;
              })
              .width(14)
              .height(14)

            DemoLabel("priority")
            Select(getEnumKeys("V2TIMMessagePriority"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                info.priority = getEnumMap("V2TIMReceiveMessageOpt").get(value) as V2TIMMessagePriority;
              })
          }.DemoRowStyle()

          Row({ space: 4 }) {

          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("sendText", () => {
              MessageTestInterfaces.createTextMessageAndSend()
            })
            DemoButton("sendTextAt", () => {
              MessageTestInterfaces.createTextAtMessageAndSend()
            })
            DemoButton("sendCustom", () => {
              MessageTestInterfaces.createCustomMessageAndSend()
            })
            DemoButton("sendImage", () => {
              MessageTestInterfaces.createImageMessageAndSend()
            })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("sendSound", () => {
              MessageTestInterfaces.createSoundMessageAndSend()
            })
            DemoButton("sendVideo", () => {
              MessageTestInterfaces.createVideoMessageAndSend()
            })
            DemoButton("sendFile", () => {
              MessageTestInterfaces.createFileMessageAndSend()
            })
            DemoButton("sendLocation", () => {
              MessageTestInterfaces.createLocationMessageAndSend()
            })
          }.DemoRowStyle()


          Row({ space: 4 }) {
            DemoButton("sendFace", () => {
              MessageTestInterfaces.createFaceMessageAndSend()
            })
            DemoButton("sendMerge", () => {
              MessageTestInterfaces.createMergeMessageAndSend()
            })
            DemoButton("sendForward", () => {
              MessageTestInterfaces.createForwardMessageAndSend()
            })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("sendTargetedGroup", () => {
              MessageTestInterfaces.createTargetedGroupMessageAndSend()
            })
            DemoButton("sendAtSigned", () => {
              MessageTestInterfaces.createAtSignedGroupMessageAndSend()
            })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: info.userID1 })
              .onChange((v) => {
                info.userID1 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: info.userID2 })
              .onChange((v) => {
                info.userID2 = v;
              })
              .demoTextInputStyle()
            TextInput({ placeholder: info.groupID2 })
              .onChange((v) => {
                info.groupID2 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row() {
            DemoLabel("recvMsgOpt")
            Select(getEnumKeys("V2TIMReceiveMessageOpt"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                info.priority = getEnumMap("V2TIMReceiveMessageOpt").get(value) as V2TIMMessagePriority;
              })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("setC2CReceiveMessageOpt", (): void => MessageTestInterfaces.setC2CReceiveMessageOpt());
            DemoButton("setGroupReceiveMessageOpt", (): void => MessageTestInterfaces.setGroupReceiveMessageOpt());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getC2CReceiveMessageOpt", (): void => MessageTestInterfaces.getC2CReceiveMessageOpt());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("startHour")
            TextInput({ placeholder: info.startHour.toString() })
              .type(InputType.Number)
              .onChange((value: string) => {
                info.startHour = parseInt(value);
              }).demoTextInputStyle()
            DemoLabel("startMinute")
            TextInput({ placeholder: info.startMinute.toString() })
              .type(InputType.Number)
              .onChange((value: string) => {
                info.startMinute = parseInt(value);
              }).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("starSecond")
            TextInput({ placeholder: info.startSecond.toString() })
              .type(InputType.Number)
              .onChange((value: string) => {
                info.startSecond = parseInt(value);
              }).demoTextInputStyle()
            DemoLabel("duration")
            TextInput({ placeholder: info.duration.toString() })
              .type(InputType.Number)
              .onChange((value: string) => {
                info.duration = parseInt(value);
              }).demoTextInputStyle()
          }.DemoRowStyle()


          Row({ space: 4 }) {
            DemoLabel("startTimeStamp")
            TextInput({ placeholder: info.startTimeStamp.toString() })
              .type(InputType.Number)
              .onChange((value: string) => {
                info.startTimeStamp = parseInt(value);
              }).demoTextInputStyle()
            DemoLabel("opt")
            Select(getEnumKeys("V2TIMReceiveMessageOpt"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                info.recvOpt2 = getEnumMap("V2TIMReceiveMessageOpt").get(value) as V2TIMReceiveMessageOpt;
              })

          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("setAllReceiveMessageOpt", (): void => MessageTestInterfaces.setAllReceiveMessageOpt());
            DemoButton("setAllReceiveMessageOpt2", (): void => MessageTestInterfaces.setAllReceiveMessageOpt2());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getAllReceiveMessageOpt", (): void => MessageTestInterfaces.getAllReceiveMessageOpt());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("revokeMessage", (): void => MessageTestInterfaces.revokeMessage());
            DemoButton("modifyMessage", (): void => MessageTestInterfaces.modifyMessage());
            DemoButton("deleteMessage", (): void => MessageTestInterfaces.modifyMessage());
          }.DemoRowStyle()

          Column({ space: 4 }) {
            Row({ space: 4 }) {
              DemoLabel("userID4")
              TextInput({ placeholder: info.userID4 })
                .onChange((v) => {
                  info.userID4 = v;
                })
                .demoTextInputStyle()
              DemoLabel("groupID4")
              TextInput({ placeholder: info.groupID4 })
                .onChange((v) => {
                  info.groupID4 = v;
                })
                .demoTextInputStyle()

            }.DemoRowStyle()

            Row({ space: 4 }) {
              DemoButton("clearC2CHistoryMessage", (): void => MessageTestInterfaces.clearC2CHistoryMessage());
              DemoButton("clearGroupHistoryMessage", (): void => MessageTestInterfaces.clearGroupHistoryMessage());
            }.DemoRowStyle()

            // Row({ space: 4 }) {
            //   DemoButton("markC2CMessageAsRead", (): void => MessageTestInterfaces.markC2CMessageAsRead());
            //   DemoButton("markC2CMessageAsRead", (): void => MessageTestInterfaces.markC2CMessageAsRead());
            // }.DemoRowStyle()
            //
            // Row({ space: 4 }) {
            //   DemoButton("markAllMessageAsRead", (): void => MessageTestInterfaces.markAllMessageAsRead());
            // }.DemoRowStyle()
          }.alignItems(HorizontalAlign.Start)
          .align(Alignment.TopStart)
          .border({ color: Color.Green, style: BorderStyle.Dashed, width: 1, radius: 4 })

          Row({ space: 4 }) {
            DemoLabel("userID5")
            TextInput({ placeholder: info.userID5 })
              .onChange((v) => {
                info.userID5 = v;
              })
              .demoTextInputStyle()
            DemoLabel("groupID5")
            TextInput({ placeholder: info.groupID5 })
              .onChange((v) => {
                info.groupID5 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("sender")
            TextInput({ placeholder: info.sender })
              .onChange((v) => {
                info.sender = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("insertGroupMsgToLocal", (): void => MessageTestInterfaces.insertGroupMessageToLocalStorage());
            DemoButton("insertC2CMsgToLocal", (): void => MessageTestInterfaces.insertC2CMessageToLocalStorage());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("messageID1")
            TextInput({ placeholder: info.messageID1 })
              .onChange((v) => {
                info.messageID1 = v;
              })
              .demoTextInputStyle()
            DemoLabel("messageID2")
            TextInput({ placeholder: info.messageID2 })
              .onChange((v) => {
                info.messageID2 = v;
              })
              .demoTextInputStyle()
          }.DemoRowStyle()

          DemoButton("findMessages", (): void => MessageTestInterfaces.findMessages());

          Row({ space: 4 }) {
            DemoButton("sendMessageReadReceipts", (): void => MessageTestInterfaces.sendMessageReadReceipts());
            DemoButton("getMessageReadReceipts", (): void => MessageTestInterfaces.getMessageReadReceipts());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("isUnread")
            Toggle({ type: ToggleType.Checkbox })
              .onChange((v) => {
                info.isUnread = v;
              })
              .width(12)
              .height(12)
          }.DemoRowStyle()

          DemoButton("getGroupMessageReadMemberList", (): void => MessageTestInterfaces.getGroupMessageReadMemberList());

          Row({ space: 4 }) {
            DemoButton("setMessageExtensions", (): void => MessageTestInterfaces.setMessageExtensions());
            DemoButton("getMessageExtensions", (): void => MessageTestInterfaces.getMessageExtensions());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("deleteMessageExtensions", (): void => MessageTestInterfaces.deleteMessageExtensions());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("addMessageReaction", (): void => MessageTestInterfaces.addMessageReaction());
            DemoButton("removeMessageReaction", (): void => MessageTestInterfaces.removeMessageReaction());
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoButton("getMessageReactions", (): void => MessageTestInterfaces.getMessageReactions());
            DemoButton("getMessageReactionUserList", (): void => MessageTestInterfaces.getMessageReactionUserList());
          }.DemoRowStyle()

          // translate
          Column({ space: 4 }) {
            Row({ space: 4 }) {
              TextInput({ placeholder: 'sourceText1' })
                .onChange((value: string) => {
                  info.sourceText1 = value;
                })
                .demoTextInputStyle()
              TextInput({ placeholder: 'sourceText2' })
                .onChange((value: string) => {
                  info.sourceText2 = value;
                })
                .demoTextInputStyle()
            }.DemoRowStyle()

            Row({ space: 4 }) {
              TextInput({ placeholder: 'sourceLanguage' })
                .onChange((value: string) => {
                  info.sourceLanguage = value;
                })
                .demoTextInputStyle()
              TextInput({ placeholder: 'targetLanguage' })
                .onChange((value: string) => {
                  info.targetLanguage = value;
                })
                .demoTextInputStyle()
            }.DemoRowStyle()

            DemoButton("translateText", (): void => MessageTestInterfaces.translateText())

          }.align(Alignment.TopStart)
          .alignItems(HorizontalAlign.Start)

          Row({ space: 4 }) {
            Column() {
              DemoButton("getLocalCustomData", MessageTestInterfaces.getLocalCustomData);
              DemoButton("setLocalCustomData", MessageTestInterfaces.setLocalCustomData);
            }
            Column() {
              DemoButton("getLocalCustomInt", MessageTestInterfaces.getLocalCustomInt);
              DemoButton("setLocalCustomInt", MessageTestInterfaces.setLocalCustomInt);
            }
          }.DemoRowStyle()

          DemoButton("pick_and_upload", MessageTestInterfaces.pick_and_upload);

        }.alignItems(HorizontalAlign.Start)
        .align(Alignment.TopStart)
      }
      .height('65%')
      .width('100%')
      .padding(16)
    }
  }
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
