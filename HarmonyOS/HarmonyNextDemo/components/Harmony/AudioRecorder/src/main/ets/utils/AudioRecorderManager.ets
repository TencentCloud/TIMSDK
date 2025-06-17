import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';

/**
 * 录制回调接口
 */
interface RecordingCallbacks {
  onDurationUpdate?: (duration: number) => void;
  onRecordingStart?: () => void;
  onRecordingStop?: (filePath: string, duration: number) => void;
  onRecordingCancel?: () => void;
  onError?: (error: string) => void;
  onPermissionDenied?: () => void;
}

/**
 * 录制状态接口
 */
interface RecordingState {
  isRecording: boolean;
  duration: number;
  filePath: string;
}

/**
 * 语音录制管理器
 */
export class AudioRecorderManager {
  // 录制状态
  private isRecording: boolean = false;
  // 录制时长
  private recordingDuration: number = 0;
  // 录制定时器
  private recordingTimer: number | null = null;
  // 录制文件路径
  private recordingFilePath: string = '';
  // 音频录制器实例
  private avRecorder: media.AVRecorder | undefined = undefined;
  // 音频文件
  private audioFile: fs.File | null = null;
  // 应用上下文
  private context: common.UIAbilityContext | null = null;
  // 录制配置
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: 100000, // 音频比特率
    audioChannels: 1, // 音频声道数（单声道）
    audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式
    audioSampleRate: 16000, // 音频采样率
    fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式 M4A
  };
  private avConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，麦克风
    profile: this.avProfile,
    url: '', // 将在创建文件时设置
  };
  // 回调函数
  private onDurationUpdate?: (duration: number) => void;
  private onRecordingStart?: () => void;
  private onRecordingStop?: (filePath: string, duration: number) => void;
  private onRecordingCancel?: () => void;
  private onError?: (error: string) => void;
  private onPermissionDenied?: () => void;

  /**
   * 构造函数
   */
  constructor(context?: common.UIAbilityContext) {
    this.context = context || null;
  }

  /**
   * 设置应用上下文
   */
  setContext(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 设置回调函数
   */
  setCallbacks(callbacks: RecordingCallbacks) {
    this.onDurationUpdate = callbacks.onDurationUpdate;
    this.onRecordingStart = callbacks.onRecordingStart;
    this.onRecordingStop = callbacks.onRecordingStop;
    this.onRecordingCancel = callbacks.onRecordingCancel;
    this.onError = callbacks.onError;
    this.onPermissionDenied = callbacks.onPermissionDenied;
  }

  /**
   * 开始录制
   */
  async startRecording(): Promise<boolean> {
    if (this.isRecording) {
      console.warn('[AudioRecorderManager] 已在录制中，无法重复开始');
      return false;
    }

    try {
      console.info('[AudioRecorderManager] 开始语音录制');

      // 1. 检查应用上下文
      if (!this.context) {
        console.error('[AudioRecorderManager] 缺少应用上下文，无法申请权限');
        if (this.onError) {
          this.onError('缺少应用上下文，无法申请权限');
        }
        return false;
      }

      // 2. 检查和申请麦克风权限
      const hasPermission = await this.checkAndRequestMicrophonePermission();
      if (!hasPermission) {
        console.error('[AudioRecorderManager] 麦克风权限未获得，无法开始录制');
        return false;
      }

      // 确保完全清理之前的录制器实例
      await this.cleanupRecorder();

      // 1. 创建录制实例
      this.avRecorder = await media.createAVRecorder();
      console.info(`[AudioRecorderManager] 录制器创建成功，当前状态: ${this.avRecorder.state}`);

      // 2. 设置回调（在准备之前设置）
      this.setAudioRecorderCallback();

      // 3. 创建录制文件并设置 URL
      await this.createAndSetFd();

      // 4. 等待录制器进入 idle 状态
      await this.waitForRecorderState('idle');

      // 5. 配置录制参数完成准备工作
      console.info('[AudioRecorderManager] 开始准备录制器');
      await this.avRecorder.prepare(this.avConfig);

      // 6. 等待录制器进入 prepared 状态
      await this.waitForRecorderState('prepared');

      // 7. 开始录制
      console.info('[AudioRecorderManager] 开始录制');
      await this.avRecorder.start();

      // 8. 等待录制器进入 started 状态
      await this.waitForRecorderState('started');

      // 设置录制状态
      this.isRecording = true;
      this.recordingDuration = 0;

      // 启动录制计时器
      this.recordingTimer = setInterval(() => {
        this.recordingDuration++;

        // 通知时长更新
        if (this.onDurationUpdate) {
          this.onDurationUpdate(this.recordingDuration);
        }

        // 最大录制时长限制（例如60秒）
        if (this.recordingDuration >= 60) {
          this.stopRecording();
        }
      }, 1000);

      // 通知录制开始
      if (this.onRecordingStart) {
        this.onRecordingStart();
      }

      console.info('[AudioRecorderManager] 语音录制已启动');
      return true;
    } catch (error) {
      console.error(`[AudioRecorderManager] 启动语音录制失败: ${error}`);
      if (this.onError) {
        this.onError(`启动录制失败: ${error}`);
      }
      await this.cancelRecording();
      return false;
    }
  }

  /**
   * 停止录制并发送
   */
  async stopRecording(): Promise<boolean> {
    if (!this.isRecording) {
      console.warn('[AudioRecorderManager] 未在录制中，无法停止');
      return false;
    }

    try {
      console.info('[AudioRecorderManager] 停止语音录制');

      // 停止计时器
      if (this.recordingTimer) {
        clearInterval(this.recordingTimer);
        this.recordingTimer = null;
      }

      // 获取录制时长
      const duration = this.recordingDuration;

      // 检查录制时长是否有效（至少1秒）
      if (duration < 1) {
        console.warn('[AudioRecorderManager] 录制时长太短，取消发送');
        await this.cancelRecording();
        return false;
      }

      // 停止录制
      if (this.avRecorder != undefined) {
        // 1. 停止录制（只有在 started 或 paused 状态下才能停止）
        if (this.avRecorder.state === 'started' || this.avRecorder.state === 'paused') {
          console.info('[AudioRecorderManager] 停止录制器');
          await this.avRecorder.stop();
          await this.waitForRecorderState('stopped');
        }

        // 2. 重置录制器
        if (this.avRecorder.state === 'stopped') {
          console.info('[AudioRecorderManager] 重置录制器');
          await this.avRecorder.reset();
          await this.waitForRecorderState('idle');
        }

        // 3. 释放录制实例
        console.info('[AudioRecorderManager] 释放录制器');
        await this.avRecorder.release();
        this.avRecorder = undefined;
      }

      // 关闭录制文件
      if (this.audioFile) {
        fs.closeSync(this.audioFile);
        this.audioFile = null;
      }

      // 保存文件路径用于回调
      const filePath = this.recordingFilePath;

      // 重置状态
      this.isRecording = false;
      this.recordingDuration = 0;

      // 通知录制停止
      if (this.onRecordingStop) {
        this.onRecordingStop(filePath, duration);
      }

      console.info(`[AudioRecorderManager] 语音录制完成，时长: ${duration}秒，文件: ${filePath}`);
      return true;
    } catch (error) {
      console.error(`[AudioRecorderManager] 停止语音录制失败: ${error}`);
      if (this.onError) {
        this.onError(`停止录制失败: ${error}`);
      }
      await this.cancelRecording();
      return false;
    }
  }

  /**
   * 取消录制
   */
  async cancelRecording(): Promise<boolean> {
    if (!this.isRecording) {
      console.warn('[AudioRecorderManager] 未在录制中，无法取消');
      return false;
    }

    try {
      console.info('[AudioRecorderManager] 取消语音录制');

      // 停止计时器
      if (this.recordingTimer) {
        clearInterval(this.recordingTimer);
        this.recordingTimer = null;
      }

      // 完全清理录制器
      await this.cleanupRecorder();

      // 删除临时录制文件
      if (this.recordingFilePath) {
        try {
          if (fs.accessSync(this.recordingFilePath)) {
            fs.unlinkSync(this.recordingFilePath);
            console.info(`[AudioRecorderManager] 已删除临时录制文件: ${this.recordingFilePath}`);
          }
        } catch (error) {
          console.warn(`[AudioRecorderManager] 删除临时文件失败: ${error}`);
        }
      }

      // 重置状态
      this.isRecording = false;
      this.recordingDuration = 0;
      this.recordingFilePath = '';

      // 通知录制取消
      if (this.onRecordingCancel) {
        this.onRecordingCancel();
      }

      console.info('[AudioRecorderManager] 语音录制已取消');
      return true;
    } catch (error) {
      console.error(`[AudioRecorderManager] 取消语音录制失败: ${error}`);
      if (this.onError) {
        this.onError(`取消录制失败: ${error}`);
      }
      return false;
    }
  }

  /**
   * 获取当前录制状态
   */
  getRecordingState(): RecordingState {
    return {
      isRecording: this.isRecording,
      duration: this.recordingDuration,
      filePath: this.recordingFilePath
    };
  }

  /**
   * 检查录制文件是否存在
   */
  checkRecordingFileExists(filePath: string): boolean {
    try {
      return fs.accessSync(filePath);
    } catch (error) {
      console.warn(`[AudioRecorderManager] 检查文件存在性失败: ${error}`);
      return false;
    }
  }

  /**
   * 获取录制文件大小
   */
  getRecordingFileSize(filePath: string): number {
    try {
      const stat = fs.statSync(filePath);
      return stat.size;
    } catch (error) {
      console.warn(`[AudioRecorderManager] 获取文件大小失败: ${error}`);
      return 0;
    }
  }

  /**
   * 销毁管理器
   */
  async destroy() {
    if (this.isRecording) {
      await this.cancelRecording();
    }

    await this.cleanupRecorder();
  }

  /**
   * 检查和申请麦克风权限
   */
  private async checkAndRequestMicrophonePermission(): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const tokenId = bundleInfo.appInfo.accessTokenId;

      // 检查权限状态
      const permission: Permissions = 'ohos.permission.MICROPHONE';
      const grantStatus = await atManager.checkAccessToken(tokenId, permission);

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        console.info('[AudioRecorderManager] 麦克风权限已授予');
        return true;
      }

      console.info('[AudioRecorderManager] 麦克风权限未授予，开始申请权限');

      // 申请权限
      const requestResult = await atManager.requestPermissionsFromUser(this.context!, [permission]);

      if (requestResult.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        console.info('[AudioRecorderManager] 麦克风权限申请成功');
        return true;
      } else {
        console.warn('[AudioRecorderManager] 麦克风权限申请被拒绝');
        if (this.onPermissionDenied) {
          this.onPermissionDenied();
        }
        return false;
      }
    } catch (error) {
      console.error(`[AudioRecorderManager] 权限检查/申请失败: ${error}`);
      if (this.onError) {
        this.onError(`权限检查失败: ${error}`);
      }
      return false;
    }
  }

  /**
   * 创建文件以及设置 avConfig.url
   */
  private async createAndSetFd(): Promise<void> {
    try {
      // 生成录制文件路径
      this.recordingFilePath = this.generateRecordingFilePath();

      // 确保目录存在
      await this.ensureDirectoryExists(this.recordingFilePath);

      // 创建音频文件
      this.audioFile = fs.openSync(this.recordingFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

      // 更新配置中的 URL
      this.avConfig.url = 'fd://' + this.audioFile.fd;

      console.info(`[AudioRecorderManager] 文件创建成功: ${this.recordingFilePath}, fd: ${this.audioFile.fd}`);
    } catch (error) {
      console.error(`[AudioRecorderManager] 创建文件失败: ${error}`);
    }
  }

  /**
   * 注册音频录制器回调函数
   */
  private setAudioRecorderCallback() {
    if (this.avRecorder != undefined) {
      // 状态机变化回调函数
      this.avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        console.info(`[AudioRecorderManager] 录制器状态变化: ${state}, 原因: ${reason}`);
      });

      // 错误上报回调函数
      this.avRecorder.on('error', (err: BusinessError) => {
        console.error(`[AudioRecorderManager] 录制器错误: code=${err.code}, message=${err.message}`);
        if (this.onError) {
          this.onError(`录制器错误: ${err.message}`);
        }
        this.cancelRecording();
      });
    }
  }

  /**
   * 生成录制文件路径
   */
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
        console.error('[AudioRecorderManager] 获取应用上下文失败，使用临时路径');
        return `/data/storage/el2/base/haps/entry/files/${fileName}`;
      }
    }

    // return `${this.context.cacheDir}/${fileName}`;
  }

  /**
   * 确保目录存在
   */
  private async ensureDirectoryExists(filePath: string): Promise<void> {
    try {
      const dir = filePath.substring(0, filePath.lastIndexOf('/'));
      if (!fs.accessSync(dir)) {
        // 递归创建目录
        fs.mkdirSync(dir, true);
        console.info(`[AudioRecorderManager] 创建目录: ${dir}`);
      }
    } catch (error) {
      console.warn(`[AudioRecorderManager] 创建目录失败: ${error}`);
      // 如果创建目录失败，尝试使用父目录
      const parentDir = filePath.substring(0, filePath.lastIndexOf('/'));
      const grandParentDir = parentDir.substring(0, parentDir.lastIndexOf('/'));
      if (fs.accessSync(grandParentDir)) {
        console.info(`[AudioRecorderManager] 使用父目录: ${grandParentDir}`);
      }
    }
  }

  /**
   * 等待录制器达到指定状态
   */
  private async waitForRecorderState(targetState: media.AVRecorderState, timeout: number = 5000): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.avRecorder) {
        reject(new Error('录制器实例不存在'));
        return;
      }

      // 如果已经是目标状态，直接返回
      if (this.avRecorder.state === targetState) {
        console.info(`[AudioRecorderManager] 录制器已处于目标状态: ${targetState}`);
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
          console.info(`[AudioRecorderManager] 录制器已达到目标状态: ${targetState}`);
          resolve();
        }
      };

      this.avRecorder.on('stateChange', stateChangeHandler);
    });
  }

  /**
   * 完全清理录制器资源
   */
  private async cleanupRecorder(): Promise<void> {
    try {
      // 停止并释放录制器
      if (this.avRecorder != undefined) {
        try {
          // 根据当前状态决定如何停止
          const currentState = this.avRecorder.state;
          console.info(`[AudioRecorderManager] 当前录制器状态: ${currentState}`);

          if (currentState === 'started' || currentState === 'paused') {
            console.info('[AudioRecorderManager] 停止录制器');
            await this.avRecorder.stop();
            await this.waitForRecorderState('stopped');
          }

          if (currentState === 'stopped' || currentState === 'prepared') {
            console.info('[AudioRecorderManager] 重置录制器');
            await this.avRecorder.reset();
            await this.waitForRecorderState('idle');
          }

          console.info('[AudioRecorderManager] 释放录制器');
          await this.avRecorder.release();
        } catch (error) {
          console.warn(`[AudioRecorderManager] 清理录制器时出错: ${error}`);
          // 强制释放
          try {
            await this.avRecorder.release();
          } catch (releaseError) {
            console.warn(`[AudioRecorderManager] 强制释放录制器失败: ${releaseError}`);
          }
        }

        this.avRecorder = undefined;
      }

      // 关闭录制文件
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