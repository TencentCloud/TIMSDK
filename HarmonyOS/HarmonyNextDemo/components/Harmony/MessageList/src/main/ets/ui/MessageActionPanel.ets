import { MessageInfo, MessageListState } from 'chatengine/src/main/ets/pages/MessageListState';
import { GetMessageView, MessageItem } from './MessageItem';
import { ThemeManager } from 'basecomponent';
import promptAction from '@ohos.promptAction';
import clipboard from '@ohos.pasteboard';

interface ActionButtonConfig {
  text: string | Resource;
  action: string;
  icon?: Resource; // 图标资源
  color?: string; // 文字颜色
  showDivider?: boolean; // 新增分割线标识
}


@CustomDialog
export struct MessageActionDialog {
  // 本地主题状态（与管理器同步）
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  @ObjectLink message: MessageInfo;
  @ObjectLink messageListState: MessageListState;
  controller: CustomDialogController;
  onMessageDeleted?: (msgId: string) => void; // 消息删除回调
  onMessageRecalled?: (msgId: string) => void; // 消息撤回回调
  @State showPrimaryMenu: boolean = true;
  @State showSecondaryMenu: boolean = false;
  @State primaryActions: ActionButtonConfig[] = [
    { text: $r('app.string.action_copy'), action: 'copy', icon: $r('app.media.icon_extion_copy') },
    { text: $r('app.string.action_forward'), action: 'forward', icon: $r('app.media.icon_extion_forward') },
    { text: $r('app.string.action_multi_select'), action: 'multiSelect', icon: $r('app.media.icon_extion_multi') },
    { text: $r('app.string.action_quote'), action: 'quote', icon: $r('app.media.icon_extion_quote') },
    {
      text: $r('app.string.action_more'),
      action: 'more',
      icon: $r('app.media.icon_extion_more'),
      color: '#147AFF',
      showDivider: true,
    },
  ];
  @State secondaryActions: ActionButtonConfig[] = [
    { text: $r('app.string.action_reply'), action: 'reply', icon: $r('app.media.icon_extion_reply') },
    { text: $r('app.string.action_translate'), action: 'translate', icon: $r('app.media.icon_extion_forward') },
    { text: $r('app.string.action_recall'), action: 'recall', icon: $r('app.media.icon_extion_delete') },
    {
      text: $r('app.string.action_delete'),
      action: 'delete',
      icon: $r('app.media.icon_extion_delete'),
      color: this.themeManager.currentTheme.textColorError
    },
    {
      text: $r('app.string.action_back'),
      action: 'back',
      icon: $r('app.media.icon_extion_more'),
      color: '#147AFF',
      showDivider: true,
    },
  ];

  @Builder
  buildActionMenu(actions: ActionButtonConfig[]) {
    Column() {
      ForEach(actions, (action: ActionButtonConfig) => {
        this.IconButton({
          text: action.text,
          action: action.action,
          icon: action.icon,
          color: action.color,
          showDivider: action.showDivider,
        })
      })
    }
  }

  @Builder
  MessageBubble(message: MessageInfo) {
    if (message.isSelf) {
      Column() {
        GetMessageView(message, this.messageListState);
      }
      .borderRadius({
        topLeft: 16,
        topRight: 16,
        bottomLeft: 16,
        bottomRight: 0
      })
      .backgroundColor(this.themeManager.currentTheme.bgColorBubbleOwn)
      .borderWidth(1)
      .borderColor(this.themeManager.currentTheme.bgColorBubbleOwn)
      .justifyContent(FlexAlign.End) // 靠右对齐
    } else {
      Column() {
        GetMessageView(message, this.messageListState);
      }
      .backgroundColor(this.themeManager.currentTheme.bgColorBubbleReciprocal)
      .borderRadius({
        topLeft: 16,
        topRight: 16,
        bottomLeft: 0,
        bottomRight: 16
      })
      .flexShrink(1)
      .alignItems(HorizontalAlign.Start) // 确保内容左对齐
      .justifyContent(FlexAlign.Start) // 靠右对齐
    }
  }

  build() {
    Column() {
      // 消息内容区域
      if (this.message.isSelf) {
        // 消息气泡
        Row() {
          Row() {
            this.MessageBubble(this.message);
          }
          .width('80%')
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 8 })
      } else {
        // 消息气泡
        Row() {
          Row() {
            this.MessageBubble(this.message);
          }
          .width('80%')
          .justifyContent(FlexAlign.Start)
        }
        .padding({ left: 36 })
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 8 })
      }

      if (this.message.isSelf) {
        // 操作按钮气泡
        Row() {
          if (this.showPrimaryMenu) {
            this.buildActionMenu(this.primaryActions)
          }
          if (this.showSecondaryMenu) {
            this.buildActionMenu(this.secondaryActions);
          }
        }
        .width(180)
        .backgroundColor(this.themeManager.getCurrentTheme().dropdownColorDefault)
        .borderRadius(16)
        .justifyContent(FlexAlign.End)
        .margin({ right: 0 })
      } else {
        // 操作按钮气泡
        Row() {
          if (this.showPrimaryMenu) {
            this.buildActionMenu(this.primaryActions);
          }
          if (this.showSecondaryMenu) {
            this.buildActionMenu(this.secondaryActions);
          }
        }
        .width(180)
        .backgroundColor(this.themeManager.getCurrentTheme().dropdownColorDefault)
        .borderRadius(16)
        .justifyContent(FlexAlign.Start)
        .margin({ left: 36 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Center)
    .alignItems(this.message.isSelf ? HorizontalAlign.End : HorizontalAlign.Start)
    .backgroundColor('rgba(0, 0, 0, 0.6)')
    .backdropBlur(8)
    .onClick(() => this.handleAction('close'))
  }

  @Builder
  private IconButton(config: ActionButtonConfig) {

    if (config.showDivider) {
      Divider()
        .width('100%')
        .height(2)
        .color(this.themeManager.getCurrentTheme().strokeColorPrimary)
    }
    Button() {
      Row() {
        // 左侧文本
        Text(config.text)
          .fontSize(16)
          .fontFamily('PingFangSC-Regular')
          .fontWeight(500)
          .fontColor(config.color || this.themeManager.getCurrentTheme().textColorPrimary)
          .layoutWeight(1)// 占据剩余空间
          .textAlign(TextAlign.Start)

        // 右侧图标
        Image(config.icon)
          .width(17)
          .height(17)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.Transparent)
    .padding({ left: 16, right: 16 })
    .onClick(() => this.handleAction(config.action))
    .width('100%')
    .height(44)
  }

  private handleAction(action: string) {
    console.log('执行操作:', action)
    if (action === 'more') {
      this.showPrimaryMenu = false
      this.showSecondaryMenu = true
    } else if (action === 'back') {
      this.showSecondaryMenu = false
      this.showPrimaryMenu = true
    } else if (action === 'copy') {
      this.copyMessageToClipboard()
    } else if (action === 'recall') {
      this.recallMessage()
    } else if (action === 'delete') {
      this.deleteMessage()
    }

    if (action !== 'more' && action !== 'back') {
      this.controller.close()
    }
  }

  /**
   * 复制消息到剪贴板
   */
  private copyMessageToClipboard() {
    // 获取消息内容
    let messageContent = '';
    if (this.message.messageBody?.text) {
      messageContent = this.message.messageBody.text;
    } else {
      messageContent = '无法复制该类型的消息';
      promptAction.showToast({
        message: '该类型消息不支持复制',
        duration: 2000
      });
      return;
    }

    let pasteData = clipboard.createData(clipboard.MIMETYPE_TEXT_PLAIN, messageContent);
    let systemPasteboard = clipboard.getSystemPasteboard();
    systemPasteboard.setData(pasteData, (err) => {
      if (err) {
        console.error(`复制到剪贴板失败: ${err}`);
        promptAction.showToast({
          message: '复制失败',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '已复制',
          duration: 2000
        });
      }
    });
  }

  /**
   * 撤回消息
   */
  private recallMessage() {
    // 只有自己的消息才能撤回
    if (!this.message.isSelf) {
      promptAction.showToast({
        message: '只能撤回自己发送的消息',
        duration: 2000
      });
      return;
    }

    // 调用回调函数处理撤回
    if (this.onMessageRecalled) {
      this.onMessageRecalled(this.message.ID);
    } else {
      console.error('未设置onMessageRecalled回调');
      promptAction.showToast({
        message: '撤回失败: 未设置撤回回调',
        duration: 2000
      });
    }
  }

  /**
   * 删除消息
   */
  private deleteMessage() {
    if (this.onMessageDeleted) {
      // 使用ID属性而不是id属性
      this.onMessageDeleted(this.message.ID);
    } else {
      console.error('未设置onMessageDeleted回调');
      promptAction.showToast({
        message: '删除失败: 未设置删除回调',
        duration: 2000
      });
    }
  }
}
