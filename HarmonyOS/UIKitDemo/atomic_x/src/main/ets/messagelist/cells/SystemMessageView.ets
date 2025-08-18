import { MessageInfo, MessageStatus } from 'chatengine';
import { ThemeState, TimeUtil } from '../../basecomponent/Index';
import { MessageBody } from 'chatengine';
import { MessageListStore } from 'chatengine';
import { MessageUtils } from '../utils/MessageUtils';

@Component
export struct SystemMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @StorageLink('themeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    Row() {
      Text(this.formatSystemInfo(this.message?.messageBody))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorPrimary)
        .padding({
          left: 8,
          right: 8,
          top: 4,
          bottom: 4
        })
        .borderRadius(4)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 8 })
  }

  private formatSystemInfo(body?: MessageBody): string | Resource {
    if (!body || !body.systemInfo) {
      return 'unsupported custom message';
    }
    return MessageUtils.getSystemInfoDisplayString(body.systemInfo);
  }
}

@Builder
export function SystemMessageView(messageData: MessageInfo, MessageListStore?: MessageListStore) {
  if (messageData && messageData.messageBody) {
    SystemMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody
    })
  }
} 