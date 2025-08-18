import { MessageInfo, MessageType, MessageResourceType, MessageListStore, MessageStatus } from 'chatengine';

import { TextMessageView } from '../cells/TextMessageView';
import { ImageMessageView } from '../cells/ImageMessageView';
import { FaceMessageView } from '../cells/FaceMessageView';
import { FileMessageView } from '../cells/FileMessageView';
import { SoundMessageView } from '../cells/SoundMessageView';
import { VideoMessageView } from '../cells/VideoMessageView';
import { Avatar, AvatarSize, AvatarContentType, TextUtils, ThemeState, TimeUtil } from '../../basecomponent/Index';
import { AppBuilderConfig, MessageAlignment } from '../../basecomponent/utils/AppBuilderHelper';
import { SystemMessageView } from '../cells/SystemMessageView';
import { CreateGroupMessageView } from '../cells/CreateGroupMessageView';

@Builder
export function GetMessageView(message: MessageInfo, MessageListStore: MessageListStore) {
  if (message.messageType == MessageType.Text) {
    TextMessageView(message, MessageListStore);
  } else if (message.messageType == MessageType.Image) {
    ImageMessageView(message, MessageListStore);
  } else if (message.messageType == MessageType.File) {
    FileMessageView(message, MessageListStore);
  } else if (message.messageType == MessageType.Sound) {
    SoundMessageView(message, MessageListStore);
  } else if (message.messageType == MessageType.Video) {
    VideoMessageView(message, MessageListStore);
  } else if (message.messageType == MessageType.Face) {
    FaceMessageView(message, MessageListStore);
  } else if (message.messageType == MessageType.System) {
    SystemMessageView(message, MessageListStore);
  } else if (message.messageType == MessageType.Custom) {
    // Custom message - handled in MessageItem build method
    if (message.messageBody?.customInfo) {
      if (message.messageBody?.customInfo["businessID"] === 'group_create') {
        CreateGroupMessageView(message, MessageListStore);
      } else {
        SystemMessageView(message, MessageListStore);
      }
    } else {
      SystemMessageView(message, MessageListStore);
    }
  } else {
    TextMessageView(message, MessageListStore);
  }
}

@Component
export struct MessageItem {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @ObjectLink message: MessageInfo;
  @Prop showAvatar: boolean = true;
  @Prop isHighlighted: boolean = false;
  onLongPress?: (message: MessageInfo) => void;
  @ObjectLink messageListStore: MessageListStore;
  @State private config: AppBuilderConfig = AppBuilderConfig.getInstance();
  @State private shouldShowAvatarValue: boolean = true;

  aboutToAppear() {

    this.config = AppBuilderConfig.getInstance();
    this.updateAvatarVisibility();
    this.downloadMessageViewSource(this.message);
  }

  public refreshConfig(): void {
    this.config = AppBuilderConfig.getInstance();
    this.updateAvatarVisibility();
  }

  downloadMessageViewSource(message: MessageInfo) {
    if (!message || !this.messageListStore) {
      return;
    }

    try {

      if (message.messageType === MessageType.Image) {

        this.messageListStore.downloadMessageResource(message, MessageResourceType.thumbImage)
          .then(() => {
            console.info('[MessageItem] Successfully downloaded thumb image');
          })
          .catch((error: object) => {
            console.error('[MessageItem] Failed to download thumb image:', error);
          });
      } else if (message.messageType === MessageType.Video) {

        this.messageListStore.downloadMessageResource(message, MessageResourceType.videoSnapshot)
          .then(() => {
            console.info('[MessageItem] Successfully downloaded video snapshot');
          })
          .catch((error: object) => {
            console.error('[MessageItem] Failed to download video snapshot:', error);
          });
      } else if (message.messageType === MessageType.Sound) {

        this.messageListStore.downloadMessageResource(message, MessageResourceType.sound)
          .then(() => {
            console.info('[MessageItem] Successfully downloaded sound');
          })
          .catch((error: object) => {
            console.error('[MessageItem] Failed to download sound:', error);
          });
      } else if (message.messageType === MessageType.File) {

        console.info('[MessageItem] File message, not downloading automatically');
      }
    } catch (error) {
      console.error('[MessageItem] Error in downloadMessageViewSource:', error);
    }
  }

  @Builder
  AvatarView(url?: string) {
    Stack() {
      Avatar({
        content: {
          type: AvatarContentType.Image,
          name: this.message.sender || '',
        },
        avatarSize: AvatarSize.S
      })
    }
    .width(32)
    .height(32)
    .visibility(this.shouldShowAvatarValue ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  MessageBubble(message: MessageInfo) {

    if (message.messageType === MessageType.System || message.messageType === MessageType.Custom) {

      Text("")
        .width(0)
        .height(0)
    } else if (message.isSelf) {
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
      if (this.config.messageAlignment === MessageAlignment.LEFT) {
        this.messageAlignmentLeftStyle();
      } else if (this.config.messageAlignment === MessageAlignment.RIGHT) {
        this.messageAlignmentRightStyle();
      } else {
        this.messageAlignmentTwosideStyle();
      }
    }
  }

  @Builder
  messageAlignmentLeftStyle() {
    Column() {
      if (this.message.messageType === MessageType.System) {
        Row() {
          GetMessageView(this.message, this.messageListStore);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else if (this.message.messageType === MessageType.Custom) {
        Row() {
          GetMessageView(this.message, this.messageListStore);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else {
        Row() {
          Stack() {
            this.AvatarView(this.message?.imMessage?.faceURL)
          }
          .margin({ right: 6 })

          Column() {
            Column() {
              GetMessageView(this.message, this.messageListStore);
            }
            .borderRadius(16)
            .backgroundColor(this.message.isSelf ?
            this.themeState.colors.bgColorBubbleOwn :
            this.themeState.colors.bgColorBubbleReciprocal)
            .borderWidth(1)
            .borderColor(this.message.isSelf ?
            this.themeState.colors.bgColorBubbleOwn :
            this.themeState.colors.bgColorBubbleReciprocal)
            .flexShrink(1)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
          }
          .flexShrink(1)

          if (this.message.isSelf && this.message.status === MessageStatus.sendFail) {
            Image($rawfile('messagelist/icon_message_send_error.svg'))
              .width(16)
              .height(16)
              .margin({ left: 4 })
          }
        }
        .width('90%')
        .justifyContent(FlexAlign.Start)
        .gesture(
          LongPressGesture({ repeat: false })
            .onAction((event: GestureEvent) => {
              console.log('[MessageItem] LongPress detected');
              if (this.onLongPress) {
                this.onLongPress(this.message);
              }
            })
        )
        .backgroundColor(this.isHighlighted ? 'rgba(0, 122, 255, 0.1)' : 'transparent')
        .borderRadius(this.isHighlighted ? 8 : 0)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  messageAlignmentRightStyle() {
    Column() {
      if (this.message.messageType === MessageType.System) {
        Row() {
          GetMessageView(this.message, this.messageListStore);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else if (this.message.messageType === MessageType.Custom) {
        Row() {
          GetMessageView(this.message, this.messageListStore);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else {
        Row() {
          if (this.message.isSelf && this.message.status === MessageStatus.sendFail) {
            Image($rawfile('messagelist/icon_message_send_error.svg'))
              .width(16)
              .height(16)
              .margin({ right: 4 })
          }
          Column() {
            Column() {
              GetMessageView(this.message, this.messageListStore);
            }
            .borderRadius(16)
            .backgroundColor(this.message.isSelf ?
            this.themeState.colors.bgColorBubbleOwn :
            this.themeState.colors.bgColorBubbleReciprocal)
            .borderWidth(1)
            .borderColor(this.message.isSelf ?
            this.themeState.colors.bgColorBubbleOwn :
            this.themeState.colors.bgColorBubbleReciprocal)
            .flexShrink(1)
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.End)
          }
          .flexShrink(1)


          Stack() {
            this.AvatarView(this.message?.imMessage?.faceURL)
          }
          .margin({ left: 6 })
        }
        .width('90%')
        .justifyContent(FlexAlign.End)
        .gesture(
          LongPressGesture({ repeat: false })
            .onAction((event: GestureEvent) => {
              console.log('[MessageItem] LongPress detected');
              if (this.onLongPress) {
                this.onLongPress(this.message);
              }
            })
        )

        .backgroundColor(this.isHighlighted ? 'rgba(0, 122, 255, 0.1)' : 'transparent')
        .borderRadius(this.isHighlighted ? 8 : 0)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.End)
  }

  @Builder
  messageAlignmentTwosideStyle() {
    Column() {
      if (this.message.messageType === MessageType.System) {
        Row() {
          GetMessageView(this.message, this.messageListStore);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else if (this.message.messageType === MessageType.Custom) {
        Row() {
          GetMessageView(this.message, this.messageListStore);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else {
        Row() {
          if (this.message.isSelf) {
            // Sender's message (right side)
            Row() {
              Column() {
                this.MessageBubble(this.message)
              }
              .flexShrink(1)

              if (this.message.status === MessageStatus.sendFail) {
                Image($rawfile('messagelist/icon_message_send_error.svg'))
                  .width(16)
                  .height(16)
                  .margin({ left: 4 })
              }
            }
            .width('90%')
            .justifyContent(FlexAlign.End)
          } else {
            Row() {
              // Avatar
              Stack() {
                this.AvatarView(this.message?.imMessage?.faceURL)
              }
              .margin({ right: 6 })

              Column() {
                this.MessageBubble(this.message)
              }
            }
            .width('80%')
            .justifyContent(FlexAlign.Start)
          }
        }
        .width('100%')
        .justifyContent(this.message.isSelf ? FlexAlign.End : FlexAlign.Start)
        .gesture(
          LongPressGesture({ repeat: false })
            .onAction((event: GestureEvent) => {
              console.log('[MessageItem] LongPress detected');
              if (this.onLongPress) {
                this.onLongPress(this.message);
              }
            })
        )
        .backgroundColor(this.isHighlighted ? 'rgba(0, 122, 255, 0.1)' : 'transparent')
        .borderRadius(this.isHighlighted ? 8 : 0)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }
    }
  }

  private updateAvatarVisibility(): void {
    this.shouldShowAvatarValue = this.shouldShowAvatar(this.config.messageAlignment);
  }

  private shouldShowAvatar(alignment: MessageAlignment): boolean {
    switch (alignment) {
      case MessageAlignment.LEFT:
      case MessageAlignment.RIGHT:

        return true;
      case MessageAlignment.TWO_SIDED:
      default:

        return this.showAvatar && !this.message.isSelf;
    }
  }
}
