import { MessageInfo } from 'chatengine/src/main/ets/pages/MessageListState';
import { ImageSizeUtil, ThemeManager, TimeUtil } from 'basecomponent';
import { MessageBody } from 'chatengine';
import router from '@ohos.router';
import {
  MediaType,
  MediaItem,
  VideoPlayerListener,
  setVideoPlayerListener,
  clearVideoPlayerListener
} from 'videoplayer';
import { MessageResourceType, MessageListState } from 'chatengine/src/main/ets/pages/MessageListState';

// import { AppContext } from 'basecomponent';

const DEFAULT_IMAGE_MAX_SIZE = 180; // 默认最大尺寸

@Component
export struct VideoMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @State isPlaying: boolean = false;
  @ObjectLink messageListState: MessageListState;

  aboutToAppear() {
    // 注册视频播放器监听器
    this.registerVideoPlayerListener();
  }

  aboutToDisappear() {
    // 清除视频播放器监听器
    this.clearVideoPlayerListener();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 视频缩略图（作为背景层）
      Image(this.messageBody?.videoSnapshotPath)
        .width('100%')
        .height('100%')
        .borderRadius(8)
        .interpolation(ImageInterpolation.Medium)
        .objectFit(ImageFit.Cover)
        .size(this.getImageSize())

      // 播放按钮（居中显示）
      Column() {
        Image(this.isPlaying ? $r('app.media.voice_pause') : $r('app.media.voice_play'))
          .width(48)
          .height(48)
          .onClick(() => this.togglePlay())
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 视频时长（右下角定位）
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
      // 如果有视频或缩略图，就打开播放器
      if (!this.messageBody?.videoSnapshotPath) {
        console.error('Thumbnail is empty');
        return;
      }

      this.navigateToPlayer();
    })
  }

  // 请求下载视频
  public requestVideoDownload() {
    if (!this.message || !this.message.ID) {
      console.error('[VideoMessageView] 请求下载视频失败: 消息ID为空');
      return;
    }

    console.info(`[VideoMessageView] 请求下载视频: ${this.message.ID}`);

    // 下载视频
    this.messageListState.downloadMessageResource(this.message, MessageResourceType.video)
      .then(() => {
        console.info('[VideoMessageView] 视频下载完成');

        // 检查是否有视频路径
        if (this.messageBody && this.messageBody.videoPath) {
          console.info(`[VideoMessageView] 下载完成，视频路径: ${this.messageBody.videoPath}`);
          
          // 获取当前的router参数
          const currentParams = router.getParams() as Record<string, object>;
          if (currentParams && currentParams.mediaItem) {
            // 更新MediaItem对象，保留原有的其他属性
            const currentMediaItem = currentParams.mediaItem as MediaItem;
            const updatedMediaItem: MediaItem = {
              path: currentMediaItem.path,
              type: currentMediaItem.type,
              videoPath: this.messageBody.videoPath
            };
            
            // 使用replaceNamedRoute替换当前页面，传入更新后的参数
            this.getUIContext().getRouter().replaceNamedRoute({
              name: 'VideoPlayer',
              params: {
                mediaItem: updatedMediaItem
              }
            }).catch((err: object) => {
              console.error(`[VideoMessageView] 更新视频播放器页面失败: ${JSON.stringify(err)}`);
            });
            
            console.info(`[VideoMessageView] 已使用新视频路径替换播放页面: ${this.messageBody.videoPath}`);
          }
        } else {
          console.warn('[VideoMessageView] 视频下载完成但路径为空');
        }
      })
      .catch((error: object) => {
        console.error(`[VideoMessageView] 下载视频失败: ${JSON.stringify(error)}`);
      });
  }

  // 注册视频播放器监听器
  private registerVideoPlayerListener() {
    // 确保视频缩略图路径存在
    if (!this.messageBody?.videoSnapshotPath) {
      console.error('[VideoMessageView] 无法注册监听器: 缩略图路径为空');
      return;
    }

    // 使用缩略图路径作为唯一标识
    const videoKey = this.messageBody.videoSnapshotPath;

    class CustomVideoPlayerListener extends VideoPlayerListener {
      private component: VideoMessageViewContent;

      constructor(component: VideoMessageViewContent) {
        super();
        this.component = component;
      }

      onVideoDownloadRequest(vUrl?: string): void {
        // 确认视频URL匹配，才执行下载
        if (vUrl && vUrl === this.component.messageBody?.videoSnapshotPath) {
          console.info(`[VideoMessageView] 收到下载请求，视频URL: ${vUrl}`);
          this.component.requestVideoDownload();
        } else {
          console.warn(`[VideoMessageView] 收到下载请求，但视频URL不匹配，请求URL: ${vUrl}, 当前URL: ${this.component.messageBody?.videoSnapshotPath}`);
        }
      }
    }

    const listener = new CustomVideoPlayerListener(this);
    // 使用视频URL注册监听器
    setVideoPlayerListener(videoKey, listener);
    console.info(`[VideoMessageView] 已注册视频播放器监听器，视频URL: ${videoKey}`);
  }

  // 清理监听器
  private clearVideoPlayerListener() {
    // 清除特定视频的监听器
    if (this.messageBody?.videoSnapshotPath) {
      clearVideoPlayerListener(this.messageBody.videoSnapshotPath);
      console.info(`[VideoMessageView] 已清除视频URL ${this.messageBody.videoSnapshotPath} 的监听器`);
    }
  }

  // 跳转到独立播放页
  private navigateToPlayer() {
    // 如果没有视频路径，但有缩略图，仍然打开查看器以全屏方式查看缩略图
    if (!this.messageBody?.videoSnapshotPath) {
      console.error('[VideoMessageView] 缩略图为空');
      return;
    }

    // 准备媒体项
    const mediaItem: MediaItem = {
      path: this.messageBody?.videoSnapshotPath || '',
      type: MediaType.VIDEO,
      videoPath: this.messageBody?.videoPath || ''
    };

    // 使用router导航到VideoPlayer页面
    this.getUIContext().getRouter().pushNamedRoute({
      name: 'VideoPlayer',
      params: {
        mediaItem: mediaItem
      }
    }).catch((err: object) => {
      console.error(`[VideoMessageView] 导航到视频播放器失败: ${JSON.stringify(err)}`);
    });
  }

  // 获取视频缩略图尺寸
  private getImageSize(): SizeOptions {
    let width = 0;
    let height = 0;

    // 情况1：无尺寸信息时使用默认方形
    if (!this.messageBody?.videoSnapshotWidth || !this.messageBody?.videoSnapshotHeight) {
      width = DEFAULT_IMAGE_MAX_SIZE;
      height = DEFAULT_IMAGE_MAX_SIZE;
      return { width, height };
    }

    // 情况2：根据宽高比计算
    const srcWidth = this.messageBody.videoSnapshotWidth;
    const srcHeight = this.messageBody.videoSnapshotHeight;
    const aspectRatio = srcWidth / srcHeight;

    if (srcWidth > srcHeight) { // 横屏视频
      width = DEFAULT_IMAGE_MAX_SIZE;
      height = DEFAULT_IMAGE_MAX_SIZE / aspectRatio;
    } else { // 竖屏视频
      width = DEFAULT_IMAGE_MAX_SIZE * aspectRatio;
      height = DEFAULT_IMAGE_MAX_SIZE;
    }

    return { width, height };
  }

  // 点击播放/暂停
  private togglePlay() {
    this.isPlaying = !this.isPlaying;
  }

  // 格式化视频时长（秒 → 00:00）
  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }
}

@Builder
export function VideoMessageView(messageData: MessageInfo, messageListState: MessageListState) {
  if (messageData && messageData.messageBody) {
    VideoMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListState: messageListState
    })
  }
}