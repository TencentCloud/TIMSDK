import { V2TIMManager, V2TIMMessage, V2TIMMessageGetType, V2TIMMessageListGetOption } from '@tencentcloud/imsdk';
import Prompt from '@system.prompt';
import promptAction from '@ohos.promptAction';

@Observed
class GetInfo {
  userID = "xlm";
  groupID = "";
  from = 0;
  period = 0;
  seq = 0;
  count = 50;
  isCloud = false;
  messageList: V2TIMMessage[] = [];
  lastMessage: V2TIMMessage | undefined;
}

class MessageListDataSource implements IDataSource {
  private messageList: V2TIMMessage[] = [];
  private listeners: DataChangeListener[] = [];

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  getData(index: number) {
    return this.messageList[index];
  }

  totalCount(): number {
    return this.messageList.length;
  }

  onDataChanged(messages: V2TIMMessage[]) {
    this.messageList = messages;
    this.notifyDataReload();
  }
}

let getInfo = new GetInfo();

@Entry
@Component
export struct MessageFetchTestPage {
  @State messageData: MessageListDataSource = new MessageListDataSource();
  @State lastMessage: V2TIMMessage | null = null;
  @State lastSeq: number = 0;

  build() {
    Column() {
      Column({ space: 4 }) {
        Row({ space: 4 }) {
          TextInput({ placeholder: `userID(${getInfo.userID})` })
            .onChange((v) => getInfo.userID = v)
            .demoTextInputStyle()
          TextInput({ placeholder: "groupID" }).onChange((v) => getInfo.groupID = v).demoTextInputStyle()
        }.DemoRowStyle()

        Row({ space: 4 }) {
          TextInput({ placeholder: `开始时间戳(${getInfo.from})` })
            .type(InputType.Number)
            .onChange((v) => getInfo.from = parseInt(v))
            .demoTextInputStyle()
          TextInput({ placeholder: `时间范围(${getInfo.from}) 秒` })
            .type(InputType.Number)
            .onChange((v) => getInfo.period = parseInt(v))
            .demoTextInputStyle()
        }.DemoRowStyle()

        Row({ space: 4 }) {
          TextInput({ placeholder: `seq(${getInfo.seq})` })
            .type(InputType.Number)
            .onChange((v) => getInfo.seq = parseInt(v))
            .demoTextInputStyle()
          TextInput({ placeholder: `拉取数量(${getInfo.count})` })
            .type(InputType.Number)
            .onChange((v) => getInfo.count = parseInt(v))
            .demoTextInputStyle()
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoLabel("是否从云端拉取")
          Checkbox().size({ width: 12, height: 12 }).onChange((v) => getInfo.isCloud = v)
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoLabel("lastMsg")
          DemoText({ name: this.lastMessage?.msgID! })
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoLabel("lastSeq")
          DemoText({ name: this.lastSeq + "" })
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoButton("拉取更旧", () => {
            this.getHistoryMessage(false)
          })
          DemoButton("拉取更新", () => {
            this.getHistoryMessage(true)
          })
          DemoButton("重置", () => {
            this.messageData.onDataChanged([]);
            this.lastSeq = 0;
            this.lastMessage = null;
          })
        }.DemoRowStyle()
      }.height('35%')
      .alignItems(HorizontalAlign.Start)
      .align(Alignment.TopStart)

      Divider()

      Column() {
        List() {
          LazyForEach(this.messageData, (item: V2TIMMessage, index: number) => {
            ListItem() {
              Column() {
                Row({ space: 4 }) {
                  DemoTitle(index + ":")
                  DemoLabel("rand")
                  DemoTitle(item.random + "")
                  DemoLabel("time")
                  DemoTitle(item.timestamp + "")
                }.DemoRowStyle().height(18)

                Row({ space: 4 }) {
                  DemoLabel("seq")
                  DemoTitle(item.seq + "")
                  DemoLabel("type")
                  DemoTitle(item.elemType.toString())
                }.DemoRowStyle().height(18)

                Divider()
              }.align(Alignment.TopStart)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Start)
            }.stateStyles({
              normal: {.backgroundColor(Color.Transparent)
              },
              pressed: {.backgroundColor(0xFF452982)
              }
            })
            .onClick(() => {
              promptAction.showActionMenu({
                buttons: [{ text: "设置 lastMsg", color: "#FF452982" }, { text: "设置 seq", color: "0xFF452982" }]
              }).then((res) => {
                if (res.index === 0) {
                  this.lastMessage = item;
                } else if (res.index === 1) {
                  this.lastSeq = item.seq;
                }
              }).catch()
            })
          }, (item: V2TIMMessage, index: number) => item.msgID)
        }.listDirection(Axis.Vertical)
        .width('100%')
        .height('100%')
      }.height('65%')
    }
  }

  getHistoryMessage(isGetNewer: boolean) {
    let testGetType: V2TIMMessageGetType = V2TIMMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG;
    if (isGetNewer) {
      if (getInfo.isCloud) {
        testGetType = V2TIMMessageGetType.V2TIM_GET_CLOUD_NEWER_MSG;
      } else {
        testGetType = V2TIMMessageGetType.V2TIM_GET_LOCAL_NEWER_MSG;
      }
    } else {
      if (getInfo.isCloud) {
        testGetType = V2TIMMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG;
      }
    }
    const option: V2TIMMessageListGetOption = {
      getType: testGetType,
      userID: getInfo.userID,
      count: getInfo.count,
    };
    V2TIMManager.getMessageManager().getHistoryMessageList(option)
      .then((messageList: V2TIMMessage[]) => {
        this.messageData.onDataChanged(messageList);
        Prompt.showToast({ message: "getMessage success" });
      })
      .catch((error: Error) => {
        Prompt.showToast({ message: `getMessage failed ${error}` });
      });
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

interface DemoTextInterface {
  name: string;
}

@Builder function DemoText(param: DemoTextInterface) {
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

