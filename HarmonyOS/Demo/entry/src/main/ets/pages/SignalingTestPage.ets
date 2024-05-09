import { V2TIMIOSOfflinePushType, V2TIMOfflinePushInfo } from '@tencentcloud/imsdk/src/main/ets/V2TIMMessage';
import { SignalingTestInterfaces } from '../interfaces/SignalingTestInterfaces';

@Observed
class Result {
  result = "";
  inviteID = "";
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

export default result;
let offlinePushInfo: V2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
offlinePushInfo.title = "SignalingTitle";
offlinePushInfo.desc = "SignalingDesc";
offlinePushInfo.ext = "SignalingExt";
offlinePushInfo.disablePush = false;
offlinePushInfo.iOSPushType = V2TIMIOSOfflinePushType.V2TIM_IOS_OFFLINE_PUSH_TYPE_APNS;
offlinePushInfo.ignoreIOSBadge = false;
offlinePushInfo.iOSSound = "";
offlinePushInfo.AndroidHuaWeiCategory = "tuikit"
offlinePushInfo.AndroidSound = "tuikit"
offlinePushInfo.AndroidOPPOChannelID = "tuikit"
offlinePushInfo.AndroidXiaoMiChannelID = "tuikit"


@Entry
@Component
export struct SignalingTestPage {
  @State result: Result = result;
  groupID = "";
  userID1 = "";
  userID2 = "";
  timeout = 30;
  onlineUserOnly = false;
  offlinePush = false;
  data = ""

  build() {
    Column() {
      Scroll() {
        Column() {
          DemoButton("清空", () => {
            this.result.result = "";
            this.result.inviteID = "";
            this.result.callbackResult = "";
          })
          DemoTitle("接口调用结果：")
          DemoText({ name: this.result.result })
          DemoTitle("inviteID：")
          DemoText({ name: this.result.inviteID })
          DemoTitle("回调结果：")
          DemoText({ name: this.result.callbackResult })
        }.align(Alignment.TopStart)
        .alignItems(HorizontalAlign.Start)

      }
      .align(Alignment.TopStart)
      .width('100%')
      .height('35%')

      Divider()

      Column({ space: 10 }) {
        Row() {
          TextInput({ placeholder: "groupID" })
            .type(InputType.Normal)
            .onChange((v) => {
              this.groupID = v;
            })
            .demoTextInputStyle()
            .margin(4)

          TextInput({ placeholder: "c2c/userID1" })
            .type(InputType.Normal)
            .onChange((v) => {
              this.userID1 = v;
            })
            .demoTextInputStyle()
            .margin(4)

          TextInput({ placeholder: "userID2" })
            .type(InputType.Normal)
            .onChange((v) => {
              this.userID2 = v;
            })
            .demoTextInputStyle()
            .margin(4)

        }.DemoRowStyle()

        Row() {

          TextInput({ placeholder: "timeout(default 30)" })
            .type(InputType.Number)
            .onChange((v) => {
              this.timeout = parseInt(v);
            })
            .demoTextInputStyle()
            .margin(4)
            .width('40%')
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoLabel("onlineUserOnly")
          Toggle({ type: ToggleType.Checkbox })
            .onChange((b) => {
              this.onlineUserOnly = b;
            })
            .size({ width: 14, height: 14 })

          DemoLabel("offlinePush")
          Toggle({ type: ToggleType.Checkbox })
            .onChange((b) => {
              this.offlinePush = b;
            })
            .size({ width: 14, height: 14 })
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoLabel("data")
          TextInput({ placeholder: "signalingData" })
            .type(InputType.Normal)
            .onChange((v) => {
              this.data = v;
            })
            .demoTextInputStyle()
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoButton("添加信令监听", () => {
            SignalingTestInterfaces.addSignalingListener();
          })
          DemoButton("移除信令监听", () => {
            SignalingTestInterfaces.removeSignalingListener();
          })
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoButton("邀请个人", () => {
            SignalingTestInterfaces.invite(this.userID1, this.data, this.onlineUserOnly, this.offlinePush ? offlinePushInfo : null, this.timeout);
          })
          DemoButton("邀请群", () => {
            SignalingTestInterfaces.inviteInGroup(this.groupID, [this.userID1, this.userID2], this.data, this.onlineUserOnly, this.timeout);
          })
          DemoButton("取消邀请", () => {
            SignalingTestInterfaces.cancel(result.inviteID, this.data);
          })
        }.DemoRowStyle()

        Row({ space: 4 }) {
          DemoButton("接受", () => {
            SignalingTestInterfaces.accept(result.inviteID, this.data);
          })
          DemoButton("拒绝", () => {
            SignalingTestInterfaces.reject(result.inviteID, this.data);
          })
          DemoButton("修改信令", () => {
            SignalingTestInterfaces.modifyInvitation(result.inviteID, this.data);
          })
        }.DemoRowStyle()
      }
      .margin({ top: 10 })
      .height('65%')
      .width('100%')
      .align(Alignment.TopStart)
      .alignItems(HorizontalAlign.Start)

    }
    .alignItems(HorizontalAlign.Start)
    .align(Alignment.TopStart)
    .padding(4)

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
