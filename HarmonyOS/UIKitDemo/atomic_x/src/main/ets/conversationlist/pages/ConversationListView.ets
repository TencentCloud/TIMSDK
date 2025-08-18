import {
  Avatar,
  AvatarSize,
  AvatarShape,
  AvatarBadge,
  AvatarBadgePosition,
  AvatarStatus,
  TextUtils,
  ThemeState,
  BadgeControl,
  BadgeType,
  AvatarContentType,
  AppBuilderConfig,
  ConversationAction
} from '../../basecomponent/Index';
import {
  ConversationListStore,
  ConversationInfo,
  ConversationFetchOption,
  ConversationType,
  ConversationActionType,
  CompletionHandler,
  ConversationDataSource,
  ConversationReceiveOption,
  LoginStore,
  ConversationListState,
} from 'chatengine';
import { ConversationMoreDialog, ConversationDialogAction as DialogAction } from './ConversationMoreDialog';
import { router } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { MessageUtils } from '../../messagelist/utils/MessageUtils';

@Component
@Entry
export struct ConversationListView {
  private static readonly AVATAR_SIZE: number = 40;
  private static readonly BADGE_SIZE: number = 20;
  private static readonly DIVIDER_HEIGHT: number = 0.1;
  private static readonly ITEM_HEIGHT: number = 76;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State isLoading: boolean = false;
  @Link isEditMode: boolean;
  @State selectedIds: string[] = [];
  // Callback function
  onRefresh?: () => void;
  onDeleteSelected?: () => void;
  onBadgeUpdate?: (badgeCount: number) => void;
  dialogController: CustomDialogController | null = null
  @State private conversationListStore: ConversationListStore = ConversationListStore.createInstance();
  @Watch('onStoreUnreadCountChanged')
  @State private conversationListState: ConversationListState = this.conversationListStore.state;
  onSelectConversation?: (item: ConversationInfo) => void = (item: ConversationInfo) => {

    console.info(`Navigate to conversation detail with ID: ${item.ID}`);
  };

  aboutToAppear() {
    this.selectedIds = [];

    this.conversationListStore?.registerListener();
    this.fetchConversationList();
    console.info('ConversationListPage aboutToAppear');
  }

  aboutToDisappear() {
    this.conversationListStore?.unregisterListener();
  }

  @Builder
  ActionButtonsBuilder(item: ConversationInfo) {
    Row() {
      // Show "More" button if there are other actions configured
      if (this.hasOtherActions()) {
        Button() {
          Column() {
            Image($rawfile('conversationlist/ic_public_more.svg'))
              .width(24)
              .height(24)
              .fillColor(Color.White)

            Text($r('app.string.more'))
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .type(ButtonType.Normal)
        .backgroundColor(this.themeState.colors.textColorAntiPrimary)
        .width(70)
        .height(ConversationListView.ITEM_HEIGHT)
        .onClick(() => {
          this.showMoreDialog(item);
        })
      }
      // Show "Mark as Read/Unread" button if MARK_UNREAD is in config
      if (this.hasMarkUnreadAction()) {
        Button() {
          Column() {
            Image($rawfile('conversationlist/ic_public_check.svg'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
            Text((item.unreadCount ?? 0) > 0 ? $r('app.string.mark_as_read') : $r('app.string.mark_as_unread'))
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .type(ButtonType.Normal)
        .backgroundColor(this.themeState.colors.textColorLink)
        .width(70)
        .height(ConversationListView.ITEM_HEIGHT)
        .onClick(() => {
          // Toggle read/unread status
          if ((item.unreadCount ?? 0) > 0) {
            // Mark as read
            this.conversationListStore.markConversationUnread(item, false)
              .then(() => {
                console.log('Marked as read successfully');
              })
              .catch((error: CompletionHandler) => {
                console.error('Failed to mark as read:', error.message);
              });
          } else {
            // Mark as unread
            this.conversationListStore.markConversationUnread(item, true)
              .then(() => {
                console.log('Marked as unread successfully');
              })
              .catch((error: CompletionHandler) => {
                console.error('Failed to mark as unread:', error.message);
              });
          }
        })
      }

    }
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($rawfile('search/empty_chat_icon.svg'))
        .width(100)
        .height(100)
        .fillColor(this.themeState.colors.textColorPrimary)
        .margin({ bottom: 16 })

      Text($r('app.string.no_messages_title'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorTertiary)

      Text($r('app.string.no_messages_desc'))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorPrimary)
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  EditActionBarBuilder() {
    if (this.isEditMode) {
      Row() {
        Button($r('app.string.delete_button'))
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Red)
          .onClick(() => {

            this.deleteSelectedConversations();
          })
          .layoutWeight(1)
          .borderRadius(8)
          .height(44)
          .margin({ right: 8 })

        Button($r('app.string.cancel_button'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.themeState.colors.buttonColorPrimaryDefault)
          .onClick(() => {

            this.isEditMode = false;
            this.selectedIds = [];
          })
          .layoutWeight(1)
          .borderRadius(8)
          .height(44)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.themeState.colors.bgColorDefault)
    }
  }

  @Builder
  BottomLogoBuilder() {
    Row() {
      Column() {
        Image($rawfile('conversationlist/conversation_bottom_tencent_logo.svg'))
          .width(120)
          .height(20)
          .objectFit(ImageFit.Contain)

        Text($r('app.string.conversationlist_copyright'))
          .fontSize(10)
          .fontColor(this.themeState.colors.textColorTertiary)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(this.themeState.colors.textColorPrimary)

      Text($r('app.string.loading_message'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorTertiary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ConversationListBuilder() {
    List({ space: 0 }) {
      LazyForEach(this.conversationListState.conversationDataSource, (item: ConversationInfo) => {
        ListItem() {
          Column() {

            Row() {

              if (this.isEditMode) {
                Checkbox()
                  .select(this.selectedIds && this.selectedIds.indexOf(item.ID ?? "") >= 0)
                  .margin({ right: 8 })
                  .onChange((value) => {
                    if (!this.selectedIds) {
                      this.selectedIds = [];
                    }
                    if (value) {
                      this.selectedIds.push(item.ID ?? "");
                    } else {
                      const index = this.selectedIds.indexOf(item.ID ?? "");
                      if (index >= 0) {
                        this.selectedIds.splice(index, 1);
                      }
                    }
                  })
              }

              Stack() {
                Avatar({
                  content: {
                    type: AvatarContentType.Image,
                    name: item.title,
                    url: item.avatarURL
                  },
                  avatarSize: AvatarSize.M,
                  badge: {
                    type: (item.receiveOption != ConversationReceiveOption.RECEIVE && ((item.unreadCount ?? 0) > 0) ?
                    AvatarBadge.Dot :
                    AvatarBadge.None),
                    position: AvatarBadgePosition.Up
                  },
                  // status: AvatarStatus.Online
                })
              }
              .margin({ right: 8 })

              Column() {

                Row() {
                  Text(item.title || $r('app.string.conversationlist_title_placeholder'))
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.themeState.colors.textColorPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)


                  if (item.receiveOption === ConversationReceiveOption.RECEIVE && (item.unreadCount ?? 0) > 0) {
                    BadgeControl({
                      text: (item.unreadCount ?? 0) > 99 ? '99+' : (item.unreadCount ?? 0).toString(),
                      type: BadgeType.Text
                    })
                      .margin({ left: 4 })
                  }


                  if (item.receiveOption != ConversationReceiveOption.RECEIVE) {
                    Image($rawfile('conversationlist/muted_icon.svg'))
                      .width(16)
                      .height(16)
                      .fillColor(this.themeState.colors.textColorSecondary)
                      .margin({ left: 4 })
                  }
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)


                Row() {
                  Text(MessageUtils.getMessageAbstract(item.lastMessage))
                    .fontSize(12)
                    .fontColor('#7A7A7A')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)


                  Text(this.formatTimeFromTs(item.timestamp || 0))
                    .fontSize(12)
                    .fontColor('#7A7A7A')
                    .margin({ left: 8 })
                }
                .width('100%')
                .margin({ top: 4 })
                .alignItems(VerticalAlign.Center)
              }
              .layoutWeight(1)
              .height('100%')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .height(ConversationListView.ITEM_HEIGHT)
            .padding({ left: 16, right: 16 })
            .backgroundColor(item.isPinned ? this.themeState.colors.bgColorInput :
            this.themeState.colors.bgColorOperate)
            .onClick(() => {
              if (this.isEditMode) {

                if (!this.selectedIds) {
                  this.selectedIds = [];
                }
                const index = this.selectedIds.indexOf(item.ID ?? "");
                if (index >= 0) {
                  this.selectedIds.splice(index, 1);
                } else {
                  this.selectedIds.push(item.ID ?? "");
                }
              } else {

                if (this.onSelectConversation) {
                  this.onSelectConversation(item);
                }
                console.info(`Navigate to conversation detail with ID: ${item.ID}`);
              }
            })


            if (this.conversationListState.conversationDataSource.getIndex(item) <
              this.conversationListState.conversationDataSource.totalCount() - 1) {
              Divider()
                .height(ConversationListView.DIVIDER_HEIGHT)
                .color(this.themeState.colors.textColorPrimary)
                .margin({ left: 16 + ConversationListView.AVATAR_SIZE + 8 })
            }
          }
        }
        .swipeAction({ end: this.ActionButtonsBuilder(item) })
      }, (item: ConversationInfo) => item.getKey())


      ListItem() {
        this.BottomLogoBuilder()
      }
    }
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .onReachEnd(() => {

      this.loadMoreConversationList();
    })
    .width('100%')
    .layoutWeight(1)
  }

  build() {
    Column() {
      if (this.conversationListState.conversationDataSource.totalCount() > 0) {

        this.ConversationListBuilder()
      } else if (this.isLoading) {

        this.LoadingStateBuilder()
      } else {
        // Empty state
        Column() {
          this.EmptyStateBuilder()


          this.BottomLogoBuilder()
        }
        .layoutWeight(1)
      }


      this.EditActionBarBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  private formatTimeFromTs(ts: number): string {
    if (!ts || ts <= 0) {
      return ''
    }
    const date = new Date(ts * 1000)
    const h = date.getHours().toString().padStart(2, '0')
    const m = date.getMinutes().toString().padStart(2, '0')
    return `${h}:${m}`
  }

  private onStoreUnreadCountChanged() {
    if (this.onBadgeUpdate) {
      this.onBadgeUpdate(this.conversationListState.totalUnreadCount);
    }
  }

  // Helper methods to determine button visibility
  private hasMarkUnreadAction(): boolean {
    return AppBuilderConfig.getInstance().conversationActionList.includes(ConversationAction.MARK_UNREAD);
  }

  private hasOtherActions(): boolean {
    return AppBuilderConfig.getInstance()
      .conversationActionList
      .some(action => action !== ConversationAction.MARK_UNREAD);
  }

  private fetchConversationList() {
    this.isLoading = true;
    const option = new ConversationFetchOption();
    option.count = 100;


    this.conversationListStore.fetchConversations(option)
      .then(() => {
        const count = this.conversationListState.conversationDataSource.totalCount();


        if (count === 0) {


          setTimeout(() => {
            this.retryFetchConversationList();
          }, 1000);
        } else {
          this.isLoading = false;
        }
      })
      .catch((error: CompletionHandler) => {

        this.isLoading = false;
      });
  }

  private retryFetchConversationList() {
    const option = new ConversationFetchOption();
    option.count = 100;


    this.conversationListStore.fetchConversations(option)
      .then(() => {
        const count = this.conversationListState.conversationDataSource.totalCount();

        this.isLoading = false;
      })
      .catch((error: CompletionHandler) => {

        this.isLoading = false;
      });
  }

  private loadMoreConversationList() {
    if (this.isLoading || !this.conversationListState.hasMoreConversation) {

      return;
    }


    this.isLoading = true;
    this.conversationListStore.fetchMoreConversations()
      .then(() => {

        this.isLoading = false;
      })
      .catch((error: CompletionHandler) => {

        this.isLoading = false;
      });
  }

  private deleteSelectedConversations() {
    if (!this.selectedIds || this.selectedIds.length === 0) {
      this.isEditMode = false;
      return;
    }

    const deletePromises = this.selectedIds.map(id => {

      for (let i = 0; i < this.conversationListState.conversationDataSource.totalCount(); i++) {
        const item = this.conversationListState.conversationDataSource.getData(i);
        if (item && item.ID === id) {
          return this.conversationListStore.deleteConversation(item);
        }
      }
      return Promise.resolve();
    });

    Promise.all(deletePromises)
      .then(() => {
        this.isEditMode = false;
        this.selectedIds = [];
        if (this.onDeleteSelected) {
          this.onDeleteSelected();
        }
      })
      .catch((error: CompletionHandler) => {
        console.error(`Failed to delete conversations:${error.message}`);
      });
  }

  private showMoreDialog(conversation: ConversationInfo) {

    this.dialogController = new CustomDialogController({
      builder: ConversationMoreDialog({
        conversation: conversation,
        onAction: (action: DialogAction, conversationId: string) => {
          this.handleConversationAction(action, conversationId, conversation);
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      maskColor: 'rgba(0, 0, 0, 0.6)',
      autoCancel: true
    });


    this.dialogController.open();
  }

  private handleConversationAction(action: DialogAction, conversationId: string, conversation: ConversationInfo) {
    switch (action) {
      case DialogAction.DELETE:
        console.log('Deleting conversation:', conversationId);
        this.deleteConversation(conversation);
        break;

      case DialogAction.CLEAR:
        console.log('Clearing conversation messages:', conversationId);
        this.conversationListStore.clearConversationMessages(conversation)
          .then(() => {
            console.log('Conversation messages cleared successfully');
          })
          .catch((error: CompletionHandler) => {
            console.error('Failed to clear conversation messages:', error.message);
          });
        break;

      case DialogAction.PIN:
        console.log('Toggling conversation pin status:', conversationId);
        this.conversationListStore.pinConversation(conversation, !conversation.isPinned)
          .then(() => {
            console.log('Conversation pin status updated successfully');
          })
          .catch((error: CompletionHandler) => {
            console.error('Failed to update conversation pin status:', error.message);
          });
        break;

      case DialogAction.MUTE:
        console.log('Muting conversation:', conversationId);
        break;

      case DialogAction.HIDE:
        console.log('Hiding conversation:', conversationId);
        this.conversationListStore.markConversationHidden(conversation)
          .then(() => {
            console.log('Conversation hidden successfully');
          })
          .catch((error: CompletionHandler) => {
            console.error('Failed to hide conversation:', error.message);
          });
        break;
    }
  }

  private deleteConversation(conversation: ConversationInfo) {
    this.conversationListStore.deleteConversation(conversation)
      .then(() => {

      })
      .catch((error: CompletionHandler) => {

      });
  }
}