import { ThemeManager } from 'basecomponent';

/**
 * MessageInputMoreDialog的菜单项接口
 */
export interface MenuItem {
  id: string;
  text: string | Resource;
  icon: Resource;
  action: () => void;
}

/**
 * 消息输入栏更多选项弹窗
 */
@CustomDialog
export struct MessageInputMoreDialog {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  controller?: CustomDialogController;
  menuItems: MenuItem[] = []; // 菜单项列表
  onCancel?: () => void; // 取消回调

  /**
   * 弹窗的构造方法
   */
  aboutToAppear() {
    // 如果没有提供菜单项，设置默认菜单项
    if (this.menuItems.length === 0) {
      this.menuItems = [
        {
          id: 'image',
          text: $r('app.string.menu_image'),
          icon: $r('app.media.camera_action_icon'),
          action: () => {
            console.info('[MessageInputMoreDialog] 选择图片');
          }
        },
        {
          id: 'photo',
          text: $r('app.string.menu_photo'),
          icon: $r('app.media.camera_action_icon'),
          action: () => {
            console.info('[MessageInputMoreDialog] 选择拍照');
          }
        },
        {
          id: 'video',
          text: $r('app.string.menu_video'),
          icon: $r('app.media.document_icon'),
          action: () => {
            console.info('[MessageInputMoreDialog] 选择录像');
          }
        },
        {
          id: 'file',
          text: $r('app.string.menu_file'),
          icon: $r('app.media.document_icon'),
          action: () => {
            console.info('[MessageInputMoreDialog] 选择文件');
          }
        },
        {
          id: 'custom',
          text: $r('app.string.menu_custom'),
          icon: $r('app.media.custom_icon'),
          action: () => {
            console.info('[MessageInputMoreDialog] 选择自定义');
          }
        }
      ];
    }
  }

  /**
   * 渲染单个菜单项
   */
  @Builder
  MenuItemBuilder(item: MenuItem, index: number, isFirst: boolean = false, isLast: boolean = false) {
    Column() {
      Row() {
        // 图标
        Image(item.icon)
          .width(24)
          .height(24)
          .fillColor(this.themeManager.currentTheme.textColorSecondary)

        // 菜单项文本
        Text(item.text)
          .fontSize(17)
          .fontColor(this.themeManager.currentTheme.textColorLink)
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
      // 菜单项列表
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
      .backgroundColor(this.themeManager.currentTheme.strokeColorPrimary)
      .borderRadius(14)
      .width('100%')
      .margin({ bottom: 8 })
      .backdropBlur(10) // 增加模糊效果

      // 取消按钮
      Button($r('app.string.cancel'))
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
        .fontColor(this.themeManager.currentTheme.textColorLink)
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