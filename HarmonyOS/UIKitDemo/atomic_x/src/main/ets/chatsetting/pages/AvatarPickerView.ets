import { ThemeState, Toast } from '../../basecomponent/Index';
@Component
export struct AvatarPickerView {
  
  private static readonly IMAGE_SIZE: number = 66;
  private static readonly IMAGE_SPACING: number = 8;
  private static readonly BORDER_RADIUS: number = 8;
  private static readonly SELECTED_BORDER_WIDTH: number = 2;
  private static readonly HEADER_HEIGHT: number = 56;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  
  title?: string | Resource = $r('app.string.chatsetting_select_avatar');
  urlList: string[] = [];
  onBack?: () => void;
  onConfirm?: (selectedUrl: string, selectedIndex: number) => void;
  dialogController?: CustomDialogController;
  onDialogClose?: () => void;
  
  @State selectedIndex: number = -1;

  aboutToAppear(): void {
    console.log('[AvatarPickerPage] Title:', this.title);
    console.log('[AvatarPickerPage] URL list length:', this.urlList.length);
  }

  build() {
    Column() {
      
      this.HeaderBuilder()

      
      if (this.urlList.length === 0) {
        this.EmptyStateBuilder()
      } else {
        this.ImageGridBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }

  @Builder
  HeaderBuilder() {
    Row() {
      // Back button
      Button() {
        Image($rawfile('search/back_icon.svg'))
          .width(24)
          .height(24)
          .fillColor('#0365F9')
      }
      .backgroundColor('transparent')
      .onClick(() => {
        this.closeDialog();
      })

      Blank()

      // Title
      Text(this.title)
        .fontSize(18)
        .fontWeight(600)
        .fontColor(this.themeState.colors.textColorSecondary)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank()

      
      Button($r('app.string.chatsetting_confirm_select'))
        .fontSize(16)
        .fontWeight(600)
        .fontColor(this.selectedIndex >= 0 ? this.themeState.colors.textColorLink :
        this.themeState.colors.textColorSecondary)
        .backgroundColor('transparent')
        .enabled(this.selectedIndex >= 0)
        .onClick(() => {
          this.handleConfirm();
        })
    }
    .width('100%')
    .height(AvatarPickerView.HEADER_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Text($r('app.string.chatsetting_no_avatar_available'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ImageGridBuilder() {
    Scroll() {
      Grid() {
        ForEach(this.urlList, (url: string, index: number) => {
          GridItem() {
            this.ImageItemBuilder(url, index)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr') 
      .rowsGap(12)
      .columnsGap(12)
      .margin({ top: 8 })
      .padding({
        left: 12,
        right: 12,
        top: 8,
        bottom: 0
      })
    }
    .width('100%')
    .backgroundColor('#FF2F7')
  }

  @Builder
  ImageItemBuilder(url: string, index: number) {
    Stack() {
      
      Image(url)
        .width(AvatarPickerView.IMAGE_SIZE)
        .height(AvatarPickerView.IMAGE_SIZE)
        .borderRadius(AvatarPickerView.BORDER_RADIUS)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#FFFFFF')
        .border({
          width: this.selectedIndex === index ? AvatarPickerView.SELECTED_BORDER_WIDTH : 0,
          color: this.themeState.colors.textColorLink,
          radius: AvatarPickerView.BORDER_RADIUS
        })

      
      if (this.selectedIndex === index) {
        Stack() {
          Circle()
            .width(20)
            .height(20)
            .fill(this.themeState.colors.textColorLink)

          Text('✓')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .position({
          x: AvatarPickerView.IMAGE_SIZE - 10,
          y: -10
        })
      }
    }
    .width(AvatarPickerView.IMAGE_SIZE)
    .height(AvatarPickerView.IMAGE_SIZE)
    .onClick(() => {
      
      if (this.selectedIndex === index) {
        this.selectedIndex = -1;
      } else {
        this.selectedIndex = index;
      }
      console.log('[AvatarPickerPage] Image clicked, selectedIndex:', this.selectedIndex);
    })
  }

  
  private closeDialog(): void {
    if (this.dialogController) {
      
      this.dialogController.close();
      if (this.onDialogClose) {
        this.onDialogClose();
      }
    } else if (this.onBack) {
      
      this.onBack();
    } else {
      console.warn('[AvatarPickerPage] 没有提供关闭方式');
    }
  }

  
  private handleConfirm(): void {
    if (this.selectedIndex >= 0 && this.selectedIndex < this.urlList.length) {
      const selectedUrl = this.urlList[this.selectedIndex];
      console.log('[AvatarPickerPage] Confirmed selection:', selectedUrl, 'at index:', this.selectedIndex);

      
      if (this.onConfirm) {
        this.onConfirm(selectedUrl, this.selectedIndex);
      }
      this.closeDialog();
    } else {
      Toast.shortToast($r('app.string.chatsetting_please_select_image_first'));
    }
  }
} 