import {
  MessageInfo,
  MessageType,
  MessageResourceType,
  MessageListState,
  MessageStatus
} from 'chatengine/src/main/ets/pages/MessageListState';
import { ChatEngine } from 'chatengine/src/main/ets/pages/ChatEngine';

import { TextMessageView } from '../cells/TextMessageView';
import { ImageMessageView } from '../cells/ImageMessageView';
import { FaceMessageView } from '../cells/FaceMessageView';
import { FileMessageView } from '../cells/FileMessageView';
import { SoundMessageView } from '../cells/SoundMessageView';
import { VideoMessageView } from '../cells/VideoMessageView';
import { TextUtils, ThemeManager, TimeUtil } from 'basecomponent';

/**
 * 判断当前消息是否为分段结尾（应该显示头像）
 * @param index 当前消息索引
 * @param message 当前消息对象
 * @param messageListState 消息列表状态
 * @param timeIntervalThreshold 时间间隔阈值
 */
export function isSectionEnd(
  index: number,
  message: MessageInfo,
  messageListState?: MessageListState,
  timeIntervalThreshold?: number
): boolean {
  const messageList = messageListState?.messageList ?? [];

  // 如果是最后一条消息，肯定显示头像
  if (index === messageList.length - 1) {
    return true;
  }

  const nextMessage = messageList[index + 1];
  if (!nextMessage) {
    return true;
  }

  // 如果下一条消息是不同发送者，当前消息显示头像（消息组结束）
  if (nextMessage.isSelf !== message.isSelf) {
    return true;
  }

  // 如果下一条消息是撤回状态，当前消息显示头像
  if (nextMessage.status === MessageStatus.revoked) {
    return true;
  }

  // 如果时间间隔超过阈值，当前消息显示头像（时间分段结束）
  if (timeIntervalThreshold &&
  nextMessage.dateTime &&
  message.dateTime &&
    (nextMessage.dateTime.getTime() - message.dateTime.getTime()) > timeIntervalThreshold) {
    return true;
  }

  // 其他情况不显示头像（同一发送者的连续消息中间部分）
  return false;
}

@Builder
export function GetMessageView(message: MessageInfo, messageListState: MessageListState) {
  if (message.messageType == MessageType.Text) {
    TextMessageView(message, messageListState);
  } else if (message.messageType == MessageType.Image) {
    ImageMessageView(message, messageListState);
  } else if (message.messageType == MessageType.File) {
    FileMessageView(message, messageListState);
  } else if (message.messageType == MessageType.Sound) {
    SoundMessageView(message, messageListState);
  } else if (message.messageType == MessageType.Video) {
    VideoMessageView(message, messageListState);
  } else if (message.messageType == MessageType.Face) {
    FaceMessageView(message, messageListState);
  } else if (message.messageType == MessageType.System) {
    // System message handling
  } else if (message.messageType == MessageType.Custom) {
    // Custom message handling
  } else {
    TextMessageView(message, messageListState);
  }
}

@Component
export struct MessageItem {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  @ObjectLink message: MessageInfo;
  @Prop showAvatar: boolean = true; // 从外部传入的头像显示状态
  onLongPress?: (message: MessageInfo) => void;
  @ObjectLink messageListState: MessageListState; // 从外部传入的 MessageListState
  timeIntervalThreshold: number = 5 * 60 * 1000; // 默认5分钟

  aboutToAppear() {
    // 自动下载需要的资源
    this.downloadMessageViewSource(this.message);
  }

  /**
   * 根据消息类型下载对应的资源
   * @param message 需要下载资源的消息
   */
  downloadMessageViewSource(message: MessageInfo) {
    if (!message || !this.messageListState) {
      return;
    }

    try {
      // 根据消息类型下载不同的资源
      if (message.messageType === MessageType.Image) {
        // 下载缩略图
        this.messageListState.downloadMessageResource(message, MessageResourceType.thumbImage)
          .then(() => {
            console.info('[MessageItem] Successfully downloaded thumb image');
          })
          .catch((error: object) => {
            console.error('[MessageItem] Failed to download thumb image:', error);
          });
      } else if (message.messageType === MessageType.Video) {
        // 下载视频缩略图
        this.messageListState.downloadMessageResource(message, MessageResourceType.videoSnapshot)
          .then(() => {
            console.info('[MessageItem] Successfully downloaded video snapshot');
          })
          .catch((error: object) => {
            console.error('[MessageItem] Failed to download video snapshot:', error);
          });
      } else if (message.messageType === MessageType.Sound) {
        // 下载语音
        this.messageListState.downloadMessageResource(message, MessageResourceType.sound)
          .then(() => {
            console.info('[MessageItem] Successfully downloaded sound');
          })
          .catch((error: object) => {
            console.error('[MessageItem] Failed to download sound:', error);
          });
      } else if (message.messageType === MessageType.File) {
        // 下载文件预览信息，不自动下载完整文件
        console.info('[MessageItem] File message, not downloading automatically');
      }
    } catch (error) {
      console.error('[MessageItem] Error in downloadMessageViewSource:', error);
    }
  }

  @Builder
  AvatarView(url?: string) {
    Stack() {
      if (TextUtils.isValidUrl(url)) {
        Image(url)
          .width(32)
          .height(32)
          .borderRadius(16)
      } else {
        // 默认头像
        Circle({ width: 32, height: 32 })
          .fill(this.themeManager.currentTheme.textColorLink)
        Text(this.message.sender?.substring(0, 1).toUpperCase() || '')
          .fontSize(20)
          .fontColor(Color.White)
      }
    }
    .width(32)
    .height(32)
    .visibility(this.showAvatar ? Visibility.Visible : Visibility.Hidden)
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
      Row() {
        if (this.message.isSelf) {
          // Sender's message (right side)
          Row() {
            // 消息气泡
            Column() {
              this.MessageBubble(this.message)
            }
            .flexShrink(1) // 允许收缩但不强制固定宽度
            // 发送失败错误图标
            if (this.message.status === MessageStatus.sendFail) {
              Image($r('app.media.icon_message_send_error'))
                .width(16)
                .height(16)
                .margin({ left: 4 })
            }
          }
          .width('90%') // 整个消息区域最大宽度90%
          .justifyContent(FlexAlign.End) // 靠右对齐
        } else {
          // 左侧消息（接收者）
          Row() {
            // 头像
            Stack() {
              this.AvatarView(this.message?.imMessage?.faceURL)
            }
            .margin({ right: 6 })

            // 消息气泡
            Column() {
              this.MessageBubble(this.message)
            }
          }
          .width('80%')
          .justifyContent(FlexAlign.Start) // 靠左对齐
        }
      }
      .width('100%')
      .justifyContent(this.message.isSelf ? FlexAlign.End : FlexAlign.Start) // 整行靠左或靠右
      .gesture(
        LongPressGesture({ repeat: false })
          .onAction((event: GestureEvent) => {
            console.log('[MessageItem] LongPress detected');
            if (this.onLongPress) {
              this.onLongPress(this.message);
            }
          })
      )
    }
  }
}
