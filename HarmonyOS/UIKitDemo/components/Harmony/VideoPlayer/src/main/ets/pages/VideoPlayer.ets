import router from '@ohos.router';
import common from '@ohos.app.ability.common';
// import { ThemeManager } from 'basecomponent';
import media from '@ohos.multimedia.media';

/**
 * 媒体类型
 */
export enum MediaType {
  IMAGE = 0, // 图片
  VIDEO = 1 // 视频
}

/**
 * 媒体项参数接口
 */
export interface MediaItem {
  path: string; // 本地路径
  type: MediaType; // 媒体类型
  videoPath?: string; // 视频完整路径（如果有）
}

/**
 * 下载回调接口
 */
export interface DownloadCallback {
  onDownload(): void;
}

/**
 * 事件监听器接口
 */
export class VideoPlayerListener {
  /**
   * 下载视频事件
   * @param videoUrl 视频URL或缩略图路径，用于标识要下载哪个视频
   */
  onVideoDownloadRequest(videoUrl?: string): void {
  }
}

// 全局事件监听器存储 - 使用Map存储，以视频URL为键
let globalListeners: Map<string, VideoPlayerListener> = new Map();

/**
 * 设置全局事件监听器
 * @param videoUrl 视频缩略图URL，用于标识此监听器关联的视频
 * @param listener 监听器实例
 */
export function setVideoPlayerListener(videoUrl: string, listener: VideoPlayerListener): void {
  globalListeners.set(videoUrl, listener);
  console.info(`[VideoPlayer] 已设置全局事件监听器，视频URL: ${videoUrl}`);
}

/**
 * 清除全局事件监听器
 * @param videoUrl 视频URL，清除此URL关联的监听器，如果不提供则清除所有
 */
export function clearVideoPlayerListener(videoUrl?: string): void {
  if (videoUrl) {
    globalListeners.delete(videoUrl);
    console.info(`[VideoPlayer] 已清除视频URL ${videoUrl} 的事件监听器`);
  } else {
    globalListeners.clear();
    console.info('[VideoPlayer] 已清除所有事件监听器');
  }
}

/**
 * 触发下载视频事件
 * @param videoUrl 要下载的视频URL或缩略图路径
 */
export function triggerVideoDownloadRequest(videoUrl: string): void {
  const listener = globalListeners.get(videoUrl);
  if (listener) {
    try {
      if (typeof listener.onVideoDownloadRequest === 'function') {
        listener.onVideoDownloadRequest(videoUrl);
        console.info(`[VideoPlayer] 已触发视频URL ${videoUrl} 的下载事件`);
      } else {
        console.error('[VideoPlayer] 事件监听器未实现 onVideoDownloadRequest 方法');
      }
    } catch (error) {
      console.error(`[VideoPlayer] 触发下载视频事件出错: ${JSON.stringify(error)}`);
    }
  } else {
    console.error(`[VideoPlayer] 视频URL ${videoUrl} 的事件监听器未设置`);
  }
}

/**
 * 视频准备完成事件接口
 */
interface PreparedEvent {
  duration: number;
  width?: number;
  height?: number;
}

/**
 * 视频播放时间更新事件接口
 */
interface UpdateTimeEvent {
  time: number;
}

/**
 * 视频播放器页面
 * 支持网络视频和本地视频播放
 * 提供基本的播放控制功能
 */
@Entry({ routeName: 'VideoPlayer' })
@Component
export struct VideoPlayer {
  // @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 缩略图/图片路径
  @State thumbnailPath: string = '';
  // 视频完整路径
  @State videoPath: string = '';
  // 媒体类型
  @State mediaType: MediaType = MediaType.IMAGE;
  // 视频加载状态
  @State isLoading: boolean = true;
  // 播放状态
  @State isPlaying: boolean = false;
  // 当前播放时间
  @State currentTime: number = 0;
  // 视频总时长
  @State duration: number = 0;
  // 是否显示控制栏
  @State showControls: boolean = true;
  // 错误状态
  @State hasError: boolean = false;
  // 错误信息
  @State errorMessage: string = '';
  // 视频下载状态
  @State isDownloading: boolean = false;
  // 下载进度 0-100
  @State downloadProgress: number = 0;
  // Video组件控制器
  private videoController: VideoController = new VideoController();
  // 控制栏自动隐藏的定时器ID
  private controlsTimerId: number = -1;
  // 下载监听器
  private downloadCheckInterval: number = -1;
  // 时长检查定时器
  private durationCheckInterval: number = -1;
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    // 获取路由参数
    const params: object = router.getParams();
    if (params) {
      try {
        // 转换为参数对象
        const routeParams = params as Record<string, object>;

        // 解析媒体项
        if (routeParams.mediaItem && typeof routeParams.mediaItem === 'object') {
          const mediaItem = routeParams.mediaItem as MediaItem;
          this.thumbnailPath = mediaItem.path || '';
          this.mediaType = (mediaItem.type !== undefined) ? mediaItem.type : MediaType.IMAGE;
          this.videoPath = mediaItem.videoPath || '';

          console.info(`[VideoPlayer] Media item loaded - type: ${this.mediaType}, thumbnail: ${this.thumbnailPath}, videoPath: ${this.videoPath}`);
        } else {
          console.error('[VideoPlayer] 无效的媒体项参数');
          this.handleError('无效的媒体项参数', new Error('无效参数'));
          return;
        }
      } catch (error) {
        console.error(`[VideoPlayer] 解析路由参数错误: ${JSON.stringify(error)}`);
        this.handleError('解析参数错误', error as Error);
        return;
      }
    } else {
      console.error('[VideoPlayer] 没有路由参数');
      this.handleError('没有参数', new Error('无参数'));
      return;
    }

    // 初始化处理 - 取决于媒体类型和是否有视频路径
    if (this.mediaType === MediaType.VIDEO) {
      if (this.videoPath) {
        console.info(`[VideoPlayer] 准备播放视频: ${this.videoPath}`);
        this.isLoading = true; // Video组件会在准备好后自动更新状态

        // 设置检查时长的定时器
        this.startCheckingDuration();
      } else {
        console.info('[VideoPlayer] 无视频路径，显示缩略图并开始检查更新');
        this.isLoading = false; // 如果没有视频路径，不要保持加载状态
        this.startCheckingForVideoPath();
      }
    } else {
      // 图片类型直接设置为已加载
      console.info('[VideoPlayer] 图片模式，直接显示');
      this.isLoading = false;
    }
  }

  aboutToDisappear() {
    // 清除定时器
    if (this.controlsTimerId !== -1) {
      clearTimeout(this.controlsTimerId);
    }
    // 清除下载检查定时器
    if (this.downloadCheckInterval !== -1) {
      clearInterval(this.downloadCheckInterval);
    }
    // 清除时长检查定时器
    if (this.durationCheckInterval !== -1) {
      clearInterval(this.durationCheckInterval);
    }

    console.info('[VideoPlayer] 页面即将销毁，清理资源');
  }

  /**
   * 构建下载中状态UI
   */
  @Builder
  DownloadingStateBuilder() {
    Column() {
      // 进度环
      Progress({
        value: this.downloadProgress,
        total: 100,
        type: ProgressType.Ring
      })
        .width(80)
        .height(80)
        .color(Color.White)

      // 进度文本
      Text(`下载中 ${this.downloadProgress}%`)
        .fontSize(16)
        .fontColor(Color.White)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.5)')
  }

  /**
   * 构建加载中UI
   */
  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(Color.White)

      Text('加载中...')
        .fontSize(16)
        .fontColor(Color.White)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建错误状态UI
   */
  @Builder
  ErrorStateBuilder() {
    Column() {
      Image($r('sys.media.ohos_app_icon'))
        .width(80)
        .height(80)
        .fillColor(Color.White)

      Text('播放失败')
        .fontSize(18)
        .fontColor(Color.White)
        .margin({ top: 16 })

      Text(this.errorMessage)
        .fontSize(14)
        .fontColor(Color.White)
        .margin({ top: 8 })

      Button('返回')
        .margin({ top: 24 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建视频控制栏
   */
  @Builder
  ControlsBuilder() {
    Column() {
      // 顶部控制栏：返回按钮
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .onClick(() => {
            router.back();
          })

        Blank()
      }
      .width('100%')
      .padding(16)

      Blank()

      // 底部控制栏：播放/暂停、进度条、时间
      Column() {
        // 进度条
        Slider({
          value: this.currentTime,
          min: 0,
          max: this.duration > 0 ? this.duration : 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .selectedColor(Color.White)
          .trackColor(Color.Gray)
          .showSteps(false)
          .showTips(false)
          .onChange((value: number) => {
            try {
              console.info(`[VideoPlayer] 拖动进度条: ${value}秒`);

              // 更新显示时间
              this.currentTime = value;

              // 使用VideoController跳转到指定位置（毫秒）
              const seekTimeMs = Math.floor(value); // 秒转毫秒 - 这个转换是正确的
              this.videoController.setCurrentTime(seekTimeMs);
              console.info(`[VideoPlayer] 已发送跳转指令: ${seekTimeMs}ms`);
            } catch (error) {
              console.error(`[VideoPlayer] 拖动进度条错误: ${JSON.stringify(error)}`);
            }

            this.resetControlsTimer();
          })

        // 播放控制和时间
        Row() {
          // 播放/暂停按钮
          Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
            .width(32)
            .height(32)
            .fillColor(Color.White)
            .onClick(() => {
              this.onPlayButtonClick();
            })

          // 时间显示
          Text(`${this.formatTime(this.currentTime)} / ${this.formatTime(this.duration)}`)
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ left: 16 })

          Blank()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .width('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
    }
    .width('100%')
    .height('100%')
    .opacity(this.showControls ? 1 : 0)
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 黑色背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')

      if (this.mediaType === MediaType.IMAGE || (this.mediaType === MediaType.VIDEO && !this.videoPath)) {
        // 图片查看模式或视频缩略图模式
        Stack({ alignContent: Alignment.TopStart }) {
          // 图片/缩略图
          Image(this.thumbnailPath)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              // 点击图片时切换工具栏显示状态
              this.showControls = !this.showControls;
              if (this.showControls) {
                this.resetControlsTimer();
              } else if (this.controlsTimerId !== -1) {
                clearTimeout(this.controlsTimerId);
              }
            })

          // 显示顶部工具栏
          Column() {
            // 顶部控制栏：返回按钮
            Row() {
              Image($r('app.media.ic_back'))
                .width(24)
                .height(24)
                .fillColor(Color.White)
                .onClick(() => {
                  router.back();
                })

              Blank()
            }
            .width('100%')
            .padding(16)

            Blank()

            // 添加中间的播放按钮（仅当媒体类型为视频时）
            if (this.mediaType === MediaType.VIDEO) {
              Row() {
                Image($r('app.media.ic_play'))
                  .width(64)
                  .height(64)
                  .fillColor(Color.White)
                  .onClick(() => {
                    this.onPlayButtonClick();
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }

            Blank()
          }
          .width('100%')
          .height('100%')
          .opacity(this.showControls ? 1 : 0)
          .animation({
            duration: 300,
            curve: Curve.EaseOut
          })

          // 如果正在下载，显示下载进度
          if (this.isDownloading) {
            this.DownloadingStateBuilder()
          }
        }
      } else if (this.hasError) {
        // 错误状态
        this.ErrorStateBuilder()
      } else {
        // 视频播放区域 - 使用内置Video组件代替AVPlayer
        // 创建一个VideoController实例以便控制播放
        if (this.videoPath) {
          Stack({ alignContent: Alignment.Center }) {
            // 使用 Video 组件直接播放视频
            Video({
              src: this.videoPath,
              previewUri: this.thumbnailPath,
              controller: this.videoController
            })
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .autoPlay(true)
              .controls(false)// 使用自定义控制栏
              .onStart(() => {
                this.isPlaying = true;
                this.resetControlsTimer();
                console.info('[VideoPlayer] Video开始播放');
              })
              .onPause(() => {
                this.isPlaying = false;
                console.info('[VideoPlayer] Video已暂停');
              })
              .onFinish(() => {
                this.isPlaying = false;
                this.currentTime = this.duration;
                console.info('[VideoPlayer] Video播放完成');
                
                // 视频播放完成时显示控制栏
                this.showControls = true;
                // 不自动隐藏控制栏，因为视频已经结束
                if (this.controlsTimerId !== -1) {
                  clearTimeout(this.controlsTimerId);
                  this.controlsTimerId = -1;
                }
              })
              .onError(() => {
                this.handleError('视频播放错误', new Error('Video组件播放错误'));
                console.error('[VideoPlayer] Video播放错误');
              })
              .onPrepared((event: PreparedEvent) => {
                console.info(`[VideoPlayer] Video准备完成，原始数据: ${JSON.stringify(event)}`);

                // 确保获取到有效的视频时长
                if (event && typeof event.duration === 'number' && event.duration > 0) {
                  this.duration = Math.floor(event.duration); // 毫秒转秒
                  console.info(`[VideoPlayer] 视频时长设置为: ${this.duration}秒`);
                } else {
                  console.warn(`[VideoPlayer] 视频准备事件中未返回有效时长: ${JSON.stringify(event)}`);
                  // 由于VideoController没有直接的API获取视频时长，设置一个默认值
                  try {
                    // 设置一个默认值，直到能够获得实际值
                    if (this.duration === 0) {
                      // 设置一个默认值，后续会更新
                      this.duration = 60; // 默认60秒
                      console.info(`[VideoPlayer] 暂时设置默认时长: ${this.duration}秒`);
                    }
                  } catch (error) {
                    console.error(`[VideoPlayer] 获取视频时长失败: ${JSON.stringify(error)}`);
                  }
                }

                this.isLoading = false;
              })
              .onUpdate((event: UpdateTimeEvent) => {
                // 检查事件对象有效性
                if (!event || typeof event.time !== 'number') {
                  console.warn(`[VideoPlayer] 收到无效的时间更新事件: ${JSON.stringify(event)}`);
                  return;
                }

                // 更新当前时间
                const newTime = Math.floor(event.time); // 直接使用event.time，不再除以1000
                if (newTime !== this.currentTime) {
                  this.currentTime = newTime;
                  console.info(`[VideoPlayer] 播放时间更新: ${this.currentTime}秒/${this.duration}秒`);
                }

                // 如果总时长仍然是0或者默认值60，尝试根据当前时间更新估计的总时长
                if (this.duration === 0 || (this.duration === 60 && this.currentTime > 30)) {
                  const estimatedDuration = Math.max(this.currentTime + 30, 60);
                  if (estimatedDuration !== this.duration) {
                    this.duration = estimatedDuration;
                    console.info(`[VideoPlayer] 根据当前时间更新估计时长: ${this.duration}秒`);
                  }
                }
              })
              .onClick(() => {
                // 点击视频区域时切换控制栏显示状态
                this.showControls = !this.showControls;
                if (this.showControls) {
                  this.resetControlsTimer();
                } else if (this.controlsTimerId !== -1) {
                  clearTimeout(this.controlsTimerId);
                }
              })

            // 如果正在加载，显示加载指示器
            if (this.isLoading) {
              this.LoadingStateBuilder()
            }
          }
        }
      }

      // 控制UI覆盖层，显示在视频上方（不再限制只在播放状态显示）
      if (this.mediaType === MediaType.VIDEO && !this.isLoading && !this.hasError && this.videoPath) {
        this.ControlsBuilder()
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 处理下载完成
   */
  public onDownloadComplete(videoPath: string) {
    console.info(`[VideoPlayer] 下载完成，视频路径: ${videoPath}`);

    // 设置新的视频路径
    this.setVideoPath(videoPath);
  }

  /**
   * 更新下载进度
   */
  public updateDownloadProgress(progress: number) {
    if (this.isDownloading) {
      this.downloadProgress = progress;
    }
  }

  /**
   * 设置视频路径（下载完成后）
   */
  public setVideoPath(path: string) {
    console.info(`[VideoPlayer] 设置新的视频路径: ${path}`);

    // 更新路径
    this.videoPath = path;
    this.isDownloading = false;
    this.downloadProgress = 100;

    // 重置播放状态
    this.isLoading = true;
    this.currentTime = 0;
    this.isPlaying = false;
    this.hasError = false;

    // 由于Video组件使用src绑定，路径变更会自动触发重载
    console.info('[VideoPlayer] 视频路径已更新，Video组件将自动重新加载');
  }

  /**
   * 开始检查视频路径是否有更新
   * 这是为了处理异步下载完成的情况
   */
  private startCheckingForVideoPath() {
    console.info('[VideoPlayer] 开始检查视频路径更新');

    // 设置最大检查时间（30秒），防止无限检查
    let checkCount = 0;
    const MAX_CHECK_COUNT = 30; // 30秒后停止检查

    // 每秒检查一次是否有视频路径更新
    this.downloadCheckInterval = setInterval(() => {
      checkCount++;
      console.info(`[VideoPlayer] 检查视频路径更新 (${checkCount}/${MAX_CHECK_COUNT})`);

      // 超过最大检查次数后停止
      if (checkCount >= MAX_CHECK_COUNT) {
        console.info('[VideoPlayer] 达到最大检查次数，停止检查');
        clearInterval(this.downloadCheckInterval);
        this.downloadCheckInterval = -1;
        return;
      }

      // 从路由参数中获取最新的mediaItem
      const params = router.getParams() as Record<string, object>;
      if (params && params.mediaItem) {
        const mediaItem = params.mediaItem as MediaItem;

        // 如果视频路径已更新，则更新当前路径
        if (mediaItem.videoPath && mediaItem.videoPath !== this.videoPath) {
          console.info(`[VideoPlayer] 检测到视频路径更新: ${mediaItem.videoPath}`);

          // 停止检查
          clearInterval(this.downloadCheckInterval);
          this.downloadCheckInterval = -1;

          // 设置新的视频路径
          this.setVideoPath(mediaItem.videoPath);
        }
      }
    }, 1000);
  }

  /**
   * 播放按钮点击 - 如果视频不存在，尝试下载
   */
  private onPlayButtonClick() {
    // 仅处理视频类型
    if (this.mediaType !== MediaType.VIDEO) {
      return;
    }

    // 检查是否有视频路径
    if (!this.videoPath) {
      // 如果没有视频路径，通过回调请求下载
      this.requestVideoDownload();
      return;
    }

    // 已有视频路径，切换播放状态
    this.togglePlayPause();
  }

  /**
   * 请求下载完整视频
   */
  private requestVideoDownload() {
    if (this.isDownloading) {
      return;
    }

    this.isDownloading = true;
    this.downloadProgress = 0;

    // 优先使用缩略图路径作为键（通常不会变），如果没有则使用视频路径
    const videoKey = this.thumbnailPath || this.videoPath;
    if (videoKey) {
      // 触发全局事件
      triggerVideoDownloadRequest(videoKey);
    } else {
      console.error('[VideoPlayer] 无法请求下载：缺少视频路径');
    }

    // 模拟下载进度 (仅供测试使用)
    this.simulateDownloadProgress();
  }

  /**
   * 模拟下载进度 (仅供测试使用)
   */
  private simulateDownloadProgress() {
    let progress = 0;
    const interval = setInterval(() => {
      progress += 10;
      this.downloadProgress = progress;

      if (progress >= 100) {
        clearInterval(interval);

        // 在实际应用中，这里应该通过监听器或其他方式获取真实的下载路径
        // 现在我们只是模拟一下，假设下载完成后会通过路由参数更新videoPath
      }
    }, 500);
  }

  /**
   * 切换播放/暂停状态
   */
  private togglePlayPause() {
    try {
      console.info(`[VideoPlayer] 切换播放状态，当前状态: ${this.isPlaying ? '播放中' : '已暂停'}`);

      if (this.isPlaying) {
        // 暂停播放
        this.videoController.pause();
        console.info('[VideoPlayer] 已发送暂停指令');
      } else {
        // 开始播放
        this.videoController.start();
        console.info('[VideoPlayer] 已发送播放指令');
      }

      // 重置控制栏定时器
      this.resetControlsTimer();
    } catch (error) {
      console.error(`[VideoPlayer] 切换播放状态出错: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理错误
   */
  private handleError(message: string, error: Error) {
    this.hasError = true;
    this.isLoading = false;
    this.errorMessage = message;
    console.error(`[VideoPlayer] ${message}: ${JSON.stringify(error)}`);
  }

  /**
   * 格式化时间（秒转为 MM:SS 格式）
   */
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 设置控制栏的自动隐藏
   */
  private resetControlsTimer() {
    // 清除旧定时器
    if (this.controlsTimerId !== -1) {
      clearTimeout(this.controlsTimerId);
    }

    // 显示控制栏
    this.showControls = true;

    // 设置新定时器，5秒后隐藏控制栏
    this.controlsTimerId = setTimeout(() => {
      this.showControls = false;
    }, 5000);
  }

  /**
   * 开始检查视频时长
   * 有时onPrepared可能不会被正确触发，或者duration没有正确获取，此方法作为备份
   */
  private startCheckingDuration() {
    // 清除旧定时器
    if (this.durationCheckInterval !== -1) {
      clearInterval(this.durationCheckInterval);
      this.durationCheckInterval = -1;
    }

    let checkCount = 0;
    const MAX_CHECK_COUNT = 10; // 最多检查10次

    console.info('[VideoPlayer] 开始定期检查视频时长');

    // 每500ms检查一次视频时长
    this.durationCheckInterval = setInterval(() => {
      checkCount++;

      // 如果已经有时长了，或者达到最大检查次数，就停止检查
      if (this.duration > 0 || checkCount >= MAX_CHECK_COUNT) {
        console.info(`[VideoPlayer] 停止检查视频时长: duration=${this.duration}, checkCount=${checkCount}`);
        clearInterval(this.durationCheckInterval);
        this.durationCheckInterval = -1;
        return;
      }

      // 尝试使用播放时间来估算视频时长
      try {
        // 如果已经播放了一段时间，估算总时长
        if (this.currentTime > 0) {
          // 如果播放时间已经超过1秒，且时长仍为0，给一个默认值
          this.duration = Math.max(this.currentTime + 10, 60); // 至少比当前时间多10秒，或者最少60秒
          console.info(`[VideoPlayer] 估算视频时长: ${this.duration}秒 (基于当前时间: ${this.currentTime})`);
        }
      } catch (error) {
        console.error(`[VideoPlayer] 定时检查估算视频时长出错: ${JSON.stringify(error)}`);
      }
    }, 500); // 每500ms检查一次
  }
} 