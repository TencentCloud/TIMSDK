import { ThemeState } from '../../basecomponent/Index';
@Component
export struct AudioRecorderView {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  
  @Prop recordingDuration: number = 0;
  // Callback function
  onCancel?: () => void;
  onSend?: () => void;

  build() {
    
    Row() {
      
      Stack() {
        
        Column() {
          
          Rect()
            .width(16)
            .height(2)
            .fill(Color.White)
            .margin({ bottom: 1 })

          
          Rect()
            .width(12)
            .height(14)
            .fill(Color.White)
            .borderRadius(1)

          
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
        
        if (this.onCancel) {
          this.onCancel();
        }
      })

      
      Row() {
        
        Text(`${Math.floor(this.recordingDuration / 60)}:${(this.recordingDuration % 60).toString()
          .padStart(2, '0')}`)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)

        
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

  
  private getWaveHeight(index: number): number {
    
    const minHeight = 4;
    const maxHeight = 12;

    
    const patterns = [
      [0.3, 0.4, 1.0, 0.5, 0.2], 
      [0.2, 0.6, 0.4, 0.8, 0.3], 
      [0.4, 0.3, 0.7, 0.2, 0.6],
    ];

    
    const patternIndex = Math.floor(this.recordingDuration / 3) % patterns.length;
    const currentPattern = patterns[patternIndex];
    const patternLength = currentPattern.length;

    
    const positionInPattern = (index - 1) % patternLength;
    const baseIntensity = currentPattern[positionInPattern];

    
    const timeVariation = Math.sin(this.recordingDuration * 0.3 + index * 0.5) * 0.08;

    
    const finalIntensity = Math.max(0.15, Math.min(0.95, baseIntensity + timeVariation));

    
    const envelope = Math.min(1, this.recordingDuration / 2); 

    
    const heightRange = maxHeight - minHeight;
    const finalHeight = minHeight + (finalIntensity * envelope * heightRange);

    return Math.round(finalHeight);
  }

  
  private getWaveArray(): number[] {
    
    const baseCount = 4;

    
    
    const additionalCount = Math.floor(this.recordingDuration * 2);

    
    const totalCount = Math.min(baseCount + additionalCount, 60);

    
    const waveArray: number[] = [];
    for (let i = 0; i < totalCount; i++) {
      waveArray.push(i + 1);
    }

    return waveArray;
  }

  
  private getWaveOpacity(index: number): number {
    const baseCount = 4;

    
    if (index < baseCount) {
      return 1.0;
    }

    
    const additionalIndex = index - baseCount;
    const appearTime = (additionalIndex + 1) / 2; 
    const timeSinceAppear = this.recordingDuration - appearTime;

    
    const fadeInDuration = 0.5;

    if (timeSinceAppear <= 0) {
      return 0; 
    } else if (timeSinceAppear < fadeInDuration) {
      return timeSinceAppear / fadeInDuration; 
    } else {
      return 1.0; 
    }
  }
} 