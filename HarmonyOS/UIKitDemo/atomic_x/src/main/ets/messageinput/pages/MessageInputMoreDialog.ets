import { ThemeState } from '../../basecomponent/Index';
export interface MenuItem {
  id: string;
  text: string | Resource;
  icon: Resource;
  action: () => void;
}
@CustomDialog
export struct MessageInputMoreDialog {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  controller?: CustomDialogController;
  menuItems: MenuItem[] = []; 
  onCancel?: () => void; 

  
  aboutToAppear() {
    
    if (this.menuItems.length === 0) {
      this.menuItems = [
        {
          id: 'image',
          text: $r('app.string.menu_image'),
          icon: $rawfile('messageinput/camera_action_icon.svg'),
          action: () => {
            
          }
        },
        {
          id: 'photo',
          text: $r('app.string.menu_photo'),
          icon: $rawfile('messageinput/camera_action_icon.svg'),
          action: () => {
            
          }
        },
        {
          id: 'video',
          text: $r('app.string.menu_video'),
          icon: $rawfile('messageinput/document_icon.svg'),
          action: () => {
            
          }
        },
        {
          id: 'file',
          text: $r('app.string.menu_file'),
          icon: $rawfile('messageinput/document_icon.svg'),
          action: () => {
            
          }
        },
        {
          id: 'custom',
          text: $r('app.string.menu_custom'),
          icon: $rawfile('messageinput/custom_icon.svg'),
          action: () => {
            
          }
        }
      ];
    }
  }

  
  @Builder
  MenuItemBuilder(item: MenuItem, index: number, isFirst: boolean = false, isLast: boolean = false) {
    Column() {
      Row() {
        
        Image(item.icon)
          .width(24)
          .height(24)
          .fillColor(this.themeState.colors.textColorSecondary)

        
        Text(item.text)
          .fontSize(17)
          .fontColor(this.themeState.colors.textColorLink)
          .fontWeight(FontWeight.Regular)
          .margin({ left: 12 })
      }
      .height(52)
      .width('100%')
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        item.action();
        this.controller?.close();
      })
    }
  }

  build() {
    Column() {
      
      Column() {
        ForEach(this.menuItems, (item: MenuItem, index: number) => {
          this.MenuItemBuilder(
            item,
            index,
            index === 0,
            index === this.menuItems.length - 1
          )
        })
      }
      .backgroundColor(this.themeState.colors.strokeColorPrimary)
      .borderRadius(14)
      .width('100%')
      .margin({ bottom: 8 })
      .backdropBlur(10) 

      
      Button($r('app.string.cancel'))
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .fontColor(this.themeState.colors.textColorLink)
        .width('100%')
        .height(56)
        .borderRadius(14)
        .margin({ bottom: 12 })
        .onClick(() => {
          if (this.onCancel) {
            this.onCancel();
          }
          this.controller?.close();
        })
    }
    .padding({ left: 16, right: 16, bottom: 8 })
    .backgroundColor(Color.Transparent)
    .width('100%')
  }
} 