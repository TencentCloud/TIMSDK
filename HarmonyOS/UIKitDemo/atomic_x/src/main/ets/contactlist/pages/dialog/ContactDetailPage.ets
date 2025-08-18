import {
  Avatar,
  AvatarSize,
  AvatarContentType,
  TextUtils,
  ThemeState,
  Toast,
  ToastType
} from '../../../basecomponent/Index';
import { ContactListStore, ContactInfo, CompletionHandler } from 'chatengine';
import router from '@ohos.router';

@Entry({ routeName: 'ContactDetailPage' })
@Component
export struct ContactDetailPage {
  private static readonly POPUP_HEIGHT_RATIO: number = 0.8;
  private static readonly AVATAR_SIZE: number = 66;
  private static readonly AVATAR_MARGIN_RIGHT: number = 18;
  private static readonly CONTENT_PADDING_HORIZONTAL: number = 16;
  private static readonly BUTTON_HEIGHT: number = 52;
  private static readonly SEND_BUTTON_WIDTH: number = 357;
  private static readonly SEND_BUTTON_HEIGHT: number = 40;
  private static readonly TOP_BORDER_RADIUS: number = 10;
  private static readonly DIVIDER_HEIGHT: number = 0.5;
  private static readonly USER_INFO_SECTION_HEIGHT: number = 86;
  private static readonly ANIMATION_DURATION: number = 300;
  private static readonly EASE_OUT_CURVE: Curve = Curve.EaseOut;
  // Theme management
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop userInfo?: ContactInfo;
  onClose?: () => void;
  @State isAddingFriend: boolean = false;
  @State remarkName: string = '';
  @State isEditingRemark: boolean = false;
  @State verificationMessage: string = '';
  @State isVisible: boolean = false;
  @State overlayOpacity: number = 0;
  @State popupTranslateY: number = 1000;
  @State private internalUserInfo: ContactInfo | null = null;
  private contactListStore: ContactListStore = ContactListStore.createInstance();

  aboutToAppear() {
    console.info('[ContactDetailPage] Page about to appear');

    this.contactListStore?.registerListener();
    if (this.userInfo) {
      this.internalUserInfo = this.userInfo;
      this.remarkName = this.userInfo.title || '';

    } else {

      const params = router.getParams() as Record<string, Object>;
      if (params && params['userInfo']) {
        this.internalUserInfo = params['userInfo'] as ContactInfo;
        this.remarkName = this.internalUserInfo?.title || '';

      }
    }


    if (!this.remarkName && this.internalUserInfo) {
      this.remarkName = this.internalUserInfo.title || '';
    }


    if (!this.userInfo) {
      this.playEnterAnimation();
    }
  }

  aboutToDisappear() {
    console.info('[ContactDetailPage] Page about to disappear');
    // DestroycontactListStore
    if (this.contactListStore) {
      this.contactListStore?.unregisterListener();
    }
  }

  @Builder
  BackButtonBuilder() {
    Text($r('app.string.back_button'))
      .fontSize(16)
      .fontColor(this.themeState.colors.textColorLink)// Figma: #4086FF
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
      .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(255, 255, 255, 0.9)
      .fontFamily('PingFang SC')
      .letterSpacing(2.34)
      .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  UserInfoSectionBuilder() {
    if (this.internalUserInfo) {
      Row() {
        Avatar({
          content: {
            type: AvatarContentType.Image,
            url: this.internalUserInfo.avatarURL,
            name: this.internalUserInfo.title || this.internalUserInfo.identifier || '',
          },
          avatarSize: AvatarSize.L,
        })

        Column() {

          Text(this.internalUserInfo.title || this.internalUserInfo.identifier || '')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang SC')
            .alignSelf(ItemAlign.Start)


          Text(`ID：${this.internalUserInfo.identifier}`)
            .fontSize(12)
            .fontColor(this.themeState.colors.textColorSecondary)
            .fontFamily('PingFang SC')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 4 })


          // if (this.internalUserInfo.signature && this.internalUserInfo.signature.length > 0) {

          //     .fontSize(12)
          //     .fontColor(this.themeState.currentTheme.textColorSecondary)
          //     .fontFamily('PingFang SC')
          //     .alignSelf(ItemAlign.Start)
          //     .maxLines(1)
          //     .textOverflow({ overflow: TextOverflow.Ellipsis })
          //     .margin({ top: 4 })
          // }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: ContactDetailPage.AVATAR_MARGIN_RIGHT })
      }
      .width('100%')
      .height(ContactDetailPage.USER_INFO_SECTION_HEIGHT)
      .padding({
        left: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
        right: ContactDetailPage.CONTENT_PADDING_HORIZONTAL
      })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.themeState.colors.bgColorOperate)
    }
  }

  @Builder
  RemarkSectionBuilder() {

    Row() {
      Text($r('app.string.remarks'))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(255, 255, 255, 0.9)
        .fontFamily('PingFang SC')
        .layoutWeight(1)

      if (this.isEditingRemark) {
        TextInput({ text: this.remarkName })
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(255, 255, 255, 0.9)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .textAlign(TextAlign.End)
          .fontFamily('PingFang SC')
          .onChange((value: string) => {
            this.remarkName = value;
          })
          .onSubmit(() => {
            this.isEditingRemark = false;
          })
      } else {
        Text(this.remarkName || '')
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(255, 255, 255, 0.9)
          .fontFamily('PingFang SC')
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.isEditingRemark = true;
          })
      }
    }
    .width('100%')
    .height(ContactDetailPage.BUTTON_HEIGHT)
    .padding({
      left: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
      right: ContactDetailPage.CONTENT_PADDING_HORIZONTAL
    })
    .backgroundColor(this.themeState.colors.bgColorOperate) // Figma: #1F2024
    .shadow({
      radius: 1,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 1
    })
  }

  @Builder
  GroupSectionBuilder() {
    Row() {
      Text($r('app.string.group'))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(255, 255, 255, 0.9)
        .fontFamily('PingFang SC')
        .layoutWeight(1)

      Row() {
        Text($r('app.string.my_friend'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(255, 255, 255, 0.9)
          .fontFamily('PingFang SC')
          .margin({ right: 4 })

        Image($r('sys.symbol.chevron_right'))
          .width(16)
          .height(16)
          .fillColor(this.themeState.colors.textColorSecondary) // Figma: rgba(255, 255, 255, 0.3)
      }
      .onClick(() => {
        console.info('[ContactDetailPage] Group setting clicked');
      })
    }
    .width('100%')
    .height(ContactDetailPage.BUTTON_HEIGHT)
    .padding({
      left: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
      right: ContactDetailPage.CONTENT_PADDING_HORIZONTAL
    })
    .backgroundColor(this.themeState.colors.bgColorOperate) // Figma: #1F2024
    .shadow({
      radius: 1,
      color: this.themeState.colors.shadowColor, // Figma: rgba(0, 0, 0, 0.1)
      offsetX: 0,
      offsetY: 1
    })
  }

  @Builder
  VerificationInfoSectionBuilder() {
    Column() {

      Text($r('app.string.validation_message'))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(255, 255, 255, 0.9)
        .fontFamily('PingFang SC')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({
          left: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
          right: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
          top: 12,
          bottom: 8
        })


      TextInput({
        text: this.verificationMessage,
        placeholder: $r('app.string.enter_verification_info')
      })
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorSecondary)// Figma: rgba(255, 255, 255, 0.3)
        .placeholderColor(this.themeState.colors.textColorTertiary)// Figma: rgba(255, 255, 255, 0.3)
        .fontFamily('PingFang SC')
        .width('100%')
        .backgroundColor('transparent')
        .border({ width: 0 })
        .maxLines(3)
        .textAlign(TextAlign.Start)
        .padding({
          left: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
          right: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
          top: 0,
          bottom: 12
        })
        .onChange((value: string) => {
          this.verificationMessage = value;
        })
    }
    .width('100%')
    .height(123)
    .backgroundColor(this.themeState.colors.bgColorInput) // Figma: #2B2C30
  }

  @Builder
  SendButtonBuilder() {
    Row() {
      Text(this.isAddingFriend ? $r('app.string.sending') : $r('app.string.send'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorLink)// Figma: #4086FF
        .fontFamily('PingFang SC')
        .textAlign(TextAlign.Center)
    }
    .width(ContactDetailPage.SEND_BUTTON_WIDTH)
    .height(ContactDetailPage.SEND_BUTTON_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorInput) // Figma: #2B2C30
    .borderRadius(10)
    .margin({
      top: 16,
      left: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
      right: ContactDetailPage.CONTENT_PADDING_HORIZONTAL,
      bottom: 16
    })
    .onClick(() => {
      if (!this.isAddingFriend) {
        this.handleAddFriend();
      }
    })
  }

  @Builder
  MainContentBuilder() {
    Column() {

      this.UserInfoSectionBuilder()

      // Divider
      Divider()
        .color(this.themeState.colors.strokeColorSecondary)// Figma: #E5E5EA
        .strokeWidth(ContactDetailPage.DIVIDER_HEIGHT)

      // Divider
      Divider()
        .color(this.themeState.colors.strokeColorSecondary)// Figma: #E5E5EA
        .strokeWidth(ContactDetailPage.DIVIDER_HEIGHT)

      this.VerificationInfoSectionBuilder()


      this.RemarkSectionBuilder()

      this.GroupSectionBuilder()


      // this.RemarksAndGroupingButtonBuilder()


      // this.FillVerificationInfoButtonBuilder()


      this.SendButtonBuilder()
    }
    .width('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  build() {
    if (this.userInfo) {

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

            // Divider
            Divider()
              .color('#E5E5EA')
              .strokeWidth(ContactDetailPage.DIVIDER_HEIGHT)


            Column() {
              this.MainContentBuilder()
            }
            .layoutWeight(1)
          }
          .width('100%')
          .borderRadius({
            topLeft: ContactDetailPage.TOP_BORDER_RADIUS,
            topRight: ContactDetailPage.TOP_BORDER_RADIUS
          })
          .height(`${ContactDetailPage.POPUP_HEIGHT_RATIO * 100}%`)
          .backdropBlur(20)
          .translate({ y: this.popupTranslateY })
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  private playEnterAnimation() {
    this.isVisible = true;


    animateTo({
      duration: ContactDetailPage.ANIMATION_DURATION,
      curve: ContactDetailPage.EASE_OUT_CURVE
    }, () => {
      this.overlayOpacity = 1;
    });


    animateTo({
      duration: ContactDetailPage.ANIMATION_DURATION,
      curve: ContactDetailPage.EASE_OUT_CURVE,
      delay: 50
    }, () => {
      this.popupTranslateY = 0;
    });
  }

  private playExitAnimation() {

    animateTo({
      duration: ContactDetailPage.ANIMATION_DURATION,
      curve: Curve.EaseIn
    }, () => {
      this.popupTranslateY = 1000;
    });


    animateTo({
      duration: ContactDetailPage.ANIMATION_DURATION,
      curve: Curve.EaseIn,
      delay: 50
    }, () => {
      this.overlayOpacity = 0;
    });


    setTimeout(() => {
      router.back();
    }, ContactDetailPage.ANIMATION_DURATION + 100);
  }

  private handleClose() {
    if (this.onClose) {

      this.onClose();
    } else {

      this.playExitAnimation();
    }
  }

  private handleAddFriend() {
    if (!this.internalUserInfo || this.isAddingFriend) {
      return;
    }


    this.isAddingFriend = true;

    this.contactListStore.addFriend(
      this.internalUserInfo.identifier || '',
      this.remarkName || this.internalUserInfo.title || '',
      this.verificationMessage ?? ' ',
    )
      .then(() => {

        this.isAddingFriend = false;

        Toast.show($r('app.string.friend_request_sent'), ToastType.Success, this.getUIContext(), 3000);
        this.handleClose();
      })
      .catch((error: CompletionHandler) => {

        this.isAddingFriend = false;
        Toast.show($r('app.string.add_friend_failed'), ToastType.Error, this.getUIContext(), 3000);

      });
  }
} 