import {
  Switch,
  SwitchType,
  SwitchSize,
  TextUtils,
  ThemeState,
  Toast,
  Avatar,
  AvatarSize,
  AvatarContentType
} from '../../basecomponent/Index';
import { C2CSettingStore, C2CSettingState } from 'chatengine';
import { GroupNameEditDialog } from '../dialog/GroupSettingDialogs';

@Component
export struct C2CChatSettingView {
  private static readonly CELL_HEIGHT: number = 56;
  private static readonly SECTION_MARGIN: number = 12;
  private static readonly HORIZONTAL_PADDING: number = 8;
  private static readonly BORDER_RADIUS: number = 12;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State c2cStore?: C2CSettingStore = undefined;
  @State c2cState?: C2CSettingState = undefined;
  @State conversationID: string = '';
  @State isLoading: boolean = true;
  @State localIsNotDisturbed: boolean = false;
  @State localIsPinned: boolean = false;
  @State localIsInBlacklist: boolean = false;
  title?: string;
  onBack?: () => void;
  dialogController?: CustomDialogController;
  onDialogClose?: () => void;
  onSelectedNavigateMessagePage?: (newConversationID?: string, title?: string, avatarUrl?: string) => void;
  private remarkEditDialogController?: CustomDialogController = new CustomDialogController({
    builder: GroupNameEditDialog({
      title: $r('app.string.chatsetting_set_remark'),
      currentName: this.c2cState?.remark || '',
      placeholder: $r('app.string.chatsetting_input_remark_name'),
      helpText: $r('app.string.chatsetting_remark_help_text'),
      maxLength: 30,
      onSave: (newRemark: string) => {
        this.handleRemarkSave(newRemark);
      }
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: true
  });

  aboutToAppear(): void {

    console.info('[C2CChatSettingPage] parm:', {
      conversationID: this.conversationID,
      title: this.title
    });


    if (this.conversationID && this.conversationID.length > 0) {
      this.initializeWithConversationID();
    } else {


      this.isLoading = false;
    }
  }

  aboutToDisappear(): void {


    if (this.remarkEditDialogController) {
      this.remarkEditDialogController = undefined;
    }
    this.c2cStore = undefined;
  }

  build() {
    Column() {
      this.NavigationBarBuilder()

      if (this.isLoading) {

        this.LoadingStateBuilder()
      } else {

        Scroll() {
          Column({ space: 0 }) {
            this.UserInfoSectionBuilder()
            this.RemarkSectionBuilder()
            this.NotificationSettingsSectionBuilder()
            this.ChatBackgroundSectionBuilder()
            this.BlacklistSectionBuilder()
            this.ActionButtonsSectionBuilder()
          }
          .width('100%')
        }
        .layoutWeight(1)
        .backgroundColor(this.themeState.colors.bgColorOperate)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  LoadingStateBuilder() {
    Column({ space: 16 }) {

      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.themeState.colors.textColorLink)


      Text($r('app.string.chatsetting_loading_contact_information'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorSecondary)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorInput)
  }

  @Builder
  NavigationBarBuilder() {
    Row() {
      // Back button
      Image($rawfile('search/back_icon.svg'))
        .width(24)
        .height(24)
        .fillColor(this.themeState.colors.textColorLink)
        .onClick(() => {
          if (this.dialogController) {


            this.dialogController.close();

            if (this.onDialogClose) {
              this.onDialogClose();
            }
          } else if (this.onBack) {


            this.onBack();
          } else {

            console.warn('[C2CChatSettingPage] 没有提供关闭方式');
          }
        })

      Blank()

      // Title
      Text(this.title || $r('app.string.chatsetting_contact_info_title'))
        .fontSize(18)
        .fontWeight(600)
        .fontFamily('SF Pro Display')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)

    // Divider
    Divider()
      .height(0.5)
      .color(this.themeState.colors.strokeColorSecondary)
  }

  @Builder
  UserInfoSectionBuilder() {
    Column() {

      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: this.c2cState?.avatar,
          name: this.getUserInitials() || '',
        },
        avatarSize: AvatarSize.XL,
      }).margin({ top: 24, bottom: 16 })

      Text((this.c2cState?.nickname || this.c2cState?.userID || ''))
        .fontSize(24)
        .fontWeight(600)
        .fontFamily('PingFang HK')
        .fontColor(this.themeState.colors.textColorPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 4 })

      // User ID
      Text(`ID: ${this.c2cState?.userID}`)
        .fontSize(15)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorSecondary)
        .margin({ bottom: 16 })


      Row({ space: 24 }) {
        this.QuickActionButtonBuilder($r('app.string.chatsetting_message'),
          $rawfile('chatsetting/setting_sendmessage_icon.svg'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius(C2CChatSettingView.BORDER_RADIUS)
    .padding({
      left: C2CChatSettingView.HORIZONTAL_PADDING,
      right: C2CChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      top: C2CChatSettingView.SECTION_MARGIN,
      bottom: C2CChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  QuickActionButtonBuilder(label: string | Resource, icon: string | Resource) {
    Column({ space: 8 }) {

      Image(icon)
        .width(36)
        .height(36)
        .fillColor(this.themeState.colors.textColorLink)
        .borderRadius(12)


      Text(label)
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor(this.themeState.colors.textColorPrimary)
        .textAlign(TextAlign.Center)
    }
    .width(92)
    .backgroundColor(this.themeState.colors.bgColorInput)
    .borderRadius(12)
    .padding({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.handleQuickActionClick(label);
    })
  }

  @Builder
  RemarkSectionBuilder() {
    Column({ space: 0 }) {

      this.RemarkRowBuilder()
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(C2CChatSettingView.BORDER_RADIUS)
    .padding({
      left: C2CChatSettingView.HORIZONTAL_PADDING,
      right: C2CChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: C2CChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  NotificationSettingsSectionBuilder() {
    Column({ space: 0 }) {

      this.DoNotDisturbRowBuilder()
      this.DividerBuilder()


      this.TopChatRowBuilder()
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(C2CChatSettingView.BORDER_RADIUS)
    .padding({
      left: C2CChatSettingView.HORIZONTAL_PADDING,
      right: C2CChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: C2CChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  ChatBackgroundSectionBuilder() {
    Column({ space: 0 }) {

      this.ChatBackgroundRowBuilder()
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(C2CChatSettingView.BORDER_RADIUS)
    .padding({
      left: C2CChatSettingView.HORIZONTAL_PADDING,
      right: C2CChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: C2CChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  BlacklistSectionBuilder() {
    Column({ space: 0 }) {

      this.BlacklistRowBuilder()
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(C2CChatSettingView.BORDER_RADIUS)
    .padding({
      left: C2CChatSettingView.HORIZONTAL_PADDING,
      right: C2CChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: C2CChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  RemarkRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_set_remark_title'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Row({ space: 8 }) {
        Text(this.c2cState?.remark || 'Not set')
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
    }
    .width('100%')
    .height(C2CChatSettingView.CELL_HEIGHT)
    .padding({ left: C2CChatSettingView.HORIZONTAL_PADDING, right: C2CChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      this.showRemarkEditDialog();
    })
  }

  @Builder
  DoNotDisturbRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_mute_notifications'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Switch({
        checked: this.localIsNotDisturbed,
        onCheckedChange: (isOn: boolean) => {
          this.c2cStore?.setChatNotDisturb(isOn)
            .then(() => {
              this.localIsNotDisturbed = isOn;
            })
            .catch((error: Error) => {

              this.localIsNotDisturbed = !isOn;
              console.error('setChatMuted failed:', error);
            });
        },
        type: SwitchType.Basic
      })
    }
    .width('100%')
    .height(C2CChatSettingView.CELL_HEIGHT)
    .padding({ left: C2CChatSettingView.HORIZONTAL_PADDING, right: C2CChatSettingView.HORIZONTAL_PADDING })
  }

  @Builder
  TopChatRowBuilder() {
    Row() {
      Text($r('app.string.pin_conversation'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Switch({
        checked: this.localIsPinned,
        type: SwitchType.Basic,
        onCheckedChange: (isOn: boolean) => {
          this.c2cStore?.setChatPinned(isOn)
            .then(() => {
              this.localIsPinned = isOn;
            })
            .catch((error: Error) => {

              this.localIsPinned = !isOn;
              console.error('setChatPinned failed:', error);
            });
        }
      })
    }
    .width('100%')
    .height(C2CChatSettingView.CELL_HEIGHT)
    .padding({ left: C2CChatSettingView.HORIZONTAL_PADDING, right: C2CChatSettingView.HORIZONTAL_PADDING })
  }

  @Builder
  ChatBackgroundRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_chat_background'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Row({ space: 8 }) {
        Text('Default')
          .fontSize(17)
          .fontWeight(400)
          .fontFamily('SF Pro Text')
          .fontColor(this.themeState.colors.textColorSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Image($rawfile('search/right_arrow_icon.svg'))
          .width(12)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
    }
    .width('100%')
    .height(C2CChatSettingView.CELL_HEIGHT)
    .padding({ left: C2CChatSettingView.HORIZONTAL_PADDING, right: C2CChatSettingView.HORIZONTAL_PADDING })
    .onClick(() => {
      console.log('Chat background clicked');

    })
  }

  @Builder
  BlacklistRowBuilder() {
    Row() {
      Text($r('app.string.chatsetting_blacklist'))
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(this.themeState.colors.textColorPrimary)

      Blank()

      Switch({
        checked: this.localIsInBlacklist,
        type: SwitchType.Basic,
        onCheckedChange: (isOn: boolean) => {
          if (isOn) {
            this.c2cStore?.addToBlacklist()
              .then(() => {
                this.localIsInBlacklist = true;
                Toast.shortToast($r('app.string.chatsetting_added_to_blacklist'));
              })
              .catch((error: Error) => {

                this.localIsInBlacklist = false;
                Toast.shortToast($r('app.string.chatsetting_add_blacklist_fail'));
                console.error('Add to blacklist failed:', error);
              });
          } else {
            this.c2cStore?.removeFromBlacklist()
              .then(() => {
                this.localIsInBlacklist = false;
                Toast.shortToast($r('app.string.chatsetting_removed_from_blacklist'));
              })
              .catch((error: Error) => {

                this.localIsInBlacklist = true;
                Toast.shortToast($r('app.string.chatsetting_remove_blacklist_fail'));
                console.error('Remove from blacklist failed:', error);
              });
          }
        }
      })
    }
    .width('100%')
    .height(C2CChatSettingView.CELL_HEIGHT)
    .padding({ left: C2CChatSettingView.HORIZONTAL_PADDING, right: C2CChatSettingView.HORIZONTAL_PADDING })
  }

  @Builder
  DividerBuilder() {
    Divider()
      .height(1)
      .color(this.themeState.colors.strokeColorSecondary)
  }

  @Builder
  ActionButtonsSectionBuilder() {
    Column({ space: 0 }) {

      this.ActionButtonBuilder($r('app.string.chatsetting_clear_chat_history_title'),
        this.themeState.colors.textColorError, () => {
          this.c2cStore?.clearHistoryMessage().then(() => {
            Toast.shortToast($r('app.string.chatsetting_clear_chat_success'));
          }).catch((error: Error) => {
            Toast.shortToast($r('app.string.chatsetting_clear_chat_fail'));
            console.error('Clear history failed:', error);
          });
        })

      this.DividerBuilder()


      this.ActionButtonBuilder($r('app.string.chatsetting_delete_friend'),
        this.themeState.colors.textColorError, () => {
          this.c2cStore?.deleteFriend().then(() => {
            Toast.shortToast($r('app.string.chatsetting_delete_friend_success'));

            if (this.dialogController) {
              this.dialogController.close();
              if (this.onDialogClose) {
                this.onDialogClose();
              }
            } else if (this.onBack) {
              this.onBack();
            }
          }).catch((error: Error) => {
            Toast.shortToast($r('app.string.chatsetting_delete_friend_fail'));
            console.error('Delete friend failed:', error);
          });
        })
    }
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(C2CChatSettingView.BORDER_RADIUS)
    .padding({
      left: C2CChatSettingView.HORIZONTAL_PADDING,
      right: C2CChatSettingView.HORIZONTAL_PADDING
    })
    .margin({
      bottom: C2CChatSettingView.SECTION_MARGIN
    })
  }

  @Builder
  ActionButtonBuilder(title: string | Resource, textColor: string, action: () => void) {
    Row() {
      Text(title)
        .fontSize(17)
        .fontWeight(400)
        .fontFamily('SF Pro Text')
        .fontColor(textColor)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(C2CChatSettingView.CELL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .onClick(action)
  }

  private syncLocalStates(): void {
    this.localIsNotDisturbed = this.c2cState?.isNotDisturb ?? false;
    this.localIsPinned = this.c2cState?.isPinned ?? false;
    this.localIsInBlacklist = this.c2cState?.isInBlacklist ?? false;

  }

  private showRemarkEditDialog(): void {

    this.remarkEditDialogController = new CustomDialogController({
      builder: GroupNameEditDialog({
        title: $r('app.string.chatsetting_set_remark'),
        currentName: this.c2cState?.remark || '',
        placeholder: $r('app.string.chatsetting_input_remark_name'),
        helpText: $r('app.string.chatsetting_remark_help_text'),
        maxLength: 30,
        onSave: (newRemark: string) => {
          this.handleRemarkSave(newRemark);
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      autoCancel: true
    });

    this.remarkEditDialogController.open();
  }

  private handleRemarkSave(newRemark: string): void {
    if (!this.c2cStore) {
      Toast.shortToast($r('app.string.chatsetting_user_status_error'));
      return;
    }


    this.c2cStore.setUserRemark(newRemark)
      .then(() => {
        Toast.shortToast($r('app.string.chatsetting_remark_set_success'));
      })
      .catch((error: Error) => {
        Toast.shortToast(TextUtils.getResourceString($r('app.string.chatsetting_remark_set_fail'))
          .replace('{error}',
            error.message || TextUtils.getResourceString($r('app.string.chatsetting_unknown_error'))));
        console.error('Set remark failed:', error);
      });
  }

  private handleQuickActionClick(label: string | Resource): void {
    if (!this.c2cStore) {
      Toast.shortToast($r('app.string.chatsetting_user_status_error'));
      return;
    }


    const messageLabel = TextUtils.getResourceString($r('app.string.chatsetting_message'));
    const currentLabel = typeof label === 'string' ? label : TextUtils.getResourceString(label);

    if (currentLabel === messageLabel) {
      this.handleSendMessageClick();
    }
  }

  private handleSendMessageClick(): void {


    if (this.dialogController) {

      this.dialogController.close();
      if (this.onSelectedNavigateMessagePage) {

        const contactTitle = this.c2cState?.nickname || this.title || '联系人';
        const contactAvatarUrl = this.c2cState?.avatar || '';
        this.onSelectedNavigateMessagePage(this.conversationID, contactTitle, contactAvatarUrl);
      }
    } else if (this.onBack) {

      this.onBack();
    } else {
      console.warn('[C2CChatSettingPage] 没有提供关闭方式');
    }
  }

  private initializeWithConversationID(): void {

    console.info('[C2CChatSettingPage] conversationID:', this.conversationID);

    if (this.conversationID) {

      const userID = this.conversationID.replace('c2c_', '');


      try {

        this.c2cStore = C2CSettingStore.createInstance(userID);
        this.c2cState = this.c2cStore.state;
        this.c2cStore?.fetchUserInfo()
          .then(() => {
            this.syncLocalStates();
          });
        this.c2cStore.checkBlacklistStatus()
          .then(() => {
            this.syncLocalStates();
          });
        this.c2cStore.fetchConversationInfo()
          .then(() => {
            this.syncLocalStates();
            this.isLoading = false;
          });
      } catch (error) {

      }
    } else {

    }
  }

  private getUserInitials(): string {
    const name = this.c2cState?.nickname || this.c2cState?.userID || 'Dominik';
    const words = name.split(' ');
    if (words.length >= 2) {
      return (words[0].charAt(0) + words[1].charAt(0)).toUpperCase();
    }
    return name.charAt(0).toUpperCase();
  }
}