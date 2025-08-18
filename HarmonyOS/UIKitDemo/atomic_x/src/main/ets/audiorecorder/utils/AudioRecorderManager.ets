import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
interface RecordingCallbacks {
  onDurationUpdate?: (duration: number) => void;
  onRecordingStart?: () => void;
  onRecordingStop?: (filePath: string, duration: number) => void;
  onRecordingCancel?: () => void;
  onError?: (error: string) => void;
  onPermissionDenied?: () => void;
}
interface RecordingState {
  isRecording: boolean;
  duration: number;
  filePath: string;
}
export class AudioRecorderManager {
  
  private isRecording: boolean = false;
  
  private recordingDuration: number = 0;
  
  private recordingTimer: number | null = null;
  
  private recordingFilePath: string = '';
  
  private avRecorder: media.AVRecorder | undefined = undefined;
  
  private audioFile: fs.File | null = null;
  
  private context: common.UIAbilityContext | null = null;
  
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: 100000, 
    audioChannels: 1, 
    audioCodec: media.CodecMimeType.AUDIO_AAC, 
    audioSampleRate: 16000, 
    fileFormat: media.ContainerFormatType.CFT_MPEG_4A, 
  };
  private avConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, 
    profile: this.avProfile,
    url: '', 
  };
  // Callback function
  private onDurationUpdate?: (duration: number) => void;
  private onRecordingStart?: () => void;
  private onRecordingStop?: (filePath: string, duration: number) => void;
  private onRecordingCancel?: () => void;
  private onError?: (error: string) => void;
  private onPermissionDenied?: () => void;

  
  constructor(context?: common.UIAbilityContext) {
    this.context = context || null;
  }

  
  setContext(context: common.UIAbilityContext) {
    this.context = context;
  }

  
  setCallbacks(callbacks: RecordingCallbacks) {
    this.onDurationUpdate = callbacks.onDurationUpdate;
    this.onRecordingStart = callbacks.onRecordingStart;
    this.onRecordingStop = callbacks.onRecordingStop;
    this.onRecordingCancel = callbacks.onRecordingCancel;
    this.onError = callbacks.onError;
    this.onPermissionDenied = callbacks.onPermissionDenied;
  }

  
  async startRecording(): Promise<boolean> {
    if (this.isRecording) {
      console.warn('[AudioRecorderManager] 已在录制中，无法重复开始');
      return false;
    }

    try {
      

      
      if (!this.context) {
        
        if (this.onError) {
          this.onError('缺少应用上下文，无法申请权限');
        }
        return false;
      }

      
      const hasPermission = await this.checkAndRequestMicrophonePermission();
      if (!hasPermission) {
        
        return false;
      }

      
      await this.cleanupRecorder();

      
      this.avRecorder = await media.createAVRecorder();
      

      
      this.setAudioRecorderCallback();

      
      await this.createAndSetFd();

      
      await this.waitForRecorderState('idle');

      
      
      await this.avRecorder.prepare(this.avConfig);

      
      await this.waitForRecorderState('prepared');

      
      
      await this.avRecorder.start();

      
      await this.waitForRecorderState('started');

      
      this.isRecording = true;
      this.recordingDuration = 0;

      
      this.recordingTimer = setInterval(() => {
        this.recordingDuration++;

        
        if (this.onDurationUpdate) {
          this.onDurationUpdate(this.recordingDuration);
        }

        
        if (this.recordingDuration >= 60) {
          this.stopRecording();
        }
      }, 1000);

      
      if (this.onRecordingStart) {
        this.onRecordingStart();
      }

      
      return true;
    } catch (error) {
      
      if (this.onError) {
        this.onError(`启动录制失败: ${error}`);
      }
      await this.cancelRecording();
      return false;
    }
  }

  
  async stopRecording(): Promise<boolean> {
    if (!this.isRecording) {
      console.warn('[AudioRecorderManager] 未在录制中，无法停止');
      return false;
    }

    try {
      

      
      if (this.recordingTimer) {
        clearInterval(this.recordingTimer);
        this.recordingTimer = null;
      }

      
      const duration = this.recordingDuration;

      
      if (duration < 1) {
        console.warn('[AudioRecorderManager] 录制时长太短，取消发送');
        await this.cancelRecording();
        return false;
      }

      
      if (this.avRecorder != undefined) {
        
        if (this.avRecorder.state === 'started' || this.avRecorder.state === 'paused') {
          
          await this.avRecorder.stop();
          await this.waitForRecorderState('stopped');
        }

        
        if (this.avRecorder.state === 'stopped') {
          
          await this.avRecorder.reset();
          await this.waitForRecorderState('idle');
        }

        
        
        await this.avRecorder.release();
        this.avRecorder = undefined;
      }

      
      if (this.audioFile) {
        fs.closeSync(this.audioFile);
        this.audioFile = null;
      }

      
      const filePath = this.recordingFilePath;

      
      this.isRecording = false;
      this.recordingDuration = 0;

      
      if (this.onRecordingStop) {
        this.onRecordingStop(filePath, duration);
      }

      
      return true;
    } catch (error) {
      
      if (this.onError) {
        this.onError(`停止录制失败: ${error}`);
      }
      await this.cancelRecording();
      return false;
    }
  }

  
  async cancelRecording(): Promise<boolean> {
    if (!this.isRecording) {
      console.warn('[AudioRecorderManager] 未在录制中，无法取消');
      return false;
    }

    try {
      

      
      if (this.recordingTimer) {
        clearInterval(this.recordingTimer);
        this.recordingTimer = null;
      }

      
      await this.cleanupRecorder();

      
      if (this.recordingFilePath) {
        try {
          if (fs.accessSync(this.recordingFilePath)) {
            fs.unlinkSync(this.recordingFilePath);
            
          }
        } catch (error) {
          console.warn(`[AudioRecorderManager] 删除临时文件失败: ${error}`);
        }
      }

      
      this.isRecording = false;
      this.recordingDuration = 0;
      this.recordingFilePath = '';

      
      if (this.onRecordingCancel) {
        this.onRecordingCancel();
      }

      
      return true;
    } catch (error) {
      
      if (this.onError) {
        this.onError(`取消录制失败: ${error}`);
      }
      return false;
    }
  }

  
  getRecordingState(): RecordingState {
    return {
      isRecording: this.isRecording,
      duration: this.recordingDuration,
      filePath: this.recordingFilePath
    };
  }

  
  checkRecordingFileExists(filePath: string): boolean {
    try {
      return fs.accessSync(filePath);
    } catch (error) {
      console.warn(`[AudioRecorderManager] 检查文件存在性失败: ${error}`);
      return false;
    }
  }

  
  getRecordingFileSize(filePath: string): number {
    try {
      const stat = fs.statSync(filePath);
      return stat.size;
    } catch (error) {
      console.warn(`[AudioRecorderManager] 获取文件大小失败: ${error}`);
      return 0;
    }
  }

  
  async destroy() {
    if (this.isRecording) {
      await this.cancelRecording();
    }

    await this.cleanupRecorder();
  }

  
  private async checkAndRequestMicrophonePermission(): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const tokenId = bundleInfo.appInfo.accessTokenId;

      
      const permission: Permissions = 'ohos.permission.MICROPHONE';
      const grantStatus = await atManager.checkAccessToken(tokenId, permission);

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        
        return true;
      }

      

      
      const requestResult = await atManager.requestPermissionsFromUser(this.context!, [permission]);

      if (requestResult.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        
        return true;
      } else {
        console.warn('[AudioRecorderManager] 麦克风权限申请被拒绝');
        if (this.onPermissionDenied) {
          this.onPermissionDenied();
        }
        return false;
      }
    } catch (error) {
      
      if (this.onError) {
        this.onError(`权限检查失败: ${error}`);
      }
      return false;
    }
  }

  
  private async createAndSetFd(): Promise<void> {
    try {
      
      this.recordingFilePath = this.generateRecordingFilePath();

      
      await this.ensureDirectoryExists(this.recordingFilePath);

      
      this.audioFile = fs.openSync(this.recordingFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

      
      this.avConfig.url = 'fd://' + this.audioFile.fd;

      
    } catch (error) {
      
    }
  }

  
  private setAudioRecorderCallback() {
    if (this.avRecorder != undefined) {
      
      this.avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        
      });

      
      this.avRecorder.on('error', (err: BusinessError) => {
        
        if (this.onError) {
          this.onError(`录制器错误: ${err.message}`);
        }
        this.cancelRecording();
      });
    }
  }

  
  private generateRecordingFilePath(): string {
    const timestamp = Date.now();
    const fileName = `voice_record_${timestamp}.m4a`;

    const appContext = getContext().getApplicationContext();
    const voiceDir = `${appContext.cacheDir}/com_tencent_imsdk_data/voice`;
    return `${voiceDir}/${fileName}`;
    if (!this.context) {
      console.warn('[AudioRecorderManager] 缺少应用上下文，使用默认路径');
      try {
        const appContext = getContext().getApplicationContext();
        const voiceDir = `${appContext.cacheDir}/com_tencent_imsdk_data/voice`;
        return `${voiceDir}/${fileName}`;
      } catch (error) {
        
        return `/data/storage/el2/base/haps/entry/files/${fileName}`;
      }
    }

    // return `${this.context.cacheDir}/${fileName}`;
  }

  
  private async ensureDirectoryExists(filePath: string): Promise<void> {
    try {
      const dir = filePath.substring(0, filePath.lastIndexOf('/'));
      if (!fs.accessSync(dir)) {
        
        fs.mkdirSync(dir, true);
        
      }
    } catch (error) {
      console.warn(`[AudioRecorderManager] 创建目录失败: ${error}`);
      
      const parentDir = filePath.substring(0, filePath.lastIndexOf('/'));
      const grandParentDir = parentDir.substring(0, parentDir.lastIndexOf('/'));
      if (fs.accessSync(grandParentDir)) {
        
      }
    }
  }

  
  private async waitForRecorderState(targetState: media.AVRecorderState, timeout: number = 5000): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.avRecorder) {
        reject(new Error('录制器实例不存在'));
        return;
      }

      
      if (this.avRecorder.state === targetState) {
        
        resolve();
        return;
      }

      const timer = setTimeout(() => {
        reject(new Error(`等待录制器状态 ${targetState} 超时`));
      }, timeout);

      const stateChangeHandler = (state: media.AVRecorderState) => {
        if (state === targetState) {
          clearTimeout(timer);
          if (this.avRecorder) {
            this.avRecorder.off('stateChange', stateChangeHandler);
          }
          
          resolve();
        }
      };

      this.avRecorder.on('stateChange', stateChangeHandler);
    });
  }

  
  private async cleanupRecorder(): Promise<void> {
    try {
      
      if (this.avRecorder != undefined) {
        try {
          
          const currentState = this.avRecorder.state;
          

          if (currentState === 'started' || currentState === 'paused') {
            
            await this.avRecorder.stop();
            await this.waitForRecorderState('stopped');
          }

          if (currentState === 'stopped' || currentState === 'prepared') {
            
            await this.avRecorder.reset();
            await this.waitForRecorderState('idle');
          }

          
          await this.avRecorder.release();
        } catch (error) {
          console.warn(`[AudioRecorderManager] 清理录制器时出错: ${error}`);
          
          try {
            await this.avRecorder.release();
          } catch (releaseError) {
            console.warn(`[AudioRecorderManager] 强制释放录制器失败: ${releaseError}`);
          }
        }

        this.avRecorder = undefined;
      }

      
      if (this.audioFile) {
        try {
          fs.closeSync(this.audioFile);
        } catch (error) {
          console.warn(`[AudioRecorderManager] 关闭文件时出错: ${error}`);
        }
        this.audioFile = null;
      }
    } catch (error) {
      console.warn(`[AudioRecorderManager] 清理资源时出错: ${error}`);
    }
  }
} 