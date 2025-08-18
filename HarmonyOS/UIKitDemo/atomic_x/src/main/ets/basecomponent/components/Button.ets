import { LightSemanticScheme, SemanticColorScheme } from '../theme/Colors';
import { ThemeState } from '../theme/ThemeState'

export enum ButtonControlType {
  filled = 'filled',
  outlined = 'outlined',
  noBorder = 'noBorder'
}
export enum ButtonColorType {
  primary = 'primary',
  secondary = 'secondary',
  danger = 'danger'
}
export enum ButtonContentType {
  textOnly = 'textOnly',
  iconOnly = 'iconOnly',
  iconWithText = 'iconWithText'
}
export enum ButtonIconPosition {
  start = 'start',
  end = 'end'
}
export enum ButtonSize {
  xs = 'xs',
  s = 's',
  m = 'm',
  l = 'l'
}
class ButtonSizeConfig {
  static get(buttonSize: ButtonSize): ButtonSizeInfo {
    switch (buttonSize) {
      case ButtonSize.xs:
        return {
          height: 24,
          horizontalPadding: 8,
          minWidth: 48,
          iconSize: 14
        };
      case ButtonSize.s:
        return {
          height: 32,
          horizontalPadding: 12,
          minWidth: 64,
          iconSize: 16
        };
      case ButtonSize.m:
        return {
          height: 40,
          horizontalPadding: 16,
          minWidth: 80,
          iconSize: 20
        };
      case ButtonSize.l:
        return {
          height: 48,
          horizontalPadding: 20,
          minWidth: 96,
          iconSize: 20
        };
      default:
        return {
          height: 48,
          horizontalPadding: 20,
          minWidth: 96,
          iconSize: 20
        };
    }
  }
}
interface ButtonSizeInfo {
  height: number;
  horizontalPadding: number;
  minWidth: number;
  iconSize: number;
}
interface ButtonColors {
  backgroundColor: ResourceColor;
  textColor: ResourceColor;
  borderColor: ResourceColor;
}
export enum ButtonContent {
  textOnly = 'textOnly',
  iconOnly = 'iconOnly',
  iconWithText = 'iconWithText'
}
export interface ButtonContentParams {
  type: ButtonContent;
  text?: string;
  icon?: ResourceStr;
  iconPosition?: ButtonIconPosition;
}
export interface ButtonParams {
  content: ButtonContentParams;
  isEnabled?: boolean;
  ButtonControlType?: ButtonControlType;
  colorType?: ButtonColorType;
  buttonSize?: ButtonSize;
  onButtonClick?: () => void;
}
export interface FilledButtonParams {
  text: string;
  buttonSize?: ButtonSize;
  onButtonClick?: () => void;
}
export interface OutlinedButtonParams {
  text: string;
  buttonSize?: ButtonSize;
  onButtonClick?: () => void;
}
export interface IconButtonParams {
  text: string;
  icon: ResourceStr;
  buttonSize?: ButtonSize;
  onButtonClick?: () => void;
}
function getDefaultColors(type: ButtonControlType, colorType: ButtonColorType, colors: SemanticColorScheme): ButtonColors {
  switch (type) {
    case ButtonControlType.filled:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: colors.buttonColorPrimaryDefault,
            textColor: colors.textColorButton,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: colors.buttonColorSecondaryDefault,
            textColor: colors.textColorPrimary,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: colors.buttonColorHangupDefault,
            textColor: colors.textColorButton,
            borderColor: Color.Transparent
          };
      }
    case ButtonControlType.outlined:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryDefault,
            borderColor: colors.buttonColorPrimaryDefault
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorPrimary,
            borderColor: colors.strokeColorPrimary
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupDefault,
            borderColor: colors.buttonColorHangupDefault
          };
      }
    case ButtonControlType.noBorder:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryDefault,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorPrimary,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupDefault,
            borderColor: Color.Transparent
          };
      }
  }
}
function getHoverColors(type: ButtonControlType, colorType: ButtonColorType, colors: SemanticColorScheme): ButtonColors {
  switch (type) {
    case ButtonControlType.filled:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: colors.buttonColorPrimaryHover,
            textColor: colors.textColorButton,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: colors.buttonColorSecondaryHover,
            textColor: colors.textColorSecondary,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: colors.buttonColorHangupHover,
            textColor: colors.textColorButton,
            borderColor: Color.Transparent
          };
      }
    case ButtonControlType.outlined:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryHover,
            borderColor: colors.buttonColorPrimaryHover
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorSecondary,
            borderColor: colors.strokeColorSecondary
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupHover,
            borderColor: colors.buttonColorHangupHover
          };
      }
    case ButtonControlType.noBorder:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryHover,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorSecondary,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupHover,
            borderColor: Color.Transparent
          };
      }
  }
}
function getActiveColors(type: ButtonControlType, colorType: ButtonColorType, colors: SemanticColorScheme): ButtonColors {
  switch (type) {
    case ButtonControlType.filled:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: colors.buttonColorPrimaryActive,
            textColor: colors.textColorButton,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: colors.buttonColorSecondaryActive,
            textColor: colors.textColorTertiary,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: colors.buttonColorHangupActive,
            textColor: colors.textColorButton,
            borderColor: Color.Transparent
          };
      }
    case ButtonControlType.outlined:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryActive,
            borderColor: colors.buttonColorPrimaryActive
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorTertiary,
            borderColor: colors.strokeColorModule
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupActive,
            borderColor: colors.buttonColorHangupActive
          };
      }
    case ButtonControlType.noBorder:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryActive,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorTertiary,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupActive,
            borderColor: Color.Transparent
          };
      }
  }
}
function getDisabledColors(type: ButtonControlType, colorType: ButtonColorType, colors: SemanticColorScheme): ButtonColors {
  switch (type) {
    case ButtonControlType.filled:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: colors.buttonColorPrimaryDisabled,
            textColor: colors.textColorButtonDisabled,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: colors.buttonColorSecondaryDisabled,
            textColor: colors.textColorDisable,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: colors.buttonColorHangupDisabled,
            textColor: colors.textColorButtonDisabled,
            borderColor: Color.Transparent
          };
      }
    case ButtonControlType.outlined:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryDisabled,
            borderColor: colors.buttonColorPrimaryDisabled
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorDisable,
            borderColor: colors.strokeColorSecondary
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupDisabled,
            borderColor: colors.buttonColorHangupDisabled
          };
      }
    case ButtonControlType.noBorder:
      switch (colorType) {
        case ButtonColorType.primary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorPrimaryDisabled,
            borderColor: Color.Transparent
          };
        case ButtonColorType.secondary:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.textColorDisable,
            borderColor: Color.Transparent
          };
        case ButtonColorType.danger:
          return {
            backgroundColor: Color.Transparent,
            textColor: colors.buttonColorHangupDisabled,
            borderColor: Color.Transparent
          };
      }
  }
}
function fontForButtonSize(buttonSize: ButtonSize): number {
  switch (buttonSize) {
    case ButtonSize.xs:
      return 12; // caption3Medium
    case ButtonSize.s:
      return 14; // caption2Medium
    case ButtonSize.m:
    case ButtonSize.l:
      return 16; // caption1Medium
    default:
      return 16;
  }
}
@Component
export struct FilledButton {
  @Prop text: string = '';
  @Prop buttonSize: ButtonSize = ButtonSize.l;
  onButtonClick?: () => void;

  build() {
    ButtonControl({
      content: {
        type: ButtonContent.textOnly,
        text: this.text
      },
      buttonSize: this.buttonSize,
      onButtonClick: this.onButtonClick
    })
  }
}
@Component
export struct OutlinedButton {
  @Prop text: string = '';
  @Prop buttonSize: ButtonSize = ButtonSize.l;
  onButtonClick?: () => void;

  build() {
    ButtonControl({
      content: {
        type: ButtonContent.textOnly,
        text: this.text
      },
      ButtonControlType: ButtonControlType.outlined,
      buttonSize: this.buttonSize,
      onButtonClick: this.onButtonClick
    })
  }
}
@Component
export struct IconButton {
  @Prop text: string = '';
  @Prop icon: ResourceStr = '';
  @Prop buttonSize: ButtonSize = ButtonSize.l;
  onButtonClick?: () => void;

  build() {
    ButtonControl({
      content: {
        type: ButtonContent.iconWithText,
        text: this.text,
        icon: this.icon
      },
      buttonSize: this.buttonSize,
      onButtonClick: this.onButtonClick
    })
  }
}
// 'Button' The struct name cannot contain reserved tag name: 'Button'. <ArkTSCheck>
@Component
export struct ButtonControl {
  @Prop content: ButtonContentParams = { type: ButtonContent.textOnly };
  @Prop isEnabled: boolean = true;
  @Prop ButtonControlType: ButtonControlType = ButtonControlType.filled;
  @Prop colorType: ButtonColorType = ButtonColorType.primary;
  @Prop buttonSize: ButtonSize = ButtonSize.l;
  onButtonClick?: () => void;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State private isPressed: boolean = false;
  @State private isHovered: boolean = false;

  build() {
    Row({ space: (this.content.type === ButtonContent.iconWithText) ? 4 : 0 }) {

      if (this.content.type === ButtonContent.iconOnly && this.content.icon) {
        Image(this.content.icon)
          .width(ButtonSizeConfig.get(this.buttonSize).iconSize)
          .height(ButtonSizeConfig.get(this.buttonSize).iconSize)
          .fillColor(this.getColors().textColor)
      } else if (this.content.type === ButtonContent.iconWithText) {

        if ((this.content.iconPosition ?? ButtonIconPosition.start) === ButtonIconPosition.start && this.content.icon) {
          Image(this.content.icon)
            .width(ButtonSizeConfig.get(this.buttonSize).iconSize)
            .height(ButtonSizeConfig.get(this.buttonSize).iconSize)
            .fillColor(this.getColors().textColor)
        }


        if (this.content.text) {
          Text(this.content.text)
            .fontSize(fontForButtonSize(this.buttonSize))
            .fontColor(this.getColors().textColor)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }


        if ((this.content.iconPosition ?? ButtonIconPosition.start) === ButtonIconPosition.end && this.content.icon) {
          Image(this.content.icon)
            .width(ButtonSizeConfig.get(this.buttonSize).iconSize)
            .height(ButtonSizeConfig.get(this.buttonSize).iconSize)
            .fillColor(this.getColors().textColor)
        }
      } else if (this.content.type === ButtonContent.textOnly && this.content.text) {
        Text(this.content.text)
          .fontSize(fontForButtonSize(this.buttonSize))
          .fontColor(this.getColors().textColor)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .constraintSize({ minWidth: this.getMinWidth() })
    .height(ButtonSizeConfig.get(this.buttonSize).height)
    .padding({
      left: this.getHorizontalPadding(),
      right: this.getHorizontalPadding()
    })
    .backgroundColor(this.getColors().backgroundColor)
    .borderRadius(ButtonSizeConfig.get(this.buttonSize).height / 2)
    .border({
      width: this.ButtonControlType === ButtonControlType.outlined ? 1 : 0,
      color: this.getColors().borderColor
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .opacity(this.isEnabled ? 1.0 : 0.5)
    .onTouch((event: TouchEvent) => {
      if (!this.isEnabled) {
        return;
      }

      switch (event.type) {
        case TouchType.Down:
          this.isPressed = true;
          break;
        case TouchType.Up:
        case TouchType.Cancel:
          this.isPressed = false;
          break;
      }
    })
    .onHover((isHover: boolean) => {
      if (!this.isEnabled) {
        return;
      }
      this.isHovered = isHover;
    })
    .onClick(() => {
      if (this.isEnabled && this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }

  private getColors(): ButtonColors {
    if (!this.isEnabled) {
      return getDisabledColors(this.ButtonControlType, this.colorType, this.themeState.colors);
    } else if (this.isPressed) {
      return getActiveColors(this.ButtonControlType, this.colorType, this.themeState.colors);
    } else if (this.isHovered) {
      return getHoverColors(this.ButtonControlType, this.colorType, this.themeState.colors);
    } else {
      return getDefaultColors(this.ButtonControlType, this.colorType, this.themeState.colors);
    }
  }

  private getMinWidth(): number {
    const sizeInfo = ButtonSizeConfig.get(this.buttonSize);
    switch (this.content.type) {
      case ButtonContent.iconOnly:
        return sizeInfo.height;
      case ButtonContent.iconWithText:
      case ButtonContent.textOnly:
        return sizeInfo.minWidth;
      default:
        return sizeInfo.minWidth;
    }
  }

  private getHorizontalPadding(): number {
    const sizeInfo = ButtonSizeConfig.get(this.buttonSize);
    if (this.content.type === ButtonContent.iconOnly) {
      return 0;
    } else {
      return sizeInfo.horizontalPadding;
    }
  }
}
