import {
  MessageInfo,
  MessageStatus,
  MessageBody,
  MessageListState,
  MessageResourceType
} from 'chatengine/src/main/ets/pages/MessageListState';
import { ThemeManager, TimeUtil } from 'basecomponent';

@Component
export struct FileMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @ObjectLink messageListState: MessageListState;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();

  build() {
    Column() {
      Row() {
        // 左侧文件类型图标
        Image($r('app.media.icon_message_file'))// 需要替换为实际资源路径
          .width(22)
          .height(22)
          .margin({ right: 10 })

        // 右侧文件信息区域
        Column() {
          // 文件名称（主标题）
          Text(this.messageBody?.fileName || '未知文件')
            .fontSize(16)
            .fontColor(this.themeManager.currentTheme.textColorPrimary)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('80%')

        }
        .alignItems(HorizontalAlign.Start)
      }
      .padding(10)
      .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
      .borderRadius(8)
      .margin({ left: 5, right: 5, top: 8 })
      .width('90%')

      // Time and status - inline with text
      Row() {
        // Left side - File size
        Text(this.formatFileSize(this.messageBody?.fileSize))
          .fontSize(12)
          .fontColor(this.themeManager.currentTheme.textColorAntiSecondary)
          .margin({ left: 1, top: 4 })
        // Right side - Status and time
        Row() {
          if (this.message?.status === MessageStatus.sending) {
            LoadingProgress()
              .width(12)
              .height(12)
              .margin({ right: 4 })
          }
          Text(TimeUtil.formatRelativeTime(this.message?.dateTime?.getTime() ?? 0))
            .fontSize(12)
            .fontColor(this.themeManager.currentTheme.textColorAntiSecondary)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: 10,
        bottom: 8,
        left: 16,
        right: 16
      })
    }
  }

  // 格式化文件大小显示
  private formatFileSize(bytes?: number): string {
    if (!bytes) {
      return '大小未知';
    }

    const units = ['B', 'KB', 'MB', 'GB'];
    let size = bytes;
    let unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return `${size.toFixed(1)} ${units[unitIndex]}`;
  }
}

@Builder
export function FileMessageView(messageData: MessageInfo, messageListState: MessageListState) {
  if (messageData && messageData.messageBody && messageListState) {
    FileMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListState: messageListState
    })
  }
}