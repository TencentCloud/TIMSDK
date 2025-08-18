import router from '@ohos.router';
import common from '@ohos.app.ability.common';
// import { ThemeState } from '../../basecomponent/Index';
import media from '@ohos.multimedia.media';
export enum MediaType {
  IMAGE = 0, 
  VIDEO = 1 
}
export interface MediaItem {
  path: string; 
  type: MediaType; 
  videoPath?: string; 
}
export interface DownloadCallback {
  onDownload(): void;
}
export class VideoPlayerListener {
  
  onVideoDownloadRequest(videoUrl?: string): void {
  }
}
let globalListeners: Map<string, VideoPlayerListener> = new Map();
export function setVideoPlayerListener(videoUrl: string, listener: VideoPlayerListener): void {
  globalListeners.set(videoUrl, listener);
  
}
export function clearVideoPlayerListener(videoUrl?: string): void {
  if (videoUrl) {
    globalListeners.delete(videoUrl);
    
  } else {
    globalListeners.clear();
    
  }
}
export function triggerVideoDownloadRequest(videoUrl: string): void {
  const listener = globalListeners.get(videoUrl);
  if (listener) {
    try {
      if (typeof listener.onVideoDownloadRequest === 'function') {
        listener.onVideoDownloadRequest(videoUrl);
        
      } else {
        
      }
    } catch (error) {
      
    }
  } else {
    
  }
}
interface PreparedEvent {
  duration: number;
  width?: number;
  height?: number;
}
interface UpdateTimeEvent {
  time: number;
}
@Entry({ routeName: 'VideoPlayer' })
@Component
export struct VideoPlayer {
  // @StorageLink('ThemeState') ThemeState: ThemeState = ThemeState.getInstance();
  
  @State thumbnailPath: string = '';
  
  @State videoPath: string = '';
  
  @State mediaType: MediaType = MediaType.IMAGE;
  
  @State isLoading: boolean = true;
  
  @State isPlaying: boolean = false;
  
  @State currentTime: number = 0;
  
  @State duration: number = 0;
  
  @State showControls: boolean = true;
  
  @State hasError: boolean = false;
  
  @State errorMessage: string = '';
  
  @State isDownloading: boolean = false;
  
  @State downloadProgress: number = 0;
  
  private videoController: VideoController = new VideoController();
  
  private controlsTimerId: number = -1;
  
  private downloadCheckInterval: number = -1;
  
  private durationCheckInterval: number = -1;
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    
    const params: object = router.getParams();
    if (params) {
      try {
        
        const routeParams = params as Record<string, object>;

        
        if (routeParams.mediaItem && typeof routeParams.mediaItem === 'object') {
          const mediaItem = routeParams.mediaItem as MediaItem;
          this.thumbnailPath = mediaItem.path || '';
          this.mediaType = (mediaItem.type !== undefined) ? mediaItem.type : MediaType.IMAGE;
          this.videoPath = mediaItem.videoPath || '';

          console.info(`[VideoPlayer] Media item loaded - type: ${this.mediaType}, thumbnail: ${this.thumbnailPath}, videoPath: ${this.videoPath}`);
        } else {
          
          this.handleError('无效的媒体项参数', new Error('无效参数'));
          return;
        }
      } catch (error) {
        
        this.handleError('解析参数错误', error as Error);
        return;
      }
    } else {
      
      this.handleError('没有参数', new Error('无参数'));
      return;
    }

    
    if (this.mediaType === MediaType.VIDEO) {
      if (this.videoPath) {
        
        this.isLoading = true; 

        
        this.startCheckingDuration();
      } else {
        
        this.isLoading = false; 
        this.startCheckingForVideoPath();
      }
    } else {
      
      
      this.isLoading = false;
    }
  }

  aboutToDisappear() {
    
    if (this.controlsTimerId !== -1) {
      clearTimeout(this.controlsTimerId);
    }
    
    if (this.downloadCheckInterval !== -1) {
      clearInterval(this.downloadCheckInterval);
    }
    
    if (this.durationCheckInterval !== -1) {
      clearInterval(this.durationCheckInterval);
    }

    
  }

  
  @Builder
  DownloadingStateBuilder() {
    Column() {
      
      Progress({
        value: this.downloadProgress,
        total: 100,
        type: ProgressType.Ring
      })
        .width(80)
        .height(80)
        .color(Color.White)

      
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

  
  @Builder
  ControlsBuilder() {
    Column() {
      
      Row() {
        Image($rawfile('videoplayer/ic_back.svg'))
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

      
      Column() {
        
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
              

              
              this.currentTime = value;

              
              const seekTimeMs = Math.floor(value); 
              this.videoController.setCurrentTime(seekTimeMs);
              
            } catch (error) {
              
            }

            this.resetControlsTimer();
          })

        
        Row() {
          
          Image(this.isPlaying ? $rawfile('videoplayer/ic_pause.svg') : $rawfile('videoplayer/ic_play.svg'))
            .width(32)
            .height(32)
            .fillColor(Color.White)
            .onClick(() => {
              this.onPlayButtonClick();
            })

          
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
      
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')

      if (this.mediaType === MediaType.IMAGE || (this.mediaType === MediaType.VIDEO && !this.videoPath)) {
        
        Stack({ alignContent: Alignment.TopStart }) {
          
          Image(this.thumbnailPath)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              
              this.showControls = !this.showControls;
              if (this.showControls) {
                this.resetControlsTimer();
              } else if (this.controlsTimerId !== -1) {
                clearTimeout(this.controlsTimerId);
              }
            })

          
          Column() {
            
            Row() {
              Image($rawfile('videoplayer/ic_back.svg'))
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

            
            if (this.mediaType === MediaType.VIDEO) {
              Row() {
                Image($rawfile('videoplayer/ic_play.svg'))
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

          
          if (this.isDownloading) {
            this.DownloadingStateBuilder()
          }
        }
      } else if (this.hasError) {
        
        this.ErrorStateBuilder()
      } else {
        
        
        if (this.videoPath) {
          Stack({ alignContent: Alignment.Center }) {
            
            Video({
              src: this.videoPath,
              previewUri: this.thumbnailPath,
              controller: this.videoController
            })
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .autoPlay(true)
              .controls(false)
              .onStart(() => {
                this.isPlaying = true;
                this.resetControlsTimer();
                
              })
              .onPause(() => {
                this.isPlaying = false;
                
              })
              .onFinish(() => {
                this.isPlaying = false;
                this.currentTime = this.duration;
                

                
                this.showControls = true;
                
                if (this.controlsTimerId !== -1) {
                  clearTimeout(this.controlsTimerId);
                  this.controlsTimerId = -1;
                }
              })
              .onError(() => {
                this.handleError('视频播放错误', new Error('Video组件播放错误'));
                
              })
              .onPrepared((event: PreparedEvent) => {
                

                
                if (event && typeof event.duration === 'number' && event.duration > 0) {
                  this.duration = Math.floor(event.duration); 
                  
                } else {
                  console.warn(`[VideoPlayer] 视频准备事件中未返回有效时长: ${JSON.stringify(event)}`);
                  
                  try {
                    
                    if (this.duration === 0) {
                      
                      this.duration = 60; 
                      
                    }
                  } catch (error) {
                    
                  }
                }

                this.isLoading = false;
              })
              .onUpdate((event: UpdateTimeEvent) => {
                
                if (!event || typeof event.time !== 'number') {
                  console.warn(`[VideoPlayer] 收到无效的时间更新事件: ${JSON.stringify(event)}`);
                  return;
                }

                
                const newTime = Math.floor(event.time); 
                if (newTime !== this.currentTime) {
                  this.currentTime = newTime;
                  
                }

                
                if (this.duration === 0 || (this.duration === 60 && this.currentTime > 30)) {
                  const estimatedDuration = Math.max(this.currentTime + 30, 60);
                  if (estimatedDuration !== this.duration) {
                    this.duration = estimatedDuration;
                    
                  }
                }
              })
              .onClick(() => {
                
                this.showControls = !this.showControls;
                if (this.showControls) {
                  this.resetControlsTimer();
                } else if (this.controlsTimerId !== -1) {
                  clearTimeout(this.controlsTimerId);
                }
              })

            
            if (this.isLoading) {
              this.LoadingStateBuilder()
            }
          }
        }
      }

      
      if (this.mediaType === MediaType.VIDEO && !this.isLoading && !this.hasError && this.videoPath) {
        this.ControlsBuilder()
      }
    }
    .width('100%')
    .height('100%')
  }

  
  public onDownloadComplete(videoPath: string) {
    

    
    this.setVideoPath(videoPath);
  }

  
  public updateDownloadProgress(progress: number) {
    if (this.isDownloading) {
      this.downloadProgress = progress;
    }
  }

  
  public setVideoPath(path: string) {
    

    
    this.videoPath = path;
    this.isDownloading = false;
    this.downloadProgress = 100;

    
    this.isLoading = true;
    this.currentTime = 0;
    this.isPlaying = false;
    this.hasError = false;

    
    
  }

  
  private startCheckingForVideoPath() {
    

    
    let checkCount = 0;
    const MAX_CHECK_COUNT = 30; 

    
    this.downloadCheckInterval = setInterval(() => {
      checkCount++;
      

      
      if (checkCount >= MAX_CHECK_COUNT) {
        
        clearInterval(this.downloadCheckInterval);
        this.downloadCheckInterval = -1;
        return;
      }

      
      const params = router.getParams() as Record<string, object>;
      if (params && params.mediaItem) {
        const mediaItem = params.mediaItem as MediaItem;

        
        if (mediaItem.videoPath && mediaItem.videoPath !== this.videoPath) {
          

          
          clearInterval(this.downloadCheckInterval);
          this.downloadCheckInterval = -1;

          
          this.setVideoPath(mediaItem.videoPath);
        }
      }
    }, 1000);
  }

  
  private onPlayButtonClick() {
    
    if (this.mediaType !== MediaType.VIDEO) {
      return;
    }

    
    if (!this.videoPath) {
      
      this.requestVideoDownload();
      return;
    }

    
    this.togglePlayPause();
  }

  
  private requestVideoDownload() {
    if (this.isDownloading) {
      return;
    }

    this.isDownloading = true;
    this.downloadProgress = 0;

    
    const videoKey = this.thumbnailPath || this.videoPath;
    if (videoKey) {
      
      triggerVideoDownloadRequest(videoKey);
    } else {
      
    }

    
    this.simulateDownloadProgress();
  }

  
  private simulateDownloadProgress() {
    let progress = 0;
    const interval = setInterval(() => {
      progress += 10;
      this.downloadProgress = progress;

      if (progress >= 100) {
        clearInterval(interval);

        
        
      }
    }, 500);
  }

  
  private togglePlayPause() {
    try {
      

      if (this.isPlaying) {
        
        this.videoController.pause();
        
      } else {
        
        this.videoController.start();
        
      }

      
      this.resetControlsTimer();
    } catch (error) {
      
    }
  }

  
  private handleError(message: string, error: Error) {
    this.hasError = true;
    this.isLoading = false;
    this.errorMessage = message;
    console.error(`[VideoPlayer] ${message}: ${JSON.stringify(error)}`);
  }

  
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  
  private resetControlsTimer() {
    
    if (this.controlsTimerId !== -1) {
      clearTimeout(this.controlsTimerId);
    }

    
    this.showControls = true;

    
    this.controlsTimerId = setTimeout(() => {
      this.showControls = false;
    }, 5000);
  }

  
  private startCheckingDuration() {
    
    if (this.durationCheckInterval !== -1) {
      clearInterval(this.durationCheckInterval);
      this.durationCheckInterval = -1;
    }

    let checkCount = 0;
    const MAX_CHECK_COUNT = 10; 

    

    
    this.durationCheckInterval = setInterval(() => {
      checkCount++;

      
      if (this.duration > 0 || checkCount >= MAX_CHECK_COUNT) {
        
        clearInterval(this.durationCheckInterval);
        this.durationCheckInterval = -1;
        return;
      }

      
      try {
        
        if (this.currentTime > 0) {
          
          this.duration = Math.max(this.currentTime + 10, 60); 
          
        }
      } catch (error) {
        
      }
    }, 500); 
  }
} 