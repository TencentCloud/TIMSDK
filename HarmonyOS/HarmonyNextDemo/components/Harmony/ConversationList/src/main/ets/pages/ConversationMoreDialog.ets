import { ThemeManager } from 'basecomponent';
import { ConversationInfo, Util } from 'chatengine';

interface ActionButtonConfig {
  text: string | Resource;
  action: string;
  color?: string; // 文字颜色
  showDivider?: boolean; // 是否显示分割线
}

@CustomDialog
export struct ConversationMoreDialog {
  // 按钮高度
  private static readonly BUTTON_HEIGHT: number = 56;
  // 底部圆角
  private static readonly BOTTOM_RADIUS: number = 14;
  // 本地主题状态（与管理器同步）
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  @ObjectLink conversation: ConversationInfo;
  controller: CustomDialogController;
  // 定义操作按钮
  @State actionButtons: ActionButtonConfig[] = [];
  onDeleteConversation?: (id: string) => void;
  onClearConversation?: (id: string) => void;
  onPinConversation?: (id: string) => void;
  onHideConverSation?: (id: string) => void;

  aboutToAppear() {
    // Initialize action buttons with dynamic texts based on conversation state
    this.actionButtons = [
      {
        text: $r('app.string.hide_conversation'),
        action: 'hideConversation',
        showDivider: true
      },
      {
        text: this.conversation?.isPinned ?
        $r('app.string.unpin_conversation') :
        $r('app.string.pin_conversation'),
        action: 'pinConversation',
        showDivider: true
      },
      {
        text: $r('app.string.clear_messages'),
        action: 'clearConversation',
        showDivider: true
      },
      {
        text: $r('app.string.delete'),
        action: 'deleteConversation',
        showDivider: true,
        color: this.themeManager.currentTheme.textColorError // 红色警告文字
      },
    ];
  }

  build() {
    Column() {

      // 顶部内容区域 - 包含所有功能按钮
      Column() {
        ForEach(this.actionButtons, (button: ActionButtonConfig) => {
          Column() {
            // 分割线
            if (button.showDivider) {
              Divider()
                .height(0.4)
                .color(this.themeManager.currentTheme.strokeColorPrimary)
                .width('100%')
            }

            // 按钮
            Button() {
              Text(button.text)
                .fontSize(17)
                .fontFamily('PingFang HK')
                .fontWeight(400)
                .fontColor(button.color || this.themeManager.currentTheme.buttonColorPrimaryDefault)
                .textAlign(TextAlign.Center)
            }
            .backgroundColor(this.themeManager.currentTheme.bgColorBubbleReciprocal)
            .height(ConversationMoreDialog.BUTTON_HEIGHT)
            .width('100%')
            .onClick(() => this.handleAction(button.action))
          }
          .width('100%')
        })
      }
      .width('100%')
      .borderRadius(12)
      .backgroundColor(this.themeManager.currentTheme.bgColorBubbleReciprocal)

      Row() {
        // 取消按钮
        Button($r('app.string.cancel'))
          .fontSize(17)
          .fontFamily('PingFang HK')
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
          .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
          .height(ConversationMoreDialog.BUTTON_HEIGHT)
          .width('100%')
          .onClick(() => this.controller.close())
      }
      .width('100%')
      .margin({ top: 12 })
      .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
      .borderRadius(ConversationMoreDialog.BOTTOM_RADIUS)
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 38 })
  }

  private handleAction(action: string) {
    console.info(`执行操作: ${action}, 会话ID: ${this.conversation.ID}`);

    switch (action) {
      case 'hideConversation':
        if (this.onHideConverSation) {
          this.onHideConverSation(this.conversation.ID);
        }
        break;
      case 'pinConversation':
        if (this.onPinConversation) {
          this.onPinConversation(this.conversation.ID);
        }
        break;
      case 'clearConversation':
        if (this.onClearConversation) {
          this.onClearConversation(this.conversation.ID);
        }
        break;
      case 'deleteConversation':
        if (this.onDeleteConversation) {
          this.onDeleteConversation(this.conversation.ID);
        }
        break;
    }

    this.controller.close();
  }
} 