import { MessageInfo } from 'chatengine';
import { ImageSizeUtil } from '../../basecomponent/Index';
import { MessageBody } from 'chatengine';
import { Core } from '@ohos/hypium';
import { MessageListStore } from 'chatengine';

let DEFAULT_IMAGE_MAX_SIZE = 180;

@Component
export struct FaceMessageViewContent {
  @State mesage?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;

  getImageSize(): SizeOptions {
    // Faces are typically square, so we'll return a fixed size
    return { width: 24, height: 24 };
  }

  build() {
    // if (this.messageBody?.faceName) {
    //   Image(this.messageBody?.faceName)
    //     .borderRadius(5)
    //     .interpolation(ImageInterpolation.Medium)
    //     .objectFit(ImageFit.Cover)
    //     .size(this.getImageSize())
    // } else {

    //     .fontSize(16)
    //     .fontColor(Color.Brown)
    //     .maxLines(100)
    //     .constraintSize({ maxWidth: '75%' })
    // }
    Text(`[face:${this.messageBody?.faceName || 0}]`)
      .fontSize(16)
      .fontColor(Color.Brown)
      .maxLines(100)
      .constraintSize({ maxWidth: '75%' })
  }
}

@Builder
export function FaceMessageView(messageData: MessageInfo, MessageListStore?: MessageListStore) {
  if (messageData && messageData.messageBody) {
    FaceMessageViewContent({ messageBody: messageData.messageBody })
  }
}