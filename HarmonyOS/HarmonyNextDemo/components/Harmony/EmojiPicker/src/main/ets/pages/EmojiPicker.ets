import { ThemeManager } from 'basecomponent';
import { EmojiDataManager, EmojiItem, EmojiCategory } from '../data/EmojiData';
import dataPreferences from '@ohos.data.preferences';

/**
 * 表情选择器组件
 */
@Component
export struct EmojiPicker {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  @State selectedEmojiType: string = 'normal'; // 'normal' 或 'large'
  @State recentEmojis: EmojiItem[] = [];
  // 最近使用表情显示数量，默认8个
  maxRecentEmojis: number = 8;
  // 表情选择回调
  onEmojiSelected?: (emoji: EmojiItem) => void;
  // 关闭回调
  onClose?: () => void;
  // 删除回调
  onDelete?: () => void;
  // 发送回调
  onSend?: () => void;

  aboutToAppear() {
    // 加载最近使用的表情
    this.loadRecentEmojis();
  }

  build() {
    // 表情选择器容器 - 从底部弹出，类似键盘
    Column() {
      // 顶部表情类型切换栏
      this.buildEmojiTypeSelector()

      // 表情网格区域 - 使用Stack来实现悬浮按钮
      Stack({ alignContent: Alignment.BottomEnd }) {
        // 表情网格（包含分类标题）
        this.buildEmojiGrid()

        // 悬浮按钮栏 - 只在普通表情模式下显示
        if (this.selectedEmojiType === 'normal') {
          this.buildBottomCategoryBar()
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(280)
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
    .borderRadius({ topLeft: 12, topRight: 12 })
    .padding({
      top: 12,
      left: 16,
      right: 16,
      bottom: 8
    })
    .transition({
      type: TransitionType.Insert,
      opacity: 1,
      translate: { y: 280 }
    })
    .transition({
      type: TransitionType.Delete,
      opacity: 0,
      translate: { y: 280 }
    })
  }

  /**
   * 构建表情类型选择器（普通表情/大表情）
   */
  @Builder
  buildEmojiTypeSelector() {
    Row() {
      // 普通表情按钮
      Button() {
        Text(EmojiDataManager.getEmojiTypeDisplayName('normal'))
          .fontSize(12)
          .fontColor(this.selectedEmojiType === 'normal' ?
          this.themeManager.currentTheme.textColorPrimary :
          this.themeManager.currentTheme.textColorSecondary)
      }
      .backgroundColor(this.selectedEmojiType === 'normal' ?
      this.themeManager.currentTheme.bgColorInput : Color.Transparent)
      .borderRadius(4)
      .onClick(() => {
        this.selectedEmojiType = 'normal';
      })

      // 大表情按钮
      Button() {
        Text(EmojiDataManager.getEmojiTypeDisplayName('large'))
          .fontSize(12)
          .fontColor(this.selectedEmojiType === 'large' ?
          this.themeManager.currentTheme.textColorPrimary :
          this.themeManager.currentTheme.textColorSecondary)
      }
      .backgroundColor(this.selectedEmojiType === 'large' ?
      this.themeManager.currentTheme.bgColorInput : Color.Transparent)
      .borderRadius(4)
      .onClick(() => {
        this.selectedEmojiType = 'large';
      })

    }
    .width('100%')
    .height(36)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 8 })
  }

  /**
   * 构建表情网格
   */
  @Builder
  buildEmojiGrid() {
    Scroll() {
      Column() {
        // 只在普通表情模式下显示分类标题
        if (this.selectedEmojiType === 'normal') {
          // 最近使用标题和表情
          if (this.recentEmojis.length > 0) {
            Text(EmojiDataManager.getCategoryDisplayName('recent'))
              .fontSize(14)
              .fontColor(this.themeManager.currentTheme.textColorSecondary)
              .fontWeight(FontWeight.Medium)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 8, bottom: 8 })

            Grid() {
              ForEach(this.recentEmojis, (emoji: EmojiItem) => {
                GridItem() {
                  this.buildEmojiItem(emoji)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(4)
            .width('100%')
            .margin({ bottom: 16 })
          }

          // 所有表情标题和表情
          Text(EmojiDataManager.getCategoryDisplayName('all'))
            .fontSize(14)
            .fontColor(this.themeManager.currentTheme.textColorSecondary)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Grid() {
            ForEach(EmojiDataManager.getAllEmojis(), (emoji: EmojiItem) => {
              GridItem() {
                this.buildEmojiItem(emoji)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .rowsGap(8)
          .columnsGap(4)
          .width('100%')
          .margin({ bottom: 60 }) // 为悬浮按钮留出空间
        } else {
          // 大表情模式下显示所有表情，不显示分类标题
          Grid() {
            ForEach(EmojiDataManager.getAllEmojis(), (emoji: EmojiItem) => {
              GridItem() {
                this.buildEmojiItem(emoji)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .rowsGap(8)
          .columnsGap(4)
          .width('100%')
        }
      }
      .width('100%')
      .padding({ top: 4, bottom: 4 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
  }

  /**
   * 构建单个表情项
   */
  @Builder
  buildEmojiItem(emoji: EmojiItem) {
    Column() {
      Image(EmojiDataManager.getEmojiImageResource(emoji.imageFile))
        .width(this.selectedEmojiType === 'large' ? 32 : 32)
        .height(this.selectedEmojiType === 'large' ? 32 : 32)
        .objectFit(ImageFit.Contain)
    }
    .width(40)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .borderRadius(6)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      this.selectEmoji(emoji);
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        // 添加按下效果
        this.addPressEffect();
      }
    })
    .stateStyles({
      pressed: {
        .backgroundColor(this.themeManager.currentTheme.bgColorInput)
      }
    })
  }

  /**
   * 构建底部悬浮按钮栏
   */
  @Builder
  buildBottomCategoryBar() {
    // 右侧悬浮按钮组 - 只占据按钮所需的空间
    Row() {
      // 删除按钮
      Button() {
        Image($r('sys.media.ohos_ic_back'))
          .width(20)
          .height(20)
          .fillColor(this.themeManager.currentTheme.textColorSecondary)
      }
      .width(44)
      .height(44)
      .backgroundColor(this.themeManager.currentTheme.bgColorInput)
      .borderRadius(22)
      .margin({ right: 8 })
      .onClick(() => {
        console.info('[EmojiPicker] 点击删除按钮');
        if (this.onDelete) {
          this.onDelete();
        }
      })

      // 发送按钮
      Button('发送')
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .borderRadius(22)
        .width(60)
        .height(44)
        .onClick(() => {
          if (this.onSend) {
            this.onSend();
          }
        })
    }
    .padding({ bottom: 16, right: 16 })
  }

  /**
   * 选择表情
   */
  private selectEmoji(emoji: EmojiItem) {
    console.info(`[EmojiPicker] 选择表情: ${emoji.name}`);

    // 添加到最近使用
    this.addToRecentEmojis(emoji);

    // 回调通知
    if (this.onEmojiSelected) {
      this.onEmojiSelected(emoji);
    }
  }

  /**
   * 添加到最近使用
   */
  private addToRecentEmojis(emoji: EmojiItem) {
    // 移除已存在的相同表情
    this.recentEmojis = this.recentEmojis.filter(item => item.id !== emoji.id);

    // 添加到开头
    this.recentEmojis.unshift(emoji);

    // 限制最近使用数量
    if (this.recentEmojis.length > this.maxRecentEmojis) {
      this.recentEmojis = this.recentEmojis.slice(0, this.maxRecentEmojis);
    }

    // 保存到本地存储
    this.saveRecentEmojis();
  }

  /**
   * 加载最近使用的表情
   */
  private async loadRecentEmojis() {
    try {
      // 从本地存储加载最近使用的表情
      const preferences = await dataPreferences.getPreferences(getContext(this), 'emoji_preferences');
      const recentEmojiIds = await preferences.get('recent_emoji_ids', '[]') as string;

      if (recentEmojiIds && recentEmojiIds !== '[]') {
        const emojiIds: string[] = JSON.parse(recentEmojiIds);
        const loadedEmojis: EmojiItem[] = [];

        // 根据ID查找对应的表情对象，限制数量
        const limitedIds = emojiIds.slice(0, this.maxRecentEmojis);
        limitedIds.forEach(id => {
          const emoji = EmojiDataManager.getEmojiById(id);
          if (emoji) {
            loadedEmojis.push(emoji);
          }
        });

        this.recentEmojis = loadedEmojis;
        console.info(`[EmojiPicker] 成功加载 ${loadedEmojis.length} 个最近使用表情 (最大显示${this.maxRecentEmojis}个)`);
      } else {
        // 如果没有存储数据，使用默认数据
        this.recentEmojis = EmojiDataManager.getDefaultRecentEmojis().slice(0, this.maxRecentEmojis);
        console.info(`[EmojiPicker] 使用默认最近使用表情 (显示${this.maxRecentEmojis}个)`);
      }
    } catch (error) {
      console.error('[EmojiPicker] 加载最近使用表情失败:', error);
      // 加载失败时使用默认数据
      this.recentEmojis = EmojiDataManager.getDefaultRecentEmojis().slice(0, this.maxRecentEmojis);
    }
  }

  /**
   * 保存最近使用的表情
   */
  private async saveRecentEmojis() {
    try {
      // 保存到本地存储
      const preferences = await dataPreferences.getPreferences(getContext(this), 'emoji_preferences');
      const emojiIds = this.recentEmojis.map(emoji => emoji.id);
      const emojiIdsJson = JSON.stringify(emojiIds);

      await preferences.put('recent_emoji_ids', emojiIdsJson);
      await preferences.flush();

      console.info(`[EmojiPicker] 成功保存 ${emojiIds.length} 个最近使用表情`);
    } catch (error) {
      console.error('[EmojiPicker] 保存最近使用表情失败:', error);
    }
  }

  /**
   * 添加按下效果
   */
  private addPressEffect() {
    // 可以添加触觉反馈或动画效果
    console.info('[EmojiPicker] 表情按下效果');
  }
} 