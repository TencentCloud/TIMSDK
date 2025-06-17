import {
  MessageInfo,
  MessageBody,
  MessageListState,
  MessageResourceType
} from 'chatengine/src/main/ets/pages/MessageListState';
import { ImageSizeUtil, ThemeManager, TimeUtil } from 'basecomponent';
import { ImageSourceType, ImageViewer } from 'imageviewer';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';

let DEFAULT_IMAGE_MAX_SIZE = 180;

@Component
export struct ImageMessageViewContent {
  @ObjectLink messageBody: MessageBody;
  @State message?: MessageInfo = undefined;
  @ObjectLink messageListState: MessageListState;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  @State private imageLoadError: boolean = false;
  @State private imageLoading: boolean = true;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  getImageSize(): SizeOptions {
    if (!this.messageBody?.originalImageWidth ||
      !this.messageBody?.originalImageHeight ||
      this.messageBody.originalImageWidth === 0 ||
      this.messageBody.originalImageHeight === 0) {
      return ImageSizeUtil.getSquareSize();
    }

    return ImageSizeUtil.calculateOptimalSize(
      this.messageBody.originalImageWidth,
      this.messageBody.originalImageHeight
    );
  }

  build() {
    Column() {
      if (this.messageBody?.originalImagePath) {
        // 原图路径存在
        Image(this.messageBody.originalImagePath)
          .borderRadius(5)
          .interpolation(ImageInterpolation.Medium)
          .objectFit(ImageFit.Cover)
          .size(this.getImageSize())
          .draggable(false)
          .onClick(() => this.openImageViewer(ImageSourceType.LOCAL, this.messageBody.originalImagePath ?? ""))
      } else if (this.messageBody?.thumbImagePath) {
        // 缩略图路径存在
        Image(this.messageBody.thumbImagePath)
          .borderRadius(5)
          .interpolation(ImageInterpolation.Medium)
          .objectFit(ImageFit.Cover)
          .size(this.getImageSize())
          .draggable(false)
          .onClick(() => {
            // 优先使用原图路径，如果没有则使用缩略图路径
            const imagePath = this.messageBody.largeImagePath || this.messageBody.thumbImagePath;
            this.openImageViewer(ImageSourceType.LOCAL, imagePath ?? "");
          })
      } else {
        // 占位符
        Column() {
          Image($r('sys.media.ohos_app_icon'))
            .width(50)
            .height(50)
            .fillColor(this.themeManager.currentTheme.textColorAntiSecondary)

          Text('图片加载失败')
            .fontSize(14)
            .fontColor(this.themeManager.currentTheme.textColorAntiSecondary)
            .margin({ top: 8 })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .size(this.getImageSize())
        .backgroundColor('#F2F2F2')
        .borderRadius(5)
      }
    }
  }

  /**
   * 下载原图
   */
  public requestImageDownload() {
    if (!this.message || !this.message.ID) {
      console.error('[ImageMessageView] 请求下载图片失败: 消息ID为空');
      return;
    }

    console.info(`[ImageMessageView] 请求下载图片: ${this.message.ID}`);
    return this.messageListState.downloadMessageResource(this.message, MessageResourceType.originalImage);
  }

  /**
   * 打开图片查看器
   * @param imageType 图片类型
   * @param imagePath 图片路径或URL
   */
  private openImageViewer(imageType: ImageSourceType, imagePath: string) {
    this.getUIContext().getRouter().pushNamedRoute({
      name: 'ImageViewer',
      params: {
        imageType: imageType.toString(),
        imagePath: imagePath
      }
    }).catch((err: object) => {
      console.error(`[ImageMessageView] 打开图片查看器失败: ${JSON.stringify(err)}`);
    });

  }
}

@Builder
export function ImageMessageView(messageData: MessageInfo, messageListState: MessageListState) {
  if (messageData && messageData.messageBody) {
    ImageMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListState: messageListState
    })
  }
}