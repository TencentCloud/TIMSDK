import { ThemeManager } from 'basecomponent';
import { ConversationListPage } from 'conversationlist';
import { router } from '@kit.ArkUI';
import { ConversationInfo } from 'chatengine';

/**
 * 会话列表页面
 * 显示用户的所有会话/聊天记录
 */
@Component
export struct ConversationPage {
  // 标题栏高度
  private static readonly HEADER_HEIGHT: number = 56;
  // 大标题高度
  private static readonly LARGE_TITLE_HEIGHT: number = 52;
  // 搜索栏高度
  private static readonly SEARCH_HEIGHT: number = 36;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 顶部搜索词
  @State searchText: string = '';
  // 编辑模式状态
  @State isEditMode: boolean = false;
  // 角标更新回调
  onBadgeUpdate?: (badgeCount: number) => void;

  /**
   * 搜索框构建器
   */
  @Builder
  SearchBuilder() {
    Row() {
      Row() {
        Image($r('app.media.search_icon'))
          .width(16)
          .height(16)
          .fillColor(this.themeManager.currentTheme.textColorLink)
          .margin({ right: 6 })

        Text($r('app.string.search_placeholder'))
          .fontSize(16)
          .fontColor(this.themeManager.currentTheme.textColorTertiary)
      }
      .width('100%')
      .height(ConversationPage.SEARCH_HEIGHT)
      .borderRadius(10)
      .backgroundColor(this.themeManager.currentTheme.bgColorInput)
      .padding({ left: 8, right: 22 })
      .onClick(() => {
        // TODO: 实现搜索功能
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ top: 8, bottom: 8 })
  }

  /**
   * 大标题构建器
   */
  @Builder
  LargeTitleBuilder() {
    Row() {
      Text($r('app.string.chat_title'))
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeManager.currentTheme.textColorPrimary)
        .layoutWeight(1)

      Row() {
        // 编辑按钮
        Image($r('app.media.edit_icon'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            this.isEditMode = true;
          })

        // 添加按钮
        Image($r('app.media.new_chat_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            // TODO: 显示添加会话选项
          })
      }
    }
    .width('100%')
    .height(ConversationPage.LARGE_TITLE_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
  }

  build() {
    Column() {
      // 正常模式下的大标题
      this.LargeTitleBuilder()

      // 搜索框
      this.SearchBuilder()

      // 会话列表组件
      ConversationListPage({
        isEditMode: this.isEditMode,
        onSelectConversation: (item: ConversationInfo) => {
          // 处理会话选择
          console.info(`Navigate to conversation detail with ID: ${item.ID}`);
          // 导航到会话详情页面
          try {
            router.pushUrl({
              url: 'pages/MessagePage',
              params: {
                conversationID: item.ID,
                title: item.title, // 这里可以通过查询会话信息获取实际标题
                avatarUrl: item.avatarUrl
              }
            });
          } catch (error) {
            console.error(`导航到消息页面失败: ${JSON.stringify(error)}`);
          }
        },
        onDeleteSelected: () => {
          // 更新编辑模式状态
          this.isEditMode = false;
        },
        onBadgeUpdate: this.onBadgeUpdate
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
  }
}
