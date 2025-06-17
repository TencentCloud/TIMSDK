import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';

/**
 * 音频播放回调接口
 */
export interface AudioPlayerCallbacks {
  onProgress?: (progress: number, position: number) => void;
  onPlayStateChange?: (isPlaying: boolean) => void;
  onError?: (error: string) => void;
}

/**
 * 音频播放管理器
 */
export class AudioPlayerManager {
  private avPlayer: media.AVPlayer | null = null;
  private isPlaying: boolean = false;
  private currentDuration: number = 0;
  private currentPosition: number = 0;
  private progressCallback?: (progress: number, position: number) => void;
  private playStateCallback?: (isPlaying: boolean) => void;
  private errorCallback?: (error: string) => void;

  /**
   * 设置回调函数
   */
  setCallbacks(callbacks: AudioPlayerCallbacks) {
    this.progressCallback = callbacks.onProgress;
    this.playStateCallback = callbacks.onPlayStateChange;
    this.errorCallback = callbacks.onError;
  }

  /**
   * 播放音频文件
   */
  async playAudio(filePath: string): Promise<void> {
    try {
      // 如果已经在播放，先停止
      if (this.avPlayer) {
        await this.stopAudio();
      }

      // 创建新的播放器实例
      this.avPlayer = await media.createAVPlayer();
      this.setupAVPlayerCallbacks();

      // 设置音频文件路径
      const fdPath = await this.getFileDescriptor(filePath);
      this.avPlayer.url = fdPath;

    } catch (error) {
      console.error(`[AudioPlayerManager] 播放音频失败: ${error}`);
      if (this.errorCallback) {
        this.errorCallback(`播放失败: ${error}`);
      }
    }
  }

  /**
   * 暂停播放
   */
  async pauseAudio(): Promise<void> {
    if (this.avPlayer && this.isPlaying) {
      try {
        await this.avPlayer.pause();
      } catch (error) {
        console.error(`[AudioPlayerManager] 暂停播放失败: ${error}`);
      }
    }
  }

  /**
   * 恢复播放
   */
  async resumeAudio(): Promise<void> {
    if (this.avPlayer && !this.isPlaying) {
      try {
        await this.avPlayer.play();
      } catch (error) {
        console.error(`[AudioPlayerManager] 恢复播放失败: ${error}`);
      }
    }
  }

  /**
   * 停止播放
   */
  async stopAudio(): Promise<void> {
    if (this.avPlayer) {
      try {
        await this.avPlayer.stop();
        await this.avPlayer.release();
        this.avPlayer = null;
        this.isPlaying = false;
        this.currentPosition = 0;
        if (this.playStateCallback) {
          this.playStateCallback(false);
        }
      } catch (error) {
        console.error(`[AudioPlayerManager] 停止播放失败: ${error}`);
      }
    }
  }

  /**
   * 获取播放状态
   */
  getPlayingState(): boolean {
    return this.isPlaying;
  }

  /**
   * 获取当前播放位置
   */
  getCurrentPosition(): number {
    return this.currentPosition;
  }

  /**
   * 获取音频总时长
   */
  getDuration(): number {
    return this.currentDuration;
  }

  /**
   * 设置AVPlayer回调
   */
  private setupAVPlayerCallbacks(): void {
    if (!this.avPlayer) return;

    // 错误回调
    this.avPlayer.on('error', (err: BusinessError) => {
      console.error(`[AudioPlayerManager] AVPlayer错误: ${err.code}, ${err.message}`);
      if (this.errorCallback) {
        this.errorCallback(`播放错误: ${err.message}`);
      }
      this.avPlayer?.reset();
    });

    // 状态变化回调
    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      console.info(`[AudioPlayerManager] 状态变化: ${state}`);
      
      switch (state) {
        case 'idle':
          console.info('[AudioPlayerManager] 播放器空闲状态');
          break;
        case 'initialized':
          console.info('[AudioPlayerManager] 播放器初始化完成');
          if (this.avPlayer) {
            this.avPlayer.audioRendererInfo = {
              usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
              rendererFlags: 0
            };
            await this.avPlayer.prepare();
          }
          break;
        case 'prepared':
          console.info('[AudioPlayerManager] 播放器准备完成');
          if (this.avPlayer) {
            this.currentDuration = this.avPlayer.duration;
            await this.avPlayer.play();
          }
          break;
        case 'playing':
          console.info('[AudioPlayerManager] 开始播放');
          this.isPlaying = true;
          if (this.playStateCallback) {
            this.playStateCallback(true);
          }
          this.startProgressTracking();
          break;
        case 'paused':
          console.info('[AudioPlayerManager] 播放暂停');
          this.isPlaying = false;
          if (this.playStateCallback) {
            this.playStateCallback(false);
          }
          break;
        case 'completed':
          console.info('[AudioPlayerManager] 播放完成');
          this.isPlaying = false;
          this.currentPosition = 0;
          if (this.playStateCallback) {
            this.playStateCallback(false);
          }
          if (this.progressCallback) {
            this.progressCallback(0, 0);
          }
          await this.avPlayer?.stop();
          break;
        case 'stopped':
          console.info('[AudioPlayerManager] 播放停止');
          this.isPlaying = false;
          if (this.playStateCallback) {
            this.playStateCallback(false);
          }
          break;
        case 'released':
          console.info('[AudioPlayerManager] 播放器已释放');
          this.avPlayer = null;
          break;
        default:
          console.info(`[AudioPlayerManager] 未知状态: ${state}`);
          break;
      }
    });
  }

  /**
   * 获取文件描述符
   */
  private async getFileDescriptor(filePath: string): Promise<string> {
    try {
      const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      return `fd://${file.fd}`;
    } catch (error) {
      throw new Error(`无法打开音频文件: ${filePath}`);
    }
  }

  /**
   * 开始进度跟踪
   */
  private startProgressTracking(): void {
    const updateProgress = () => {
      if (this.avPlayer && this.isPlaying) {
        this.currentPosition = this.avPlayer.currentTime;
        const progress = this.currentDuration > 0 ? (this.currentPosition / this.currentDuration) * 100 : 0;
        
        if (this.progressCallback) {
          this.progressCallback(progress, this.currentPosition);
        }

        // 继续跟踪进度
        setTimeout(updateProgress, 100);
      }
    };

    updateProgress();
  }
} 