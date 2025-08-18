import { ThemeState } from '../../basecomponent/Index';
import { EmojiDataManager, EmojiItem, EmojiCategory } from '../data/EmojiData';
import dataPreferences from '@ohos.data.preferences';
@Component
export struct EmojiPicker {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State selectedEmojiType: string = 'normal'; 
  @State recentEmojis: EmojiItem[] = [];
  
  maxRecentEmojis: number = 8;
  
  onEmojiSelected?: (emoji: EmojiItem) => void;
  
  onClose?: () => void;
  
  onDelete?: () => void;
  
  onSend?: () => void;

  aboutToAppear() {
    
    this.loadRecentEmojis();
  }

  build() {
    
    Column() {
      
      this.buildEmojiTypeSelector()

      
      Stack({ alignContent: Alignment.BottomEnd }) {
        
        this.buildEmojiGrid()

        
        if (this.selectedEmojiType === 'normal') {
          this.buildBottomCategoryBar()
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(280)
    .backgroundColor(this.themeState.colors.bgColorOperate)
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

  
  @Builder
  buildEmojiTypeSelector() {
    Row() {
      
      Button() {
        Text(EmojiDataManager.getEmojiTypeDisplayName('normal'))
          .fontSize(12)
          .fontColor(this.selectedEmojiType === 'normal' ?
          this.themeState.colors.textColorPrimary :
          this.themeState.colors.textColorSecondary)
      }
      .backgroundColor(this.selectedEmojiType === 'normal' ?
      this.themeState.colors.bgColorInput : Color.Transparent)
      .borderRadius(4)
      .onClick(() => {
        this.selectedEmojiType = 'normal';
      })

      
      Button() {
        Text(EmojiDataManager.getEmojiTypeDisplayName('large'))
          .fontSize(12)
          .fontColor(this.selectedEmojiType === 'large' ?
          this.themeState.colors.textColorPrimary :
          this.themeState.colors.textColorSecondary)
      }
      .backgroundColor(this.selectedEmojiType === 'large' ?
      this.themeState.colors.bgColorInput : Color.Transparent)
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

  
  @Builder
  buildEmojiGrid() {
    Scroll() {
      Column() {
        
        if (this.selectedEmojiType === 'normal') {
          
          if (this.recentEmojis.length > 0) {
            Text(EmojiDataManager.getCategoryDisplayName('recent'))
              .fontSize(14)
              .fontColor(this.themeState.colors.textColorSecondary)
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

          
          Text(EmojiDataManager.getCategoryDisplayName('all'))
            .fontSize(14)
            .fontColor(this.themeState.colors.textColorSecondary)
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
          .margin({ bottom: 60 }) 
        } else {
          
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
        
        this.addPressEffect();
      }
    })
    .stateStyles({
      pressed: {
        .backgroundColor(this.themeState.colors.bgColorInput)
      }
    })
  }

  
  @Builder
  buildBottomCategoryBar() {
    
    Row() {
      
      Button() {
        Image($r('sys.media.ohos_ic_back'))
          .width(20)
          .height(20)
          .fillColor(this.themeState.colors.textColorSecondary)
      }
      .width(44)
      .height(44)
      .backgroundColor(this.themeState.colors.bgColorInput)
      .borderRadius(22)
      .margin({ right: 8 })
      .onClick(() => {
        
        if (this.onDelete) {
          this.onDelete();
        }
      })

      
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

  
  private selectEmoji(emoji: EmojiItem) {
    

    
    this.addToRecentEmojis(emoji);

    
    if (this.onEmojiSelected) {
      this.onEmojiSelected(emoji);
    }
  }

  
  private addToRecentEmojis(emoji: EmojiItem) {
    
    this.recentEmojis = this.recentEmojis.filter(item => item.id !== emoji.id);

    
    this.recentEmojis.unshift(emoji);

    
    if (this.recentEmojis.length > this.maxRecentEmojis) {
      this.recentEmojis = this.recentEmojis.slice(0, this.maxRecentEmojis);
    }

    
    this.saveRecentEmojis();
  }

  
  private async loadRecentEmojis() {
    try {
      
      const preferences = await dataPreferences.getPreferences(getContext(this), 'emoji_preferences');
      const recentEmojiIds = await preferences.get('recent_emoji_ids', '[]') as string;

      if (recentEmojiIds && recentEmojiIds !== '[]') {
        const emojiIds: string[] = JSON.parse(recentEmojiIds);
        const loadedEmojis: EmojiItem[] = [];

        
        const limitedIds = emojiIds.slice(0, this.maxRecentEmojis);
        limitedIds.forEach(id => {
          const emoji = EmojiDataManager.getEmojiById(id);
          if (emoji) {
            loadedEmojis.push(emoji);
          }
        });

        this.recentEmojis = loadedEmojis;
        
      } else {
        
        this.recentEmojis = EmojiDataManager.getDefaultRecentEmojis().slice(0, this.maxRecentEmojis);
        
      }
    } catch (error) {
      
      
      this.recentEmojis = EmojiDataManager.getDefaultRecentEmojis().slice(0, this.maxRecentEmojis);
    }
  }

  
  private async saveRecentEmojis() {
    try {
      
      const preferences = await dataPreferences.getPreferences(getContext(this), 'emoji_preferences');
      const emojiIds = this.recentEmojis.map(emoji => emoji.id);
      const emojiIdsJson = JSON.stringify(emojiIds);

      await preferences.put('recent_emoji_ids', emojiIdsJson);
      await preferences.flush();

      
    } catch (error) {
      
    }
  }

  
  private addPressEffect() {
    
    
  }
} 