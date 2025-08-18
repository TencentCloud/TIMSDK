import { MessageInfo, MessageStatus, MessageBody, MessageListStore, MessageResourceType } from 'chatengine';
import { ImageSizeUtil, ThemeState, TimeUtil } from '../../basecomponent/Index';
import { AudioPlayer, AudioPlayerCallbacks } from '../../audioplayer/Index';

@Component
export struct SoundMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @State isPlaying: boolean = false;
  @State progress: number = 0;
  @State currentPosition: number = 0;
  @ObjectLink messageListStore: MessageListStore;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  private audioPlayer: AudioPlayer = new AudioPlayer();

  aboutToAppear() {

    const callbacks: AudioPlayerCallbacks = {
      onProgress: (progress: number, position: number) => {
        this.progress = progress;
        this.currentPosition = position;
      },
      onPlayStateChange: (isPlaying: boolean) => {
        this.isPlaying = isPlaying;
      },
      onError: (error: string) => {

        this.isPlaying = false;
        this.progress = 0;
      }
    };

    this.audioPlayer.setCallbacks(callbacks);
  }

  aboutToDisappear() {

    this.audioPlayer.stopAudio();
  }

  build() {
    Column() {
      Row() {

        Image(this.isPlaying ? $rawfile('messagelist/voice_pause.png') : $rawfile('messagelist/voice_play.svg'))
          .width(12)
          .height(12)
          .fillColor(this.message?.isSelf ? this.themeState.colors.textColorAntiSecondary :
          this.themeState.colors.textColorPrimary)
          .margin({ left: 16 })
          .onClick(() => {
            this.togglePlay();
          })

        Row() {
          ForEach([0, 1, 2, 3, 4, 5, 6], (item: number) => {
            Image($rawfile('messagelist/voice_play_animation.svg'))
              .width(21)
              .height(21)
              .margin({ left: 4 })
              .fillColor(this.message?.isSelf ? this.themeState.colors.textColorAntiSecondary :
              this.themeState.colors.textColorPrimary)
              .opacity(this.progress > (item * 14.28) ? 1 : 0.3)
          })
        }
        .margin({ left: 8, bottom: 4 })

        Text(this.formatDuration(this.messageBody?.soundDuration || 0))
          .fontSize(12)
          .fontColor(this.message?.isSelf ? this.themeState.colors.textColorAntiSecondary :
          this.themeState.colors.textColorPrimary)
          .margin({ left: 8 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Row() {
        if (this.message?.status === MessageStatus.sending) {
          LoadingProgress()
            .width(12)
            .height(12)
            .margin({ right: 4 })
        }
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
    .width('100%')
  }

  private async togglePlay() {
    try {
      if (this.isPlaying) {

        await this.audioPlayer.pauseAudio();
      } else {

        const soundPath = this.messageBody?.soundPath;
        if (!soundPath) {

          return;
        }


        if (this.audioPlayer.getCurrentPosition() > 0) {

          await this.audioPlayer.resumeAudio();
        } else {

          await this.audioPlayer.playAudio(soundPath);
        }
      }
    } catch (error) {

      this.isPlaying = false;
      this.progress = 0;
    }
  }

  private formatDuration(milliseconds: number): string {
    const seconds = Math.floor(milliseconds);
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  private getMessageStatusIcon(): Resource {
    if (this.message?.status === MessageStatus.sendSuccess) {
      return $rawfile('messagelist/msg_status_send_succ.png');
    } else {
      return $rawfile('messagelist/icon_message_send_error.svg');
    }
  }
}

@Builder
export function SoundMessageView(messageData: MessageInfo, MessageListStore: MessageListStore) {
  if (messageData && messageData.messageBody) {
    SoundMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListStore: MessageListStore
    })
  }
}