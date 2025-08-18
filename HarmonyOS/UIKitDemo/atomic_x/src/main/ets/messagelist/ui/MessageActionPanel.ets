import { MessageInfo, MessageListStore } from 'chatengine';
import { GetMessageView, MessageItem } from './MessageItem';
import { AppBuilderConfig, ThemeState, MessageAction } from '../../basecomponent/Index';
import promptAction from '@ohos.promptAction';
import clipboard from '@ohos.pasteboard';

interface ActionButtonConfig {
  text: string | Resource;
  action: string;
  icon?: Resource;
  color?: string;
  showDivider?: boolean;
}

@CustomDialog
export struct MessageActionDialog {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @ObjectLink message: MessageInfo;
  @ObjectLink messageListStore: MessageListStore;
  controller: CustomDialogController;
  onMessageDeleted?: (msgId: string) => void;
  onMessageRecalled?: (msgId: string) => void;
  @State showPrimaryMenu: boolean = true;
  @State showSecondaryMenu: boolean = false;
  @State primaryActions: ActionButtonConfig[] = [];
  @State secondaryActions: ActionButtonConfig[] = [];

  // Action configuration mapping
  private getActionConfig(action: MessageAction): ActionButtonConfig | null {
    switch (action) {
      case MessageAction.COPY:
        return {
          text: $r('app.string.action_copy'),
          action: 'copy',
          icon: $rawfile('messagelist/icon_extion_copy.png')
        };
      case MessageAction.RECALL:
        return {
          text: $r('app.string.action_recall'),
          action: 'recall',
          icon: $rawfile('messagelist/icon_extion_delete.png')
        };
      case MessageAction.DELETE:
        return {
          text: $r('app.string.action_delete'),
          action: 'delete',
          icon: $rawfile('messagelist/icon_extion_delete.png'),
          color: this.themeState.colors.textColorError
        };
      default:
        return null;
    }
  }

  aboutToAppear() {
    this.initializeActions();
  }

  /**
   * Initialize action buttons based on AppBuilderConfig.messageActionList
   * Only shows configured actions, no additional actions
   */
  private initializeActions() {
    const config = AppBuilderConfig.getInstance();
    const configuredActions: ActionButtonConfig[] = [];
    
    // Get configured actions from AppBuilderConfig.messageActionList
    // Only these actions will be displayed: COPY, RECALL, DELETE
    if (config.messageActionList && config.messageActionList.length > 0) {
      for (const messageAction of config.messageActionList) {
        const actionConfig = this.getActionConfig(messageAction);
        if (actionConfig) {
          configuredActions.push(actionConfig);
        }
      }
    }

    // Setup actions based on configured actions only
    const maxPrimaryActions = 4;
    
    if (configuredActions.length <= maxPrimaryActions) {
      // All actions fit in primary menu
      this.primaryActions = [...configuredActions];
      this.secondaryActions = [];
    } else {
      // Need secondary menu for overflow actions
      this.primaryActions = [
        ...configuredActions.slice(0, maxPrimaryActions - 1),
        {
          text: $r('app.string.action_more'),
          action: 'more',
          icon: $rawfile('messagelist/icon_extion_more.png'),
          color: '#147AFF',
          showDivider: true,
        }
      ];

      // Setup secondary actions menu with remaining configured actions
      this.secondaryActions = [
        ...configuredActions.slice(maxPrimaryActions - 1),
        {
          text: $r('app.string.action_back'),
          action: 'back',
          icon: $rawfile('messagelist/icon_extion_more.png'),
          color: '#147AFF',
          showDivider: true,
        }
      ];
    }
  }

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
        GetMessageView(message, this.messageListStore);
      }
      .borderRadius({
        topLeft: 16,
        topRight: 16,
        bottomLeft: 16,
        bottomRight: 0
      })
      .backgroundColor(this.themeState.colors.bgColorBubbleOwn)
      .borderWidth(1)
      .borderColor(this.themeState.colors.bgColorBubbleOwn)
      .justifyContent(FlexAlign.End)
    } else {
      Column() {
        GetMessageView(message, this.messageListStore);
      }
      .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
      .borderRadius({
        topLeft: 16,
        topRight: 16,
        bottomLeft: 0,
        bottomRight: 16
      })
      .flexShrink(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
  }

  build() {
    Column() {

      if (this.message.isSelf) {

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

        Row() {
          if (this.showPrimaryMenu) {
            this.buildActionMenu(this.primaryActions)
          }
          if (this.showSecondaryMenu) {
            this.buildActionMenu(this.secondaryActions);
          }
        }
        .width(180)
        .backgroundColor(this.themeState.getCurrentTheme().dropdownColorDefault)
        .borderRadius(16)
        .justifyContent(FlexAlign.End)
        .margin({ right: 0 })
      } else {

        Row() {
          if (this.showPrimaryMenu) {
            this.buildActionMenu(this.primaryActions);
          }
          if (this.showSecondaryMenu) {
            this.buildActionMenu(this.secondaryActions);
          }
        }
        .width(180)
        .backgroundColor(this.themeState.getCurrentTheme().dropdownColorDefault)
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
        .color(this.themeState.getCurrentTheme().strokeColorPrimary)
    }
    Button() {
      Row() {

        Text(config.text)
          .fontSize(16)
          .fontFamily('PingFangSC-Regular')
          .fontWeight(500)
          .fontColor(config.color || this.themeState.getCurrentTheme().textColorPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)


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

  private copyMessageToClipboard() {

    let messageContent = '';
    if (this.message.messageBody?.text) {
      messageContent = this.message.messageBody.text;
    } else {
      messageContent = '无法复制该类型的消息';
      promptAction.showToast({
        message: $r('app.string.messagelist_copy_unsupported'),
        duration: 2000
      });
      return;
    }

    let pasteData = clipboard.createData(clipboard.MIMETYPE_TEXT_PLAIN, messageContent);
    let systemPasteboard = clipboard.getSystemPasteboard();
    systemPasteboard.setData(pasteData, (err) => {
      if (err) {

        promptAction.showToast({
          message: $r('app.string.messagelist_copy_failed'),
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: $r('app.string.messagelist_copied'),
          duration: 2000
        });
      }
    });
  }

  private recallMessage() {

    if (!this.message.isSelf) {
      promptAction.showToast({
        message: $r('app.string.messagelist_recall_only_own'),
        duration: 2000
      });
      return;
    }


    if (this.onMessageRecalled) {
      this.onMessageRecalled(this.message.ID);
    } else {
      promptAction.showToast({
        message: $r('app.string.messagelist_recall_failed_no_callback'),
        duration: 2000
      });
    }
  }

  private deleteMessage() {
    if (this.onMessageDeleted) {

      this.onMessageDeleted(this.message.ID);
    } else {
      promptAction.showToast({
        message: $r('app.string.messagelist_delete_failed_no_callback'),
        duration: 2000
      });
    }
  }
}
