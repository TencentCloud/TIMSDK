// import { ConversationPage } from "tuiconversation"
// import { ContactPage } from 'tuicontact'

// import { Index } from './Index';
import { ProfilePage } from './ProfilePage'
import { ImageSizeUtil, ThemeManager, TimeUtil } from 'basecomponent';
import { ConversationPage } from './ConversationPage'

/**
 * 标签项定义
 */
@Observed
class TabItem {
  index: number;
  title: Resource;
  selectedIcon: Resource;
  normalIcon: Resource;
  badgeCount?: number; // 角标数量

  constructor(index: number, title: Resource, selectedIcon: Resource, normalIcon: Resource, badgeCount?: number) {
    this.index = index;
    this.title = title;
    this.selectedIcon = selectedIcon;
    this.normalIcon = normalIcon;
    this.badgeCount = badgeCount;
  }
}

/**
 * 主页面组件
 * 包含底部标签栏，显示消息、联系人和设置三个标签页
 *
 * 图标文件位于：resources/base/media/目录
 * 使用的SVG图标文件：
 * - tab_message_normal.svg：未选中状态的消息图标
 * - tab_message_selected.svg：选中状态的消息图标（蓝色）
 * - tab_contact_normal.svg：未选中状态的联系人图标
 * - tab_contact_selected.svg：选中状态的联系人图标（蓝色）
 * - tab_profile_normal.svg：未选中状态的设置/我的图标
 * - tab_profile_selected.svg：选中状态的设置/我的图标（蓝色）
 */
@Entry
@Component
struct MainPage {
  // 标签栏高度
  private static readonly TAB_BAR_HEIGHT: number = 56;
  // 标签栏图标尺寸
  private static readonly ICON_SIZE: number = 24;
  // 指示器宽度
  private static readonly INDICATOR_WIDTH: number = 16;
  // 指示器高度
  private static readonly INDICATOR_HEIGHT: number = 3;
  // 角标尺寸
  private static readonly BADGE_SIZE: number = 16;
  private static readonly BADGE_FONT_SIZE: number = 10;
  // 标签索引常量
  private static readonly TAB_MESSAGE: number = 0;
  private static readonly TAB_CONTACT: number = 1;
  private static readonly TAB_PROFILE: number = 2;
  @State currentIndex: number = 0;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 标签配置
  @State tabItems: TabItem[] = [];
  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    // 初始化标签配置
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
        0// 联系人标签无角标
      ),
      new TabItem(
        MainPage.TAB_PROFILE,
        $r("app.string.demo_profile_tab_name"),
        $r('app.media.tab_profile_selected'),
        $r('app.media.tab_profile_normal'),
        0// 设置标签无角标
      )
    ];
  }

  /**
   * 为特定索引创建标签图标
   */
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
        this.themeManager.currentTheme.textColorLink :
        this.themeManager.currentTheme.textColorSecondary)

      // 角标显示
      if (this.getTabItem(index).badgeCount && this.getTabItem(index).badgeCount! > 0) {
        Row() {
          Text(this.getTabItem(index).badgeCount! > 99 ? '99+' : this.getTabItem(index).badgeCount!.toString())
            .fontSize(MainPage.BADGE_FONT_SIZE)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
        }
        .backgroundColor(this.themeManager.currentTheme.textColorError) // 红色角标背景
        .borderRadius(MainPage.BADGE_SIZE / 2.5)
        .width(this.getTabItem(index).badgeCount! > 9 ? undefined : MainPage.BADGE_SIZE)
        .height(MainPage.BADGE_SIZE)
        .padding({ left: 4, right: 4 })
        .justifyContent(FlexAlign.Center)
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

  /**
   * 构建标签栏项
   */
  @Builder
  TabBuilder(index: number) {
    Column() {
      // 使用索引创建对应的图标
      this.TabIcon(index)

      Text(this.getTabItem(index).title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ?
        this.themeManager.currentTheme.textColorLink :
        this.themeManager.currentTheme.textColorSecondary)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)

      // 直接在此处渲染指示器，避免额外的Builder嵌套
      if (this.currentIndex === index) {
        Row() {
          Row()
            .width(MainPage.INDICATOR_WIDTH)
            .height(MainPage.INDICATOR_HEIGHT)
            .borderRadius(MainPage.INDICATOR_HEIGHT / 2)
            .backgroundColor(this.themeManager.currentTheme.textColorLink)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 2 })
      } else {
        // 未选中状态占位，保持布局稳定
        Row()
          .width('100%')
          .height(MainPage.INDICATOR_HEIGHT)
          .margin({ top: 2 })
      }
    }
    .width('100%')
    .height(MainPage.TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
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
          // Index()
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
      .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 更新指定标签的角标数量
   * @param tabIndex 标签索引
   * @param badgeCount 角标数量
   */
  updateTabBadge(tabIndex: number, badgeCount: number) {
    const tabItem = this.getTabItem(tabIndex);
    if (tabItem) {
      tabItem.badgeCount = badgeCount;
      // 触发状态更新
      this.tabItems = [...this.tabItems];
      console.info(`更新标签 ${tabIndex} 角标数量为: ${badgeCount}`);
    }
  }

  /**
   * 根据索引获取标签项
   */
  private getTabItem(index: number): TabItem {
    for (let i = 0; i < this.tabItems.length; i++) {
      if (this.tabItems[i].index === index) {
        return this.tabItems[i];
      }
    }
    return this.tabItems[0];
  }
}