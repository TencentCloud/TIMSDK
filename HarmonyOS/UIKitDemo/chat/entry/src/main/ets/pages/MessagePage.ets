import { LoginStore, MessageInfo, MessageType, CompletionHandler } from 'chatengine';
import { Avatar, AvatarContentType, AvatarSize, TextUtils, ThemeState } from 'atomic_x';
import router from '@ohos.router';
import { MessageListView } from 'atomic_x';
import { MessageInputBar } from 'atomic_x';
import { C2CChatSettingView, GroupChatSettingView } from 'atomic_x';

import { ImmersiveMode, LevelMode } from '@ohos.promptAction';

@CustomDialog
struct C2CSettingDialog {
  controller: CustomDialogController;
  conversationID: string = '';
  title: string = '联系人信息';
  onDialogClose?: () => void;
  onSelectedNavigateMessagePage?: (newConversationID?: string, title?: string, avatarUrl?: string) => void;

  build() {
    C2CChatSettingView({
      conversationID: this.conversationID,
      title: this.title,
      onBack: () => {
        this.controller.close();
      },
      onDialogClose: () => {
        if (this.onDialogClose) {
          this.onDialogClose();
        }
      },
      onSelectedNavigateMessagePage: (newConversationID?: string, title?: string, avatarUrl?: string) => {
        if (this.onSelectedNavigateMessagePage) {
          this.onSelectedNavigateMessagePage(newConversationID, title, avatarUrl);
        }
      },
      dialogController: this.controller
    })
  }
}

@CustomDialog
struct GroupSettingDialog {
  controller: CustomDialogController;
  conversationID: string = '';
  title: string = '群设置';
  onDialogClose?: () => void;
  onSelectedNavigateMessagePage?: (newConversationID?: string, title?: string, avatarUrl?: string) => void;

  build() {
    GroupChatSettingView({
      conversationID: this.conversationID,
      // title: this.title,
      onBack: () => {
        this.controller.close();
      },
      onDialogClose: () => {
        if (this.onDialogClose) {
          this.onDialogClose();
        }
      },
      onSelectedNavigateMessagePage: (newConversationID?: string, title?: string, avatarUrl?: string) => {
        if (this.onSelectedNavigateMessagePage) {
          this.onSelectedNavigateMessagePage(newConversationID, title, avatarUrl);
        }
      },
      dialogController: this.controller
    })
  }
}

@Entry
@Component
export struct MessagePage {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State conversationID: string = '';
  @State title: string = '聊天';
  @State status: string = 'online';
  @State avatarUrl: string = '';
  @State locateMessage?: MessageInfo = undefined;
  private settingDialogController?: CustomDialogController;

  aboutToAppear(): void {

    const params = this.getUIContext().getRouter().getParams();
    if (params) {
      const paramsObj = params as Record<string, string>;
      this.conversationID = paramsObj.conversationID as string || '';
      this.title = paramsObj.title as string || '聊天';
      this.status = paramsObj.status as string || 'online';
      this.avatarUrl = paramsObj.avatarUrl as string || '';


      if (paramsObj.locateMessage) {
        try {
          if (typeof paramsObj.locateMessage === 'string') {

            this.locateMessage = JSON.parse(paramsObj.locateMessage as string) as MessageInfo;
          } else {

            this.locateMessage = paramsObj.locateMessage as MessageInfo;
          }
        } catch (error) {

          this.locateMessage = undefined;
        }
      }
      console.info(`MessagePage: 接收到会话ID: ${this.conversationID}, 标题: ${this.title}, 定位消息ID: ${this.locateMessage?.ID ||
        'none'}`);
    } else {

    }
  }

  aboutToDisappear(): void {

    if (this.settingDialogController) {
      this.settingDialogController = undefined;
    }
  }

  build() {
    Stack() {

      Column() {

        Column() {

          Row() {

            Row({ space: 8 }) {
              // Back button
              Image($r('app.media.back_icon'))
                .width(24)
                .height(24)
                .fillColor(this.themeState.colors.textColorSecondary)
                .onClick(() => {
                  router.back();
                })


              Row({ space: 8 }) {
                // Avatar
                Avatar({
                  content: {
                    type: AvatarContentType.Image,
                    url: this.avatarUrl,
                    name: this.title || '',
                  },
                  avatarSize: AvatarSize.S,
                })

                Column() {
                  Text(this.title)
                    .fontSize(14)
                    .fontColor(this.themeState.colors.textColorPrimary)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Start)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(this.status)
                    .fontSize(12)
                    .fontColor(this.themeState.colors.textColorTertiary)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.Start)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .constraintSize({ maxWidth: '60%' })
              }
              .layoutWeight(1)
              .onClick(() => {
                this.navigateToProfile();
              })
            }
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)


            Row({ space: 16 }) {

              Image($r('app.media.video_icon'))
                .width(24)
                .height(24)
                .onClick(() => {

                })


              Image($r('app.media.call_icon'))
                .width(24)
                .height(24)
                .onClick(() => {

                })
            }
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height(56)
          .padding({ left: 10, right: 10 })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)

          // Divider
          Divider()
            .width('100%')
            .height(0.3)
            .color(this.themeState.colors.strokeColorSecondary)
        }
        .width('100%')
        .backgroundColor(this.themeState.colors.bgColorOperate)


        MessageListView({
          conversationID: this.conversationID,
          locateMessage: this.locateMessage
        })
          .width('100%')
          .layoutWeight(1)


        MessageInputBar({
          conversationID: this.conversationID,
          onSendMessage: (text: string) => {


          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.colors.bgColorOperate)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  private showC2CSettingWithCustomComponent(): void {
    try {
      if (this.settingDialogController) {
        this.settingDialogController.close();
        this.settingDialogController = undefined;
      }
      if (!this.conversationID || this.conversationID.length === 0) {
        return;
      }
      this.settingDialogController = new CustomDialogController({
        builder: C2CSettingDialog({
          conversationID: this.conversationID,
          title: '联系人信息',
          onDialogClose: () => {
          },
          onSelectedNavigateMessagePage: (newConversationID?: string, title?: string, avatarUrl?: string) => {
            this.handleSelectedNavigateMessagePage(newConversationID, title, avatarUrl);
          }
        }),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        customStyle: true,
        keyboardAvoidMode: KeyboardAvoidMode.NONE,
        maskColor: 'rgba(0, 0, 0, 0)',
        cancel: () => {
          this.settingDialogController = undefined;
        },
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        openAnimation: {
          duration: 300,
          curve: Curve.EaseInOut,
          playMode: PlayMode.Normal,
          onFinish: () => {

          }
        },
        closeAnimation: {
          duration: 250,
          curve: Curve.EaseInOut,
          playMode: PlayMode.Normal,
          onFinish: () => {

          }
        }
      });

      this.settingDialogController.open();

    } catch (error) {

    }
  }

  private showGroupSettingWithCustomComponent(): void {
    try {

      if (this.settingDialogController) {
        this.settingDialogController.close();
        this.settingDialogController = undefined;
      }


      if (!this.conversationID || this.conversationID.length === 0) {

        return;
      }

      this.settingDialogController = new CustomDialogController({
        builder: GroupSettingDialog({
          conversationID: this.conversationID,
          title: '群设置',
          onDialogClose: () => {


          },
          onSelectedNavigateMessagePage: (newConversationID?: string, title?: string, avatarUrl?: string) => {
            this.handleSelectedNavigateMessagePage(newConversationID, title, avatarUrl);
          }
        }),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        customStyle: true,
        keyboardAvoidMode: KeyboardAvoidMode.NONE,
        maskColor: 'rgba(0, 0, 0, 0)',
        cancel: () => {
          this.settingDialogController = undefined;
        },
        levelMode: LevelMode.EMBEDDED,
        immersiveMode: ImmersiveMode.EXTEND,
        openAnimation: {
          duration: 300,
          curve: Curve.EaseInOut,
          playMode: PlayMode.Normal,
          onFinish: () => {

          }
        },
        closeAnimation: {
          duration: 250,
          curve: Curve.EaseInOut,
          playMode: PlayMode.Normal,
          onFinish: () => {

          }
        }
      });

      this.settingDialogController.open();

    } catch (error) {


    }
  }

  private handleSelectedNavigateMessagePage(newConversationID?: string, title?: string, avatarUrl?: string): void {


    if (newConversationID && newConversationID.length > 0) {

      if (newConversationID === this.conversationID) {


        return;
      }


      const isGroupChat = newConversationID.startsWith('group_');
      const chatID = isGroupChat ? newConversationID.replace('group_', '') : newConversationID.replace('c2c_', '');


      const chatTitle = title || (isGroupChat ? '群聊' : '联系人');
      const chatAvatarUrl = avatarUrl || '';


      router.pushUrl({
        url: 'pages/MessagePage',
        params: {
          conversationID: newConversationID,
          conversationType: isGroupChat ? 2 : 1,
          title: chatTitle,
          avatarUrl: chatAvatarUrl,
          status: 'online'
        }
      }).then(() => {

      }).catch((error: Error) => {

      });
    } else {


      // this.refreshData();
    }
  }

  private navigateToProfile(): void {
    try {
      const isGroupChat = this.conversationID.startsWith('group_');

      if (isGroupChat) {

        this.showGroupSettingWithCustomComponent();
      } else {

        this.showC2CSettingWithCustomComponent();
      }
    } catch (error) {

    }
  }
}
