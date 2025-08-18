import {
  AppBuilderConfig,
  Avatar,
  AvatarContentType,
  AvatarSize,
  TextUtils,
  ThemeState
} from '../../basecomponent/Index';
import {
  SearchStore,
  ResultInfo,
  ConversationResultInfo,
  MessageInConversationResultInfo,
  SearchType,
  SearchMessagesParams,
  CompletionHandler,
  ConversationType,
  MessageInfo,
  MatchFieldType,
  SearchState,
} from 'chatengine';
import { router } from '@kit.ArkUI';
import { HighlightText } from '../components/HighlightText';

@Component
export struct SearchMessageInOneConversationPage {
  private static readonly AVATAR_SIZE: number = 40;
  private static readonly ITEM_HEIGHT: number = 68;
  private static readonly SEARCH_BAR_HEIGHT: number = 56;
  private static readonly DIVIDER_HEIGHT: number = 0;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State searchKeyword: string = '';
  @Prop initialSearchKeyword?: string;
  @Prop conversationInfo: ConversationResultInfo =
    new ConversationResultInfo('', '', '', 0, '', undefined, MatchFieldType.none);
  @State messageList: MessageInConversationResultInfo[] = [];
  @State isLoading: boolean = false;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = true;
  // Callback function
  onSelectMessage?: (message: MessageInConversationResultInfo) => void;
  onSelectConversation?: (message: MessageInConversationResultInfo) => void;
  onBack?: () => void;
  @State private searchStore: SearchStore = SearchStore.createInstance();
  @State private searchState: SearchState = this.searchStore.state;

  aboutToAppear() {
    console.info('SearchMessageInOneConversationPage aboutToAppear');


    if (this.initialSearchKeyword && this.initialSearchKeyword.trim().length > 0) {
      this.searchKeyword = this.initialSearchKeyword;
      this.performSearch();
    }
  }

  aboutToDisappear() {
    console.info('SearchMessageInOneConversationPage aboutToDisappear');

  }

  build() {
    Column() {

      if (!AppBuilderConfig.getInstance().hideSearch) {
        this.SearchBarBuilder()
      }

      if (this.isLoading) {
        this.LoadingStateBuilder()
      } else if (this.messageList.length > 0) {
        this.MessageListBuilder()
      } else {
        this.EmptyStateBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  SearchBarBuilder() {
    Row() {
      // Back button
      Button() {
        Image($rawfile('search/back_icon.svg'))
          .width(24)
          .height(24)
          .fillColor(this.themeState.colors.textColorPrimary)
      }
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .width(44)
      .height(44)
      .onClick(() => {
        if (this.onBack) {
          this.onBack();
        }
      })


      Row() {
        Image($rawfile('search/search_icon.svg'))
          .width(20)
          .height(20)
          .fillColor(this.themeState.colors.textColorSecondary)
          .margin({ right: 2 })

        TextInput({
          placeholder: $r('app.string.search_search_in_conversation_placeholder'),
          text: this.searchKeyword
        })
          .placeholderColor(this.themeState.colors.textColorTertiary)
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchKeyword = value;
            this.handleSearchInputChange(value);
          })
          .onSubmit(() => {
            this.performSearch();
          })


        if (this.searchKeyword.length > 0) {
          Button() {
            Image($rawfile('contactlist/contact_del.svg'))
              .width(16)
              .height(16)
              .fillColor(this.themeState.colors.textColorSecondary)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .width(32)
          .height(32)
          .onClick(() => {
            this.searchKeyword = '';
            this.clearSearch();
          })
        }
      }
      .backgroundColor(this.themeState.colors.bgColorInput)
      .borderRadius(20)
      .padding({ left: 12, right: 8 })
      .height(40)
      .layoutWeight(1)
      .margin({ left: 8 })


      Text($r('app.string.search_cancel'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor('#1C66E5')
        .margin({ left: 14, right: 16 })
        .onClick(() => {
          if (this.onBack) {
            this.onBack();
          }
        })
    }
    .width('100%')
    .height(SearchMessageInOneConversationPage.SEARCH_BAR_HEIGHT)
    .padding({ left: 8, right: 0 })
    .margin({ top: 25 + 26 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  MessageListBuilder() {
    List() {

      ListItem() {
        this.ConversationHeaderBuilder()
      }


      ForEach(this.messageList, (message: MessageInConversationResultInfo, index: number) => {
        ListItem() {
          this.MessageItemBuilder(message, index)
        }
        .onClick(() => {
          this.handleMessageClick(message);
        })
      }, (message: MessageInConversationResultInfo) => message.message.ID ?? '')


      if (this.isLoadingMore) {
        ListItem() {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(this.themeState.colors.textColorPrimary)

            Text($r('app.string.search_loading_more'))
              .fontSize(12)
              .fontColor(this.themeState.colors.textColorSecondary)
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 16, bottom: 16 })
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .scrollBar(BarState.Off)
    .onReachEnd(() => {
      if (this.hasMore && !this.isLoadingMore && !this.isLoading) {

        this.loadMoreMessages();
      }
    })
  }

  @Builder
  ConversationHeaderBuilder() {
    Row() {

      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: this.conversationInfo.conversationAvatar,
          name: this.conversationInfo.conversationName,
        },
        avatarSize: AvatarSize.M,
      }).margin({ right: 12 })

      Text(this.conversationInfo.conversationName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.colors.textColorPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)


      Image($rawfile('search/right_arrow_icon.svg'))
        .width(8)
        .height(12)
        .fillColor(this.themeState.colors.textColorTertiary)
    }
    .width('100%')
    .height(SearchMessageInOneConversationPage.ITEM_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .onClick(() => {
      this.handleConversationHeaderClick();
    })
  }

  @Builder
  MessageItemBuilder(message: MessageInConversationResultInfo, index: number) {
    Row() {

      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: this.conversationInfo.conversationAvatar,
          name: this.conversationInfo.conversationName,
        },
        avatarSize: AvatarSize.M,
      }).margin({ right: 12 })

      Column() {
        Row() {
          Text(message.messageSender)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorSecondary)
        }.margin({ bottom: 5 })

        Row() {

          HighlightText({
            text: message.message.messageBody?.text || '',
            keyword: this.searchKeyword,
            fontSize: 14,
            fontWeight: FontWeight.Normal,
            textColor: this.themeState.colors.textColorSecondary,
            maxLines: 2
          })
            .layoutWeight(1)


          Text('')
            .fontSize(12)
            .fontColor(this.themeState.colors.textColorSecondary)
            .margin({ left: 8 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(SearchMessageInOneConversationPage.ITEM_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.themeState.colors.textColorLink)

      Text($r('app.string.search_loading'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($rawfile('search/empty_chat_icon.svg'))
        .width(80)
        .height(80)
        .fillColor(this.themeState.colors.textColorSecondary)
        .margin({ bottom: 16 })

      Text($r('app.string.search_no_matched_messages'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  private async performSearch(): Promise<void> {
    if (this.searchKeyword.trim().length === 0) {
      this.clearSearch();
      return;
    }


    if (!this.conversationInfo.conversationID) {
      console.warn('[SearchMessageInOneConversationPage] 缺少会话ID');
      return;
    }


    this.isLoading = true;
    this.messageList = [];
    this.hasMore = true;


    const startTime = Date.now();
    const minLoadingTime = 600;

    try {
      const searchMessagesParams = new SearchMessagesParams(this.searchKeyword, 10);
      const result = await this.searchStore.searchMessagesInOneConversation(
        this.conversationInfo.conversationID,
        searchMessagesParams
      );

      if (result.isSuccess) {

        const messageSearchResult = this.searchState.searchResultMap.get(SearchType.messagesInConversation);
        if (messageSearchResult) {
          this.messageList = messageSearchResult.results as MessageInConversationResultInfo[];
          this.hasMore = messageSearchResult.hasMore;
        }

      } else {
        console.warn(`[SearchMessageInOneConversationPage] 搜索失败: ${result.message}`);
        this.messageList = [];
        this.hasMore = false;
      }
    } catch (error) {

      this.messageList = [];
      this.hasMore = false;
    } finally {

      const elapsedTime = Date.now() - startTime;
      const remainingTime = Math.max(0, minLoadingTime - elapsedTime);

      if (remainingTime > 0) {
        setTimeout(() => {
          this.isLoading = false;

        }, remainingTime);
      } else {
        this.isLoading = false;
      }
    }
  }

  private async loadMoreMessages(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore) {
      return;
    }


    this.isLoadingMore = true;


    const startTime = Date.now();
    const minLoadingTime = 800;

    try {
      const result = await this.searchStore.searchMore(SearchType.messagesInConversation);

      if (result.isSuccess) {

        const messageSearchResult = this.searchState.searchResultMap.get(SearchType.messagesInConversation);
        if (messageSearchResult) {
          this.messageList = messageSearchResult.results as MessageInConversationResultInfo[];
          this.hasMore = messageSearchResult.hasMore;
        }

      } else {
        console.warn(`[SearchMessageInOneConversationPage] 加载更多失败: ${result.message}`);
        this.hasMore = false;
      }
    } catch (error) {

      this.hasMore = false;
    } finally {

      const elapsedTime = Date.now() - startTime;
      const remainingTime = Math.max(0, minLoadingTime - elapsedTime);

      if (remainingTime > 0) {
        setTimeout(() => {
          this.isLoadingMore = false;

        }, remainingTime);
      } else {
        this.isLoadingMore = false;
      }
    }
  }

  private handleMessageClick(message: MessageInConversationResultInfo): void {

    if (this.onSelectMessage) {
      this.onSelectMessage(message);
    }
  }

  private handleConversationHeaderClick(): void {


    const messageInfo = new MessageInfo();
    messageInfo.ID = '';


    const conversationMessage = new MessageInConversationResultInfo(
      this.conversationInfo.conversationID,
      this.conversationInfo.conversationName,
      this.conversationInfo.conversationAvatar,
      messageInfo,
      this.conversationInfo.conversationName,
      '',
      MatchFieldType.none
    );

    if (this.onSelectConversation) {
      this.onSelectConversation(conversationMessage)
    }
  }

  private handleSearchInputChange(value: string): void {
    if (value.trim().length === 0) {
      this.clearSearch();
    } else {

      this.debounceSearch(value);
    }
  }

  private debounceSearch(keyword: string): void {

    if (keyword.trim().length > 0) {
      this.performSearch();
    }
  }

  private clearSearch(): void {
    this.messageList = [];
    this.hasMore = true;
    this.isLoadingMore = false;
    this.searchStore.clearSearchResults();
  }

  private formatTime(timestamp: number): string {
    if (timestamp === 0) {
      return '';
    }

    const date = new Date(timestamp * 1000);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const messageDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    if (messageDate.getTime() === today.getTime()) {

      return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else {

      return `${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}`;
    }
  }
} 