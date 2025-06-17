import {
  MessageInfo,
  MessageStatus,
  MessageBody,
  MessageListState,
  MessageResourceType
} from 'chatengine/src/main/ets/pages/MessageListState';
import { ImageSizeUtil, ThemeManager, TimeUtil } from 'basecomponent';
import { AudioPlayerManager, AudioPlayerCallbacks } from 'audioplayer';

@Component
export struct SoundMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @State isPlaying: boolean = false;
  @State progress: number = 0; // 播放进度 0-100
  @State currentPosition: number = 0; // 当前播放位置（毫秒）
  @ObjectLink messageListState: MessageListState;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 音频播放管理器
  private audioPlayerManager: AudioPlayerManager = new AudioPlayerManager();

  aboutToAppear() {
    // 设置音频播放回调
    const callbacks: AudioPlayerCallbacks = {
      onProgress: (progress: number, position: number) => {
        this.progress = progress;
        this.currentPosition = position;
      },
      onPlayStateChange: (isPlaying: boolean) => {
        this.isPlaying = isPlaying;
      },
      onError: (error: string) => {
        console.error(`[SoundMessageView] 播放错误: ${error}`);
        this.isPlaying = false;
        this.progress = 0;
      }
    };

    this.audioPlayerManager.setCallbacks(callbacks);
  }

  aboutToDisappear() {
    // 组件销毁时停止播放
    this.audioPlayerManager.stopAudio();
  }

  build() {
    Column() {
      Row() {
        // 左侧播放按钮
        Image(this.isPlaying ? $r('app.media.voice_pause') : $r('app.media.voice_play'))
          .width(12)
          .height(12)
          .margin({ left: 16 })
          .onClick(() => {
            this.togglePlay();
          })

        // 音频波形显示
        Row() {
          ForEach([0, 1, 2, 3, 4, 5, 6], (item: number) => {
            Image($r('app.media.voice_play_animation'))
              .width(21)
              .height(21)
              .margin({ left: 4 })
              .opacity(this.progress > (item * 14.28) ? 1 : 0.3) // 7个波形条，每个约14.28%
          })
        }
        .margin({ left: 8, bottom: 4 })

        // 时长显示
        Text(this.formatDuration(this.messageBody?.soundDuration || 0))
          .fontSize(12)
          .fontColor(this.themeManager.currentTheme.textColorAntiSecondary)
          .margin({ left: 8 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Row() {
        // 右侧状态图标（未读/已读）
        Image(this.getMessageStatusIcon())
          .width(12)
          .height(12)

        Text(TimeUtil.formatRelativeTime(this.message?.dateTime?.getTime() ?? 0))
          .fontSize(12)
          .fontColor(this.themeManager.currentTheme.textColorAntiSecondary)
      }
      .justifyContent(FlexAlign.End)
      .alignSelf(ItemAlign.End)
      .margin({ top: 4, right: 16 })
      .width('100%')
    }
    .margin({
      top: 8,
      bottom: 8,
    })
    .borderRadius(8)
    .margin(10)
    .width('100%')
  }

  /**
   * 切换播放状态
   */
  private async togglePlay() {
    try {
      if (this.isPlaying) {
        // 当前正在播放，暂停播放
        await this.audioPlayerManager.pauseAudio();
      } else {
        // 当前未播放，开始播放
        const soundPath = this.messageBody?.soundPath;
        if (!soundPath) {
          console.error('[SoundMessageView] 音频文件路径为空');
          return;
        }

        // 检查是否已经有播放器实例且处于暂停状态
        if (this.audioPlayerManager.getCurrentPosition() > 0) {
          // 恢复播放
          await this.audioPlayerManager.resumeAudio();
        } else {
          // 开始新的播放
          await this.audioPlayerManager.playAudio(soundPath);
        }
      }
    } catch (error) {
      console.error(`[SoundMessageView] 播放操作失败: ${error}`);
      this.isPlaying = false;
      this.progress = 0;
    }
  }

  /**
   * 格式化时长显示（毫秒 → 00:00）
   */
  private formatDuration(milliseconds: number): string {
    const seconds = Math.floor(milliseconds);
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 获取消息状态图标
   */
  private getMessageStatusIcon(): Resource {
    if (this.message?.status === MessageStatus.sendSuccess) {
      return $r('app.media.msg_status_send_succ');
    } else {
      return $r('app.media.icon_message_send_error');
    }
  }
}

@Builder
export function SoundMessageView(messageData: MessageInfo, messageListState: MessageListState) {
  if (messageData && messageData.messageBody) {
    SoundMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListState: messageListState
    })
  }
}