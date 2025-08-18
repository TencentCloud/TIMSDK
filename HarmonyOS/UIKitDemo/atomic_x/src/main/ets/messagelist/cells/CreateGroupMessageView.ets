import { MessageInfo, MessageStatus } from 'chatengine';
import { ThemeState, TimeUtil } from '../../basecomponent/Index';
import { MessageBody, MessageListStore } from 'chatengine';

@Component
export struct CreateGroupMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @StorageLink('themeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    Text(this.getCreateText())
      .fontSize(14)
      .fontColor(this.themeState.colors.textColorSecondary)
      .fontWeight(400)
      .textAlign(TextAlign.Center)
      .width('100%')
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
  }

  private getSenderDisplayName(): string {
    if (!this.message) {
      return '';
    }
    const displayName = this.message.imMessage?.nickName ||
      this.message.imMessage?.sender ||
    this.message.sender ||
      '';

    return displayName;
  }

  private isCommunity(): boolean {
    const customInfo = this.message?.messageBody?.customInfo;
    return customInfo?.["cmd"] === 1;
  }

  private getCreateText(): string {
    const senderName = this.getSenderDisplayName();
    const actionText = this.isCommunity() ? "创建了社群" : "创建了群聊";
    return `${senderName} ${actionText}`;
  }
}

@Builder
export function CreateGroupMessageView(messageData: MessageInfo, MessageListStore?: MessageListStore) {
  if (messageData && messageData.messageBody) {
    CreateGroupMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody
    })
  }
} 