import { MessageInfo, MessageBody, MessageListStore, MessageResourceType } from 'chatengine';
import { ImageSizeUtil, ThemeState, TimeUtil } from '../../basecomponent/Index';
import { ImageSourceType, ImageViewer } from '../../imageviewer/Index';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';

@Component
export struct ImageMessageViewContent {
  @ObjectLink messageBody: MessageBody;
  @ObjectLink message: MessageInfo;
  @ObjectLink messageListStore: MessageListStore;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
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
        Image(this.messageBody.originalImagePath)
          .interpolation(ImageInterpolation.Low)
          .objectFit(ImageFit.Cover)
          .size(this.getImageSize())
          .draggable(false)
          .onClick(() => this.openImageViewer(ImageSourceType.LOCAL, this.messageBody.originalImagePath ?? ""))
      } else if (this.messageBody?.thumbImagePath) {
        Image(this.messageBody.thumbImagePath)
          .interpolation(ImageInterpolation.Low)
          .objectFit(ImageFit.Cover)
          .size(this.getImageSize())
          .draggable(false)
          .onClick(() => {
            const imagePath = this.messageBody.largeImagePath || this.messageBody.thumbImagePath;
            this.openImageViewer(ImageSourceType.LOCAL, imagePath ?? "");
          })
      } else {
        Image($rawfile("basecomponent/common_image_replace_icon.png"))
          .size(this.getImageSize())
          .backgroundColor('#F2F2F2')
          .borderRadius(5)
      }
    }
  }

  public requestImageDownload() {
    if (!this.message || !this.message.ID) {
      return;
    }
    return this.messageListStore.downloadMessageResource(this.message, MessageResourceType.originalImage);
  }

  private openImageViewer(imageType: ImageSourceType, imagePath: string) {
    this.getUIContext().getRouter().pushNamedRoute({
      name: 'ImageViewer',
      params: {
        imageType: imageType.toString(),
        imagePath: imagePath
      }
    }).catch((err: object) => {

    });

  }
}

@Builder
export function ImageMessageView(messageData: MessageInfo, MessageListStore: MessageListStore) {
  if (messageData && messageData.messageBody) {
    ImageMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListStore: MessageListStore
    })
  }
}