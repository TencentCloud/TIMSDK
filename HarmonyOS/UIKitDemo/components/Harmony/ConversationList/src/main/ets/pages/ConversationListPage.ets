import { TextUtils, ThemeManager } from 'basecomponent';
import {
  ConversationListState,
  ConversationInfo,
  ConversationGetOption,
  ConversationType,
  ConversationAction,
  ConversationActionType,
  ErrorResult,
  ConversationDataSource
} from 'chatengine';
import { ConversationMoreDialog } from './ConversationMoreDialog';
import { router } from '@kit.ArkUI';

/**
 * 会话列表组件
 */
@Component
@Entry
export struct ConversationListPage {
  // 头像尺寸
  private static readonly AVATAR_SIZE: number = 40;
  // 未读消息气泡尺寸
  private static readonly BADGE_SIZE: number = 20;
  // 分隔线高度
  private static readonly DIVIDER_HEIGHT: number = 0.1;
  // 列表项高度
  private static readonly ITEM_HEIGHT: number = 76;
  // 在线状态指示器尺寸
  private static readonly ONLINE_INDICATOR_SIZE: number = 12;
  // 主题色
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 是否加载中
  @State isLoading: boolean = false;
  // 编辑模式状态 - 使用@Link实现双向绑定
  @Link isEditMode: boolean;
  // 选中的会话ID
  @State selectedIds: string[] = [];
  // 回调函数
  onRefresh?: () => void;
  onDeleteSelected?: () => void;
  onBadgeUpdate?: (badgeCount: number) => void;
  dialogController: CustomDialogController | null = null
  // 总未读数状态
  @State totalUnreadCount: number = 0;
  // 聊天引擎会话列表状态
  @State private conversationListState: ConversationListState = new ConversationListState();
  onSelectConversation?: (item: ConversationInfo) => void = (item: ConversationInfo) => {
    // 处理会话选择
    console.info(`Navigate to conversation detail with ID: ${item.ID}`);
  };

  aboutToAppear() {
    // 确保selectedIds已初始化
    this.selectedIds = [];

    // 设置未读数变化回调
    this.conversationListState.setOnUnreadCountChangedCallback(() => {
      this.updateTotalUnreadCount();
    });

    // 获取会话列表
    this.fetchConversationList();

    // 同步初始未读数
    this.syncTotalUnreadCount();

    console.info('ConversationListPage aboutToAppear');
  }

  aboutToDisappear() {
    // 移除会话列表监听器
    this.conversationListState.destroy();
  }

  /**
   * 更新总未读数并通知角标变化
   */
  public updateTotalUnreadCount() {
    const newCount = this.conversationListState.conversationTotalUnreadCount;
    if (newCount !== this.totalUnreadCount) {
      this.totalUnreadCount = newCount;
      // 通知角标更新
      if (this.onBadgeUpdate) {
        this.onBadgeUpdate(this.totalUnreadCount);
      }
      console.info(`更新总未读数: ${this.totalUnreadCount}`);
    }
  }

  /**
   * 操作按钮组构建器
   */
  @Builder
  ActionButtonsBuilder(item: ConversationInfo) {
    Row() {
      // 更多按钮（黑色）
      Button() {
        Column() {
          Image($r('app.media.ic_public_more'))
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
      .backgroundColor(this.themeManager.currentTheme.textColorAntiPrimary)
      .width(70)
      .height(ConversationListPage.ITEM_HEIGHT)
      .onClick(() => {
        console.info(`更多操作: ${item.ID}`);
        this.showMoreDialog(item);
      })

      // 已读按钮（蓝色）
      Button() {
        Column() {
          Image($r('app.media.ic_public_check'))
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
      .backgroundColor(this.themeManager.currentTheme.textColorLink)
      .width(70)
      .height(ConversationListPage.ITEM_HEIGHT)
      .onClick(() => {
        // 根据未读消息数量决定操作
        if ((item.unreadCount ?? 0) > 0) {
          // 标记为已读
          console.info(`标记会话为已读: ${item.ID}`);
          // 实现标记会话为已读
          const action = new ConversationAction(ConversationActionType.MARK_READ);
          this.conversationListState.setConversationAction(item, action)
            .then(() => {
              console.info(`成功标记会话为已读: ${item.ID}`);
            })
            .catch((error: ErrorResult) => {
              console.error(`标记会话为已读失败: ${error.message}`);
            });
        } else {
          // 标记会话为未读
          console.info(`标记会话为未读: ${item.ID}`);
          // 实现标记会话为未读
          const action = new ConversationAction(ConversationActionType.MARK_UNREAD);
          this.conversationListState.setConversationAction(item, action)
            .then(() => {
              console.info(`成功标记会话为未读: ${item.ID}`);
            })
            .catch((error: ErrorResult) => {
              console.error(`标记会话为未读失败: ${error.message}`);
            });
        }
      })
    }
  }

  /**
   * 空会话状态构建器
   */
  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($r('app.media.empty_chat_icon'))
        .width(100)
        .height(100)
        .fillColor(this.themeManager.currentTheme.textColorPrimary)
        .margin({ bottom: 16 })

      Text($r('app.string.no_messages_title'))
        .fontSize(16)
        .fontColor(this.themeManager.currentTheme.textColorTertiary)

      Text($r('app.string.no_messages_desc'))
        .fontSize(14)
        .fontColor(this.themeManager.currentTheme.textColorPrimary)
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 底部编辑操作栏构建器
   */
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
            // 删除所选会话
            this.deleteSelectedConversations();
          })
          .layoutWeight(1)
          .borderRadius(8)
          .height(44)
          .margin({ right: 8 })

        Button($r('app.string.cancel_button'))
          .fontSize(16)
          .fontColor(this.themeManager.currentTheme.textColorPrimary)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
          .onClick(() => {
            // 取消编辑模式
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
      .backgroundColor(this.themeManager.currentTheme.bgColorDefault)
    }
  }

  /**
   * 底部Logo构建器
   */
  @Builder
  BottomLogoBuilder() {
    Row() {
      Column() {
        Image($r('app.media.conversation_bottom_tencent_logo'))
          .width(120)
          .height(20)
          .objectFit(ImageFit.Contain)

        Text('© 2023 Tencent. All Rights Reserved.')
          .fontSize(10)
          .fontColor(this.themeManager.currentTheme.textColorTertiary)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
  }

  /**
   * 加载中状态构建器
   */
  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(this.themeManager.currentTheme.textColorPrimary)

      Text($r('app.string.loading_message'))
        .fontSize(16)
        .fontColor(this.themeManager.currentTheme.textColorTertiary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 会话列表构建器
   */
  @Builder
  ConversationListBuilder() {
    List({ space: 0 }) {
      LazyForEach(this.conversationListState.conversationDataSource, (item: ConversationInfo) => {
        ListItem() {
          Column() {
            // 会话项内容
            Row() {
              // 选择框（编辑模式下显示）
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

              // 头像区域
              Stack() {
                // 有头像URL时显示图片
                if (TextUtils.isEmpty(item.avatarUrl) && TextUtils.isValidUrl(item.avatarUrl)) {
                  Image(item.avatarUrl)
                    .width(ConversationListPage.AVATAR_SIZE)
                    .height(ConversationListPage.AVATAR_SIZE)
                    .borderRadius(ConversationListPage.AVATAR_SIZE / 2)
                    .objectFit(ImageFit.Cover)
                } else {
                  // 没有头像URL时显示首字母
                  Circle()
                    .width(ConversationListPage.AVATAR_SIZE)
                    .height(ConversationListPage.AVATAR_SIZE)
                    .fill(this.themeManager.currentTheme.textColorLink)

                  Text(TextUtils.getAvatarLetter(item.title))
                    .fontSize(18)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                }

                // 在线状态指示器
                if (true) { // 暂无法直接从ChatEngine获取，默认为false
                  Circle()
                    .width(ConversationListPage.ONLINE_INDICATOR_SIZE)
                    .height(ConversationListPage.ONLINE_INDICATOR_SIZE)
                    .fill('#20E070')// 使用Figma中的颜色
                    .stroke(this.themeManager.currentTheme.bgColorOperate)
                    .strokeWidth(2)
                    .position({
                      x: ConversationListPage.AVATAR_SIZE - 12,
                      y: ConversationListPage.AVATAR_SIZE - 12
                    })
                }
              }
              .width(ConversationListPage.AVATAR_SIZE)
              .height(ConversationListPage.AVATAR_SIZE)
              .margin({ right: 8 })

              // 会话内容
              Column() {
                // 会话标题行，包含标题和时间戳
                Row() {
                  Text(item.title || '未命名会话')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.themeManager.currentTheme.textColorPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)

                  // 未读消息气泡(与静音图标互斥)
                  if ((item.unreadCount ?? 0) > 0) {
                    Row() {
                      Text((item.unreadCount ?? 0) > 99 ? '99+' : (item.unreadCount ?? 0).toString())
                        .fontSize(11)
                        .fontColor(Color.White)
                        .fontWeight(FontWeight.Bold)
                        .textAlign(TextAlign.Center)
                    }
                    .backgroundColor('#FF3742') // 使用Figma中的颜色
                    .borderRadius(8) // 使用Figma中的值
                    .width((item.unreadCount ?? 0) > 9 ? undefined : ConversationListPage.BADGE_SIZE)
                    .height(ConversationListPage.BADGE_SIZE)
                    .padding({ left: 5, right: 5 })
                    .justifyContent(FlexAlign.Center)
                    .margin({ left: 4 })
                  }
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)

                // 底部内容：最后一条消息和时间戳
                Row() {
                  // 最后一条消息
                  Text(item.subTitle || '')
                    .fontSize(12)
                    .fontColor('#7A7A7A')// 使用Figma中的颜色
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)

                  // 时间戳 (移到底部行)
                  Text(item.formatTime || '')
                    .fontSize(12)
                    .fontColor('#7A7A7A')
                    .margin({ left: 8 })

                  // 静音图标(只在没有未读消息时显示)
                  if (false) { // 暂无法直接从ChatEngine获取，默认为false
                    Image($r('app.media.muted_icon'))
                      .width(16)
                      .height(16)
                      .fillColor(this.themeManager.currentTheme.textColorSecondary)
                      .margin({ left: 4 })
                  }
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
            .height(ConversationListPage.ITEM_HEIGHT)
            .padding({ left: 16, right: 16 })
            .backgroundColor(item.isPinned ? this.themeManager.currentTheme.bgColorInput :
            this.themeManager.currentTheme.bgColorOperate)
            .onClick(() => {
              if (this.isEditMode) {
                // 选择/取消选择对话
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
                // 进入会话详情
                if (this.onSelectConversation) {
                  this.onSelectConversation(item);
                }
                console.info(`Navigate to conversation detail with ID: ${item.ID}`);
              }
            })

            // 分隔线
            if (this.conversationListState.conversationDataSource.getIndex(item) <
              this.conversationListState.conversationDataSource.totalCount() - 1) {
              Divider()
                .height(ConversationListPage.DIVIDER_HEIGHT)
                .color(this.themeManager.currentTheme.textColorPrimary)
                .margin({ left: 16 + ConversationListPage.AVATAR_SIZE + 8 })
            }
          }
        }
        .swipeAction({ end: this.ActionButtonsBuilder(item) })
      }, (item: ConversationInfo) => item.getKey())

      // 添加底部Logo项到列表中
      ListItem() {
        this.BottomLogoBuilder()
      }
    }
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
    .onReachEnd(() => {
      // 加载更多数据
      this.loadMoreConversationList();
    })
    .width('100%')
    .layoutWeight(1)
  }

  build() {
    Column() {
      // 判断是否有数据
      if (this.conversationListState.conversationDataSource.totalCount() > 0) {
        // 有数据，显示会话列表
        this.ConversationListBuilder()
      } else if (this.isLoading) {
        // 正在加载，显示加载状态
        this.LoadingStateBuilder()
      } else {
        // 空状态
        Column() {
          this.EmptyStateBuilder()

          // 底部Logo (空状态下也显示)
          this.BottomLogoBuilder()
        }
        .layoutWeight(1)
      }

      // 底部编辑操作栏
      this.EditActionBarBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
  }

  /**
   * 同步总未读数
   */
  private syncTotalUnreadCount() {
    // 直接绑定状态，不需要定时器轮询
    // 由于 ConversationListState 现在有 onTotalUnreadMessageCountChanged 监听器
    // conversationTotalUnreadCount 会自动更新
    this.totalUnreadCount = this.conversationListState.conversationTotalUnreadCount;

    console.info(`初始化总未读数: ${this.totalUnreadCount}`);
  }


  /**
   * 获取会话列表
   */
  private fetchConversationList() {
    this.isLoading = true;
    const option = new ConversationGetOption();
    option.count = 100;

    console.info('开始获取会话列表');

    this.conversationListState.fetchConversationList(option)
      .then(() => {
        const count = this.conversationListState.conversationDataSource.totalCount();
        console.info(`获取会话列表成功，数量: ${count}`);
        
        // 如果数量为0，尝试重新获取一次
        if (count === 0) {
          console.info('会话列表为空，尝试重新获取一次...');
          // 延迟1秒后重试
          setTimeout(() => {
            this.retryFetchConversationList();
          }, 1000);
        } else {
          this.isLoading = false;
        }
      })
      .catch((error: ErrorResult) => {
        console.error(`获取会话列表失败: ${error.message}`);
        this.isLoading = false;
      });
  }

  /**
   * 重试获取会话列表
   */
  private retryFetchConversationList() {
    const option = new ConversationGetOption();
    option.count = 100;

    console.info('重试获取会话列表');

    this.conversationListState.fetchConversationList(option)
      .then(() => {
        const count = this.conversationListState.conversationDataSource.totalCount();
        console.info(`重试获取会话列表成功，数量: ${count}`);
        this.isLoading = false;
      })
      .catch((error: ErrorResult) => {
        console.error(`重试获取会话列表失败: ${error.message}`);
        this.isLoading = false;
      });
  }

  /**
   * 加载更多会话
   */
  private loadMoreConversationList() {
    if (this.isLoading || !this.conversationListState.hasMoreConversation) {
      console.info(`不加载更多会话：${this.isLoading ? '正在加载中' : '没有更多数据'}`);
      return;
    }

    console.info('开始加载更多会话');
    this.isLoading = true;
    this.conversationListState.loadMoreConversationList()
      .then(() => {
        console.info(`加载更多会话成功，当前总数: ${this.conversationListState.conversationDataSource.totalCount()}`);
        this.isLoading = false;
      })
      .catch((error: ErrorResult) => {
        console.error(`加载更多会话失败: ${error.message}`);
        this.isLoading = false;
      });
  }

  /**
   * 删除选中的会话
   */
  private deleteSelectedConversations() {
    if (!this.selectedIds || this.selectedIds.length === 0) {
      this.isEditMode = false;
      return;
    }

    const deletePromises = this.selectedIds.map(id => {
      // 从DataSource中获取会话
      for (let i = 0; i < this.conversationListState.conversationDataSource.totalCount(); i++) {
        const item = this.conversationListState.conversationDataSource.getData(i);
        if (item && item.ID === id) {
          const action = new ConversationAction(ConversationActionType.DELETE);
          return this.conversationListState.setConversationAction(item, action);
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
      .catch((error: ErrorResult) => {
        console.error(`Failed to delete conversations:${error.message}`);
      });
  }

  /**
   * 显示更多操作对话框
   */
  private showMoreDialog(conversation: ConversationInfo) {
    // 创建对话框控制器
    this.dialogController = new CustomDialogController({
      builder: ConversationMoreDialog({
        conversation: conversation,
        onDeleteConversation: (id: string) => {
          console.info(`删除会话: ${id}`);
          this.deleteConversation(conversation);
        },
        onClearConversation: (id: string) => {
          console.info(`清空会话: ${id}`);
          // 实现清空会话逻辑
          const action = new ConversationAction(ConversationActionType.CLEAR_MESSAGE);
          this.conversationListState.setConversationAction(conversation, action)
            .then(() => {
              console.info(`成功清空会话消息: ${conversation.ID}`);
            })
            .catch((error: ErrorResult) => {
              console.error(`清空会话消息失败: ${error.message}`);
            });
        },
        onPinConversation: (id: string) => {
          console.info(`置顶/取消置顶 会话: ${id}`);
          // 根据当前会话的置顶状态决定是置顶还是取消置顶
          const actionType = conversation.isPinned ?
          ConversationActionType.UNPIN :
          ConversationActionType.PIN;

          const action = new ConversationAction(actionType);
          this.conversationListState.setConversationAction(conversation, action)
            .then(() => {
              console.info(`成功${conversation.isPinned ? '取消置顶' : '置顶'}会话: ${conversation.ID}`);
            })
            .catch((error: ErrorResult) => {
              console.error(`${conversation.isPinned ? '取消置顶' : '置顶'}会话失败: ${error.message}`);
            });
        },
        onHideConverSation: (id: string) => {
          console.info(`隐藏会话: ${id}`);
          // 实现隐藏会话逻辑
          const action = new ConversationAction(ConversationActionType.MARK_HIDDEN);
          this.conversationListState.setConversationAction(conversation, action)
            .then(() => {
              console.info(`成功隐藏会话: ${conversation.ID}`);
            })
            .catch((error: ErrorResult) => {
              console.error(`隐藏会话失败: ${error.message}`);
            });
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      maskColor: 'rgba(0, 0, 0, 0.6)', // 半透明黑色背景
      autoCancel: true // 点击蒙层自动关闭
    });

    // 显示对话框
    this.dialogController.open();
  }

  /**
   * 删除会话
   */
  private deleteConversation(conversation: ConversationInfo) {
    const action = new ConversationAction(ConversationActionType.DELETE);
    this.conversationListState.setConversationAction(conversation, action)
      .then(() => {
        console.info(`成功删除会话: ${conversation.ID}`);
      })
      .catch((error: ErrorResult) => {
        console.error(`删除会话失败: ${error.message}`);
      });
  }
}