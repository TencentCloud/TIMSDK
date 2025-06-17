import { ThemeManager } from 'basecomponent';

/**
 * 语音录制视图组件
 */
@Component
export struct VoiceRecordingView {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 录制时长（秒）
  @Prop recordingDuration: number = 0;
  // 回调函数
  onCancel?: () => void;
  onSend?: () => void;

  build() {
    // 主要录制界面 - 简化版，适合在MessageInputBar中使用
    Row() {
      // 左侧：垃圾桶图标
      Stack() {
        // 垃圾桶主体
        Column() {
          // 垃圾桶盖子
          Rect()
            .width(16)
            .height(2)
            .fill(Color.White)
            .margin({ bottom: 1 })

          // 垃圾桶身体
          Rect()
            .width(12)
            .height(14)
            .fill(Color.White)
            .borderRadius(1)

          // 垃圾桶底部
          Rect()
            .width(14)
            .height(2)
            .fill(Color.White)
            .borderRadius(1)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width(32)
      .height(32)
      .backgroundColor('#4A90E2')
      .borderRadius(6)
      .margin({ right: 12 })
      .onClick(() => {
        // 点击垃圾桶取消录制
        if (this.onCancel) {
          this.onCancel();
        }
      })

      // 右侧：录制状态胶囊
      Row() {
        // 时间显示
        Text(`${Math.floor(this.recordingDuration / 60)}:${(this.recordingDuration % 60).toString()
          .padStart(2, '0')}`)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)

        // 音频波形图标 - 紧贴时间显示
        Row() {
          ForEach(this.getWaveArray(), (item: number, index: number) => {
            Rect()
              .width(2)
              .height(this.getWaveHeight(index + 1))
              .fill(Color.White)
              .borderRadius(1)
              .margin({ right: 0.5 })
          })
        }
        .alignItems(VerticalAlign.Center)
        .margin({ left: 8 })
      }
      .layoutWeight(1)
      .height(36)
      .backgroundColor('#4A90E2')
      .borderRadius(18)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        // 点击胶囊发送录制
        if (this.onSend) {
          this.onSend();
        }
      })
    }
    .width('100%')
    .height(36)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 获取音频波形高度
   */
  private getWaveHeight(index: number): number {
    // 基础高度范围：4-12px（适合36px高度的容器）
    const minHeight = 4;
    const maxHeight = 12;

    // 定义多种重复的波形模式，避免单调
    const patterns = [
      [0.3, 0.4, 1.0, 0.5, 0.2], // 低低高低低
      [0.2, 0.6, 0.4, 0.8, 0.3], // 低中低高低
      [0.4, 0.3, 0.7, 0.2, 0.6],// 中低高低中
    ];

    // 根据录制时长选择不同的模式（每3秒切换一次）
    const patternIndex = Math.floor(this.recordingDuration / 3) % patterns.length;
    const currentPattern = patterns[patternIndex];
    const patternLength = currentPattern.length;

    // 根据索引获取模式中的位置
    const positionInPattern = (index - 1) % patternLength;
    const baseIntensity = currentPattern[positionInPattern];

    // 添加轻微的时间变化（基于录制时长），但保持在小范围内
    const timeVariation = Math.sin(this.recordingDuration * 0.3 + index * 0.5) * 0.08;

    // 最终强度（严格限制范围，避免极端值）
    const finalIntensity = Math.max(0.15, Math.min(0.95, baseIntensity + timeVariation));

    // 添加音量包络（录制开始时较小，逐渐增大）
    const envelope = Math.min(1, this.recordingDuration / 2); // 2秒内逐渐达到最大音量

    // 计算最终高度
    const heightRange = maxHeight - minHeight;
    const finalHeight = minHeight + (finalIntensity * envelope * heightRange);

    return Math.round(finalHeight);
  }

  /**
   * 根据录制时长生成波形条数组
   */
  private getWaveArray(): number[] {
    // 基础波形条数量（最少显示）
    const baseCount = 4;

    // 根据录制时长增加波形条数量
    // 每秒增加2个波形条，模拟音频数据的累积
    const additionalCount = Math.floor(this.recordingDuration * 2);

    // 总数量（限制最大数量避免过多）
    const totalCount = Math.min(baseCount + additionalCount, 60);

    // 生成数组
    const waveArray: number[] = [];
    for (let i = 0; i < totalCount; i++) {
      waveArray.push(i + 1);
    }

    return waveArray;
  }

  /**
   * 获取波形条的透明度（用于渐入效果）
   */
  private getWaveOpacity(index: number): number {
    const baseCount = 4;

    // 基础波形条始终完全可见
    if (index < baseCount) {
      return 1.0;
    }

    // 新增的波形条根据出现时间渐入
    const additionalIndex = index - baseCount;
    const appearTime = (additionalIndex + 1) / 2; // 每秒出现2个
    const timeSinceAppear = this.recordingDuration - appearTime;

    // 渐入时间为0.5秒
    const fadeInDuration = 0.5;

    if (timeSinceAppear <= 0) {
      return 0; // 还未到出现时间
    } else if (timeSinceAppear < fadeInDuration) {
      return timeSinceAppear / fadeInDuration; // 渐入过程
    } else {
      return 1.0; // 完全可见
    }
  }
} 