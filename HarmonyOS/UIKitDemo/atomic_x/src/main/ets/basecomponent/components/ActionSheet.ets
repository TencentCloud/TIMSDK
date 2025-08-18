import { ThemeState } from '../theme/ThemeState';
export interface ActionItem {
  text: string | Resource;
  isDestructive?: boolean; 
  isEnabled?: boolean; 
  value?: string | number | boolean | object; 
  isSelected?: boolean; 
}
@CustomDialog
export struct ActionSheet {
  
  private static readonly BUTTON_HEIGHT: number = 56;
  
  private static readonly BORDER_RADIUS: number = 14;
  
  private static readonly SPACING: number = 12;
  
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  
  controller: CustomDialogController;
  
  @Prop title?: string | Resource = '';
  
  @Prop options: ActionItem[] = [];
  
  @Prop showCancel: boolean = true;
  
  @Prop cancelText: string | Resource = '取消';
  // Callback function
  onActionSelected?: (item: ActionItem) => void;
  onDismiss?: () => void;

  build() {
    Column() {
      
      Column() {
        
        if (this.title && this.title.toString().length > 0) {
          Row() {
            Text(this.title)
              .fontSize(17)
              .fontFamily('PingFang HK')
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.colors.textColorPrimary)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(ActionSheet.BUTTON_HEIGHT)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
          .borderRadius({ topLeft: ActionSheet.BORDER_RADIUS, topRight: ActionSheet.BORDER_RADIUS })
        }

        
        if (this.options.length > 0) {
          Column() {
            ForEach(this.options, (option: ActionItem, index: number) => {
              Column() {
                
                if ((index > 0 && !this.title) || (this.title && this.title.toString().length > 0)) {
                  Divider()
                    .height(0.4)
                    .color(this.themeState.colors.strokeColorPrimary)
                    .width('100%')
                }

                // Action buttons
                this.ActionButton(option)
              }
              .width('100%')
            })
          }
          .width('100%')
          .borderRadius(this.title && this.title.toString().length > 0 ?
            { bottomLeft: ActionSheet.BORDER_RADIUS, bottomRight: ActionSheet.BORDER_RADIUS } :
          ActionSheet.BORDER_RADIUS)
          .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
          .clip(true)
        }
      }
      .width('100%')

      
      if (this.showCancel) {
        Button() {
          Text(this.cancelText)
            .fontSize(17)
            .fontFamily('PingFang HK')
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.buttonColorPrimaryDefault)
            .textAlign(TextAlign.Center)
        }
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .height(ActionSheet.BUTTON_HEIGHT)
        .width('100%')
        .borderRadius(ActionSheet.BORDER_RADIUS)
        .margin({ top: ActionSheet.SPACING })
        .onClick(() => this.handleCancel())
      }
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 38 })
  }

  
  @Builder
  ActionButton(option: ActionItem) {
    Button() {
      Text(option.text)
        .fontSize(17)
        .fontFamily('PingFang HK')
        .fontWeight(400)
        .fontColor(this.getTextColor(option))
        .textAlign(TextAlign.Center)
    }
    .backgroundColor(Color.Transparent)
    .height(ActionSheet.BUTTON_HEIGHT)
    .width('100%')
    .enabled(option.isEnabled !== false)
    .opacity(option.isEnabled === false ? 0.5 : 1.0)
    .onClick(() => this.handleAction(option))
  }

  
  private getTextColor(option: ActionItem): string {
    if (option.isEnabled === false) {
      return this.themeState.colors.textColorDisable;
    }
    if (option.isSelected === true) {
      return '#0365F9'; 
    }
    if (option.isDestructive === true) {
      return this.themeState.colors.textColorError;
    }
    return this.themeState.colors.buttonColorPrimaryDefault;
  }

  
  private handleAction(option: ActionItem) {
    if (option.isEnabled === false) {
      return;
    }

    

    // Close dialog
    this.controller.close();

    
    if (this.onActionSelected) {
      this.onActionSelected(option);
    }
  }

  
  private handleCancel() {
    

    // Close dialog
    this.controller.close();

    
    if (this.onDismiss) {
      this.onDismiss();
    }
  }
}
