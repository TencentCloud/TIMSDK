import { ContactListStore, ContactInfo, CompletionHandler, LoginStore, ContactListState, } from 'chatengine';
import { PinyinUtils } from '../../utils/PinyinUtils';
import { AppBuilderConfig, TextUtils, ThemeState } from '../../../basecomponent/Index';
import { router } from '@kit.ArkUI';

interface GroupSection {
  letter: string;
  groups: ContactInfo[];
}

@Component
export struct MyGroupPage {
  private static readonly AVATAR_SIZE: number = 40;
  private static readonly ITEM_HEIGHT: number = 74;
  private static readonly SECTION_HEADER_HEIGHT: number = 32;
  private static readonly INDEX_BAR_WIDTH: number = 20;
  onBack?: () => void;
  // Callback function
  onSelectGroup?: (group: ContactInfo) => void;
  // Theme management
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State private contactListStore: ContactListStore = ContactListStore.createInstance();
  @State private contactListState: ContactListState = this.contactListStore.state;
  @State private isLoading: boolean = true;
  @State private searchKeyword: string = '';
  @State private showSearchResults: boolean = false;
  @State private searchResults: ContactInfo[] = [];
  @State private currentSelectedLetter: string = '';
  private listScroller: Scroller = new Scroller();

  aboutToAppear() {
    console.info('MyGroupPage aboutToAppear');
    this.contactListStore?.registerListener();
    this.loadGroupList();
  }

  aboutToDisappear() {
    this.contactListStore?.unregisterListener();
    console.info('MyGroupPage aboutToDisappear');
  }

  onBackPress(): boolean {
    this.handleBack();
    return true;
  }

  build() {
    Column() {
      // Navigation bar
      this.buildNavigationBar()
      if (!AppBuilderConfig.getInstance().hideSearch) {
        this.buildSearchBar()
      }
      Stack() {
        if (this.isLoading) {
          this.buildLoadingState()
        } else if (this.contactListState.joinedGroupDataSource.totalCount() === 0) {
          this.buildEmptyState()
        } else {
          this.buildGroupContent()
        }
        this.buildAlphabetIndex()
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate) // Figma: #FFFFFF
  }

  // Navigation bar
  @Builder
  buildNavigationBar() {
    Column() {
      Row() {

        Row() {
          Image($rawfile('contactlist/back_arrow.svg'))
            .width(24)
            .height(24)
            .fillColor(this.themeState.colors.textColorLink)

          Text($r('app.string.back_button'))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorLink)
            .margin({ left: 8 })
        }
        .onClick(() => this.handleBack())


        Text($r('app.string.my_group'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.colors.textColorPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)


        Text($r('app.string.done_button'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.colors.textColorLink)
          .opacity(0)
      }
      .width('100%')
      .height(56)
      .padding({ left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // Divider
      Divider()
        .height(0.5)
        .color(this.themeState.colors.strokeColorSecondary) // Figma: #E0E0E0
    }
  }

  @Builder
  buildSearchBar() {
    Row() {
      Row() {
        Image($rawfile('contactlist/search_icon.svg'))
          .width(16)
          .height(16)
          .fillColor(this.themeState.colors.textColorSecondary) // Figma: #DADADA

        TextInput({ placeholder: $r('app.string.search_placeholder') })
          .fontSize(17)
          .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(0, 0, 0, 0.9)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchKeyword = value;
            this.performSearch();
          })
      }
      .width('100%')
      .height(36)
      .backgroundColor(this.themeState.colors.bgColorInput) // Figma: rgba(249, 249, 249, 0.94)
      .borderRadius(10)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width(358)
    .justifyContent(FlexAlign.Center)
    .alignSelf(ItemAlign.Center)
    .margin({ top: 16, bottom: 16 })
  }

  @Builder
  buildGroupContent() {
    if (this.showSearchResults) {
      this.buildSearchResults()
    } else {
      this.buildGroupedList()
    }
  }

  @Builder
  buildGroupedList() {
    List({ scroller: this.listScroller }) {

      ForEach(this.getValidGroupSections(), (section: GroupSection) => {
        this.buildSectionGroup(section.letter, section.groups)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .divider({
      strokeWidth: 1,
      color: this.themeState.colors.strokeColorSecondary,
      startMargin: 87,
      endMargin: 0
    })
  }

  @Builder
  buildSearchResults() {
    if (this.searchResults.length > 0) {
      List({ scroller: this.listScroller }) {
        ForEach(this.searchResults, (group: ContactInfo) => {
          ListItem() {
            this.buildGroupItem(group)
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.colors.bgColorDefault)
    } else {

      Column() {
        Text($r('app.string.no_results_found'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorSecondary)
          .margin({ top: 50 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  buildSectionGroup(letter: string, groups: ContactInfo[]) {
    ListItemGroup() {

      ListItem() {
        Row() {
          Text(`${letter}（${groups.length}）`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(0, 0, 0, 0.9)
            .fontFamily('PingFang SC')
        }
        .width('100%')
        .height(MyGroupPage.SECTION_HEADER_HEIGHT)
        .padding({ left: 16 })
        .alignItems(VerticalAlign.Center)
      }


      ForEach(groups, (group: ContactInfo) => {
        ListItem() {
          this.buildGroupItem(group)
        }
      })
    }
  }

  @Builder
  buildGroupItem(group: ContactInfo) {
    Row() {

      Stack() {
        Circle()
          .width(MyGroupPage.AVATAR_SIZE)
          .height(MyGroupPage.AVATAR_SIZE)
          .fill(this.themeState.colors.textColorLink)

        Text(TextUtils.getAvatarLetter(group.title || ''))
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      .width(MyGroupPage.AVATAR_SIZE)
      .height(MyGroupPage.AVATAR_SIZE)


      Column() {
        Text(group.title || '')
          .fontSize(14)
          .fontColor(this.themeState.colors.textColorPrimary)// Figma: rgba(0, 0, 0, 0.9)
          .fontWeight(FontWeight.Normal)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Start)


        // if (group.friendCount && group.friendCount > 0) {

        //     .fontSize(12)
        //     .fontColor(this.themeState.currentTheme.textColorSecondary)  // Figma: rgba(0, 0, 0, 0.6)
        //     .margin({ top: 4 })
        //     .width('100%')
        //     .textAlign(TextAlign.Start)
        // }
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .margin({ left: 13 })
    }
    .width('100%')
    .height(MyGroupPage.ITEM_HEIGHT)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {

      this.handleSelectGroup(group);
    })
  }

  @Builder
  buildAlphabetIndex() {
    if (!this.showSearchResults && this.contactListState.joinedGroupDataSource.totalCount() > 0) {
      Column() {

        Row() {
          Image($rawfile('contactlist/search_icon.svg'))
            .width(10)
            .height(10)
            .fillColor(this.themeState.colors.textColorLink) // Figma: #0365F9
        }
        .width(20)
        .height(16)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 2 })
        .onClick(() => {

        })


        ForEach(this.getIndexLetters(), (letter: string) => {
          if (letter === this.currentSelectedLetter) {

            Row() {
              Text(letter)
                .fontSize(10)
                .fontColor(this.themeState.colors.textColorButton)// Figma: #FFFFFF
                .fontFamily('PingFang SC')
            }
            .width(20)
            .height(16)
            .backgroundColor(this.themeState.colors.textColorLink) // Figma: #007AFF
            .borderRadius(10)
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 2 })
            .onClick(() => this.scrollToSection(letter))
          } else {
            Text(letter)
              .fontSize(10)
              .fontColor(this.themeState.colors.textColorLink)// Figma: #0365F9
              .fontFamily('PingFang SC')
              .margin({ bottom: 2 })
              .onClick(() => this.scrollToSection(letter))
          }
        })
      }
      .width(MyGroupPage.INDEX_BAR_WIDTH)
      .justifyContent(FlexAlign.Center)
      .position({ x: '100%', y: '50%' })
      .translate({ x: -24, y: '-50%' })
    }
  }

  // Empty state
  @Builder
  buildEmptyState() {
    Column() {
      Text($r('app.string.no_groups_title'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorSecondary)// Figma: #999999
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })

      Text($r('app.string.no_groups_desc'))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorTertiary)// Figma: #CCCCCC
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 32, right: 32 })
  }

  // Loading state
  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
      Text($r('app.string.loading_groups'))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorSecondary)// Figma: #999999
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private handleBack() {
    if (this.onBack) {
      this.onBack();
    }
  }

  private handleSelectGroup(group: ContactInfo): void {
    console.log('[MyGroupPage] handleSelectGroup - Returning with group:', group.title);


    if (this.onSelectGroup) {
      this.onSelectGroup(group);
    }
  }

  private async loadGroupList() {
    try {
      this.isLoading = true;
      await this.contactListStore.fetchGroups();


    } catch (error) {
      const errorResult = error as CompletionHandler;
      console.error('Failed to load group list:', error.errorMessage);
    } finally {
      this.isLoading = false;
    }
  }

  private performSearch() {
    if (this.searchKeyword.trim().length === 0) {
      this.clearSearch();
      return;
    }

    this.searchResults = this.searchGroups(this.searchKeyword);
    this.showSearchResults = true;
  }

  private clearSearch() {
    this.searchResults = [];
    this.showSearchResults = false;
  }

  private searchGroups(keyword: string): ContactInfo[] {
    if (!keyword.trim()) {
      return [];
    }

    const result: ContactInfo[] = [];
    const lowerKeyword = keyword.toLowerCase();

    for (let i = 0; i < this.contactListStore.state.joinedGroupDataSource.totalCount(); i++) {
      const group = this.contactListStore.state.joinedGroupDataSource.getData(i) as ContactInfo;
      if (group) {
        const matchGroupName = group.title?.toLowerCase().includes(lowerKeyword);
        if (matchGroupName) {
          result.push(group);
        }
      }
    }

    return result;
  }

  private scrollToSection(letter: string) {


    if (this.showSearchResults) {

      return;
    }


    let targetIndex = this.calculateSectionIndex(letter);
    if (targetIndex >= 0) {

      this.currentSelectedLetter = letter;


      this.listScroller.scrollToIndex(targetIndex, true, ScrollAlign.START);


      setTimeout(() => {
        this.currentSelectedLetter = '';
      }, 1500);
    }
  }

  private calculateSectionIndex(targetLetter: string): number {
    try {
      let index = 0;
      const validSections = this.getValidGroupSections();

      for (let i = 0; i < validSections.length; i++) {
        const section = validSections[i];
        if (section.letter === targetLetter) {
          return index;
        }
        index += 1;
      }

      console.warn(`未找到分组: ${targetLetter}`);
      return -1;
    } catch (error) {

      return -1;
    }
  }

  private getValidGroupSections(): GroupSection[] {
    const sections: GroupSection[] = [];
    const grouped = this.getGroupedGroups();


    const letters = Object.keys(grouped).sort((a, b) => {
      if (a === '#' && b !== '#') {
        return 1;
      }
      if (a !== '#' && b === '#') {
        return -1;
      }
      return a.localeCompare(b);
    });

    letters.forEach(letter => {
      const groups = grouped[letter];
      if (groups && groups.length > 0) {
        sections.push({ letter, groups });
      }
    });

    return sections;
  }

  private getGroupedGroups(): Record<string, ContactInfo[]> {
    const grouped: Record<string, ContactInfo[]> = {};

    for (let i = 0; i < this.contactListState.joinedGroupDataSource.totalCount(); i++) {
      const group = this.contactListState.joinedGroupDataSource.getData(i) as ContactInfo;
      if (group) {
        const firstLetter = this.getFirstLetter(group.title || group.identifier);
        if (!grouped[firstLetter]) {
          grouped[firstLetter] = [];
        }
        grouped[firstLetter].push(group);
      }
    }

    return grouped;
  }

  private getIndexLetters(): string[] {
    const letters = new Set<string>();

    for (let i = 0; i < this.contactListState.joinedGroupDataSource.totalCount(); i++) {
      const group = this.contactListState.joinedGroupDataSource.getData(i) as ContactInfo;
      if (group) {
        const firstLetter = this.getFirstLetter(group.title || group.identifier);
        letters.add(firstLetter);
      }
    }


    return Array.from(letters).sort((a, b) => {
      if (a === '#' && b !== '#') {
        return 1;
      }
      if (a !== '#' && b === '#') {
        return -1;
      }
      return a.localeCompare(b);
    });
  }

  private getFirstLetter(name: string): string {
    if (!name) {
      return '#';
    }
    return PinyinUtils.getSortLetter(name);
  }
}