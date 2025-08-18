import { MessageInfo } from 'chatengine';
import { ImageSizeUtil, ThemeState, TimeUtil } from '../../basecomponent/Index';
import { MessageBody } from 'chatengine';
import router from '@ohos.router';
import {
  MediaType,
  MediaItem,
  VideoPlayerListener,
  setVideoPlayerListener,
  clearVideoPlayerListener
} from '../../videoplayer/Index';
import { MessageResourceType, MessageListStore } from 'chatengine';

// import { AppContext } from '../../basecomponent/Index';

const DEFAULT_IMAGE_MAX_SIZE = 180;

@Component
export struct VideoMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @State isPlaying: boolean = false;
  @ObjectLink messageListStore: MessageListStore;

  aboutToAppear() {

    this.registerVideoPlayerListener();
  }

  aboutToDisappear() {

    this.clearVideoPlayerListener();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {

      Image(this.messageBody?.videoSnapshotPath)
        .width('100%')
        .height('100%')
        .borderRadius(8)
        .interpolation(ImageInterpolation.Medium)
        .objectFit(ImageFit.Cover)
        .size(this.getImageSize())


      Column() {
        Image(this.isPlaying ? $rawfile('messagelist/voice_pause.png') : $rawfile('messagelist/voice_play.png'))
          .width(48)
          .height(48)
          .onClick(() => this.togglePlay())
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)


      Row() {
        Text(this.formatDuration(this.messageBody?.videoDuration ?? 0))
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor('#99000000')
          .borderRadius(4)
          .padding({
            left: 6,
            right: 6,
            top: 2,
            bottom: 2
          })
      }
      .margin({ right: 8, bottom: 8 })
      .alignItems(VerticalAlign.Bottom)
    }
    .width(this.getImageSize().width)
    .height(this.getImageSize().height)
    .onClick(() => {

      if (!this.messageBody?.videoSnapshotPath) {
        console.error('Thumbnail is empty');
        return;
      }

      this.navigateToPlayer();
    })
  }

  public requestVideoDownload() {
    if (!this.message || !this.message.ID) {
      return;
    }
    this.messageListStore.downloadMessageResource(this.message, MessageResourceType.video)
      .then(() => {
        if (this.messageBody && this.messageBody.videoPath) {
          const currentParams = router.getParams() as Record<string, object>;
          if (currentParams && currentParams.mediaItem) {

            const currentMediaItem = currentParams.mediaItem as MediaItem;
            const updatedMediaItem: MediaItem = {
              path: currentMediaItem.path,
              type: currentMediaItem.type,
              videoPath: this.messageBody.videoPath
            };
            this.getUIContext().getRouter().replaceNamedRoute({
              name: 'VideoPlayer',
              params: {
                mediaItem: updatedMediaItem
              }
            }).catch((err: object) => {

            });
          }
        } else {
          console.warn('[VideoMessageView] 视频下载完成但路径为空');
        }
      })
      .catch((error: object) => {

      });
  }

  private registerVideoPlayerListener() {

    if (!this.messageBody?.videoSnapshotPath) {

      return;
    }


    const videoKey = this.messageBody.videoSnapshotPath;

    class CustomVideoPlayerListener extends VideoPlayerListener {
      private component: VideoMessageViewContent;

      constructor(component: VideoMessageViewContent) {
        super();
        this.component = component;
      }

      onVideoDownloadRequest(vUrl?: string): void {

        if (vUrl && vUrl === this.component.messageBody?.videoSnapshotPath) {

          this.component.requestVideoDownload();
        } else {
          console.warn(`[VideoMessageView] 收到下载请求，但视频URL不匹配，请求URL: ${vUrl}, 当前URL: ${this.component.messageBody?.videoSnapshotPath}`);
        }
      }
    }

    const listener = new CustomVideoPlayerListener(this);

    setVideoPlayerListener(videoKey, listener);

  }

  private clearVideoPlayerListener() {

    if (this.messageBody?.videoSnapshotPath) {
      clearVideoPlayerListener(this.messageBody.videoSnapshotPath);

    }
  }

  private navigateToPlayer() {

    if (!this.messageBody?.videoSnapshotPath) {

      return;
    }


    const mediaItem: MediaItem = {
      path: this.messageBody?.videoSnapshotPath || '',
      type: MediaType.VIDEO,
      videoPath: this.messageBody?.videoPath || ''
    };


    this.getUIContext().getRouter().pushNamedRoute({
      name: 'VideoPlayer',
      params: {
        mediaItem: mediaItem
      }
    }).catch((err: object) => {

    });
  }

  private getImageSize(): SizeOptions {
    let width = 0;
    let height = 0;


    if (!this.messageBody?.videoSnapshotWidth || !this.messageBody?.videoSnapshotHeight) {
      width = DEFAULT_IMAGE_MAX_SIZE;
      height = DEFAULT_IMAGE_MAX_SIZE;
      return { width, height };
    }


    const srcWidth = this.messageBody.videoSnapshotWidth;
    const srcHeight = this.messageBody.videoSnapshotHeight;
    const aspectRatio = srcWidth / srcHeight;

    if (srcWidth > srcHeight) {
      width = DEFAULT_IMAGE_MAX_SIZE;
      height = DEFAULT_IMAGE_MAX_SIZE / aspectRatio;
    } else {
      width = DEFAULT_IMAGE_MAX_SIZE * aspectRatio;
      height = DEFAULT_IMAGE_MAX_SIZE;
    }

    return { width, height };
  }

  private togglePlay() {
    this.isPlaying = !this.isPlaying;
  }

  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }
}

@Builder
export function VideoMessageView(messageData: MessageInfo, MessageListStore: MessageListStore) {
  if (messageData && messageData.messageBody) {
    VideoMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListStore: MessageListStore
    })
  }
}