import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';
export interface AudioPlayerCallbacks {
  onProgress?: (progress: number, position: number) => void;
  onPlayStateChange?: (isPlaying: boolean) => void;
  onError?: (error: string) => void;
}
export class AudioPlayer {
  private avPlayer: media.AVPlayer | null = null;
  private isPlaying: boolean = false;
  private currentDuration: number = 0;
  private currentPosition: number = 0;
  private progressCallback?: (progress: number, position: number) => void;
  private playStateCallback?: (isPlaying: boolean) => void;
  private errorCallback?: (error: string) => void;

  
  setCallbacks(callbacks: AudioPlayerCallbacks) {
    this.progressCallback = callbacks.onProgress;
    this.playStateCallback = callbacks.onPlayStateChange;
    this.errorCallback = callbacks.onError;
  }

  
  async playAudio(filePath: string): Promise<void> {
    try {
      
      if (this.avPlayer) {
        await this.stopAudio();
      }

      
      this.avPlayer = await media.createAVPlayer();
      this.setupAVPlayerCallbacks();

      
      const fdPath = await this.getFileDescriptor(filePath);
      this.avPlayer.url = fdPath;

    } catch (error) {
      
      if (this.errorCallback) {
        this.errorCallback(`播放失败: ${error}`);
      }
    }
  }

  
  async pauseAudio(): Promise<void> {
    if (this.avPlayer && this.isPlaying) {
      try {
        await this.avPlayer.pause();
      } catch (error) {
        
      }
    }
  }

  
  async resumeAudio(): Promise<void> {
    if (this.avPlayer && !this.isPlaying) {
      try {
        await this.avPlayer.play();
      } catch (error) {
        
      }
    }
  }

  
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
        
      }
    }
  }

  
  getPlayingState(): boolean {
    return this.isPlaying;
  }

  
  getCurrentPosition(): number {
    return this.currentPosition;
  }

  
  getDuration(): number {
    return this.currentDuration;
  }

  
  private setupAVPlayerCallbacks(): void {
    if (!this.avPlayer) {
      return;
    }

    
    this.avPlayer.on('error', (err: BusinessError) => {
      
      if (this.errorCallback) {
        this.errorCallback(`播放错误: ${err.message}`);
      }
      this.avPlayer?.reset();
    });

    
    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      

      switch (state) {
        case 'idle':
          
          break;
        case 'initialized':
          
          if (this.avPlayer) {
            this.avPlayer.audioRendererInfo = {
              usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
              rendererFlags: 0
            };
            await this.avPlayer.prepare();
          }
          break;
        case 'prepared':
          
          if (this.avPlayer) {
            this.currentDuration = this.avPlayer.duration;
            await this.avPlayer.play();
          }
          break;
        case 'playing':
          
          this.isPlaying = true;
          if (this.playStateCallback) {
            this.playStateCallback(true);
          }
          this.startProgressTracking();
          break;
        case 'paused':
          
          this.isPlaying = false;
          if (this.playStateCallback) {
            this.playStateCallback(false);
          }
          break;
        case 'completed':
          
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
          
          this.isPlaying = false;
          if (this.playStateCallback) {
            this.playStateCallback(false);
          }
          break;
        case 'released':
          
          this.avPlayer = null;
          break;
        default:
          
          break;
      }
    });
  }

  
  private async getFileDescriptor(filePath: string): Promise<string> {
    try {
      const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      return `fd://${file.fd}`;
    } catch (error) {
      throw new Error(`无法打开音频文件: ${filePath}`);
    }
  }

  
  private startProgressTracking(): void {
    const updateProgress = () => {
      if (this.avPlayer && this.isPlaying) {
        this.currentPosition = this.avPlayer.currentTime;
        const progress = this.currentDuration > 0 ? (this.currentPosition / this.currentDuration) * 100 : 0;

        if (this.progressCallback) {
          this.progressCallback(progress, this.currentPosition);
        }

        
        setTimeout(updateProgress, 100);
      }
    };

    updateProgress();
  }
} 