import {
  ChatEngine,
  MessageListState,
  MessageInfo,
  MessageType,
  MessageListType,
  MessageGetOption,
  MessageGetDirection,
  ErrorResult,
  MessageListChangeSource,
  MessageActionState,
  MessageAction,
  MessageActionType,
  MessageStatus
} from 'chatengine';
import { ThemeManager, TimeUtil } from 'basecomponent';
import { MessageItem, isSectionEnd } from '../ui/MessageItem';
import { MessageActionDialog } from '../ui/MessageActionPanel';
import promptAction from '@ohos.promptAction';
import { TextMessageView } from '../cells/TextMessageView';
import { MessageListStyle } from '../config/MessageListConfig';

/**
 * 消息 padding 状态接口
 */
interface MessagePadding {
  top: number;
  bottom: number;
}

/**
 * 消息列表组件
 */
@Component
export struct MessageList {
  // 每条消息间隔时间阈值（5分钟）
  private static readonly TIME_INTERVAL_THRESHOLD: number = 5 * 60 * 1000;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 消息列表状态
  @State messageListState?: MessageListState = undefined;
  @State isLoading: boolean = true;
  @State isLoadingMore: boolean = false;
  // 记录上一次首个可见项索引，用于判断滚动方向
  @State lastFirstIndex: number = -1;
  // 标记是否是用户手动滚动
  @State userScrolling: boolean = false;
  // 消息操作对话框相关
  @State selectedMessage?: MessageInfo = undefined;
  dialogController: CustomDialogController | null = null;
  // 会话ID
  conversationID: string = '';
  // 滚动控制器
  scroller: Scroller = new Scroller();
  // 消息操作回调
  onMessageLongPress?: (message: MessageInfo) => void;
  // 发送消息成功回调
  onMessageSent?: (message: MessageInfo) => void;
  // 消息列表变化来源回调
  onMessageListChangeSourceChanged?: (changeSource: MessageListChangeSource) => void;
  // 新增：消息列表样式（使用配置管理器的默认值）
  @Prop messageListStyle: MessageListStyle = MessageListStyle.Normal;
  // 用于保持加载历史消息时的滚动位置
  private scrollPositionBeforeLoad: number = -1;
  private messageCountBeforeLoad: number = 0;
  // 消息操作状态
  private messageActionState: MessageActionState = new MessageActionState();
  // 新增：存储每条消息的头像显示状态
  @State private messageAvatarStates: Map<string, boolean> = new Map();
  // 新增：存储每条消息的 padding 状态
  @State private messagePaddingStates: Map<string, MessagePadding> = new Map();

  aboutToAppear() {
    console.info('[MessageList] aboutToAppear with conversationID: ' + this.conversationID);
    if (this.conversationID) {
      this.loadMessages();
    } else {
      console.error('[MessageList] No valid conversationID provided');
      this.isLoading = false;
    }
  }

  /**
   * 加载消息
   */
  loadMessages() {
    this.isLoading = true;

    // 使用ChatEngine创建消息列表状态
    this.messageListState =
      ChatEngine.getInstance().createMessageListState(this.conversationID, MessageListType.history);

    // 设置消息列表变化来源回调
    this.messageListState.onMessageListChangeSourceChanged = (changeSource: MessageListChangeSource) => {
      console.info(`[MessageList] messageListChangeSource 变化: ${changeSource}`);

      // 根据变化来源执行相应的滚动操作
      this.handleMessageListChangeSource(changeSource);

      // 如果外部也需要处理变化来源，则回调
      if (this.onMessageListChangeSourceChanged) {
        this.onMessageListChangeSourceChanged(changeSource);
      }
    };

    // 获取消息
    const option: MessageGetOption = {
      direction: MessageGetDirection.Older,
      pageCount: 20
    };

    this.messageListState.fetchMessages(option)
      .then(() => {
        this.isLoading = false;
      })
      .catch((error: ErrorResult) => {
        this.isLoading = false;
        console.error('[MessageList] 加载消息失败', error);
      });
  }

  /**
   * 显示消息操作对话框
   */
  showMessageActionDialog(message: MessageInfo) {
    if (!message) {
      console.error('[MessageList] 没有选中的消息');
      return;
    }

    this.selectedMessage = message;

    this.dialogController = new CustomDialogController({
      builder: MessageActionDialog({
        message: this.selectedMessage,
        messageListState: this.messageListState,
        onMessageDeleted: (msgId: string) => {
          this.handleMessageDeleted(msgId);
        },
        onMessageRecalled: (msgId: string) => {
          this.recallMessage(msgId);
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true
    });

    this.dialogController.open();
  }

  /**
   * 处理消息删除
   * @param msgId 要删除的消息ID
   */
  handleMessageDeleted(msgId: string) {
    if (!this.messageListState) {
      console.error('[MessageList] messageListState是空的');
      promptAction.showToast({
        message: '删除失败: 消息列表状态无效',
        duration: 2000
      });
      return;
    }

    try {
      // 查找要删除的消息
      const index = this.messageListState.messageDataSource.getIndex(msgId);

      if (index !== -1) {
        const message = this.messageListState.messageDataSource.getData(index);
        if (message) {
          // 创建删除操作
          const deleteAction = new MessageAction(MessageActionType.DELETE);

          // 使用MessageActionState执行删除操作
          this.messageActionState.setMessageAction(message, deleteAction)
            .then(() => {
              console.info('[MessageList] 消息删除成功');
              promptAction.showToast({
                message: '消息已删除',
                duration: 2000
              });
              // 这里不需要手动从数据源删除消息，因为MessageActionState会通过通知机制更新UI
            })
            .catch((error: ErrorResult) => {
              console.error(`[MessageList] 删除消息失败: ${error}`);
              promptAction.showToast({
                message: '删除消息失败',
                duration: 2000
              });
            });
        }
      } else {
        console.error(`[MessageList] 未找到ID为 ${msgId} 的消息`);
        promptAction.showToast({
          message: '删除失败: 未找到消息',
          duration: 2000
        });
      }
    } catch (error) {
      console.error(`[MessageList] 删除消息失败: ${error}`);
      promptAction.showToast({
        message: '删除消息失败',
        duration: 2000
      });
    }
  }

  /**
   * 撤回消息
   * @param msgId 要撤回的消息ID
   */
  recallMessage(msgId: string) {
    if (!this.messageListState) {
      console.error('[MessageList] messageListState是空的');
      promptAction.showToast({
        message: '撤回失败: 消息列表状态无效',
        duration: 2000
      });
      return;
    }

    try {
      // 查找要撤回的消息
      const index = this.messageListState.messageDataSource.getIndex(msgId);

      if (index !== -1) {
        const message = this.messageListState.messageDataSource.getData(index);
        if (message) {
          // 检查是否是自己的消息
          if (!message.isSelf) {
            promptAction.showToast({
              message: '只能撤回自己发送的消息',
              duration: 2000
            });
            return;
          }

          // 创建撤回操作
          const recallAction = new MessageAction(MessageActionType.REVOKE);

          // 使用MessageActionState执行撤回操作
          this.messageActionState.setMessageAction(message, recallAction)
            .then(() => {
              console.info('[MessageList] 消息撤回成功');
              promptAction.showToast({
                message: $r('app.string.message_tips_normal_recall'),
                duration: 2000
              });
              // 这里不需要手动更新UI，因为MessageActionState会通过通知机制更新UI
            })
            .catch((error: ErrorResult) => {
              console.error(`[MessageList] 撤回消息失败: ${error}`);
              promptAction.showToast({
                message: '撤回失败',
                duration: 2000
              });
            });
        }
      } else {
        console.error(`[MessageList] 未找到ID为 ${msgId} 的消息`);
        promptAction.showToast({
          message: '撤回失败: 未找到消息',
          duration: 2000
        });
      }
    } catch (error) {
      console.error(`[MessageList] 撤回消息失败: ${error}`);
      promptAction.showToast({
        message: '撤回失败',
        duration: 2000
      });
    }
  }

  /**
   * 加载更多历史消息
   */
  loadMoreHistoryMessages() {
    this.loadMoreMessages(MessageGetDirection.Older);
  }

  /**
   * 加载更多新消息
   */
  loadMoreNewerMessages() {
    // this.loadMoreMessages(MessageGetDirection.Newer);
  }

  /**
   * 消息项生成器
   */
  @Builder
  MessageItemBuilder(message: MessageInfo, index: number) {
    // 根据样式选择不同的构建器
    if (this.messageListStyle === MessageListStyle.RoomStyle) {
      this.RoomStyleMessageItemBuilder(message, index);
    } else {
      this.NormalMessageItemBuilder(message, index);
    }
  }

  /**
   * 普通样式消息项生成器
   */
  @Builder
  NormalMessageItemBuilder(message: MessageInfo, index: number) {
    Column() {
      // 时间标签（如果当前是时间消息）
      if (this.isSystemMessage(message, index)) {
        Row() {
          Text(message?.messageBody?.systemInfo ?? "")
            .fontSize(14)
            .fontColor(this.themeManager.currentTheme.textColorAntiSecondary)// .backgroundColor('#F2F2F2')
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .borderRadius(4)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else if (this.isCustomMessage(message, index)) {
        Row() {
          Text("自定义消息")
            .fontSize(14)
            .fontColor(this.themeManager.currentTheme.textColorAntiSecondary)
            .backgroundColor('#F2F2F2')
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .borderRadius(4)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      } else {
        // 消息气泡
        MessageItem({
          message: message,
          showAvatar: this.getMessageAvatarState(message.ID),
          timeIntervalThreshold: MessageList.TIME_INTERVAL_THRESHOLD,
          onLongPress: (message: MessageInfo) => {
            // 内部处理长按事件，显示操作菜单
            this.showMessageActionDialog(message);

            // 如果外部也需要处理长按事件，则回调
            if (this.onMessageLongPress) {
              this.onMessageLongPress(message);
            }
          },
          messageListState: this.messageListState
        })
      }
    }
    .padding({
      top: this.getMessagePaddingState(message.ID).top,
      bottom: this.getMessagePaddingState(message.ID).bottom
    })
  }

  /**
   * 直播间风格消息项生成器
   */
  @Builder
  RoomStyleMessageItemBuilder(message: MessageInfo, index: number) {
    // 系统消息和自定义消息在直播间样式中简化显示
    if (message.messageType === MessageType.Text) {
      // 直播间风格的普通消息
      Row({ space: 8 }) {
        // 头像（直播间样式默认不显示头像）
        // showAvatar: false

        // 消息内容区域
        Row({ space: 0 }) {
          // 消息内容（包含昵称）
          this.RoomStyleMessageContent(message)
        }
        .alignItems(VerticalAlign.Top)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 12, right: 12 })
      .margin({ bottom: 4 }) // messageSpacing: 4
      .onClick(() => {
        // 直播间样式中点击消息可以触发操作
        if (this.onMessageLongPress) {
          this.onMessageLongPress(message);
        }
      })
    }
  }

  /**
   * 直播间风格消息内容构建器
   */
  @Builder
  RoomStyleMessageContent(message: MessageInfo) {
    TextMessageView(message, this.messageListState, this.messageListStyle)
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

      Text('加载中...')
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
   * 空消息状态构建器
   */
  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($r('sys.media.ohos_app_icon'))
        .width(100)
        .height(100)
        .fillColor(this.themeManager.currentTheme.textColorTertiary)
        .margin({ bottom: 16 })

      Text('暂无消息')
        .fontSize(16)
        .fontColor(this.themeManager.currentTheme.textColorTertiary)

      Text('开始发送消息吧')
        .fontSize(14)
        .fontColor(this.themeManager.currentTheme.textColorPrimary)
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    if (this.isLoading) {
      // 加载中
      this.LoadingStateBuilder()
    } else if (this.messageListState && this.messageListState.messageList.length > 0) {
      // 有消息内容
      if (this.messageListStyle === MessageListStyle.RoomStyle) {
        // 直播间样式布局
        this.RoomStyleListBuilder()
      } else {
        // 普通样式布局
        this.NormalListBuilder()
      }
    } else {
      // 没有消息
      this.EmptyStateBuilder()
    }
  }

  /**
   * 普通样式列表构建器
   */
  @Builder
  NormalListBuilder() {
    if (this.messageListState) {
      Column() {
        // 加载更多历史消息的进度指示器
        if (this.isLoadingMore) {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(this.themeManager.currentTheme.textColorPrimary)

            Text('加载中...')
              .fontSize(12)
              .fontColor(this.themeManager.currentTheme.textColorSecondary)
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 8 })

          // .backgroundColor(this.themeManager.currentTheme.backgroundColorPrimary)
        }

        List({
          space: 0,
          scroller: this.scroller,
          initialIndex: (this.messageListState?.messageList.length ?? 1) - 1
        }) {
          LazyForEach(this.messageListState.messageDataSource, (message: MessageInfo, index: number) => {
            ListItem() {
              this.MessageItemBuilder(message, index)
            }
          }, (message: MessageInfo) => message.getKey())
        }
        .padding({ left: 15, right: 15 })
        .width('100%')
        .layoutWeight(1)
        .onReachStart(() => {
          // 滚动到顶部时，加载更多历史消息
          console.info('[MessageList] Reached start of list');

          // 检查是否可以加载更多历史消息
          if (this.messageListState?.hasMoreOlderMessage &&
            !this.isLoadingMore &&
            this.messageListState?.messageList.length > 0) {

            // 记录加载前的状态，用于加载完成后恢复位置
            this.messageCountBeforeLoad = this.messageListState.messageList.length;
            this.scrollPositionBeforeLoad = this.scroller.currentOffset().yOffset;

            console.info('[MessageList] Loading more history messages from onReachStart', {
              messageCountBefore: this.messageCountBeforeLoad,
              scrollPositionBefore: this.scrollPositionBeforeLoad
            });

            this.loadMoreHistoryMessages();
          } else {
            console.info('[MessageList] Cannot load more messages:', {
              hasMoreOlderMessage: this.messageListState?.hasMoreOlderMessage,
              isLoadingMore: this.isLoadingMore,
              messageCount: this.messageListState?.messageList.length
            });
          }
        })
        .onReachEnd(() => {
          console.info('[MessageList] Reached end of list');
          // 滚动到底部时加载更新的消息
          // 检查是否可以加载更多新消息
          if (this.messageListState?.hasMoreNewerMessage &&
            !this.isLoadingMore &&
            this.messageListState?.messageList.length > 0) {

            // 记录加载前的状态
            this.messageCountBeforeLoad = this.messageListState.messageList.length;
            this.scrollPositionBeforeLoad = this.scroller.currentOffset().yOffset;

            console.info('[MessageList] Loading more newer messages from onReachEnd', {
              messageCountBefore: this.messageCountBeforeLoad,
              scrollPositionBefore: this.scrollPositionBeforeLoad
            });

            this.loadMoreNewerMessages();
          } else {
            console.info('[MessageList] Cannot load more newer messages from onReachEnd:', {
              hasMoreNewerMessage: this.messageListState?.hasMoreNewerMessage,
              isLoadingMore: this.isLoadingMore,
              messageCount: this.messageListState?.messageList.length
            });
          }
        })
        .onScrollIndex((firstIndex: number) => {
          // 记录滚动索引变化，用于调试
          console.info(`[MessageList] Scroll index changed: ${firstIndex}, last: ${this.lastFirstIndex}, userScrolling: ${this.userScrolling}`);

          // 更新上一次索引（保留用于其他可能的用途）
          this.lastFirstIndex = firstIndex;
        })
        .onScrollStart(() => {
          // 滚动开始时，标记为用户手动滚动
          this.userScrolling = true;
          console.info('[MessageList] User scroll started');
        })
        .onScrollStop(() => {
          // 滚动停止后，重置手动滚动标记
          setTimeout(() => {
            this.userScrolling = false;
            console.info('[MessageList] User scroll stopped');
          }, 200);
        })
      }
    }
  }

  /**
   * 直播间样式列表构建器
   */
  @Builder
  RoomStyleListBuilder() {
    if (this.messageListState) {
      Stack() {
        // 背景（直播间样式默认透明背景）
        // backgroundColor: 'transparent'

        // 消息列表
        List({
          space: 0,
          scroller: this.scroller,
          initialIndex: (this.messageListState?.messageList.length ?? 1) - 1
        }) {
          LazyForEach(this.messageListState.messageDataSource, (message: MessageInfo, index: number) => {
            ListItem() {
              this.MessageItemBuilder(message, index)
            }
            .transition({
              type: TransitionType.Insert,
              opacity: 0,
              translate: { x: -50, y: 0 }
            })
            .animation({
              duration: 300,
              curve: Curve.EaseOut
            })
          }, (message: MessageInfo) => message.getKey())
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off) // 直播间样式隐藏滚动条
        .edgeEffect(EdgeEffect.None) // 禁用边缘效果
        .onScrollIndex((firstIndex: number) => {
          // 记录滚动索引变化，用于调试
          console.info(`[MessageList] Scroll index changed: ${firstIndex}, last: ${this.lastFirstIndex}, userScrolling: ${this.userScrolling}`);

          // 更新上一次索引（保留用于其他可能的用途）
          this.lastFirstIndex = firstIndex;
        })
        .onScrollStart(() => {
          this.userScrolling = true;
        })
        .onScrollStop(() => {
          setTimeout(() => {
            this.userScrolling = false;
          }, 200);
        })
      }
      .width('100%')
      .layoutWeight(1)
      .alignContent(Alignment.BottomStart) // 消息从底部开始显示
    }
  }

  // 滚动到底部方法
  scrollToBottom() {
    setTimeout(() => {
      if (this.messageListStyle === MessageListStyle.RoomStyle) {
        // 直播间样式：平滑滚动到底部，模拟新消息流入效果
        this.scroller?.scrollEdge(Edge.End);
      } else {
        // 普通样式：直接滚动到底部
        this.scroller?.scrollEdge(Edge.End);
      }
    }, this.messageListStyle === MessageListStyle.RoomStyle ? 50 : 100);
  }

  /**
   * 获取指定消息的头像显示状态
   */
  getMessageAvatarState(messageId: string): boolean {
    return this.messageAvatarStates.get(messageId) ?? true;
  }

  /**
   * 加载更多消息（通用方法）
   */
  private loadMoreMessages(direction: number) {
    const isOlder = direction === MessageGetDirection.Older;
    const directionName = isOlder ? 'history' : 'newer';

    console.info(`[MessageList] loadMore${isOlder ? 'History' : 'Newer'}Messages called - checking conditions`);

    if (!this.messageListState || this.isLoadingMore) {
      console.info(`[MessageList] Skip loading more ${directionName} messages - already loading`);
      return;
    }

    // 检查是否还有更多消息可加载
    const hasMoreMessages = isOlder ?
    this.messageListState.hasMoreOlderMessage :
    this.messageListState.hasMoreNewerMessage;

    if (!hasMoreMessages) {
      console.info(`[MessageList] No more ${directionName} messages available`);
      return;
    }

    console.info(`[MessageList] Loading more ${directionName} messages...`);
    this.isLoadingMore = true;

    this.messageListState.loadMoreMessages(direction)
      .then(() => {
        console.info(`[MessageList] Successfully loaded more ${directionName} messages, count:`,
          this.messageListState?.messageList.length);
        this.isLoadingMore = false;
      })
      .catch((error: ErrorResult) => {
        // 检查错误类型，使用类型转换替代in操作符
        if (error && typeof error === 'object') {
          const errorObj = error as Record<string, string>;
          const noMoreMessage = isOlder ? 'No more older message' : 'No more newer message';
          if (errorObj.message !== undefined && errorObj.message === noMoreMessage) {
            console.info(`[MessageList] Reached ${isOlder ? 'top' : 'end'} of ${directionName} messages`);
          }
        }

        this.isLoadingMore = false;
        console.error(`[MessageList] 加载更多${directionName === 'history' ? '历史' : '新'}消息失败`, error);
      });
  }

  /**
   * 生成直播间消息显示文本
   */
  private getRoomStyleDisplayText(message: MessageInfo): string {
    let contentText = '';

    // 根据消息类型获取内容文本
    switch (message.messageType) {
      case MessageType.Text:
        contentText = message.messageBody?.text || '';
        break;
      case MessageType.Image:
        contentText = '[图片]';
        break;
      case MessageType.Sound:
        contentText = '[语音]';
        break;
      case MessageType.Video:
        contentText = '[视频]';
        break;
      default:
        contentText = '[其他消息]';
        break;
    }

    // 直播间样式默认显示昵称（showNickname: true）
    if (!message.isSelf) {
      return `${message.sender || '用户'}:${contentText}`;
    }

    return contentText;
  }

  /**
   * 根据消息列表变化来源执行相应的滚动操作
   */
  private handleMessageListChangeSource(changeSource: MessageListChangeSource) {
    console.info(`[MessageList] 消息列表变化来源: ${changeSource}`);

    // 重新计算头像显示状态（所有变化都可能影响头像显示）
    this.calculateAllMessageAvatarStates();
    // 重新计算消息 padding 状态（所有变化都可能影响 padding）
    this.calculateAllMessagePaddingStates();

    // 直播间样式的特殊处理
    if (this.messageListStyle === MessageListStyle.RoomStyle) {
      this.handleRoomStyleMessageListChange(changeSource);
      return;
    }

    // 普通样式的处理
    switch (changeSource) {
      case MessageListChangeSource.fetchMessages:
        // 初始获取消息完成，initialIndex已经设置了正确的初始位置
        console.info('[MessageList] fetchMessages - 初始消息加载完成');
        break;

      case MessageListChangeSource.sendMessage:
        // 发送消息时，滚动到底部，有动画
        console.info('[MessageList] sendMessage - 滚动到底部（有动画）');
        this.scrollToBottom();
        break;

      case MessageListChangeSource.recvMessage:
        // 接收消息时，滚动到底部，有动画
        console.info('[MessageList] recvMessage - 滚动到底部（有动画）');
        this.scrollToBottom();
        break;

      case MessageListChangeSource.loadMoreMessages:
        // 加载更多消息时，恢复滚动位置以保持用户之前查看的消息
        console.info('[MessageList] loadMoreMessages - 恢复滚动位置');
        this.restoreScrollPosition();
        break;

      case MessageListChangeSource.deleteMessage:
        // 删除消息时，不需要滚动
        console.info('[MessageList] deleteMessage - 保持当前位置');
        break;
      case MessageListChangeSource.revokeMessage:
        console.info('[MessageList] revokeMessage - 保持当前位置');
        break;
      case MessageListChangeSource.unknown:
      default:
      // 未知来源，不执行滚动
        console.info('[MessageList] unknown changeSource - 不执行滚动');
        break;
    }
  }

  /**
   * 处理直播间样式的消息列表变化
   */
  private handleRoomStyleMessageListChange(changeSource: MessageListChangeSource) {
    console.info(`[MessageList] 直播间样式处理消息变化: ${changeSource}`);

    switch (changeSource) {
      case MessageListChangeSource.fetchMessages:
        // 直播间初始加载消息，滚动到底部
        console.info('[MessageList] RoomStyle fetchMessages - 滚动到底部');
        this.scrollToBottom();
        break;

      case MessageListChangeSource.sendMessage:
      case MessageListChangeSource.recvMessage:
        // 直播间新消息，始终滚动到底部保持最新消息可见
        console.info('[MessageList] RoomStyle 新消息 - 自动滚动到底部');
        this.scrollToBottom();
        break;

      case MessageListChangeSource.loadMoreMessages:
        // 直播间不支持加载历史消息，保持当前位置
        console.info('[MessageList] RoomStyle loadMoreMessages - 保持当前位置');
        break;

      case MessageListChangeSource.deleteMessage:
        // 直播间删除消息，保持当前位置
        console.info('[MessageList] RoomStyle deleteMessage - 保持当前位置');
        break;

      default:
        console.info('[MessageList] RoomStyle unknown changeSource');
        break;
    }
  }

  private isSystemMessage(message: MessageInfo, index: number): boolean {
    if (message.messageType != MessageType.System) {
      return false;
    }

    if (!message.dateTime) {
      return false;
    }
    return true;
  }

  private isCustomMessage(message: MessageInfo, index: number): boolean {
    if (message.messageType != MessageType.Custom) {
      return false;
    }
    return true;
  }

  /**
   * 计算所有消息的头像显示状态
   * 当消息列表发生变化时调用此方法重新计算
   */
  private calculateAllMessageAvatarStates() {
    if (!this.messageListState?.messageList) {
      return;
    }

    const messageList = this.messageListState.messageList;
    const newAvatarStates = new Map<string, boolean>();

    messageList.forEach((message, index) => {
      // 只有接收方消息才需要显示头像
      if (message.isSelf) {
        newAvatarStates.set(message.ID, false);
      } else {
        // 使用isSectionEnd函数判断是否应该显示头像
        const shouldShow = isSectionEnd(index, message, this.messageListState, MessageList.TIME_INTERVAL_THRESHOLD);
        newAvatarStates.set(message.ID, shouldShow);
      }
    });

    // 更新状态，触发UI重新渲染
    this.messageAvatarStates = newAvatarStates;
    console.info(`[MessageList] Updated avatar states for ${newAvatarStates.size} messages`);
  }

  private restoreScrollPosition() {
    if (this.scrollPositionBeforeLoad === -1 || !this.messageListState) {
      console.info('[MessageList] No scroll position to restore');
      return;
    }

    const currentMessageCount = this.messageListState.messageList.length;
    const newMessagesCount = currentMessageCount - this.messageCountBeforeLoad;

    console.info('[MessageList] Restoring scroll position:', {
      messageCountBefore: this.messageCountBeforeLoad,
      currentMessageCount: currentMessageCount,
      newMessagesCount: newMessagesCount,
      scrollPositionBefore: this.scrollPositionBeforeLoad
    });

    if (newMessagesCount > 0) {
      // 立即滚动到新消息加载后对应的位置，无动画避免闪烁
      // 由于新消息被插入到顶部，我们需要滚动到对应的索引位置
      this.scroller.scrollToIndex(newMessagesCount, false, ScrollAlign.START);

      console.info(`[MessageList] Immediately scrolled to index ${newMessagesCount} to maintain position`);

      // 重置记录的位置
      this.scrollPositionBeforeLoad = -1;
      this.messageCountBeforeLoad = 0;
    }
  }

  private getMessagePaddingState(messageId: string): MessagePadding {
    const defaultPadding: MessagePadding = { top: 8, bottom: 8 };
    return this.messagePaddingStates.get(messageId) ?? defaultPadding;
  }

  /**
   * 计算所有消息的 padding 状态
   * 当消息列表发生变化时调用此方法重新计算，避免实时计算导致的UI更新明显
   */
  private calculateAllMessagePaddingStates() {
    if (!this.messageListState?.messageList) {
      return;
    }

    const messageList = this.messageListState.messageList;
    const newPaddingStates = new Map<string, MessagePadding>();

    messageList.forEach((message, index) => {
      // 计算顶部 padding
      let topPadding = 8; // 默认值
      if (index > 0) {
        const previousMessage = messageList[index - 1];
        if (previousMessage &&
          previousMessage.isSelf === message.isSelf &&
        message.dateTime && previousMessage.dateTime) {
          const timeDiff = message.dateTime.getTime() - previousMessage.dateTime.getTime();
          if (timeDiff <= MessageList.TIME_INTERVAL_THRESHOLD) {
            topPadding = 2; // 紧凑 padding
          }
        }
      }

      // 计算底部 padding
      let bottomPadding = 8; // 默认值
      if (index < messageList.length - 1) {
        const nextMessage = messageList[index + 1];
        if (nextMessage &&
          nextMessage.isSelf === message.isSelf &&
        message.dateTime && nextMessage.dateTime) {
          const timeDiff = nextMessage.dateTime.getTime() - message.dateTime.getTime();
          if (timeDiff <= MessageList.TIME_INTERVAL_THRESHOLD) {
            bottomPadding = 2; // 紧凑 padding
          }
        }
      }

      const paddingState: MessagePadding = { top: topPadding, bottom: bottomPadding };
      newPaddingStates.set(message.ID, paddingState);
    });

    // 更新状态，触发UI重新渲染
    this.messagePaddingStates = newPaddingStates;
    console.info(`[MessageList] Updated padding states for ${newPaddingStates.size} messages`);
  }
}