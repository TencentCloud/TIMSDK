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
  ContactResultInfo,
  GroupResultInfo,
  ConversationResultInfo,
  MessageInConversationResultInfo,
  SearchType,
  SearchContactsParams,
  SearchGroupsParams,
  SearchMessagesParams,
  CompletionHandler,
  ConversationType,
  MatchFieldType,
  SearchState,
} from 'chatengine';
import { router } from '@kit.ArkUI';
import { SearchContactPage } from './SearchContactPage';
import { SearchGroupPage } from './SearchGroupPage';
import { SearchMessageInAllConversationsPage } from './SearchMessageInAllConversationsPage';
import { SearchMessageInOneConversationPage } from './SearchMessageInOneConversationPage';
import { HighlightText } from '../components/HighlightText';
import { MessageUtils } from '../../messagelist/utils/MessageUtils';

interface SearchCategory {
  type: SearchType;
  title: string;
  results: ResultInfo[];
  hasMore: boolean;
  totalCount: number;
}

@Component
export struct SearchListPage {
  private static readonly AVATAR_SIZE: number = 40;
  private static readonly ITEM_HEIGHT: number = 68;
  private static readonly SEARCH_BAR_HEIGHT: number = 56;
  private static readonly DIVIDER_HEIGHT: number = 0;
  private static readonly MAX_RESULTS_PER_CATEGORY: number = 3;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State searchKeyword: string = '';
  @State showSearchResults: boolean = false;
  @State searchHistory: string[] = [];
  @State searchCategories: SearchCategory[] = [];
  @State showDetailView: boolean = false;
  @State detailViewType: SearchType = SearchType.contact;
  @State showConversationDetail: boolean = false;
  @State selectedConversation: ConversationResultInfo =
    new ConversationResultInfo('', '', '', 0, '', undefined, MatchFieldType.none);
  // Callback function
  onContactSelect?: (contact: ContactResultInfo) => void;
  onGroupSelect?: (group: GroupResultInfo) => void;
  onMessageSelect?: (message: MessageInConversationResultInfo) => void;
  onConversationSelect?: (message: MessageInConversationResultInfo) => void;
  onBack?: () => void;
  onShowMore?: (type: SearchType) => void;
  @State private searchStore: SearchStore = SearchStore.createInstance();
  @State private searchState: SearchState = this.searchStore.state;

  aboutToAppear() {
    console.info('SearchListPage aboutToAppear');

    this.loadSearchHistory();
  }

  aboutToDisappear() {
    console.info('SearchListPage aboutToDisappear');
    // Remove destroy call as it doesn't exist in new API
  }

  build() {
    Column() {

      Column() {
        if (this.showConversationDetail) {
          this.ConversationDetailBuilder()
        } else if (this.showDetailView) {
          this.DetailViewBuilder()
        } else if (this.showSearchResults) {
          this.SearchResultsBuilder()
        } else {
          this.SearchHistoryBuilder()
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  SearchBarBuilder() {
    Row() {

      if (this.showDetailView || this.showConversationDetail) {
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
          if (this.showConversationDetail) {
            this.showConversationDetail = false;
          } else if (this.showDetailView) {
            this.showDetailView = false;
          } else if (this.onBack) {
            this.onBack();
          } else {
            router.back();
          }
        })
      }

      Row() {
        Image($rawfile('search/search_icon.svg'))
          .width(20)
          .height(20)
          .fillColor(this.themeState.colors.textColorSecondary)
          .margin({ right: 2 })

        TextInput({
          placeholder: $r('app.string.search_search_placeholder'),
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


      Text(this.showDetailView || this.showConversationDetail ? $r('app.string.search_back') :
      $r('app.string.search_cancel'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor('#1C66E5')
        .margin({ left: 14, right: 16 })
        .onClick(() => {
          if (this.showConversationDetail) {
            this.showConversationDetail = false;
          } else if (this.showDetailView) {
            this.showDetailView = false;
          } else if (this.onBack) {
            this.onBack();
          } else {
            router.back();
          }
        })
    }
    .width('100%')
    .height(SearchListPage.SEARCH_BAR_HEIGHT)
    .padding({ left: 8, right: 0 })
    .margin({ top: 25 + 26 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  SearchHistoryBuilder() {
    Column() {

      if (!AppBuilderConfig.getInstance().hideSearch) {
        this.SearchBarBuilder()
      }


      if (this.searchHistory.length > 0) {
        List() {
          ForEach(this.searchHistory, (item: string, index: number) => {
            ListItem() {
              Row() {
                Image($rawfile('search/search_icon.svg'))
                  .width(20)
                  .height(20)
                  .fillColor(this.themeState.colors.textColorSecondary)
                  .margin({ right: 12 })

                Text(item)
                  .fontSize(16)
                  .fontColor(this.themeState.colors.textColorPrimary)
                  .layoutWeight(1)

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
                  this.removeSearchHistory(index);
                })
              }
              .width('100%')
              .height(SearchListPage.ITEM_HEIGHT)
              .padding({ left: 16, right: 16 })
              .backgroundColor(this.themeState.colors.bgColorOperate)
            }
            .onClick(() => {
              this.searchKeyword = item;
              this.performSearch();
            })
          }, (item: string) => item)
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Image($rawfile('search/empty_chat_icon.svg'))
            .width(80)
            .height(80)
            .fillColor(this.themeState.colors.textColorSecondary)
            .margin({ bottom: 16 })

          Text($r('app.string.search_suggest_text'))
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorSecondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeState.colors.bgColorOperate)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SearchResultsBuilder() {
    Column() {

      if (!AppBuilderConfig.getInstance().hideSearch) {
        this.SearchBarBuilder()
      }


      if (this.searchCategories.length > 0) {
        List() {
          ForEach(this.searchCategories, (category: SearchCategory, index: number) => {
            if (category.results.length > 0) {

              ListItem() {
                Row() {
                  Text(category.title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.themeState.colors.textColorPrimary)
                    .layoutWeight(1)


                  if (category.hasMore) {
                    Button() {
                      Text('查看更多')
                        .fontSize(14)
                        .fontColor(this.themeState.colors.textColorLink)
                    }
                    .type(ButtonType.Normal)
                    .backgroundColor(Color.Transparent)
                    .onClick(() => {
                      this.showMoreResults(category.type);
                    })
                  }
                }
                .width('100%')
                .height(44)
                .padding({ left: 16, right: 16 })
                .backgroundColor(this.themeState.colors.bgColorOperate)
              }


              ForEach(category.results, (item: ResultInfo, itemIndex: number) => {
                ListItem() {
                  this.SearchResultItemBuilder(item, category.type)
                }
                .onClick(() => {
                  this.handleSearchResultClick(item, category.type);
                })
              }, (item: ResultInfo) => item.getKey())
            }
          }, (category: SearchCategory) => category.type)
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .scrollBar(BarState.Off)
        .divider({
          strokeWidth: SearchListPage.DIVIDER_HEIGHT,
          color: this.themeState.colors.textColorTertiary,
          startMargin: 16 + SearchListPage.AVATAR_SIZE + 12,
          endMargin: 16
        })
      } else {
        Column() {
          Image($rawfile('search/empty_chat_icon.svg'))
            .width(80)
            .height(80)
            .fillColor(this.themeState.colors.textColorSecondary)
            .margin({ bottom: 16 })

          Text($r('app.string.search_no_results'))
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorSecondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeState.colors.bgColorOperate)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SearchResultItemBuilder(item: ResultInfo, type: SearchType) {
    Row() {

      Avatar({
        content: {
          type: AvatarContentType.Image,
          url: this.getDisplayAvatar(item),
          name: this.getDisplayName(item),
        },
        avatarSize: AvatarSize.M,
      }).margin({ right: 12 })

      Column() {
        HighlightText({
          text: this.getDisplayName(item),
          keyword: this.searchKeyword,
          fontSize: 16,
          fontWeight: FontWeight.Medium,
          textColor: this.themeState.colors.textColorPrimary,
          maxLines: 1
        })


        if (this.getDisplaySubtitle(item) && this.getDisplaySubtitle(item).length > 0) {
          HighlightText({
            text: this.getDisplaySubtitle(item),
            keyword: this.searchKeyword,
            fontSize: 14,
            fontWeight: FontWeight.Normal,
            textColor: this.themeState.colors.textColorSecondary,
            maxLines: type === SearchType.conversationsWithMatchedMessages ||
              type === SearchType.messagesInConversation ?
              2 : 1
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
    .height(SearchListPage.ITEM_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  DetailViewBuilder() {
    if (this.detailViewType === SearchType.contact) {
      SearchContactPage({
        initialSearchKeyword: this.searchKeyword,
        onSelectContact: (contact: ContactResultInfo) => {
          if (this.onContactSelect) {
            this.onContactSelect(contact);
          }
        },
        onBack: () => {
          this.showDetailView = false;
        }
      })
    } else if (this.detailViewType === SearchType.group) {
      SearchGroupPage({
        initialSearchKeyword: this.searchKeyword,
        onSelectGroup: (group: GroupResultInfo) => {
          if (this.onGroupSelect) {
            this.onGroupSelect(group);
          }
        },
        onBack: () => {
          this.showDetailView = false;
        }
      })
    } else if (this.detailViewType === SearchType.conversationsWithMatchedMessages) {
      SearchMessageInAllConversationsPage({
        initialSearchKeyword: this.searchKeyword,
        onSelectMessage: (message: ConversationResultInfo) => {

          this.selectedConversation = message;
          this.showConversationDetail = true;
          this.showDetailView = false;
        },
        onBack: () => {
          this.showDetailView = false;
        }
      })
    }
  }

  @Builder
  ConversationDetailBuilder() {
    SearchMessageInOneConversationPage({
      initialSearchKeyword: this.searchKeyword,
      conversationInfo: this.selectedConversation,
      onSelectMessage: (message: MessageInConversationResultInfo) => {
        if (this.onMessageSelect) {
          this.onMessageSelect(message);
        }
      },
      onSelectConversation: (message: MessageInConversationResultInfo) => {
        if (this.onConversationSelect) {
          this.onConversationSelect(message);
        }
      },
      onBack: () => {
        this.showConversationDetail = false;
      }
    })
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

  private async performSearch(): Promise<void> {
    if (this.searchKeyword.trim().length === 0) {
      return;
    }

    try {
      await this.searchStore.searchAll(this.searchKeyword);
      this.loadSearchResults();
      this.showSearchResults = true;
      this.addSearchHistory(this.searchKeyword);
    } catch (error) {

    }
  }

  private loadSearchResults(): void {
    this.searchCategories = [];


    const contactResult = this.searchState.searchResultMap.get(SearchType.contact);
    if (contactResult && contactResult.results.length > 0) {
      this.searchCategories.push({
        type: SearchType.contact,
        title: '联系人',
        results: contactResult.results.slice(0, SearchListPage.MAX_RESULTS_PER_CATEGORY),
        hasMore: contactResult.results.length > SearchListPage.MAX_RESULTS_PER_CATEGORY,
        totalCount: contactResult.results.length
      });
    }


    const groupResult = this.searchState.searchResultMap.get(SearchType.group);
    if (groupResult && groupResult.results.length > 0) {
      this.searchCategories.push({
        type: SearchType.group,
        title: '群组',
        results: groupResult.results.slice(0, SearchListPage.MAX_RESULTS_PER_CATEGORY),
        hasMore: groupResult.results.length > SearchListPage.MAX_RESULTS_PER_CATEGORY,
        totalCount: groupResult.results.length
      });
    }


    const messageResult = this.searchState.searchResultMap.get(SearchType.conversationsWithMatchedMessages);
    if (messageResult && messageResult.results.length > 0) {
      this.searchCategories.push({
        type: SearchType.conversationsWithMatchedMessages,
        title: '聊天记录',
        results: messageResult.results.slice(0, SearchListPage.MAX_RESULTS_PER_CATEGORY),
        hasMore: messageResult.results.length > SearchListPage.MAX_RESULTS_PER_CATEGORY,
        totalCount: messageResult.results.length
      });
    }


  }

  private handleSearchResultClick(item: ResultInfo, type: SearchType): void {


    switch (type) {
      case SearchType.contact:
        if (this.onContactSelect && item instanceof ContactResultInfo) {
          this.onContactSelect(item);
        }
        break;
      case SearchType.group:
        if (this.onGroupSelect && item instanceof GroupResultInfo) {
          this.onGroupSelect(item);
        }
        break;
      case SearchType.conversationsWithMatchedMessages:

        if (item instanceof ConversationResultInfo) {
          this.selectedConversation = item;
          this.showConversationDetail = true;
        }
        break;
      case SearchType.messagesInConversation:

        if (this.onMessageSelect && item instanceof MessageInConversationResultInfo) {
          this.onMessageSelect(item);
        }
        break;
    }
  }

  private showMoreResults(type: SearchType): void {

    this.detailViewType = type;
    this.showDetailView = true;
  }

  private clearSearch(): void {
    this.showSearchResults = false;
    this.searchCategories = [];
    this.searchStore.clearSearchResults();
  }

  private loadSearchHistory(): void {

    // this.searchHistory = ['', '', ''];
  }

  private addSearchHistory(keyword: string): void {
    if (keyword.trim().length === 0) {
      return;
    }


    const index = this.searchHistory.indexOf(keyword);
    if (index > -1) {
      this.searchHistory.splice(index, 1);
    }


    this.searchHistory.unshift(keyword);


    if (this.searchHistory.length > 10) {
      this.searchHistory = this.searchHistory.slice(0, 10);
    }
  }

  private removeSearchHistory(index: number): void {
    this.searchHistory.splice(index, 1);
  }

  private getDisplayName(item: ResultInfo): string {
    if (item instanceof ContactResultInfo) {
      return item.friendRemark || item.nickname || item.userID;
    } else if (item instanceof GroupResultInfo) {
      return item.groupName || item.groupID;
    } else if (item instanceof ConversationResultInfo) {
      return item.conversationName;
    } else if (item instanceof MessageInConversationResultInfo) {
      return item.messageSender;
    }
    return '未知';
  }

  private getDisplayAvatar(item: ResultInfo): string {
    if (item instanceof ContactResultInfo) {
      return item.userAvatar;
    } else if (item instanceof GroupResultInfo) {
      return item.groupAvatar;
    } else if (item instanceof ConversationResultInfo) {
      return item.conversationAvatar;
    } else if (item instanceof MessageInConversationResultInfo) {
      return item.conversationAvatar;
    }
    return '';
  }

  private getDisplaySubtitle(item: ResultInfo): string {
    if (item instanceof ContactResultInfo) {
      return `ID: ${item.userID}`;
    } else if (item instanceof GroupResultInfo) {
      if (item.matchedMemberList.length > 0) {
        const member = item.matchedMemberList[0];
        return member.nameCard || member.friendRemark || member.nickname || member.userID;
      }
      return `ID: ${item.groupID}`;
    } else if (item instanceof ConversationResultInfo) {
      return MessageUtils.getMessageAbstract(item.message).toString() ?? " ";
    } else if (item instanceof MessageInConversationResultInfo) {
      return MessageUtils.getMessageAbstract(item.message).toString() ?? " ";
    }
    return '';
  }
}