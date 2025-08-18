import { AppBuilderConfig, ThemeState } from 'atomic_x';
import { ConversationListView } from 'atomic_x';
import { router } from '@kit.ArkUI';
import {
  ConversationInfo,
  ContactInfo,
  ContactResultInfo,
  GroupResultInfo,
  ConversationResultInfo,
  MessageInConversationResultInfo,
  SearchType
} from 'chatengine';
import { StartConversationDialog, DialogType } from 'atomic_x';
import { GroupInfo } from 'atomic_x';
import { SearchListPage } from 'atomic_x';

@Component
export struct ConversationPage {
  private static readonly HEADER_HEIGHT: number = 56;
  private static readonly LARGE_TITLE_HEIGHT: number = 52;
  private static readonly SEARCH_HEIGHT: number = 36;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State searchText: string = '';
  @State isEditMode: boolean = false;
  onBadgeUpdate?: (badgeCount: number) => void;
  @State showAddMenu: boolean = false;
  private startConversationDialogController: CustomDialogController | null = null;
  private createGroupDialogController: CustomDialogController | null = null;
  private searchDialogController: CustomDialogController | null = null;

  @Builder
  SearchBuilder() {
    Row() {
      Row() {
        Image($r('app.media.search_icon'))
          .width(16)
          .height(16)
          .fillColor(this.themeState.colors.textColorLink)
          .margin({ right: 6 })

        Text($r('app.string.search_placeholder'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorTertiary)
      }
      .width('100%')
      .height(ConversationPage.SEARCH_HEIGHT)
      .borderRadius(10)
      .backgroundColor(this.themeState.colors.bgColorInput)
      .padding({ left: 8, right: 22 })
      .onClick(() => {
        this.handleSearch();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  LargeTitleBuilder() {
    Row() {
      Text($r('app.string.chat_title'))
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.colors.textColorPrimary)
        .layoutWeight(1)

      Row() {

        Image($r('app.media.edit_icon'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            this.isEditMode = true;
          })


        Image($r('app.media.new_chat_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.showAddMenu = true;
          })
      }
    }
    .width('100%')
    .height(ConversationPage.LARGE_TITLE_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
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

          Text($r('app.string.start_conversation'))
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang HK')
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.showAddMenu = false;
          this.handleStartConversation();
        })

        // Divider
        Divider()
          .color('#E5E5E5')
          .strokeWidth(0.5)
          .margin({ left: 52 })


        if (AppBuilderConfig.getInstance().enableCreateConversation) {
          Row() {
            Image($r('app.media.start_conversation_group'))
              .width(19)
              .height(16)
              .margin({ right: 12 })
              .fillColor(this.themeState.colors.textColorPrimary)

            Text($r('app.string.create_group_chat'))
              .fontSize(16)
              .fontColor(this.themeState.colors.textColorPrimary)
              .fontFamily('PingFang HK')
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.showAddMenu = false;
            this.handleCreateGroup();
          })
        }

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
      .width(160)
    }
    .position({ x: '100%', y: ConversationPage.LARGE_TITLE_HEIGHT + 8 })
    .markAnchor({ x: 168, y: 0 })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.LargeTitleBuilder()
        if (!AppBuilderConfig.getInstance().hideSearch) {
          this.SearchBuilder()
        }
        ConversationListView({
          isEditMode: this.isEditMode,
          onSelectConversation: (item: ConversationInfo) => {
            console.info(`Navigate to conversation detail with ID: ${item.ID}`);
            try {
              router.pushUrl({
                url: 'pages/MessagePage',
                params: {
                  conversationID: item.ID,
                  title: item.title,
                  avatarUrl: item.avatarURL
                }
              });
            } catch (error) {

            }
          },
          onDeleteSelected: () => {

            this.isEditMode = false;
          },
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

  @Builder
  SearchDialogBuilder() {
    Column() {
      SearchListPage({
        onContactSelect: (contact: ContactResultInfo) => {
          if (contact.userID) {
            router.pushUrl({
              url: 'pages/MessagePage',
              params: {
                conversationID: `c2c_${contact.userID}`,
                conversationType: 1,
                title: contact.friendRemark || contact.nickname || contact.userID,
                avatarUrl: contact.userAvatar
              }
            })
          }
          this.searchDialogController?.close();
          this.searchDialogController = null;
        },
        onGroupSelect: (group: GroupResultInfo) => {


          if (group.groupID) {
            router.pushUrl({
              url: 'pages/MessagePage',
              params: {
                conversationID: `group_${group.groupID}`,
                conversationType: 2, // Group chat
                title: group.groupName || group.groupID,
                avatarUrl: group.groupAvatar
              }
            })
          }
          this.searchDialogController?.close();
          this.searchDialogController = null;
        },
        onMessageSelect: (message: MessageInConversationResultInfo) => {
          if (message.conversationID) {
            router.pushUrl({
              url: 'pages/MessagePage',
              params: {
                conversationID: message.conversationID,
                title: message.conversationName,
                locateMessage: message.message,
                avatarUrl: message.conversationAvatar
              }
            })
          }
          this.searchDialogController?.close();
          this.searchDialogController = null;
        },
        onConversationSelect: (message: MessageInConversationResultInfo) => {
          if (message.conversationID) {
            router.pushUrl({
              url: 'pages/MessagePage',
              params: {
                conversationID: message.conversationID,
                title: message.conversationName,
                locateMessage: message.message,
                avatarUrl: message.conversationAvatar
              }
            })
          }
          this.searchDialogController?.close();
          this.searchDialogController = null;
        },
        onBack: () => {

          this.searchDialogController?.close();
          this.searchDialogController = null;
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  private handleStartConversation(): void {
    console.info('[ConversationPage] 发起会话')


    if (this.startConversationDialogController) {
      this.startConversationDialogController.close();
      this.startConversationDialogController = null;
    }


    this.startConversationDialogController = new CustomDialogController({
      builder: StartConversationDialog({
        dialogType: DialogType.START_CONVERSATION,
        onCancel: () => {

          this.startConversationDialogController = null;
        },
        onSelectUser: (contact: ContactInfo) => {


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
              console.info('[ConversationPage] 成功跳转到聊天页面')
            }).catch((error: Error) => {
              console.error('[ConversationPage] 跳转聊天页面失败:', error.message)
            })
          }
          this.startConversationDialogController?.close();
          this.startConversationDialogController = null;
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      cancel: () => {
        this.startConversationDialogController = null;
      }
    });


    this.startConversationDialogController.open();
  }

  private handleCreateGroup(): void {
    console.info('[ConversationPage] 创建群聊')


    if (this.createGroupDialogController) {
      this.createGroupDialogController.close();
      this.createGroupDialogController = null;
    }


    this.createGroupDialogController = new CustomDialogController({
      builder: StartConversationDialog({
        dialogType: DialogType.CREATE_GROUP,
        onCancel: () => {

          this.createGroupDialogController = null;
        },
        onCreateGroup: (groupInfo: GroupInfo) => {

          this.createGroupDirectly(groupInfo);
          this.createGroupDialogController = null;
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      cancel: () => {
        this.createGroupDialogController = null;
      }
    });


    this.createGroupDialogController.open();
  }

  private createGroupDirectly(groupInfo: GroupInfo): void {
    const tempGroupId = groupInfo.groupID;

    router.pushUrl({
      url: 'pages/MessagePage',
      params: {
        conversationID: `group_${tempGroupId}`,
        conversationType: 2, // Group chat
        title: groupInfo.groupName,
        avatarUrl: groupInfo.avatarUrl,
        memberCount: groupInfo.selectedContacts.length + 1,
        selectedContacts: groupInfo.selectedContacts
      }
    }).then(() => {
      console.info('[ConversationPage] 成功跳转到群聊页面')
    }).catch((error: Error) => {
      console.error('[ConversationPage] 跳转群聊页面失败:', error.message)
    })
  }

  private handleSearch(): void {
    console.info('[ConversationPage] 打开搜索页面')


    if (this.searchDialogController) {
      this.searchDialogController.close();
      this.searchDialogController = null;
    }


    this.searchDialogController = new CustomDialogController({
      builder: this.SearchDialogBuilder,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true,
      keyboardAvoidMode: KeyboardAvoidMode.NONE,
      maskColor: 'rgba(0, 0, 0, 0)',
      cancel: () => {
        this.searchDialogController = null;
      }
    });


    this.searchDialogController.open();
  }
}
