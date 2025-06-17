// import {
//   TUIChatEngineV1,
//   TUIMessage,
//   TUIMessageGetOption,
//   V2TUIMessageDataProvider
// } from 'chatengine/src/main/ets/pages/ChatEngineV1';
// import { genTestUserSig, SDKAPPID } from '../signature/GenerateTestUserSig';
// import { MessageItem } from 'messagelist/src/main/ets/ui/MessageItem';
// import { MessageActionDialog } from 'messagelist/src/main/ets/ui/MessageActionPanel';
// import { MMKV } from '@tencent/mmkv';
// import { TimeUtil, ThemeManager } from 'basecomponent';
// import { add } from 'messageinput/src/main/ets/utils/Calc'
//
// @Entry
// @Component
// export struct Index {
//   @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
//   @State dataprovider?: V2TUIMessageDataProvider = undefined;
//   isUseClassic: boolean = false;
//   @State showMessageActions: boolean = false; // 控制弹窗显示
//   @State selectedMessage?: TUIMessage = undefined; // 当前选中的消息
//   dialogController: CustomDialogController | null = null
//   // 滚动控制器
//   private scroller: Scroller = new Scroller();
//
//   aboutToAppear(): void {
//     let userId = '99618';
//     let userSig = genTestUserSig(userId);
//     let loginPromise = TUIChatEngineV1.getInstance().login(SDKAPPID, userId, userSig);
//     loginPromise.then(() => {
//       console.log('[ChatEngine]login success');
//       this.loadMessage();
//     }).catch((error: object) => {
//       console.error('[ChatEngine]login failed', error);
//     });
//     add(1, 2);
//   }
//
//   loadMessage() {
//     this.dataprovider = TUIChatEngineV1.getInstance().getMessageDataProvider('chatID');
//     let op = new TUIMessageGetOption();
//     this.dataprovider.initIMSDKListener();
//     this.dataprovider.getMessageList(op).then((list) => {
//       list.forEach((item) => {
//         console.log('[ChatEngine]' + item.text);
//         this.scrollToBottom();
//       })
//     });
//   }
//
//   // 正确的对话框调用方法
//   showDialog() {
//     this.dialogController = new CustomDialogController({
//       builder: MessageActionDialog({
//         message: this.selectedMessage  // 传递参数
//       }),
//       alignment: DialogAlignment.Bottom, // 底部对齐
//       customStyle: true  // 启用自定义样式
//     })
//     this.dialogController.open()
//   }
//
//   @Builder
//   MessageItemBuilderClassicStyle(message: TUIMessage, index: number) {
//     Column() {
//       //时间显示逻辑
//       if (index === 0 ||
//         (message.timestamp ?? 0) - (this.dataprovider?.messageList[index - 1].timestamp ?? 0) >
//         TimeUtil.minuteDiffTimestamp) {
//         Text(TimeUtil.formatRelativeTime(message.timestamp ?? 0))
//           .fontSize(14)
//           .fontColor('#999999')
//           .backgroundColor('#F2F2F2')
//           .padding({
//             left: 8,
//             right: 8,
//             top: 4,
//             bottom: 4
//           })
//           .borderRadius(4)
//           .margin({ bottom: 8 })
//       }
//       MessageItem({
//         message: message,
//         showAvatar: true
//       }).padding({ top: 16, bottom: 16 })
//     }
//   }
//
//   @Builder
//   MessageItemBuilder(message: TUIMessage, index: number) {
//     Column() {
//
//       // 时间显示逻辑
//       if (index === 0 ||
//         (message.timestamp ?? 0) - (this.dataprovider?.messageList[index - 1]?.timestamp ?? 0) >
//         TimeUtil.minuteDiffTimestamp) {
//         Text(TimeUtil.formatRelativeTime(message.timestamp ?? 0))
//           .fontSize(14)
//           .fontColor('#999999')
//           .backgroundColor('#F2F2F2')
//           .padding({
//             left: 8,
//             right: 8,
//             top: 4,
//             bottom: 4
//           })
//           .borderRadius(4)
//           .margin({ bottom: 8 })
//       }
//       MessageItem({
//         message: message,
//         showAvatar: (
//           // 是否为最后一条消息
//           index === (this.dataprovider?.messageList?.length ?? 0) - 1 ||
//             // 或者下一条消息开始新的时间段
//             ((this.dataprovider?.messageList[index + 1]?.timestamp ?? 0) - (message.timestamp ?? 0) >
//             TimeUtil.minuteDiffTimestamp) ||
//             // 或者下一条消息是其他发送者
//             (this.dataprovider?.messageList[index + 1]?.isMe !== message.isMe)
//         ),
//         onLongPress: (message: TUIMessage) => {
//           this.selectedMessage = message;
//           this.showMessageActions = true;
//           this.showDialog()
//         }
//       })
//     }
//     .padding({
//       top: index > 0 &&
//         this.dataprovider?.messageList[index - 1]?.isMe === message.isMe &&
//         (message.timestamp ?? 0) - (this.dataprovider?.messageList[index - 1]?.timestamp ?? 0) <=
//         TimeUtil.minuteDiffTimestamp ? 2 : 8,
//       bottom: this.dataprovider?.messageList[index + 1]?.isMe === message.isMe &&
//         (this.dataprovider?.messageList[index + 1]?.timestamp ?? 0) - (message.timestamp ?? 0) <=
//         TimeUtil.minuteDiffTimestamp ? 2 : 8
//     })
//   }
//
//   build() {
//     Column() {
//       Row() {
//         // 消息列表标题
//         Text('Chat Messages')
//           .fontSize(24)
//           .fontColor(this.themeManager.currentTheme.textColorPrimary)
//           .fontWeight(FontWeight.Bold)
//           .margin({ top: 20, bottom: 15 })
//           .zIndex(1);
//         // 主题切换开关
//         Toggle({ type: ToggleType.Switch, isOn: false })
//           .onChange((isOn: boolean) => {
//             ThemeManager.getInstance().changeTheme(isOn ? 'dark' : 'light');
//             console.log('开关状态变更：', isOn ? '开启' : '关闭')
//           })
//           .width(40)// 设置宽度
//           .height(24) // 设置高度
//       }
//
//       // 消息列表容器
//       List({ space: 0, scroller: this.scroller }) {
//         ForEach(this.dataprovider?.messageList, (message: TUIMessage, index: number) => {
//           ListItem() {
//             if (this.isUseClassic) {
//               this.MessageItemBuilderClassicStyle(message, index);
//             } else {
//               this.MessageItemBuilder(message, index);
//             }
//           }
//         }, (message: TUIMessage) => message.messageId)
//       }
//       .width('100%')
//       .layoutWeight(1)
//       .onScroll(() => {
//         // 可以在这里添加滚动事件处理
//       })
//
//       // 底部输入区域 (可选)
//       MessageInput({ dataprovider: this.dataprovider, scroller: this.scroller })
//         .margin({ top: 10 })
//
//     }
//     .width('100%')
//     .height('100%')
//     .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
//     .padding(16)
//     .onAppear(() => {
//       // 页面显示时滚动到底部
//       this.scrollToBottom();
//     })
//     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
//
//   }
//
//   // 滚动到底部方法
//   private scrollToBottom() {
//     this.scroller?.scrollEdge(Edge.End);
//   }
// }
//
// // 消息输入组件 (可选)
// @Component
// struct MessageInput {
//   @Link dataprovider?: V2TUIMessageDataProvider;
//   @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
//   @State private inputText: string = '';
//   private scroller: Scroller = new Scroller();
//
//   build() {
//     Row() {
//       TextInput({ text: this.inputText, placeholder: 'Type a message...' })
//         .onChange((value: string) => {
//           this.inputText = value;
//         })
//         .layoutWeight(1)
//         .height(40)
//         .padding(8)
//         .borderRadius(20)
//         .placeholderColor(this.themeManager.currentTheme.textColorTertiary)
//         .backgroundColor(this.themeManager.currentTheme.bgColorInput)
//
//       Button('Send')
//         .margin({ left: 8 })
//         .backgroundColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
//         .onClick(() => {
//           if (this.inputText.trim()) {
//             // 发送消息逻辑
//             if (this.dataprovider) {
//               let msg = new TUIMessage();
//               msg.text = this.inputText;
//               this.dataprovider?.sendMessage(msg);
//               this.scroller?.scrollEdge(Edge.End);
//             }
//           }
//         })
//     }
//     .width('100%')
//     .padding(8)
//     .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
//   }
// }
