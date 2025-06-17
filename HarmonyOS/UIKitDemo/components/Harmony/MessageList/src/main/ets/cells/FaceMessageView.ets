import { MessageInfo } from 'chatengine/src/main/ets/pages/MessageListState';
import { ImageSizeUtil } from 'basecomponent';
import { MessageBody } from 'chatengine';
import { Core } from '@ohos/hypium';
import { MessageListState } from 'chatengine/src/main/ets/pages/MessageListState';

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
    //   Text(`[表情:${this.messageBody?.faceIndex || 0}]`)
    //     .fontSize(16)
    //     .fontColor(Color.Brown)
    //     .maxLines(100)
    //     .constraintSize({ maxWidth: '75%' })
    // }
    Text(`[表情:${this.messageBody?.faceName || 0}]`)
      .fontSize(16)
      .fontColor(Color.Brown)
      .maxLines(100)
      .constraintSize({ maxWidth: '75%' })
  }
}

@Builder
export function FaceMessageView(messageData: MessageInfo, messageListState?: MessageListState) {
  if (messageData && messageData.messageBody) {
    FaceMessageViewContent({ messageBody: messageData.messageBody })
  }
}