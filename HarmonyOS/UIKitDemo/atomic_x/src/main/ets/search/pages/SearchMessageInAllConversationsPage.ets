import {
  Avatar,
  AvatarContentType,
  TextUtils,
  ThemeState,
  AvatarSize,
  AppBuilderConfig
} from '../../basecomponent/Index';
import {
  SearchStore,
  ResultInfo,
  ConversationResultInfo,
  SearchType,
  SearchMessagesParams,
  CompletionHandler,
  ConversationType,
  SearchState,
} from 'chatengine';
import { router } from '@kit.ArkUI';
import { HighlightText } from '../components/HighlightText';

@Component
export struct SearchMessageInAllConversationsPage {
  private static readonly AVATAR_SIZE: number = 40;
  private static readonly ITEM_HEIGHT: number = 68;
  private static readonly SEARCH_BAR_HEIGHT: number = 56;
  private static readonly DIVIDER_HEIGHT: number = 0;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State searchKeyword: string = '';
  @Prop initialSearchKeyword?: string;
  @State messageResults: ConversationResultInfo[] = [];
  @State isLoading: boolean = false;
  // Callback function
  onSelectMessage?: (message: ConversationResultInfo) => void;
  onBack?: () => void;
  @State private searchStore: SearchStore = SearchStore.createInstance();
  @State private searchState: SearchState = this.searchStore.state;

  aboutToAppear() {
    console.info('SearchMessageInAllConversationsPage aboutToAppear');

    if (this.initialSearchKeyword && this.initialSearchKeyword.trim().length > 0) {
      this.searchKeyword = this.initialSearchKeyword;
      this.performSearch();
    }
  }

  aboutToDisappear() {
    console.info('SearchMessageInAllConversationsPage aboutToDisappear');

  }

  build() {
    Column() {

      if (!AppBuilderConfig.getInstance().hideSearch) {
        this.SearchBarBuilder()
      }


      if (this.isLoading) {
        this.LoadingStateBuilder()
      } else if (this.messageResults.length > 0) {
        this.MessageListWithTitleBuilder()
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
          placeholder: $r('app.string.search_search_messages_placeholder'),
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
    .height(SearchMessageInAllConversationsPage.SEARCH_BAR_HEIGHT)
    .padding({ left: 8, right: 0 })
    .margin({ top: 25 + 26 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  MessageListWithTitleBuilder() {
    List() {

      ListItem() {
        Row() {
          Text($r('app.string.search_messages_title'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorPrimary)
            .margin({ left: 16, top: 16, bottom: 8 })
        }
        .width('100%')
        .backgroundColor(this.themeState.colors.bgColorOperate)
      }


      ForEach(this.messageResults,
        (item: ConversationResultInfo, index: number) => {
          ListItem() {
            this.MessageItemBuilder(item)
          }
          .onClick(() => {
            this.handleMessageClick(item);
          })
        }, (item: ConversationResultInfo) => item.getKey())
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .scrollBar(BarState.Off)
    .divider({
      strokeWidth: SearchMessageInAllConversationsPage.DIVIDER_HEIGHT,
      color: this.themeState.colors.textColorTertiary,
      startMargin: 16 + SearchMessageInAllConversationsPage.AVATAR_SIZE + 12,
      endMargin: 16
    })
  }

  @Builder
  MessageItemBuilder(item: ConversationResultInfo) {
    Row() {
      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: item.conversationAvatar,
          name: item.conversationName,
        },
        avatarSize: AvatarSize.M,
      }).margin({ right: 12 })

      Column() {
        HighlightText({
          text: item.conversationName,
          keyword: this.searchKeyword,
          fontSize: 16,
          fontWeight: FontWeight.Medium,
          textColor: this.themeState.colors.textColorPrimary,
          maxLines: 1
        })


        if (item.message) {
          HighlightText({
            text: item.message.messageBody?.text,
            keyword: this.searchKeyword,
            fontSize: 14,
            fontWeight: FontWeight.Normal,
            textColor: this.themeState.colors.textColorSecondary,
            maxLines: 2
          })
            .margin({ top: 4 })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)


      Image($rawfile('search/right_arrow_icon.svg'))
        .width(8)
        .height(12)
        .fillColor(this.themeState.colors.textColorTertiary)
    }
    .width('100%')
    .height(SearchMessageInAllConversationsPage.ITEM_HEIGHT)
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

      Text($r('app.string.search_no_messages'))
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
      return;
    }


    this.isLoading = true;

    try {
      const searchMessagesParams = new SearchMessagesParams(this.searchKeyword, 10);
      await this.searchStore.searchMessagesInAllConversations(searchMessagesParams);
      this.loadMessageResults();
    } catch (error) {

    } finally {
      this.isLoading = false;
    }
  }

  private loadMessageResults(): void {
    const messageSearchResult = this.searchState.searchResultMap.get(SearchType.conversationsWithMatchedMessages);
    this.messageResults = (messageSearchResult?.results as ConversationResultInfo[]) || [];

  }

  private handleMessageClick(item: ConversationResultInfo): void {


    if (this.onSelectMessage) {
      this.onSelectMessage(item);
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
    this.messageResults = [];
    this.searchStore.clearSearchResults();
  }
} 