import { ThemeState } from '../theme/ThemeState'
interface SliderSize {
  thumbRadius: number 
  thumbBorderWidth: number 
  trackThickness: number 
}
interface SliderColors {
  trackColor: string 
  activeTrackColor: string 
  thumbColor: string 
  thumbBorderColor: string 
}
export enum SliderOrientation {
  Horizontal = 'Horizontal',
  Vertical = 'Vertical'
}
@Component
export struct SliderControl {
  @Prop value: number = 0
  @Prop orientation: SliderOrientation = SliderOrientation.Horizontal
  @Prop isEnabled: boolean = true
  @Prop valueRange: [number, number] = [0, 100]
  @Prop showTooltip: boolean = false
  onValueChange?: (value: number) => void
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance()
  @State private isDragging: boolean = false
  @State private isHovering: boolean = false
  @State private dragStartX: number = 0
  @State private dragStartY: number = 0
  @State private componentWidth: number = 300
  @State private componentHeight: number = 300
  @State private dragStartValue: number = 0
  
  private sliderSize: SliderSize = {
    thumbRadius: 7,
    thumbBorderWidth: 2,
    trackThickness: 4
  }

  build() {
    if (this.orientation === SliderOrientation.Horizontal) {
      this.HorizontalSliderBuilder()
    } else {
      this.VerticalSliderBuilder()
    }
  }

  @Builder
  HorizontalSliderBuilder() {
    Stack() {
      
      Row() {
        this.HorizontalTrackBuilder()
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.componentWidth = newValue.width as number
      })
      .gesture(
        PanGesture({ fingers: 1, direction: PanDirection.Horizontal, distance: 1 })
          .onActionStart((event: GestureEvent) => {
            if (this.isEnabled) {
              this.isDragging = true
              this.isHovering = true
              this.dragStartX = event.offsetX
              this.dragStartValue = this.value
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.isEnabled && this.isDragging) {
              this.handleHorizontalPan(event)
            }
          })
          .onActionEnd(() => {
            this.isDragging = false
            this.isHovering = false
          })
      )
      .onTouch((event: TouchEvent) => {
        if (this.isEnabled && event.type === TouchType.Down) {
          this.handleHorizontalTouch(event)
        }
      })
    }
    .width('100%')
    .height(48)
    .alignContent(Alignment.Center)
  }

  @Builder
  VerticalSliderBuilder() {
    Stack() {
      
      Column() {
        this.VerticalTrackBuilder()
      }
      .width(48)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.componentHeight = newValue.height as number
      })
      .gesture(
        PanGesture({ fingers: 1, direction: PanDirection.Vertical, distance: 1 })
          .onActionStart((event: GestureEvent) => {
            if (this.isEnabled) {
              this.isDragging = true
              this.isHovering = true
              this.dragStartY = event.offsetY
              this.dragStartValue = this.value
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.isEnabled && this.isDragging) {
              this.handleVerticalPan(event)
            }
          })
          .onActionEnd(() => {
            this.isDragging = false
            this.isHovering = false
          })
      )
      .onTouch((event: TouchEvent) => {
        if (this.isEnabled && event.type === TouchType.Down) {
          this.handleVerticalTouch(event)
        }
      })
    }
    .width(48)
    .height('100%')
    .alignContent(Alignment.Center)
  }

  @Builder
  HorizontalTrackBuilder() {
    Stack() {
      
      Row()
        .width('100%')
        .height(this.sliderSize.trackThickness)
        .backgroundColor(this.getSliderColors().trackColor)
        .borderRadius(this.sliderSize.trackThickness / 2)
        .opacity(this.isEnabled ? 1 : 0.5)

      
      Row()
        .width(`${this.getProgress() * 100}%`)
        .height(this.sliderSize.trackThickness)
        .backgroundColor(this.getSliderColors().activeTrackColor)
        .borderRadius(this.sliderSize.trackThickness / 2)
        .opacity(this.isEnabled ? 1 : 0.5)

      
      Stack() {
        
        if (this.isDragging && this.isEnabled) {
          Circle()
            .size({ width: (this.sliderSize.thumbRadius + 2) * 2, height: (this.sliderSize.thumbRadius + 2) * 2 })
            .fill('rgba(0, 0, 0, 0.12)')
            .offset({ x: 1, y: 2 })
        }

        
        Circle()
          .size({ width: this.sliderSize.thumbRadius * 2, height: this.sliderSize.thumbRadius * 2 })
          .fill(this.getSliderColors().thumbColor)
          .stroke(this.getSliderColors().thumbBorderColor)
          .strokeWidth(this.sliderSize.thumbBorderWidth)
          .opacity(this.isEnabled ? 1 : 0.5)
      }
      .position({ x: `${this.getProgress() * 100}%` })
      .markAnchor({ x: 0.5, y: 0.5 })
    }
    .width('100%')
    .height(this.sliderSize.trackThickness)
    .alignContent(Alignment.Start)
  }

  @Builder
  VerticalTrackBuilder() {
    Stack() {
      
      Column()
        .width(this.sliderSize.trackThickness)
        .height('100%')
        .backgroundColor(this.getSliderColors().trackColor)
        .borderRadius(this.sliderSize.trackThickness / 2)
        .opacity(this.isEnabled ? 1 : 0.5)

      
      Column()
        .width(this.sliderSize.trackThickness)
        .height(`${this.getProgress() * 100}%`)
        .backgroundColor(this.getSliderColors().activeTrackColor)
        .borderRadius(this.sliderSize.trackThickness / 2)
        .opacity(this.isEnabled ? 1 : 0.5)

      
      Stack() {
        
        if (this.isDragging && this.isEnabled) {
          Circle()
            .size({ width: (this.sliderSize.thumbRadius + 2) * 2, height: (this.sliderSize.thumbRadius + 2) * 2 })
            .fill('rgba(0, 0, 0, 0.12)')
            .offset({ x: 1, y: 2 })
        }

        
        Circle()
          .size({ width: this.sliderSize.thumbRadius * 2, height: this.sliderSize.thumbRadius * 2 })
          .fill(this.getSliderColors().thumbColor)
          .stroke(this.getSliderColors().thumbBorderColor)
          .strokeWidth(this.sliderSize.thumbBorderWidth)
          .opacity(this.isEnabled ? 1 : 0.5)
      }
      .position({ y: `${(1 - this.getProgress()) * 100}%` })
      .markAnchor({ x: 0.5, y: 0.5 })
    }
    .width(this.sliderSize.trackThickness)
    .height('100%')
    .alignContent(Alignment.Bottom)
  }
  
  
  private getSliderColors(): SliderColors {
    return {
      trackColor: this.themeState.colors.sliderColorEmpty,
      activeTrackColor: this.themeState.colors.sliderColorFilled,
      thumbColor: this.themeState.colors.sliderColorButton,
      thumbBorderColor: this.themeState.colors.sliderColorFilled
    }
  }

  
  private getProgress(): number {
    const clampedValue = Math.max(this.valueRange[0], Math.min(this.valueRange[1], this.value))
    return (clampedValue - this.valueRange[0]) / (this.valueRange[1] - this.valueRange[0])
  }

  
  private calculateNewValue(offset: number, sliderSize: number): number {
    const thumbRadius = this.sliderSize.thumbRadius
    const newProgress = Math.max(0, Math.min(1, (offset - thumbRadius) / (sliderSize - 2 * thumbRadius)))
    return this.valueRange[0] + newProgress * (this.valueRange[1] - this.valueRange[0])
  }

  
  private calculateNewValueVertical(offset: number, sliderHeight: number): number {
    const thumbRadius = this.sliderSize.thumbRadius
    const invertedOffset = sliderHeight - offset
    const newProgress = Math.max(0, Math.min(1, (invertedOffset - thumbRadius) / (sliderHeight - 2 * thumbRadius)))
    return this.valueRange[0] + newProgress * (this.valueRange[1] - this.valueRange[0])
  }

  
  private handleValueChange(newValue: number): void {
    if (this.onValueChange) {
      this.onValueChange(newValue)
    }
  }

  private handleHorizontalPan(event: GestureEvent): void {
    
    const deltaX = event.offsetX - this.dragStartX
    const thumbRadius = this.sliderSize.thumbRadius
    const trackWidth = this.componentWidth - 2 * thumbRadius
    const deltaProgress = deltaX / trackWidth
    const deltaValue = deltaProgress * (this.valueRange[1] - this.valueRange[0])
    const newValue = Math.max(this.valueRange[0], Math.min(this.valueRange[1], this.dragStartValue + deltaValue))
    this.handleValueChange(newValue)
  }

  private handleVerticalPan(event: GestureEvent): void {
    
    const deltaY = event.offsetY - this.dragStartY
    const thumbRadius = this.sliderSize.thumbRadius
    const trackHeight = this.componentHeight - 2 * thumbRadius
    const deltaProgress = -deltaY / trackHeight 
    const deltaValue = deltaProgress * (this.valueRange[1] - this.valueRange[0])
    const newValue = Math.max(this.valueRange[0], Math.min(this.valueRange[1], this.dragStartValue + deltaValue))
    this.handleValueChange(newValue)
  }

  private handleHorizontalTouch(event: TouchEvent): void {
    
    const newValue = this.calculateNewValue(event.touches[0].x, this.componentWidth)
    this.handleValueChange(newValue)
  }

  private handleVerticalTouch(event: TouchEvent): void {
    
    const newValue = this.calculateNewValueVertical(event.touches[0].y, this.componentHeight)
    this.handleValueChange(newValue)
  }
} 