import {
  Avatar,
  AvatarSize,
  AvatarContentType,
  TextUtils,
  ThemeState,
  BadgeControl,
  BadgeType
} from '../../basecomponent/Index';
import { ContactListStore, ContactInfo, CompletionHandler, LoginStore, ContactListState, } from 'chatengine';
import { ImmersiveMode, LevelMode } from '@ohos.promptAction';
import ContactArrayDataSource from '../datasource/ContactArrayDataSource';
import { MyGroupPage } from './manager/MyGroupPage';
import { NewContactsPage } from './manager/NewContactsPage';
import { NewGroupsPage } from './manager/NewGroupsPage';
import { BlackListPage } from './manager/BlackListPage';
import { PinyinUtils } from '../utils/PinyinUtils';

interface ContactSection {
  letter: string;
  contacts: ContactInfo[];
}

@Component
export struct ContactListView {
  private static readonly AVATAR_SIZE: number = 40;
  private static readonly ITEM_HEIGHT: number = 68;
  private static readonly SEARCH_BAR_HEIGHT: number = 36;
  private static readonly SECTION_HEADER_HEIGHT: number = 32;
  private static readonly INDEX_BAR_WIDTH: number = 20;
  private static readonly NOTIFICATION_BADGE_SIZE: number = 20;
  // Theme management
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  // State management
  @State isLoading: boolean = false;
  @Prop @Watch('onSearchKeywordChanged') searchKeyword: string = '';
  @State showSearchResults: boolean = false;
  @State searchResults: ContactInfo[] = [];
  @State currentSelectedLetter: string = '';
  // Callback function
  onRefresh?: () => void;
  onDeleteSelected?: () => void;
  onSelectContact?: (item: ContactInfo) => void;
  onSelectGroup?: (item: ContactInfo) => void;
  onSelectBlackListContact?: (item: ContactInfo) => void;
  onBadgeUpdate?: (badgeCount: number) => void;
  dialogController: CustomDialogController | null = null;
  private newContactsDialogController: CustomDialogController | null = null;
  private newGroupsDialogController: CustomDialogController | null = null;
  private myGroupDialogController: CustomDialogController | null = null;
  private blackListDialogController: CustomDialogController | null = null;
  @State private dialogAnimationOffset: number = 0;
  private listScroller: Scroller = new Scroller();
  @State private contactListStore: ContactListStore = ContactListStore.createInstance();
  @Watch('onContactListChanged')
  @State private contactListState: ContactListState = this.contactListStore.state;
  private dataChangeListener?: DataChangeListener | undefined;
  @State private sectionDataSources: Map<string, ContactArrayDataSource> = new Map();

  aboutToAppear() {
    this.contactListStore?.registerListener();

    this.registerDataSourceListener();

    this.fetchContactList();
    console.info('ContactListPage aboutToAppear');
    this.contactListStore.fetchBlackList();

    this.contactListStore.fetchFriendApplications();
    this.contactListStore.fetchGroupApplications();

    this.updateSectionDataSources();
    this.updateBadgeCount();
  }

  aboutToDisappear() {
    this.contactListStore?.unregisterListener();

    this.unregisterDataSourceListener();

    this.sectionDataSources.clear();
  }

  public updateBadgeCount() {
    const badgeCount = this.contactListState.friendApplicationUnreadCount +
    this.contactListState.groupApplicationUnreadCount;
    if (this.onBadgeUpdate) {
      this.onBadgeUpdate(badgeCount);
    }
    console.info(`Contact badge count updated: ${badgeCount}`);
  }

  onSearchKeywordChanged() {
    this.performSearch();
  }

  @Builder
  ManagementSectionBuilder() {
    Column() {

      Row() {
        Text($r('app.string.new_contacts'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontFamily('PingFang SC')
          .layoutWeight(1)

        Row() {
          if (this.contactListState.friendApplicationUnreadCount > 0) {
            BadgeControl({
              text: this.contactListState.friendApplicationUnreadCount.toString(),
              type: BadgeType.Text
            })
              .margin({ right: 8 })
          }

          Image($rawfile('contactlist/contact_arrow.svg'))
            .width(12)
            .height(12)
            .fillColor(this.themeState.colors.textColorPrimary)
        }
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.themeState.colors.bgColorInput)
      .onClick(() => {
        console.info('Navigate to new contacts page');
        this.handleNewContacts();
      })


      Row() {
        Text($r('app.string.new_group_requests'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontFamily('PingFang SC')
          .layoutWeight(1)

        Row() {
          if (this.contactListState.groupApplicationUnreadCount > 0) {
            BadgeControl({
              text: this.contactListState.groupApplicationUnreadCount.toString(),
              type: BadgeType.Text
            })
              .margin({ right: 8 })
          }

          Image($rawfile('contactlist/contact_arrow.svg'))
            .width(12)
            .height(12)
            .fillColor(this.themeState.colors.textColorPrimary)
        }
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.themeState.colors.bgColorInput)
      .onClick(() => {
        console.info('Navigate to new group requests page');
        this.handleNewGroups();
      })


      Row() {
        Text($r('app.string.my_group'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontFamily('PingFang SC')
          .layoutWeight(1)

        Image($rawfile('contactlist/contact_arrow.svg'))
          .width(12)
          .height(12)
          .fillColor(this.themeState.colors.textColorPrimary)
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.themeState.colors.bgColorInput)
      .onClick(() => {
        console.info('Navigate to my groups');
        this.handleMyGroups();
      })


      Row() {
        Text($r('app.string.the_blacklist'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontFamily('PingFang SC')
          .layoutWeight(1)

        Image($rawfile('contactlist/contact_arrow.svg'))
          .width(12)
          .height(12)
          .fillColor(this.themeState.colors.textColorPrimary)
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.themeState.colors.bgColorInput)
      .onClick(() => {
        console.info('Navigate to blacklist management');
        this.handleBlackList();
      })
    }
    .margin({ left: 0, right: 0 })
  }

  @Builder
  AlphabetIndexBuilder() {
    if (!this.showSearchResults && this.contactListState.contactDataSource.totalCount() > 0) {
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
                .fontColor(this.themeState.colors.textColorButton)
                .fontFamily('PingFang SC')
            }
            .width(20)
            .height(16)
            .backgroundColor(this.themeState.colors.textColorLink)
            .borderRadius(10)
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 2 })
            .onClick(() => this.scrollToSection(letter))
          } else {
            Text(letter)
              .fontSize(10)
              .fontColor(this.themeState.colors.textColorLink)
              .fontFamily('PingFang SC')
              .margin({ bottom: 2 })
              .onClick(() => this.scrollToSection(letter))
          }
        })
      }
      .width(ContactListView.INDEX_BAR_WIDTH)
      .justifyContent(FlexAlign.Center)
      .position({ x: '100%', y: '50%' })
      .translate({ x: -24, y: '-50%' })
    }
  }

  @Builder
  ContactListBuilder() {
    Column() {
      if (this.showSearchResults) {

        this.SearchResultsBuilder()
      } else {
        this.GroupedContactListBuilder()
      }
    }
  }

  @Builder
  GroupedContactListBuilder() {
    List({ scroller: this.listScroller }) {

      ListItem() {
        this.ManagementSectionBuilder()
      }
      .margin({ bottom: 16 })


      ForEach(this.getValidLetterSections(), (section: ContactSection) => {
        this.SectionBuilder(section.letter, section.contacts)
      }, (section: ContactSection) => section.letter)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  SectionBuilder(letter: string, contacts: ContactInfo[]) {
    ListItemGroup() {

      ListItem() {
        Row() {
          Text(letter)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang SC')
        }
        .width('100%')
        .height(ContactListView.SECTION_HEADER_HEIGHT)
        .padding({ left: 16 })
        .backgroundColor(this.themeState.colors.bgColorOperate)
      }


      LazyForEach(this.getSectionDataSource(letter, contacts), (contact: ContactInfo) => {
        ListItem() {
          this.ContactItemBuilder(contact)
        }
      }, (contact: ContactInfo) => contact.getKey())
    }
  }

  @Builder
  ContactItemBuilder(contact: ContactInfo) {
    Column() {
      Row() {
        // Avatar
        Avatar({
          content: {
            type: AvatarContentType.Image,
            url: contact.avatarURL,
            name: this.getContactDisplayName(contact) || '',
          },
          avatarSize: AvatarSize.M,
        })

        Column() {

          Text(this.getContactDisplayName(contact))
            .fontSize(14)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang SC')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 13 })
      }
      .width('100%')
      .height(ContactListView.ITEM_HEIGHT)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .onClick(() => {
      if (this.onSelectContact) {
        this.onSelectContact(contact);
      }

    })
  }

  @Builder
  SearchResultsBuilder() {
    if (this.searchResults.length > 0) {
      List({ scroller: this.listScroller }) {

        ListItem() {
          this.ManagementSectionBuilder()
        }
        .margin({ bottom: 16 })

        ForEach(this.searchResults, (contact: ContactInfo) => {
          ListItem() {
            this.ContactItemBuilder(contact)
          }
        }, (contact: ContactInfo) => contact.ID)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.themeState.colors.bgColorOperate)
    } else {

      List({ scroller: this.listScroller }) {

        ListItem() {
          this.ManagementSectionBuilder()
        }
        .margin({ bottom: 16 })

        ListItem() {
          Column() {
            Text($r('app.string.no_results_found'))
              .fontSize(16)
              .fontColor(this.themeState.colors.textColorSecondary)
              .margin({ top: 50 })
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.themeState.colors.bgColorOperate)
    }
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Text($r('app.string.no_contacts_title'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontFamily('PingFang SC')

      Text($r('app.string.no_contacts_desc'))
        .fontSize(14)
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontFamily('PingFang SC')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(this.themeState.colors.textColorLink)

      Text($r('app.string.loading_contacts'))
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
  NewContactsDialogBuilder() {
    Column() {
      NewContactsPage({
        onBack: () => {

          this.newContactsDialogController?.close();
          this.newContactsDialogController = null;
        }
      })
    }
    .width('100%')
    .height('100%')
    .translate({ x: `${this.dialogAnimationOffset}%` })
    .onAppear(() => {

      animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, () => {
        this.dialogAnimationOffset = 0;
      });
    })
  }

  @Builder
  NewGroupsDialogBuilder() {
    Column() {
      NewGroupsPage({
        onBack: () => {

          this.newGroupsDialogController?.close();
          this.newGroupsDialogController = null;
        }
      })
    }
    .width('100%')
    .height('100%')
    .translate({ x: `${this.dialogAnimationOffset}%` })
    .onAppear(() => {

      animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, () => {
        this.dialogAnimationOffset = 0;
      });
    })
  }

  @Builder
  MyGroupDialogBuilder() {
    Column() {
      MyGroupPage({
        onBack: () => {
          this.myGroupDialogController?.close();
          this.myGroupDialogController = null;
        },
        onSelectGroup: (group: ContactInfo) => {
          console.log("selectedGroup: " + group.title);
          this.myGroupDialogController?.close();
          this.myGroupDialogController = null;

          this.handleSelectedGroup(group);
        }
      })
    }
    .width('100%')
    .height('100%')
    .translate({ x: `${this.dialogAnimationOffset}%` })
    .onAppear(() => {

      animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, () => {
        this.dialogAnimationOffset = 0;
      });
    })
  }

  @Builder
  BlackListDialogBuilder() {
    Column() {
      BlackListPage({
        onBack: () => {
          this.blackListDialogController?.close();
          this.blackListDialogController = null;
        },
        onSelectBlackListContact: (item: ContactInfo) => {
          this.blackListDialogController?.close();
          this.blackListDialogController = null;
          if (this.onSelectBlackListContact) {
            this.onSelectBlackListContact(item);
          }
        },
      })
    }
    .width('100%')
    .height('100%')
    .translate({ x: `${this.dialogAnimationOffset}%` })
    .onAppear(() => {

      animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, () => {
        this.dialogAnimationOffset = 0;
      });
    })
  }

  build() {
    Column() {

      Stack() {

        if (this.isLoading) {
          this.LoadingStateBuilder()
        } else if (this.contactListState.contactDataSource.totalCount() === 0) {
          Column() {
            this.ManagementSectionBuilder()
            this.EmptyStateBuilder()
          }
        } else {
          this.ContactListBuilder()

          this.AlphabetIndexBuilder()
        }


      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  onContactListChanged() {
    this.updateSectionDataSources();
    this.updateBadgeCount();
  }

  private registerDataSourceListener() {
    this.dataChangeListener = {
      // CommonDataSource
      onDataReloaded: () => {
        this.onDataSourceChanged();
      },
      onDataAdd: (index: number) => {
        this.onDataSourceChanged();
      },
      onDataChange: (index: number) => {
        this.onDataSourceChanged();
      },
      onDataDelete: (index: number) => {
        this.onDataSourceChanged();
      },
      onDataMove: (from: number, to: number) => {
        this.onDataSourceChanged();
      },
      onDataAdded: (index: number) => {
        this.onDataSourceChanged();
      },
      onDataChanged: (index: number) => {
        this.onDataSourceChanged();
      },
      onDataDeleted: (index: number) => {
        this.onDataSourceChanged();
      },
      onDataMoved: (from: number, to: number) => {
        this.onDataSourceChanged();
      },
      onDatasetChange: () => {
        this.onDataSourceChanged();
      }
    };
    if (this.dataChangeListener) {
      this.contactListState.contactDataSource.registerDataChangeListener(this.dataChangeListener);
    }
  }

  private unregisterDataSourceListener() {
    if (this.dataChangeListener) {
      this.contactListState.contactDataSource.unregisterDataChangeListener(this.dataChangeListener);
      this.dataChangeListener = undefined;
    }
  }

  private onDataSourceChanged() {
    this.updateSectionDataSources();
  }

  private updateSectionDataSources() {
    const groupedContacts = this.getGroupedContacts();

    const newSectionDataSources = new Map<string, ContactArrayDataSource>();

    for (const entry of Object.entries(groupedContacts)) {
      const letter = entry[0];
      const contacts = entry[1];
      if (contacts.length > 0) {
        let dataSource = this.sectionDataSources.get(letter);
        if (!dataSource) {
          dataSource = new ContactArrayDataSource(contacts);
        } else {
          dataSource.updateData(contacts);
        }
        newSectionDataSources.set(letter, dataSource);
      }
    }

    this.sectionDataSources = newSectionDataSources;
  }

  private getSectionDataSource(letter: string, contacts: ContactInfo[]): ContactArrayDataSource {
    let dataSource = this.sectionDataSources.get(letter);
    if (!dataSource) {
      dataSource = new ContactArrayDataSource(contacts);
    }
    return dataSource;
  }

  private fetchContactList() {

    this.isLoading = true;
    this.contactListStore.fetchFriends()
      .then(() => {
        this.isLoading = false;
      })
      .catch((error: CompletionHandler) => {

        this.isLoading = false;
      });


    setTimeout(() => {
      if (this.isLoading) {
        console.warn('联系人加载超时，停止加载状态');
        this.isLoading = false;
      }
    }, 5000);
  }

  private performSearch() {
    if (this.searchKeyword.trim().length === 0) {
      this.clearSearch();
      return;
    }

    this.searchResults = this.searchContactsLocal(this.searchKeyword);
    this.showSearchResults = true;
  }

  private clearSearch() {
    this.searchResults = [];
    this.showSearchResults = false;
  }

  // Local search for contacts in current list view.
  // This replaces the previous store-level searchContacts.
  private searchContactsLocal(keyword: string): ContactInfo[] {
    const trimmed = keyword ? keyword.trim() : '';
    if (!trimmed) {
      return [];
    }

    const lowerKeyword = trimmed.toLowerCase();
    const results: ContactInfo[] = [];

    for (let i = 0; i < this.contactListState.contactDataSource.totalCount(); i++) {
      const contact = this.contactListState.contactDataSource.getData(i);
      if (!contact) {
        continue;
      }
      const title = (contact.title || '').toLowerCase();
      const identifier = (contact.identifier || '').toLowerCase();
      const match = title.includes(lowerKeyword) || identifier.includes(lowerKeyword);
      if (match) {
        results.push(contact);
      }
    }

    return results;
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


      index += 1;


      const validSections = this.getValidLetterSections();
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

  private getValidLetterSections(): ContactSection[] {
    const sections: ContactSection[] = [];
    const groupedContacts = this.getGroupedContacts();
    const letters = this.getIndexLetters();

    letters.forEach(letter => {
      const contacts = groupedContacts[letter] || [];
      if (contacts.length > 0) {
        sections.push({ letter, contacts });
      }
    });

    return sections;
  }

  private getContactDisplayName(contact: ContactInfo): string {
    return contact.title || contact.identifier || '';
  }

  private getGroupedContacts(): Record<string, ContactInfo[]> {
    const grouped: Record<string, ContactInfo[]> = {};

    for (let i = 0; i < this.contactListState.contactDataSource.totalCount(); i++) {
      const contact = this.contactListState.contactDataSource.getData(i);
      if (contact) {
        const firstLetter = this.getFirstLetter(contact.title || contact.identifier);
        if (!grouped[firstLetter]) {
          grouped[firstLetter] = [];
        }
        grouped[firstLetter].push(contact);
      }
    }

    return grouped;
  }

  private getIndexLetters(): string[] {
    const letters = new Set<string>();

    for (let i = 0; i < this.contactListState.contactDataSource.totalCount(); i++) {
      const contact = this.contactListState.contactDataSource.getData(i);
      if (contact) {
        const firstLetter = this.getFirstLetter(contact.title || contact.identifier);
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

  private handleSelectedGroup(group: ContactInfo): void {
    console.log('[ContactListPage] handleSelectedGroup:', group.title);


    if (this.onSelectGroup) {
      this.onSelectGroup(group);
    }
  }

  private handleNewContacts(): void {


    if (this.newContactsDialogController) {
      this.newContactsDialogController.close();
      this.newContactsDialogController = null;
    }


    this.dialogAnimationOffset = 100;


    this.newContactsDialogController = new CustomDialogController({
      builder: this.NewContactsDialogBuilder,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true,
      keyboardAvoidMode: KeyboardAvoidMode.NONE,
      maskColor: 'rgba(0, 0, 0, 0)',
      cancel: () => {
        this.newContactsDialogController = null;
      },
      levelMode: LevelMode.EMBEDDED,
      immersiveMode: ImmersiveMode.EXTEND,
      openAnimation: {
        duration: 300,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      },
      closeAnimation: {
        duration: 250,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      }
    });


    this.newContactsDialogController.open();
  }

  private handleNewGroups(): void {


    if (this.newGroupsDialogController) {
      this.newGroupsDialogController.close();
      this.newGroupsDialogController = null;
    }


    this.dialogAnimationOffset = 100;


    this.newGroupsDialogController = new CustomDialogController({
      builder: this.NewGroupsDialogBuilder,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true,
      keyboardAvoidMode: KeyboardAvoidMode.NONE,
      maskColor: 'rgba(0, 0, 0, 0)',
      cancel: () => {
        this.newGroupsDialogController = null;
      },
      levelMode: LevelMode.EMBEDDED,
      immersiveMode: ImmersiveMode.EXTEND,
      openAnimation: {
        duration: 300,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      },
      closeAnimation: {
        duration: 250,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      }
    });


    this.newGroupsDialogController.open();
  }

  private handleMyGroups(): void {


    if (this.myGroupDialogController) {
      this.myGroupDialogController.close();
      this.myGroupDialogController = null;
    }


    this.dialogAnimationOffset = 100;


    this.myGroupDialogController = new CustomDialogController({
      builder: this.MyGroupDialogBuilder,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true,
      keyboardAvoidMode: KeyboardAvoidMode.NONE,
      maskColor: 'rgba(0, 0, 0, 0)',
      cancel: () => {
        this.myGroupDialogController = null;
      },
      levelMode: LevelMode.EMBEDDED,
      immersiveMode: ImmersiveMode.EXTEND,
      openAnimation: {
        duration: 300,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      },
      closeAnimation: {
        duration: 250,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      }
    });


    this.myGroupDialogController.open();
  }

  private handleBlackList(): void {


    if (this.blackListDialogController) {
      this.blackListDialogController.close();
      this.blackListDialogController = null;
    }


    this.dialogAnimationOffset = 100;


    this.blackListDialogController = new CustomDialogController({
      builder: this.BlackListDialogBuilder,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true,
      keyboardAvoidMode: KeyboardAvoidMode.NONE,
      maskColor: 'rgba(0, 0, 0, 0)',
      cancel: () => {
        this.blackListDialogController = null;
      },
      levelMode: LevelMode.EMBEDDED,
      immersiveMode: ImmersiveMode.EXTEND,
      openAnimation: {
        duration: 300,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      },
      closeAnimation: {
        duration: 250,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal,
        onFinish: () => {

        }
      }
    });


    this.blackListDialogController.open();
  }
}