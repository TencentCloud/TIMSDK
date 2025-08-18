import { ProfilePage } from './ProfilePage'
import { ContactPage } from './ContactPage'
import { ImageSizeUtil, ThemeState, TimeUtil, BadgeControl, BadgeType } from 'atomic_x';
import { ConversationPage } from './ConversationPage'
import { LoginStore, ContactListStore, ContactListState } from 'chatengine'

@Observed
class TabItem {
  index: number;
  title: Resource;
  selectedIcon: Resource;
  normalIcon: Resource;
  badgeCount?: number;

  constructor(index: number, title: Resource, selectedIcon: Resource, normalIcon: Resource, badgeCount?: number) {
    this.index = index;
    this.title = title;
    this.selectedIcon = selectedIcon;
    this.normalIcon = normalIcon;
    this.badgeCount = badgeCount;
  }
}

@Entry
@Component
struct MainPage {
  private static readonly TAB_BAR_HEIGHT: number = 56;
  private static readonly ICON_SIZE: number = 24;
  private static readonly INDICATOR_WIDTH: number = 16;
  private static readonly INDICATOR_HEIGHT: number = 3;
  private static readonly TAB_MESSAGE: number = 0;
  private static readonly TAB_CONTACT: number = 1;
  private static readonly TAB_PROFILE: number = 2;
  @State currentIndex: number = 0;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State tabItems: TabItem[] = [];
  private tabsController: TabsController = new TabsController();
  @State private contactListStore: ContactListStore = ContactListStore.createInstance();
  @Watch('onApplicationUnreadCountChanged')
  @State private contactListState: ContactListState = this.contactListStore.state;

  aboutToAppear() {
    this.tabItems = [
      new TabItem(
        MainPage.TAB_MESSAGE,
        $r("app.string.demo_conversation_tab_name"),
        $r('app.media.tab_message_selected'),
        $r('app.media.tab_message_normal'),
        0
      ),
      new TabItem(
        MainPage.TAB_CONTACT,
        $r("app.string.demo_contact_tab_name"),
        $r('app.media.tab_contact_selected'),
        $r('app.media.tab_contact_normal'),
        0
      ),
      new TabItem(
        MainPage.TAB_PROFILE,
        $r("app.string.demo_profile_tab_name"),
        $r('app.media.tab_profile_selected'),
        $r('app.media.tab_profile_normal'),
        0
      )
    ];

    this.contactListStore?.registerListener();
    this.initContactBadge();
  }

  aboutToDisappear() {
    this.contactListStore?.unregisterListener();
  }

  onApplicationUnreadCountChanged() {
    this.updateTabBadge(MainPage.TAB_CONTACT,
      this.contactListState.friendApplicationUnreadCount + this.contactListState.groupApplicationUnreadCount);
  }

  @Builder
  TabIcon(index: number) {
    Stack() {
      Image(this.currentIndex === index ?
      this.getTabItem(index).selectedIcon :
      this.getTabItem(index).normalIcon)
        .width(MainPage.ICON_SIZE)
        .height(MainPage.ICON_SIZE)
        .objectFit(ImageFit.Contain)
        .fillColor(this.currentIndex === index ?
        this.themeState.colors.textColorLink :
        this.themeState.colors.textColorSecondary)


      if (this.getTabItem(index).badgeCount && this.getTabItem(index).badgeCount! > 0) {
        BadgeControl({
          text: this.getTabItem(index).badgeCount! > 99 ? '99+' : this.getTabItem(index).badgeCount!.toString(),
          type: BadgeType.Text
        })
          .position({
            x: MainPage.ICON_SIZE - 8,
            y: -4
          })
      }
    }
    .width(MainPage.ICON_SIZE)
    .height(MainPage.ICON_SIZE)
    .margin({ bottom: 4 })
  }

  @Builder
  TabBuilder(index: number) {
    Column() {

      this.TabIcon(index)

      Text(this.getTabItem(index).title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ?
        this.themeState.colors.textColorLink :
        this.themeState.colors.textColorSecondary)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)


      if (this.currentIndex === index) {
        Row() {
          Row()
            .width(MainPage.INDICATOR_WIDTH)
            .height(MainPage.INDICATOR_HEIGHT)
            .borderRadius(MainPage.INDICATOR_HEIGHT / 2)
            .backgroundColor(this.themeState.colors.textColorLink)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 2 })
      } else {

        Row()
          .width('100%')
          .height(MainPage.INDICATOR_HEIGHT)
          .margin({ top: 2 })
      }
    }
    .width('100%')
    .height(MainPage.TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          ConversationPage({
            onBadgeUpdate: (badgeCount: number) => {
              this.updateTabBadge(MainPage.TAB_MESSAGE, badgeCount);
            }
          })
        }.tabBar(this.TabBuilder(MainPage.TAB_MESSAGE))

        TabContent() {
          ContactPage({
            onBadgeUpdate: (badgeCount: number) => {
              this.updateTabBadge(MainPage.TAB_CONTACT, badgeCount);
            }
          })
        }.tabBar(this.TabBuilder(MainPage.TAB_CONTACT))

        TabContent() {
          ProfilePage()
        }.tabBar(this.TabBuilder(MainPage.TAB_PROFILE))
      }
      .barHeight(MainPage.TAB_BAR_HEIGHT)
      .barMode(BarMode.Fixed)
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(this.themeState.colors.bgColorOperate)
    }
    .width('100%')
    .height('100%')
  }

  updateTabBadge(tabIndex: number, badgeCount: number) {
    const tabItem = this.getTabItem(tabIndex);
    if (tabItem) {
      tabItem.badgeCount = badgeCount;

      this.tabItems = [...this.tabItems];

    }
  }

  private initContactBadge() {
    this.contactListStore.fetchFriendApplications()
      .then(() => {
        this.contactListStore.fetchGroupApplications().then(() => {
          this.updateTabBadge(MainPage.TAB_CONTACT,
            this.contactListState.friendApplicationUnreadCount + this.contactListState.groupApplicationUnreadCount);
        })
      })
      .catch((error: Error) => {

      });
  }

  private getTabItem(index: number): TabItem {
    for (let i = 0; i < this.tabItems.length; i++) {
      if (this.tabItems[i].index === index) {
        return this.tabItems[i];
      }
    }
    return this.tabItems[0];
  }
}