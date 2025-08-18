import {
  ContactListView,
  ContactInfo,
  AddContactDialog,
  SearchResultType,
  AppBuilderConfig,
  C2CChatSettingView
} from 'atomic_x'
import { ThemeState } from 'atomic_x'
import router from '@ohos.router'
import { ImmersiveMode, LevelMode } from '@ohos.promptAction'

@CustomDialog
struct C2CSettingDialogInContactPage {
  controller: CustomDialogController;
  conversationID: string = '';
  title: string = 'Contact Info';
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

@Entry
@Component
export struct ContactPage {
  private static readonly HEADER_HEIGHT: number = 56;
  private static readonly LARGE_TITLE_HEIGHT: number = 52;
  private static readonly SEARCH_HEIGHT: number = 36;
  private static readonly SEARCH_BAR_HEIGHT: number = 36;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State searchKeyword: string = '';
  onBadgeUpdate?: (badgeCount: number) => void;
  @State showAddMenu: boolean = false;
  private addContactDialogController: CustomDialogController | null = null;
  private settingDialogController?: CustomDialogController;

  aboutToAppear() {

  }

  aboutToDisappear() {
    if (this.settingDialogController) {
      this.settingDialogController = undefined;
    }
  }

  @Builder
  LargeTitleBuilder() {
    Row() {
      Text($r('app.string.contacts_title'))
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontFamily('PingFang HK')
        .layoutWeight(1)

      Row() {

        Image($r('app.media.new_chat_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.showAddMenu = true;
          })
      }
    }
    .width('100%')
    .height(ContactPage.LARGE_TITLE_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  SearchBarBuilder() {
    Row() {
      Image($r('app.media.search_icon'))
        .width(16)
        .height(16)
        .fillColor(this.themeState.colors.textColorLink)
        .margin({ left: 16 })

      TextInput({
        placeholder: $r('app.string.contacts_search_placeholder'),
        text: this.searchKeyword
      })
        .backgroundColor(Color.Transparent)
        .border({ width: 0 })
        .fontSize(17)
        .fontColor(this.themeState.colors.textColorPrimary)
        .placeholderColor(this.themeState.colors.textColorTertiary)
        .fontFamily('PingFang HK')
        .layoutWeight(1)
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.performSearch();
        })

      if (this.searchKeyword.length > 0) {
        Button() {
          Text('✕')
            .fontSize(14)
            .fontColor('rgba(60, 60, 67, 0.6)')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .width(20)
        .height(20)
        .margin({ right: 8 })
        .onClick(() => {
          this.searchKeyword = '';
          this.clearSearch();
        })
      }
    }
    .height(ContactPage.SEARCH_BAR_HEIGHT)
    .backgroundColor(this.themeState.colors.bgColorInput)
    .borderRadius(10)
    .margin({
      left: 16,
      right: 16,
      top: 9,
      bottom: 16
    })
  }

  @Builder
  AddMenuDialog() {
    Column() {

      Polygon({ width: 12, height: 6 })
        .points([[6, 0], [0, 6], [12, 6]])
        .fill(this.themeState.colors.bgColorOperate)// .stroke('#E5E5E5')
        .strokeWidth(1)
        .margin({ bottom: -1 })
        .alignSelf(ItemAlign.End)
        .margin({ right: 18 })


      Column() {

        Row() {
          Image($r('app.media.start_conversation_c2c'))
            .width(15)
            .height(17)
            .margin({ right: 12 })
            .fillColor(this.themeState.colors.textColorPrimary)

          Text($r('app.string.add_friend'))
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang HK')
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.showAddMenu = false;
          this.handleAddFriend();
        })

        // Divider
        Divider()
          .color('#E5E5E5')
          .strokeWidth(0.5)
          .margin({ left: 52 })


        Row() {
          Image($r('app.media.start_conversation_group'))
            .width(19)
            .height(16)
            .margin({ right: 12 })
            .fillColor(this.themeState.colors.textColorPrimary)

          Text($r('app.string.add_group_chat'))
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang HK')
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.showAddMenu = false;
          this.handleAddGroup();
        })
      }
      .backgroundColor(this.themeState.colors.bgColorOperate)
      .borderRadius(12)
      .border({ width: 1, color: '#E5E5E5' })
      .shadow({
        radius: 8,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 2
      })
      .width(140)
    }
    .position({ x: '100%', y: ContactPage.LARGE_TITLE_HEIGHT + 8 })
    .markAnchor({ x: 148, y: 0 })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {

        this.LargeTitleBuilder()

        if (!AppBuilderConfig.getInstance().hideSearch) {
          this.SearchBarBuilder()
        }
        ContactListView({
          onSelectContact: this.handleContactSelect,
          onSelectGroup: this.handleGroupSelect,
          onDeleteSelected: this.handleContactDelete,
          onSelectBlackListContact: this.handleContactInfo,
          searchKeyword: this.searchKeyword,
          onBadgeUpdate: this.onBadgeUpdate
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.colors.bgColorOperate)
      .onClick(() => {

        if (this.showAddMenu) {
          this.showAddMenu = false;
        }
      })


      if (this.showAddMenu) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0)')
          .onClick(() => {
            this.showAddMenu = false;
          })
      }


      if (this.showAddMenu) {
        this.AddMenuDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  private handleContactSelect = (contact: ContactInfo) => {
    console.info(`[ContactPage] 选择联系人: ${contact.identifier}`)
    if (contact.identifier) {
      router.pushUrl({
        url: 'pages/MessagePage',
        params: {
          conversationID: `c2c_${contact.identifier}`,
          conversationType: 1,
          contactInfo: contact,
          title: contact.title,
          avatarUrl: contact.avatarURL
        }
      }).then(() => {
        console.info('[ContactPage] 成功跳转到聊天页面')
      }).catch((error: Error) => {
        console.error('[ContactPage] 跳转聊天页面失败:', error.message)
      })
    }
  }
  private handleGroupSelect = (group: ContactInfo) => {
    console.info(`[ContactPage] handleGroupSelect: ${group.identifier}`)

    if (group.identifier) {
      router.pushUrl({
        url: 'pages/MessagePage',
        params: {
          conversationID: `group_${group.identifier}`,
          conversationType: 2, // Group chat
          groupInfo: group,
          title: group.title,
          avatarUrl: group.avatarURL
        }
      }).then(() => {

      }).catch((error: Error) => {

      })
    }
  }
  private handleContactDelete = () => {
    console.info('[ContactPage] handleContactDelete')
  }
  private handleAddFriend = () => {
    console.info('[ContactPage] handleAddFriend')
    if (this.addContactDialogController) {
      this.addContactDialogController.close();
      this.addContactDialogController = null;
    }
    this.addContactDialogController = new CustomDialogController({
      builder: AddContactDialog({
        onCancel: () => {

          this.addContactDialogController = null;
        },
        onSearchUser: (keyword: string) => {

        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Default,
      customStyle: true,
      cancel: () => {
        this.addContactDialogController = null;
      }
    });


    this.addContactDialogController.open();
  }
  private handleAddGroup = () => {
    console.info('[ContactPage] handleAddGroup')
    if (this.addContactDialogController) {
      this.addContactDialogController.close();
      this.addContactDialogController = null;
    }
    this.addContactDialogController = new CustomDialogController({
      builder: AddContactDialog({
        initialSearchType: SearchResultType.GROUP,
        onCancel: () => {
          this.addContactDialogController = null;
        },
        onSearchUser: (keyword: string) => {

        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Default,
      customStyle: true,
      cancel: () => {
        this.addContactDialogController = null;
      }
    });


    this.addContactDialogController.open();
  }
  private handleContactInfo = (info: ContactInfo) => {
    console.info(`[ContactPage] ${info.identifier}`)
    if (info.identifier) {
      const conversationID = `c2c_${info.identifier}`;
      this.showC2CSettingDialog(conversationID, info.title || 'Contact Info');
    }
  }

  private showC2CSettingDialog(conversationID: string, title: string): void {
    try {
      if (this.settingDialogController) {
        this.settingDialogController.close();
        this.settingDialogController = undefined;
      }

      if (!conversationID || conversationID.length === 0) {
        return;
      }

      this.settingDialogController = new CustomDialogController({
        builder: C2CSettingDialogInContactPage({
          conversationID: conversationID,
          title: title,
          onDialogClose: () => {
            // Handle dialog close if needed
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
            // Animation finished
          }
        },
        closeAnimation: {
          duration: 250,
          curve: Curve.EaseInOut,
          playMode: PlayMode.Normal,
          onFinish: () => {
            // Animation finished
          }
        }
      });

      this.settingDialogController.open();
    } catch (error) {
    }
  }

  private handleSelectedNavigateMessagePage(newConversationID?: string, title?: string, avatarUrl?: string): void {

    if (newConversationID && newConversationID.length > 0) {
      // Determine conversation type
      const isGroupChat = newConversationID.startsWith('group_');
      const chatTitle = title || (isGroupChat ? 'group chat' : 'contact');
      const chatAvatarUrl = avatarUrl || '';

      // Navigate to message page
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
    }
  }

  private performSearch() {
    console.info(`[ContactPage] SearchKeyword: ${this.searchKeyword}`)
  }

  private clearSearch() {
    console.info('[ContactPage] clearSearch')
  }
}