import {
  LoginStore,
  MessageListStore,
  MessageInfo,
  MessageType,
  MessageListType,
  MessageFetchOption,
  MessageFetchDirection,
  CompletionHandler,
  MessageListChangeSource,
  MessageActionStore,
  MessageAction,
  MessageActionType,
  MessageStatus,
  MessageDataSource,
  MessageListState,
} from 'chatengine';
import { AppBuilderConfig, ThemeState, TimeUtil } from '../../basecomponent/Index';
import { MessageItem } from '../ui/MessageItem';
import { MessageActionDialog } from '../ui/MessageActionPanel';
import promptAction from '@ohos.promptAction';
import { TextMessageView } from '../cells/TextMessageView';
import { MessageAlignment } from '../../basecomponent/utils/AppBuilderHelper';
import { util } from '@kit.ArkTS';

@Component
export struct MessageListView {
  private static readonly TIME_INTERVAL_THRESHOLD: number = 5 * 60;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State messageListStore?: MessageListStore = undefined;
  @Watch('onMessageListChangeSourceChanged')
  @State messageListState?: MessageListState = undefined;
  @State messageDataSource?: MessageDataSource = undefined;
  @State isLoading: boolean = true;
  @State isLoadingMore: boolean = false;
  @State lastFirstIndex: number = -1;
  @State userScrolling: boolean = false;
  @State selectedMessage?: MessageInfo = undefined;
  dialogController: CustomDialogController | null = null;
  conversationID: string = '';
  @Prop locateMessage?: MessageInfo = undefined;
  @State highlightedMessageID: string = '';
  scroller: Scroller = new Scroller();
  onMessageLongPress?: (message: MessageInfo) => void;
  onMessageSent?: (message: MessageInfo) => void;
  private scrollPositionBeforeLoad: number = -1;
  private messageCountBeforeLoad: number = 0;
  private currentLoadDirection: number = MessageFetchDirection.Older;
  private isLoadingAroundTargetMessage: boolean = false;
  private messageActionState: MessageActionStore = MessageActionStore.createInstance();

  aboutToDisappear(): void {
    this.messageListStore?.unregisterListener();
    if (this.conversationID) {
      this.clearMessageUnreadCount();
    }
  }

  aboutToAppear() {
    console.info(`[MessageList] aboutToAppear with conversationID: ${this.conversationID}, locateMessage: ${this.locateMessage?.ID ||
      'none'}`);
    if (this.conversationID) {
      this.loadMessages();
      this.clearMessageUnreadCount();
    } else {
      console.error('[MessageList] No valid conversationID provided');
      this.isLoading = false;
    }
  }

  loadMessages() {
    this.isLoading = true;
    this.messageListStore = MessageListStore.createInstance(this.conversationID, MessageListType.history);
    this.messageListStore?.registerListener();
    this.messageListState = this.messageListStore.state;
    this.messageDataSource = this.messageListState.messageDataSource;
    if (this.locateMessage) {
      this.loadMessagesAroundTargetMessage();
    } else {
      this.loadHistoryMessages();
    }
  }

  showMessageActionDialog(message: MessageInfo) {
    if (!message) {

      return;
    }

    this.selectedMessage = message;

    this.dialogController = new CustomDialogController({
      builder: MessageActionDialog({
        message: this.selectedMessage,
        messageListStore: this.messageListStore,
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

  clearMessageUnreadCount() {
    this.messageListStore?.clearMessageUnreadCount()
  }

  handleMessageDeleted(msgId: string) {
    if (!this.messageListStore || !this.messageListState) {

      promptAction.showToast({
        message: $r('app.string.messagelist_delete_failed_invalid_state'),
        duration: 2000
      });
      return;
    }

    try {

      const index = this.messageListState.messageDataSource.getIndex(msgId);

      if (index !== -1) {
        const message = this.messageListState.messageDataSource.getData(index);
        if (message) {

          this.messageActionState.deleteMessage(message)
            .then(() => {

              promptAction.showToast({
                message: $r('app.string.messagelist_message_deleted'),
                duration: 2000
              });

            })
            .catch((error: CompletionHandler) => {

              promptAction.showToast({
                message: $r('app.string.messagelist_delete_message_failed'),
                duration: 2000
              });
            });
        }
      } else {

        promptAction.showToast({
          message: $r('app.string.messagelist_delete_failed_not_found'),
          duration: 2000
        });
      }
    } catch (error) {

      promptAction.showToast({
        message: '删除消息失败',
        duration: 2000
      });
    }
  }

  recallMessage(msgId: string) {
    if (!this.messageListState) {
      promptAction.showToast({
        message: $r('app.string.messagelist_recall_failed_invalid_state'),
        duration: 2000
      });
      return;
    }
    try {
      const index = this.messageListState.messageDataSource.getIndex(msgId);
      if (index !== -1) {
        const message = this.messageListState.messageDataSource.getData(index);
        if (message) {
          if (!message.isSelf) {
            promptAction.showToast({
              message: $r('app.string.messagelist_recall_only_own'),
              duration: 2000
            });
            return;
          }
          this.messageActionState.recallMessage(message)
            .then(() => {
              promptAction.showToast({
                message: $r('app.string.message_tips_normal_recall'),
                duration: 2000
              });
            })
            .catch((error: CompletionHandler) => {
              promptAction.showToast({
                message: $r('app.string.messagelist_recall_failed'),
                duration: 2000
              });
            });
        }
      } else {
        promptAction.showToast({
          message: $r('app.string.messagelist_recall_failed_not_found'),
          duration: 2000
        });
      }
    } catch (error) {
      promptAction.showToast({
        message: $r('app.string.messagelist_recall_failed'),
        duration: 2000
      });
    }
  }

  loadMoreHistoryMessages() {
    this.loadMoreMessages(MessageFetchDirection.Older);
  }

  loadMoreNewerMessages() {
    this.loadMoreMessages(MessageFetchDirection.Newer);
  }

  @Builder
  MessageItemBuilder(message: MessageInfo, index: number) {
    this.NormalMessageItemBuilder(message, index);
  }

  @Builder
  NormalMessageItemBuilder(message: MessageInfo, index: number) {
    Column() {
      if (this.getMessageTimeString(index)) {
        Row() {
          Text(this.getMessageTimeString(index))
            .fontSize(12)
            .fontColor(this.themeState.colors.textColorSecondary)
            .padding({
              left: 8,
              right: 8,
              top: 2,
              bottom: 2
            })
            .borderRadius(4)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8, top: 8 })
      }
      MessageItem({
        message: message,
        showAvatar: message.isSelf ? false : !this.checkNextMessageIsAggregation(index),
        isHighlighted: this.highlightedMessageID === message.msgID,
        onLongPress: (message: MessageInfo) => {
          this.showMessageActionDialog(message);
          if (this.onMessageLongPress) {
            this.onMessageLongPress(message);
          }
        },
        messageListStore: this.messageListStore
      })
    }
    .padding({
      top: this.checkPreviousMessageIsAggregation(index) ? 2 : 10,
      bottom: this.checkNextMessageIsAggregation(index) ? 2 : 10
    })
  }

  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(this.themeState.colors.textColorPrimary)

      Text($r('app.string.messagelist_loading'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorTertiary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    if (this.isLoading) {
      // Loading
      this.LoadingStateBuilder()
    } else {

      this.NormalListBuilder()
    }
  }

  @Builder
  NormalListBuilder() {
    if (this.messageListStore && this.messageListState) {
      Column() {

        if (this.isLoadingMore && this.currentLoadDirection === MessageFetchDirection.Older) {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(this.themeState.colors.textColorPrimary)

            Text($r('app.string.messagelist_loading_history'))
              .fontSize(12)
              .fontColor(this.themeState.colors.textColorSecondary)
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 8 })
        }

        List({
          space: 0,
          scroller: this.scroller,
          initialIndex: (this.messageListState?.messageDataSource.messageList.length ?? 1) - 1
        }) {
          LazyForEach(this.messageListState.messageDataSource, (message: MessageInfo, index: number) => {
            ListItem() {
              this.MessageItemBuilder(message, index)
            }
          }, (message: MessageInfo, index: number) => `${message.getKey()}_${index}`)
        }
        .padding({ left: 15, right: 15 })
        .width('100%')
        .layoutWeight(1)
        .onReachStart(() => {

          console.info('[MessageList] Reached start of list');


          if (this.messageListState?.hasMoreOlderMessage &&
            !this.isLoadingMore &&
            this.messageListState?.messageDataSource.messageList.length > 0 &&
            !this.isLoadingAroundTargetMessage) {


            this.messageCountBeforeLoad = this.messageListState.messageDataSource.messageList.length;
            this.scrollPositionBeforeLoad = this.scroller.currentOffset().yOffset;
            this.currentLoadDirection = MessageFetchDirection.Older;

            console.info('[MessageList] Loading more history messages from onReachStart', {
              messageCountBefore: this.messageCountBeforeLoad,
              scrollPositionBefore: this.scrollPositionBeforeLoad
            });

            this.loadMoreHistoryMessages();
          } else {
            console.info('[MessageList] Cannot load more messages:', {
              hasMoreOlderMessage: this.messageListState?.hasMoreOlderMessage,
              isLoadingMore: this.isLoadingMore,
              messageCount: this.messageListState?.messageDataSource.messageList.length
            });
          }
        })
        .onReachEnd(() => {
          console.info('[MessageList] Reached end of list');


          if (this.messageListState?.hasMoreNewerMessage &&
            !this.isLoadingMore &&
            this.messageListState?.messageDataSource.messageList.length > 0 &&
            !this.isLoadingAroundTargetMessage) {

            this.messageCountBeforeLoad = this.messageListState.messageDataSource.messageList.length;
            this.scrollPositionBeforeLoad = this.scroller.currentOffset().yOffset;
            this.currentLoadDirection = MessageFetchDirection.Newer;

            console.info('[MessageList] Loading more newer messages from onReachEnd', {
              messageCountBefore: this.messageCountBeforeLoad,
              scrollPositionBefore: this.scrollPositionBeforeLoad
            });

            this.loadMoreNewerMessages();
          } else {
            console.info('[MessageList] Cannot load more newer messages from onReachEnd:', {
              hasMoreNewerMessage: this.messageListState?.hasMoreNewerMessage,
              isLoadingMore: this.isLoadingMore,
              messageCount: this.messageListState?.messageDataSource.messageList.length
            });
          }
        })
        .onScrollIndex((firstIndex: number) => {

          console.info(`[MessageList] Scroll index changed: ${firstIndex}, last: ${this.lastFirstIndex}, userScrolling: ${this.userScrolling}`);


          this.lastFirstIndex = firstIndex;
        })
        .onScrollStart(() => {

          this.userScrolling = true;
          console.info('[MessageList] User scroll started');
        })
        .onScrollStop(() => {

          setTimeout(() => {
            this.userScrolling = false;
            console.info('[MessageList] User scroll stopped');
          }, 200);
        })


        if (this.isLoadingMore && this.currentLoadDirection === MessageFetchDirection.Newer) {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(this.themeState.colors.textColorPrimary)

            Text($r('app.string.messagelist_loading_new'))
              .fontSize(12)
              .fontColor(this.themeState.colors.textColorSecondary)
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 8 })
        }
      }
    }
  }

  @Builder
  RoomStyleListBuilder() {
    if (this.messageListStore && this.messageListState) {
      Stack() {

        // backgroundColor: 'transparent'


        List({
          space: 0,
          scroller: this.scroller,
          initialIndex: (this.messageListState?.messageDataSource.messageList.length ?? 1) - 1
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
          }, (message: MessageInfo, index: number) => `${message.getKey()}_${index}`)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .onScrollIndex((firstIndex: number) => {

          console.info(`[MessageList] Scroll index changed: ${firstIndex}, last: ${this.lastFirstIndex}, userScrolling: ${this.userScrolling}`);


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
      .alignContent(Alignment.BottomStart)
    }
  }

  scrollToBottom() {
    setTimeout(() => {
      this.scroller?.scrollEdge(Edge.End);
    }, 100);
  }

  locateToMessage(messageID: string) {
    if (!this.messageListState || !messageID) {


      if (this.isLoadingAroundTargetMessage) {
        this.isLoadingAroundTargetMessage = false;
        console.info(`[MessageList] Reset isLoadingAroundTargetMessage = false (invalid params)`);
      }
      return;
    }


    const messageIndex = this.messageListState.messageDataSource.getIndex(messageID);

    if (messageIndex !== -1) {


      this.highlightedMessageID = messageID;


      setTimeout(() => {
        this.scroller.scrollToIndex(messageIndex, true, ScrollAlign.CENTER);


        if (this.isLoadingAroundTargetMessage) {
          this.isLoadingAroundTargetMessage = false;
          console.info(`[MessageList] Reset isLoadingAroundTargetMessage = false after successful locate`);
        }


        setTimeout(() => {
          this.highlightedMessageID = '';
        }, 3000);
      }, 200);
    } else {
      console.warn(`[MessageList] 未找到消息ID: ${messageID}`);

      if (this.isLoadingAroundTargetMessage) {
        this.isLoadingAroundTargetMessage = false;
        console.info(`[MessageList] Reset isLoadingAroundTargetMessage = false (message not found)`);
      }
    }
  }

  private onMessageListChangeSourceChanged() {
    let changeSource = this.messageListState?.messageListChangeSource ?? MessageListChangeSource.unknown;
    this.handleMessageListChangeSource(changeSource);
  }

  private getPreviousMessage(currentIndex: number): MessageInfo | undefined {
    if (!this.messageListState?.messageDataSource.messageList || currentIndex <= 0) {
      return undefined;
    }

    return this.messageDataSource?.messageList[currentIndex - 1];
  }

  private getNextMessage(currentIndex: number): MessageInfo | undefined {
    if (!this.messageDataSource?.messageList ||
      currentIndex >= this.messageDataSource?.messageList.length - 1) {
      return undefined;
    }

    return this.messageDataSource?.messageList[currentIndex + 1];
  }

  private checkPreviousMessageIsAggregation(currentIndex: number): boolean {
    const message = this.messageListState?.messageDataSource.messageList[currentIndex];
    const prevMessage = this.getPreviousMessage(currentIndex);

    if (!message || !prevMessage) {
      return false;
    }


    if (message.isSelf !== prevMessage.isSelf) {
      return false;
    }


    if (prevMessage.status === MessageStatus.revoked) {
      return false;
    }


    if (message.timestamp && prevMessage.timestamp &&
      message.timestamp > 0 && prevMessage.timestamp > 0) {
      const timeInterval = this.getIntervalSeconds(message.timestamp, prevMessage.timestamp);
      if (timeInterval > MessageListView.TIME_INTERVAL_THRESHOLD) {
        return false;
      }
    }

    return true;
  }

  private checkNextMessageIsAggregation(currentIndex: number): boolean {
    const message = this.messageListState?.messageDataSource.messageList[currentIndex];
    const nextMessage = this.getNextMessage(currentIndex);

    if (!message || !nextMessage) {
      return false;
    }


    if (message.isSelf !== nextMessage.isSelf) {
      return false;
    }


    if (nextMessage.status === MessageStatus.revoked) {
      return false;
    }


    if (message.timestamp && nextMessage.timestamp &&
      message.timestamp > 0 && nextMessage.timestamp > 0) {
      const timeInterval = this.getIntervalSeconds(message.timestamp, nextMessage.timestamp);
      if (timeInterval > MessageListView.TIME_INTERVAL_THRESHOLD) {
        return false;
      }
    }

    return true;
  }

  private getMessageTimeString(currentIndex: number): string | null {
    const message = this.messageListState?.messageDataSource.messageList[currentIndex];

    if (!message || !message.timestamp) {
      return null;
    }


    if (!message.timestamp || message.timestamp === 0 || message.timestamp < 0 ||
    isNaN(message.timestamp)) {
      console.warn(`[MessageList] Invalid message dateTime: ${message.timestamp}, messageID: ${message.ID}`);
      return null;
    }


    if (currentIndex === 0) {
      console.info(`[MessageList] First message, showing time for message ${message.ID}`);
      return this.getTimeString(message.timestamp);
    }

    const prevMessage = this.getPreviousMessage(currentIndex);
    if (message && prevMessage && prevMessage.timestamp) {
      const timeInterval = this.getIntervalSeconds(message.timestamp, prevMessage.timestamp);
      console.info(`[MessageList] Message ${currentIndex} time interval: ${timeInterval}s, threshold: ${MessageListView.TIME_INTERVAL_THRESHOLD}s`);
      if (timeInterval > MessageListView.TIME_INTERVAL_THRESHOLD) {
        return this.getTimeString(message.timestamp);
      }
    }

    return null;
  }

  private getTimeString(timestamp?: number): string | null {
    if (!timestamp || timestamp <= 0 || isNaN(timestamp)) {
      return null;
    }
    const date = new Date(timestamp * 1000);
    const now = new Date();


    const nowYear = now.getFullYear();
    const nowMonth = now.getMonth();
    const nowDay = now.getDate();


    const dateYear = date.getFullYear();
    const dateMonth = date.getMonth();
    const dateDay = date.getDate();


    const getWeekOfMonth = (targetDate: Date): number => {
      const firstDayOfMonth = new Date(targetDate.getFullYear(), targetDate.getMonth(), 1);
      let firstDayOfWeek = firstDayOfMonth.getDay(); // 0=Sunday, 6=Saturday


      firstDayOfWeek = (firstDayOfWeek + 1) % 7;


      const dayOfMonth = targetDate.getDate();
      return Math.ceil((dayOfMonth + firstDayOfWeek) / 7);
    };

    const nowWeekOfMonth = getWeekOfMonth(now);
    const dateWeekOfMonth = getWeekOfMonth(date);

    if (nowYear === dateYear) {
      if (nowMonth === dateMonth) {
        if (nowWeekOfMonth === dateWeekOfMonth) {
          if (nowDay === dateDay) {

            return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
          } else {

            const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
            return weekdays[date.getDay()];
          }
        } else {

          return `${(dateMonth + 1).toString().padStart(2, '0')}/${dateDay.toString().padStart(2, '0')}`;
        }
      } else {

        return `${(dateMonth + 1).toString().padStart(2, '0')}/${dateDay.toString().padStart(2, '0')}`;
      }
    } else {

      return `${dateYear}/${(dateMonth + 1).toString().padStart(2, '0')}/${dateDay.toString().padStart(2, '0')}`;
    }
  }

  private getIntervalSeconds(timestamp1?: number, timestamp2?: number): number {
    if (!timestamp1 || !timestamp2) {
      return Number.MAX_SAFE_INTEGER;
    }
    return Math.abs(timestamp2 - timestamp1);
  }

  private loadHistoryMessages() {

    const option: MessageFetchOption = {
      direction: MessageFetchDirection.Older,
      pageCount: 20
    };

    this.messageListStore!.fetchMessages(option)
      .then(() => {
        this.isLoading = false;

        if (this.locateMessage?.ID) {
          this.locateToMessage(this.locateMessage.ID);
        }
      })
      .catch((error: CompletionHandler) => {
        this.isLoading = false;

      });
  }

  private loadMessagesAroundTargetMessage() {
    if (!this.locateMessage) {

      this.loadHistoryMessages();
      return;
    }


    this.isLoadingAroundTargetMessage = true;
    console.info(`[MessageList] Set isLoadingAroundTargetMessage = true`);


    const option: MessageFetchOption = {
      message: this.locateMessage,
      pageCount: 20
    };

    this.messageListStore!.fetchMessages(option)
      .then(() => {

        if (this.locateMessage?.ID) {
          const targetMessageID = this.locateMessage.ID;
          setTimeout(() => {
            this.locateToMessage(targetMessageID);
            this.isLoading = false;
          }, 100);
        } else {
          this.isLoading = false;

          this.isLoadingAroundTargetMessage = false;
          console.info(`[MessageList] Reset isLoadingAroundTargetMessage = false (no locateMessage)`);
        }
      })
      .catch((error: CompletionHandler) => {
        this.isLoading = false;

        this.isLoadingAroundTargetMessage = false;
        console.info(`[MessageList] Reset isLoadingAroundTargetMessage = false (error case)`);


        this.loadHistoryMessages();
      });
  }

  private loadMoreMessages(direction: number) {
    const isOlder = direction === MessageFetchDirection.Older;
    const directionName = isOlder ? 'history' : 'newer';

    console.info(`[MessageList] loadMore${isOlder ? 'History' : 'Newer'}Messages called - checking conditions`);

    if (!this.messageListStore || !this.messageListState || this.isLoadingMore) {
      console.info(`[MessageList] Skip loading more ${directionName} messages - already loading`);
      return;
    }


    const hasMoreMessages = isOlder ?
    this.messageListState.hasMoreOlderMessage :
    this.messageListState.hasMoreNewerMessage;

    if (!hasMoreMessages) {
      console.info(`[MessageList] No more ${directionName} messages available`);
      return;
    }

    console.info(`[MessageList] Loading more ${directionName} messages...`);
    this.isLoadingMore = true;

    this.currentLoadDirection = direction;

    this.messageListStore.fetchMoreMessages(direction)
      .then(() => {
        console.info(`[MessageList] Successfully loaded more ${directionName} messages, count:`,
          this.messageListState?.messageDataSource.messageList.length);
        this.isLoadingMore = false;
      })
      .catch((error: CompletionHandler) => {
        
        this.isLoadingMore = false;

      });
  }

  private getRoomStyleDisplayText(message: MessageInfo): string {
    let contentText = '';


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


    if (!message.isSelf) {
      return `${message.sender || '用户'}:${contentText}`;
    }

    return contentText;
  }

  private handleMessageListChangeSource(changeSource: MessageListChangeSource) {


    switch (changeSource) {
      case MessageListChangeSource.fetchMessages:


        break;

      case MessageListChangeSource.sendMessage:


        this.scrollToBottom();
        break;

      case MessageListChangeSource.recvMessage:


        this.scrollToBottom();
        break;

      case MessageListChangeSource.fetchMoreMessages:


        this.restoreScrollPosition();
        break;

      case MessageListChangeSource.deleteMessage:


        break;
      case MessageListChangeSource.revokeMessage:

        break;
      case MessageListChangeSource.unknown:
      default:


        break;
    }
  }

  private restoreScrollPosition() {

    if (this.isLoadingAroundTargetMessage) {
      console.info('[MessageList] Skip restoreScrollPosition for loadMessagesAroundTargetMessage');
      return;
    }

    console.info(`[MessageList] restoreScrollPosition called, isLoadingAroundTargetMessage: ${this.isLoadingAroundTargetMessage}`);

    if (this.scrollPositionBeforeLoad === -1 || !this.messageListStore) {
      console.info('[MessageList] No scroll position to restore');
      return;
    }

    const currentMessageCount = this.messageListState?.messageDataSource.messageList.length ?? 0;
    const newMessagesCount = currentMessageCount - this.messageCountBeforeLoad;

    console.info('[MessageList] Restoring scroll position:', {
      messageCountBefore: this.messageCountBeforeLoad,
      currentMessageCount: currentMessageCount,
      newMessagesCount: newMessagesCount,
      scrollPositionBefore: this.scrollPositionBeforeLoad,
      loadDirection: this.currentLoadDirection === MessageFetchDirection.Older ? 'older' : 'newer'
    });

    if (newMessagesCount > 0) {
      if (this.currentLoadDirection === MessageFetchDirection.Older) {

        console.info('[MessageList] Restoring position after loading older messages');
        this.scroller.scrollToIndex(newMessagesCount, false, ScrollAlign.START);
        console.info(`[MessageList] Scrolled to index ${newMessagesCount} to maintain position`);
      } else {

        console.info('[MessageList] Restoring position after loading newer messages');

        const targetIndex = this.messageCountBeforeLoad - 1;
        if (targetIndex >= 0 && targetIndex < (this.messageListState?.messageDataSource.messageList.length ?? 0)) {
          this.scroller.scrollToIndex(targetIndex, false, ScrollAlign.END);
          console.info(`[MessageList] Scrolled to index ${targetIndex} to maintain viewing position`);
        }
      }
    }


    this.scrollPositionBeforeLoad = -1;
    this.messageCountBeforeLoad = 0;
  }
}