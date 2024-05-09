// Copyright (c) 2023 Tencent. All rights reserved.

import {
  V2TIMConversationType,
} from '@tencentcloud/imsdk'

import { getEnumKeys, getEnumMap } from "../tools/GetEnum";

import { ConversationTestInterfaces } from '../interfaces/ConversationTestInterfaces';

@Observed
class Result {
  result = ""
  callbackResult = ""
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

@Entry
@Component
export struct ConversationManagerTestPage {
  @State result: Result = result;
  nextSeq = 0;
  count = 10;
  conversationID = "";
  conversationID2 = "";
  conversationID3 = "";
  clearMessage = false;
  draftText = "draftText11";
  nextSeq2 = 0;
  count2 = 0;
  markType = 0;
  conversationType: string | undefined;
  type: V2TIMConversationType | undefined;
  conversationID4 = "";
  conversationID5 = "";
  customBuffer = "";
  //pin
  conversationID6 = "";
  isPin = false;
  // mark
  conversationID7 = "";
  conversationID8 = "";
  markType2 = 0;
  enableMark = false;
  // unread
  conversationGroup = "";
  type2: V2TIMConversationType | undefined;
  markType3 = 0;

  // clear unread
  conversationID9 = "";
  cleanTimestamp = 0;
  cleanSequence = 0;

  //create conversation group
  conversationID10 = "";
  conversationID11 = "";
  conversationGroupName = "";
  oldGroupName = "";
  newGroupName = "";

  //add conversation to group
  conversationID12 = "";
  conversationID13 = "";
  conversationGroupName2 = "";

  build() {
    Column() {
      Column() {
        DemoButton("清空", () => {
          this.result.result = "";
          this.result.callbackResult = "";
        })
        DemoTitle("接口调用结果：")
        DemoText({ name: this.result.result })
        DemoTitle("回调结果：")
        DemoText({ name: this.result.callbackResult })
      }.width('100%')
      .height('35%')
      .alignItems(HorizontalAlign.Start)

      Divider()

      Scroll() {
        Column({ space: 16 }) {
          Row({ space: 10 }) {
            DemoButton("addConversationListener", ConversationTestInterfaces.addConversationListener);
            DemoButton("removeConversationListener", ConversationTestInterfaces.removeConversationListener);
          }.demoRowStyle()

          Row({ space: 10 }) {
            DemoLabel("nextSeq")
            TextInput({ placeholder: '0' })
              .type(InputType.Number)
              .onChange((value: string) => this.nextSeq = parseInt(value))
              .demoTextInputStyle().width(40)
            DemoLabel("count")
            TextInput({ placeholder: '10' })
              .type(InputType.Number)
              .onChange((value: string) => this.count = parseInt(value))
              .demoTextInputStyle().width(40)
          }.demoRowStyle()

          Row() {
            DemoButton("getConversationListByFilter", () => {
              ConversationTestInterfaces.getConversationListByFilter(this.nextSeq, this.count);
            });
          }.demoRowStyle()

          Row({ space: 10 }) {
            DemoLabel("conversationID")
            TextInput({ placeholder: '' })
              .onChange((value: string) => {
                this.conversationID = value;
              })
              .demoTextInputStyle()
          }.demoRowStyle()

          Row({ space: 10 }) {
            DemoLabel('draftText')
            TextInput({ placeholder: 'draftText11' })
              .onChange((value: string) => {
                this.draftText = value;
              }).demoTextInputStyle()
          }.demoRowStyle()

          Row({ space: 10 }) {
            DemoButton("getConversation", () => {
              ConversationTestInterfaces.getConversation(this.conversationID);
            })
            DemoButton("deleteConversation", () => {
              ConversationTestInterfaces.deleteConversation(this.conversationID);
            })
          }.demoRowStyle()


          Row({ space: 10 }) {
            DemoButton("setConversationDraft", () => {
              ConversationTestInterfaces.setConversationDraft(this.conversationID, this.draftText);
            })
            DemoButton("getTotalUnreadMessageCount", () => {
              ConversationTestInterfaces.getTotalUnreadMessageCount();
            })
          }.demoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("conversationID2")
            TextInput({ placeholder: 'conversationID2' })
              .onChange((value: string) => {
                this.conversationID2 = value;
              }).demoTextInputStyle()

          }.demoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("conversationID3")
            TextInput({ placeholder: 'conversationID3' })
              .onChange((value: string) => {
                this.conversationID3 = value;
              }).demoTextInputStyle()

            DemoLabel("clearMessage")
            Checkbox()
              .size({ width: 14 })
              .onChange((value: boolean) => {
                this.clearMessage = value;
              })

          }.demoRowStyle()

          Row({ space: 10 }) {
            DemoButton("getConversationList", () => {
              ConversationTestInterfaces.getConversationList(this.conversationID2, this.conversationID3);
            })
            DemoButton("deleteConversationList", () => {
              ConversationTestInterfaces.deleteConversationList([this.conversationID2, this.conversationID3], this.clearMessage);
            })
          }.demoRowStyle()

          Flex({ wrap: FlexWrap.Wrap }) {
            DemoLabel("nextSeq2")
            TextInput({ placeholder: '0' })
              .type(InputType.Number)
              .onChange((value: string) => this.nextSeq2 = parseInt(value))
              .demoTextInputStyle().width(40)
            DemoLabel("count2")
            TextInput({ placeholder: '10' })
              .type(InputType.Number)
              .onChange((value: string) => this.count2 = parseInt(value))
              .demoTextInputStyle().width(40)
            DemoLabel("markType")
            TextInput({ placeholder: '0' })
              .type(InputType.Number)
              .onChange((value: string) => this.markType = parseInt(value))
              .demoTextInputStyle().width(40)
            DemoLabel("conversationType")
            TextInput({ placeholder: '0' })
              .onChange((value: string) => this.conversationType = value)
              .demoTextInputStyle().width(40)
            DemoLabel("Type")
            Select(getEnumKeys("V2TIMConversationType"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                this.type = getEnumMap("V2TIMConversationType").get(value);
              })
          }

          Row({ space: 10 }) {
            DemoButton("getConversationList", () => {
              ConversationTestInterfaces.getConversationListByFilter2(this.nextSeq2, this.count2, this.type, this.conversationType, this.markType);
            })
          }.demoRowStyle()


          Flex({ wrap: FlexWrap.Wrap }) {
            DemoLabel("conversationID4")
            TextInput({ placeholder: 'conversationID4' })
              .onChange((value: string) => {
                this.conversationID4 = value;
              }).demoTextInputStyle()

            DemoLabel("conversationID5")
            TextInput({ placeholder: 'conversationID5' })
              .onChange((value: string) => {
                this.conversationID5 = value;
              }).demoTextInputStyle()

            DemoLabel("customBuffer")
            TextInput({ placeholder: 'customBuffer' })
              .onChange((value: string) => {
                this.customBuffer = value;
              }).demoTextInputStyle()
          }

          Row({ space: 10 }) {
            DemoButton("setConversationCustomData", () => {
              ConversationTestInterfaces.setConversationCustomData(this.customBuffer, this.conversationID2, this.conversationID3);
            })
          }.demoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("conversationID6")
            TextInput({ placeholder: 'conversationID6' })
              .onChange((value: string) => {
                this.conversationID6 = value;
              }).demoTextInputStyle()

            DemoLabel("isPin")
            Checkbox()
              .size({ width: 14 })
              .onChange((value: boolean) => {
                this.isPin = value;
              })

          }.demoRowStyle()

          Row({ space: 10 }) {
            DemoButton("pinConversation", () => {
              ConversationTestInterfaces.pinConversation(this.conversationID2, this.isPin);
            })
          }.demoRowStyle()

          Flex({ wrap: FlexWrap.Wrap }) {
            DemoLabel("conversationID7")
            TextInput({ placeholder: 'conversationID7' })
              .onChange((value: string) => {
                this.conversationID7 = value;
              }).demoTextInputStyle()
            DemoLabel("conversationID8")
            TextInput({ placeholder: 'conversationID8' })
              .onChange((value: string) => {
                this.conversationID8 = value;
              }).demoTextInputStyle()
            DemoLabel("markType2")
            TextInput({ placeholder: 'markType2' })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.markType2 = Number(value);
              }).demoTextInputStyle()
            DemoLabel("enableMark")
            Checkbox({ name: 'enableMark' })
              .width(12)
              .onChange((value: boolean) => {
                this.enableMark = value;
              })
          }

          Row({ space: 10 }) {
            DemoButton("markConversation", () => {
              ConversationTestInterfaces.markConversation([this.conversationID7, this.conversationID8], this.markType2, this.isPin);
            })
          }.demoRowStyle()

          Flex({ wrap: FlexWrap.Wrap }) {
            DemoLabel("conversationGroup")
            TextInput({ placeholder: 'conversationGroup' })
              .onChange((value: string) => {
                this.conversationGroup = value;
              }).demoTextInputStyle()
            DemoLabel("markType3")
            TextInput({ placeholder: 'markType' })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.markType3 = Number(value);
              }).demoTextInputStyle()
            DemoLabel("type2")

            Select(getEnumKeys("V2TIMConversationType"))
              .font({ size: 12 })
              .selected(0)
              .onSelect((index: number, value: string) => {
                this.type2 = getEnumMap("V2TIMConversationType").get(value);
              })
          }

          Row() {
            DemoButton("getUnreadMessageCountByFilter", () => {
              ConversationTestInterfaces.getUnreadMessageCountByFilter(this.conversationGroup, this.markType3, this.type2);
            })
          }.demoRowStyle()

          Row() {
            DemoButton("subscribeUnreadMessageCountByFilter", () => {
              ConversationTestInterfaces.subscribeUnreadMessageCountByFilter(this.conversationGroup, this.markType3, this.type2);
            })
          }.demoRowStyle()

          Row() {
            DemoButton("unsubscribeUnreadMessageCountByFilter", () => {
              ConversationTestInterfaces.unsubscribeUnreadMessageCountByFilter(this.conversationGroup, this.markType3, this.type2);
            })
          }.demoRowStyle()

          Flex({ wrap: FlexWrap.Wrap }) {
            TextInput({ placeholder: 'conversationID9' })
              .onChange((value: string) => {
                this.conversationID9 = value;
              })
              .demoTextInputStyle()
              .margin({ right: 10 })

            TextInput({ placeholder: 'cleanTimestamp' })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.cleanTimestamp = parseInt(value);
              })
              .demoTextInputStyle()
              .margin({ right: 10 })


            TextInput({ placeholder: 'cleanSequence' })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.cleanSequence = parseInt(value);
              })
              .demoTextInputStyle()
          }

          Row() {
            DemoButton("cleanConversationUnreadMessageCount", () => {
              ConversationTestInterfaces.cleanConversationUnreadMessageCount(this.conversationID9, this.cleanTimestamp, this.cleanSequence);
            })
          }.demoRowStyle()

          Flex({ wrap: FlexWrap.Wrap }) {
            TextInput({ placeholder: 'groupName' })
              .onChange((value: string) => {
                this.conversationGroupName = value;
              })
              .demoTextInputStyle()
              .margin({ right: 10 })

            TextInput({ placeholder: 'conversationID10' })
              .onChange((value: string) => {
                this.conversationID10 = value;
              })
              .demoTextInputStyle()
              .margin({ right: 10 })
            TextInput({ placeholder: 'conversationID11' })
              .onChange((value: string) => {
                this.conversationID11 = value;
              })
              .demoTextInputStyle()
              .margin({ right: 10 })

          }

          Row({ space: 4 }) {
            DemoButton("createConversationGroup", () => {
              ConversationTestInterfaces.createConversationGroup(this.conversationGroupName, this.conversationID10, this.conversationID11);
            })

            DemoButton("deleteConversationGroup", () => {
              ConversationTestInterfaces.deleteConversationGroup(this.conversationGroupName);
            })
          }.demoRowStyle()

          Row() {
            DemoButton("getConversationGroupList", (): void => ConversationTestInterfaces.getConversationGroupList());
          }.demoRowStyle()

          Row({ space: 4 }) {

            TextInput({ placeholder: 'oldGroupName' })
              .onChange((value: string) => {
                this.oldGroupName = value;
              }).demoTextInputStyle()
            TextInput({ placeholder: 'newGroupName' })
              .onChange((value: string) => {
                this.newGroupName = value;
              }).demoTextInputStyle()
          }.demoRowStyle()

          Row() {
            DemoButton("renameConversationGroup", (): void => ConversationTestInterfaces.renameConversationGroup(this.oldGroupName, this.newGroupName));
          }.demoRowStyle()


          Flex({ wrap: FlexWrap.Wrap }) {
            TextInput({ placeholder: 'groupName2' })
              .onChange((value: string) => {
                this.conversationGroupName2 = value;
              })
              .demoTextInputStyle()
              .margin({ right: 10 })

            TextInput({ placeholder: 'conversationID12' })
              .onChange((value: string) => {
                this.conversationID12 = value;
              })
              .demoTextInputStyle()
              .margin({ right: 10 })
            TextInput({ placeholder: 'conversationID13' })
              .onChange((value: string) => {
                this.conversationID13 = value;
              })
              .demoTextInputStyle()
              .margin({ right: 10 })

          }

          Row({ space: 4 }) {
            DemoButton("addConversationsToGroup", () => {
              ConversationTestInterfaces.addConversationsToGroup(this.conversationGroupName2, this.conversationID12, this.conversationID13);
            })

            DemoButton("deleteConversationsFromGroup", () => {
              ConversationTestInterfaces.deleteConversationsFromGroup(this.conversationGroupName, this.conversationID12, this.conversationID13);
            })
          }.demoRowStyle()

          Row({ space: 4 }) {
            DemoButton("testConversationGroupList", ConversationTestInterfaces.testConversationGroupList)
          }.demoRowStyle()
        }
      }
      .height('65%')
      .width('100%')
      .padding(16)
      .scrollBar(BarState.On)

    }
  }
}

@Extend(Button) function dialogButtonStyle() {
  .backgroundColor(Color.White)
  .fontColor('#007DFF')
  .height(16)
}

@Extend(Text) function dialogTextStyle() {
  .fontSize(16)
  .textAlign(TextAlign.Start)
}

@Extend(Row) function dialogRowStyle() {
  .width('100%')
}

@Extend(Column) function dialogColumnStyle() {
  .backgroundColor(Color.White)
  .borderRadius(16)
  .padding(16)
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

@Extend(Row) function demoRowStyle() {
  .width('100%')
  .justifyContent(FlexAlign.Start)
}
