import { Colors, SemanticColorScheme } from '../theme/Colors'
import { ThemeState } from '../theme/ThemeState'

export class SwitchSize {
  static readonly S = new SwitchSize(26, 16, 12, 2, 10);
  static readonly M = new SwitchSize(32, 20, 15, 2.5, 12);
  static readonly L = new SwitchSize(40, 24, 18, 3, 14);
  width: number;
  height: number;
  thumbSize: number;
  padding: number;
  textSize: number;

  constructor(width: number, height: number, thumbSize: number, padding: number, textSize: number) {
    this.width = width;
    this.height = height;
    this.thumbSize = thumbSize;
    this.padding = padding;
    this.textSize = textSize;
  }
}

export enum SwitchType {
  Basic = 'Basic',
  WithText = 'WithText',
  WithIcon = 'WithIcon'
}

export interface SwitchParams {
  checked: boolean;
  onCheckedChange?: (checked: boolean) => void;
  enabled?: boolean;
  loading?: boolean;
  size?: SwitchSize;
  type?: SwitchType;
}

export interface LoadingIndicatorParams {
  size: number;
  color: string;
}

function getSwitchWidth(size: SwitchSize, type: SwitchType): number {
  switch (type) {
    case SwitchType.Basic:
      return size.width;
    case SwitchType.WithIcon:
    case SwitchType.WithText:
      return size.height * 2;
    default:
      return size.width;
  }
}

function getSwitchTrackColor(checked: boolean, enabled: boolean, colors: SemanticColorScheme): ResourceColor {
  let color = checked ? colors.switchColorOn : colors.switchColorOff;
  if (!enabled) {

    color = color + '99';
  }
  return color;
}

function getSwitchThumbColor(enabled: boolean, colors: SemanticColorScheme): ResourceColor {
  let color = colors.switchColorButton;
  if (!enabled) {

    color = color + '99';
  }
  return color;
}

function getShadowRadius(size: SwitchSize): number {
  if (size === SwitchSize.S) {
    return 1.6;
  }
  if (size === SwitchSize.M) {
    return 2;
  }
  if (size === SwitchSize.L) {
    return 2.4;
  }
  return 2;
}

@Builder
export function Switch(params: SwitchParams) {
  SwitchInternal({
    checked: params.checked,
    onCheckedChange: params.onCheckedChange,
    isEnabled: params.enabled ?? true,
    isLoading: params.loading ?? false,
    switchSize: params.size ?? SwitchSize.L,
    switchType: params.type ?? SwitchType.Basic
  })
}

@Component
struct SwitchInternal {
  @Prop checked: boolean = false;
  onCheckedChange?: (checked: boolean) => void;
  @Prop isEnabled: boolean = true;
  @Prop isLoading: boolean = false;
  @Prop switchSize: SwitchSize = SwitchSize.L;
  @Prop switchType: SwitchType = SwitchType.Basic;

  build() {
    Stack() {

      Rect()
        .width(this.getWidth())
        .height(this.switchSize.height)
        .radius(this.switchSize.height / 2)
        .fill(this.getTrackColor())


      if (this.switchType === SwitchType.WithText || this.switchType === SwitchType.WithIcon) {
        Row() {
          if (!this.checked) {
            Blank()
          }

          if (this.switchType === SwitchType.WithIcon) {
            Image(this.checked ? $rawfile('basecomponent/switch_on.svg') : $rawfile('basecomponent/switch_off.svg'))
              .width(this.getWidth() - this.switchSize.thumbSize - this.switchSize.padding * 2)
              .height(this.switchSize.thumbSize)
          } else if (this.switchType === SwitchType.WithText) {
            Text(this.checked ? '开' : '关')
              .fontSize(this.switchSize.textSize)
              .fontColor(this.getThemeColors().textColorButton)
              .fontWeight(FontWeight.Medium)
              .width(this.getWidth() - this.switchSize.thumbSize - this.switchSize.padding * 2)
              .height(this.switchSize.height)
              .textAlign(TextAlign.Center)
              .maxLines(1)
          }

          if (this.checked) {
            Blank()
          }
        }
        .width(this.getWidth())
        .height(this.switchSize.height)
      }


      Circle()
        .width(this.switchSize.thumbSize)
        .height(this.switchSize.thumbSize)
        .fill(this.getThumbColor())
        .shadow({
          radius: getShadowRadius(this.switchSize),
          color: '#19000000',
          offsetX: 0,
          offsetY: 0
        })
        .position({
          x: this.checked ? this.getMaxOffset() : this.switchSize.padding,
          y: (this.switchSize.height - this.switchSize.thumbSize) / 2
        })
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
        .overlay(
          this.isLoading ?
          LoadingIndicator({
            size: this.switchSize.thumbSize * 0.6,
            color: this.getThemeColors().switchColorOn
          }) : null
        )
    }
    .width(this.getWidth())
    .height(this.switchSize.height)
    .onClick(() => {
      if (this.isEnabled && !this.isLoading && this.onCheckedChange) {
        this.onCheckedChange(!this.checked);
      }
    })
  }

  private getThemeColors(): SemanticColorScheme {
    const themeState = ThemeState.getInstance();
    return themeState.colors;
  }

  private getWidth(): number {
    return getSwitchWidth(this.switchSize, this.switchType);
  }

  private getMaxOffset(): number {
    return this.getWidth() - this.switchSize.thumbSize - this.switchSize.padding;
  }

  private getTrackColor(): ResourceColor {
    return getSwitchTrackColor(this.checked, this.isEnabled, this.getThemeColors());
  }

  private getThumbColor(): ResourceColor {
    return getSwitchThumbColor(this.isEnabled, this.getThemeColors());
  }
}

@Builder
function LoadingIndicator(params: LoadingIndicatorParams) {
  LoadingProgress()
    .width(params.size)
    .height(params.size)
    .color(params.color)
} 