import { ThemeState, TextUtils, Toast, ToastType } from '../../../basecomponent/Index';
import { ContactListStore, ContactInfo, CompletionHandler } from 'chatengine';
import router from '@ohos.router';

@Entry({ routeName: 'GroupDetailPage' })
@Component
export struct GroupDetailPage {
  private static readonly POPUP_HEIGHT_RATIO: number = 0.8;
  private static readonly GROUP_AVATAR_SIZE: number = 74;
  private static readonly CONTENT_PADDING_HORIZONTAL: number = 16;
  private static readonly SEND_BUTTON_WIDTH: number = 357;
  private static readonly SEND_BUTTON_HEIGHT: number = 40;
  private static readonly TOP_BORDER_RADIUS: number = 10;
  private static readonly DIVIDER_HEIGHT: number = 0.5;
  private static readonly ANIMATION_DURATION: number = 300;
  private static readonly EASE_OUT_CURVE: Curve = Curve.EaseOut;
  // Theme management
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop groupInfo?: ContactInfo;
  onClose?: () => void;
  @State isJoiningGroup: boolean = false;
  @State verificationMessage: string = '';
  @State isVisible: boolean = false;
  @State overlayOpacity: number = 0;
  @State popupTranslateY: number = 1000;
  @State private internalGroupInfo: ContactInfo | null = null;
  private contactListStore: ContactListStore = ContactListStore.createInstance();

  aboutToAppear() {
    console.info('[GroupDetailPage] Page about to appear');

    this.contactListStore?.registerListener();
    if (this.groupInfo) {
      this.internalGroupInfo = this.groupInfo;
    } else {
      const params = router.getParams() as Record<string, Object>;
      if (params && params['groupInfo']) {
        this.internalGroupInfo = params['groupInfo'] as ContactInfo;
      }
    }

    if (!this.groupInfo) {
      this.playEnterAnimation();
    }
  }

  aboutToDisappear() {
    console.info('[GroupDetailPage] Page about to disappear');
    // DestroycontactListStore
    if (this.contactListStore) {
      this.contactListStore?.unregisterListener();
    }
  }

  @Builder
  BackButtonBuilder() {
    Text($r('app.string.back_button'))
      .fontSize(16)
      .fontColor(this.themeState.colors.textColorLink)// Figma: #1C66E5
      .fontFamily('PingFang SC')
      .fontWeight(FontWeight.Normal)
      .onClick(() => {
        this.handleClose();
      })
  }

  @Builder
  TitleBuilder() {
    Text($r('app.string.info'))
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(0, 0, 0, 0.9)
      .fontFamily('PingFang SC')
      .letterSpacing(2.34)
  }

  @Builder
  GroupAvatarBuilder() {
    if (this.internalGroupInfo) {
      Stack() {
        if (this.internalGroupInfo.avatarURL && this.internalGroupInfo.avatarURL.startsWith('http')) {
          Image(this.internalGroupInfo.avatarURL)
            .width(GroupDetailPage.GROUP_AVATAR_SIZE)
            .height(GroupDetailPage.GROUP_AVATAR_SIZE)
            .borderRadius(GroupDetailPage.GROUP_AVATAR_SIZE / 2)
            .objectFit(ImageFit.Cover)
        } else {

          Circle()
            .width(GroupDetailPage.GROUP_AVATAR_SIZE)
            .height(GroupDetailPage.GROUP_AVATAR_SIZE)
            .fill(this.themeState.colors.textColorLink)

          Text(TextUtils.getAvatarLetter(this.internalGroupInfo.title || this.internalGroupInfo.identifier || ''))
            .fontSize(32)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
        }
      }
      .margin({ top: 18, bottom: 18 })
    }
  }

  @Builder
  GroupInfoSectionBuilder() {
    if (this.internalGroupInfo) {
      Row() {

        this.GroupAvatarBuilder()


        Column() {

          Text(this.internalGroupInfo.title || this.internalGroupInfo.identifier || '')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang SC')
            .alignSelf(ItemAlign.Start)


          Text(`ID：${this.internalGroupInfo.identifier}`)
            .fontSize(12)
            .fontColor(this.themeState.colors.textColorSecondary)
            .fontFamily('PingFang SC')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 4 })


          Text(`Type：Work`)
            .fontSize(12)
            .fontColor(this.themeState.colors.textColorSecondary)
            .fontFamily('PingFang SC')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 18 })
      }
      .width('100%')
      .height(86)
      .padding({
        left: GroupDetailPage.CONTENT_PADDING_HORIZONTAL,
        right: GroupDetailPage.CONTENT_PADDING_HORIZONTAL
      })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.themeState.colors.bgColorOperate)
    }
  }

  @Builder
  VerificationInfoSectionBuilder() {
    Column() {

      TextInput({
        text: this.verificationMessage,
        placeholder: $r('app.string.enter_verification_info')
      })
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorSecondary)
        .placeholderColor(this.themeState.colors.textColorTertiary)
        .fontFamily('PingFang SC')
        .width('100%')
        .backgroundColor('transparent')
        .border({ width: 0 })
        .maxLines(3)
        .textAlign(TextAlign.Start)
        .padding({
          left: GroupDetailPage.CONTENT_PADDING_HORIZONTAL,
          right: GroupDetailPage.CONTENT_PADDING_HORIZONTAL,
          top: 12,
          bottom: 12
        })
        .onChange((value: string) => {
          this.verificationMessage = value;
        })
    }
    .width('100%')
    .height(123)
    .backgroundColor(this.themeState.colors.bgColorInput)
  }

  @Builder
  SendButtonBuilder() {
    Row() {
      Text(this.isJoiningGroup ? $r('app.string.sending') : $r('app.string.send'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorLink)
        .fontFamily('PingFang SC')
        .textAlign(TextAlign.Center)
    }
    .width(GroupDetailPage.SEND_BUTTON_WIDTH)
    .height(GroupDetailPage.SEND_BUTTON_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorInput)
    .borderRadius(10)
    .margin({
      top: 16,
      left: GroupDetailPage.CONTENT_PADDING_HORIZONTAL,
      right: GroupDetailPage.CONTENT_PADDING_HORIZONTAL,
      bottom: 16
    })
    .onClick(() => {
      if (!this.isJoiningGroup) {
        this.handleJoinGroup();
      }
    })
  }

  @Builder
  MainContentBuilder() {
    Column() {

      this.GroupInfoSectionBuilder()

      // Divider
      Divider()
        .color('#E5E5EA')
        .strokeWidth(GroupDetailPage.DIVIDER_HEIGHT)


      this.VerificationInfoSectionBuilder()


      this.SendButtonBuilder()
    }
    .width('100%')
    .backgroundColor(this.themeState.colors.bgColorDefault)
  }

  build() {
    if (this.groupInfo) {

      this.MainContentBuilder()
    } else {

      if (this.isVisible) {
        Column() {

          Column()
            .layoutWeight(1)
            .backgroundColor('rgba(0, 0, 0, 0.6)')
            .opacity(this.overlayOpacity)
            .onClick(() => {
              this.handleClose();
            })


          Column() {

            Row() {
              // Back button
              this.BackButtonBuilder()


              Row() {
                this.TitleBuilder()
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)


              Row()
                .width(60)
            }
            .width('100%')
            .height(44)
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.themeState.colors.bgColorDefault)

            // Divider
            Divider()
              .color(this.themeState.colors.strokeColorSecondary)
              .strokeWidth(GroupDetailPage.DIVIDER_HEIGHT)


            Column() {
              this.MainContentBuilder()
            }
            .layoutWeight(1)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius({
            topLeft: GroupDetailPage.TOP_BORDER_RADIUS,
            topRight: GroupDetailPage.TOP_BORDER_RADIUS
          })
          .height(`${GroupDetailPage.POPUP_HEIGHT_RATIO * 100}%`)
          .backdropBlur(20)
          .translate({ y: this.popupTranslateY })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.6)')
      }
    }
  }

  private playEnterAnimation() {
    this.isVisible = true;


    animateTo({
      duration: GroupDetailPage.ANIMATION_DURATION,
      curve: GroupDetailPage.EASE_OUT_CURVE
    }, () => {
      this.overlayOpacity = 1;
    });


    animateTo({
      duration: GroupDetailPage.ANIMATION_DURATION,
      curve: GroupDetailPage.EASE_OUT_CURVE,
      delay: 50
    }, () => {
      this.popupTranslateY = 0;
    });
  }

  private playExitAnimation() {

    animateTo({
      duration: GroupDetailPage.ANIMATION_DURATION,
      curve: Curve.EaseIn
    }, () => {
      this.popupTranslateY = 1000;
    });


    animateTo({
      duration: GroupDetailPage.ANIMATION_DURATION,
      curve: Curve.EaseIn,
      delay: 50
    }, () => {
      this.overlayOpacity = 0;
    });


    setTimeout(() => {
      router.back();
    }, GroupDetailPage.ANIMATION_DURATION + 100);
  }

  private handleClose() {
    if (this.onClose) {

      this.onClose();
    } else {

      this.playExitAnimation();
    }
  }

  private handleJoinGroup() {
    if (!this.internalGroupInfo || this.isJoiningGroup) {
      return;
    }


    this.isJoiningGroup = true;


    if (this.internalGroupInfo.identifier) {
      this.contactListStore.joinGroup(this.internalGroupInfo.identifier, this.verificationMessage || '申请加入群组')
        .then(() => {

          this.isJoiningGroup = false;


          if (this.internalGroupInfo) {

            // this.internalGroupInfo.isJoined = true;
          }
          Toast.show($r('app.string.group_request_sent'), ToastType.Success, this.getUIContext(), 3000);
          this.handleClose();

        })
        .catch((error: CompletionHandler) => {
          Toast.show($r('app.string.already_in_group'), ToastType.Error, this.getUIContext(), 3000);
          this.handleClose();
        });
    }
  }

  private handleSendMessage() {
    if (!this.internalGroupInfo) {
      return;
    }


    // router.pushUrl({
    //   url: 'pages/GroupChatPage',
    //   params: {
    //     groupId: this.internalGroupInfo.identifier,
    //     groupName: this.internalGroupInfo.title
    //   }
    // });
  }
} 