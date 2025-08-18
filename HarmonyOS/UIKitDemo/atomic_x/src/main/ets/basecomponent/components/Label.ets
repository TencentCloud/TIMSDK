import { ThemeState } from '../theme/ThemeState'
import { SemanticColorScheme } from '../theme/Colors'
import { FontScheme, SemanticFontScheme } from '../theme/Fonts'

export enum LabelSize {
  s = 's',
  m = 'm',
  l = 'l'
}

export enum LabelIconPosition {
  start = 'start',
  end = 'end'
}

export enum TagLabelColor {
  white = 'white',
  blue = 'blue',
  green = 'green',
  gray = 'gray',
  orange = 'orange',
  red = 'red'
}

export interface TagLabelParams {
  size: LabelSize;
  text: string;
  colorType: TagLabelColor;
}

export interface TitleLabelParams {
  size: LabelSize;
  text: string;
}

export interface SubTitleLabelParams {
  size: LabelSize;
  text: string;
  icon?: string;
  iconPosition?: LabelIconPosition;
}

export interface ItemLabelParams {
  size: LabelSize;
  text: string;
  icon?: string;
  iconPosition?: LabelIconPosition;
}

export interface DangerLabelParams {
  size: LabelSize;
  text: string;
  icon?: string;
  iconPosition?: LabelIconPosition;
}

export interface CustomLabelParams {
  text: string;
  font: number;
  textColor: ResourceColor;
  backgroundColor?: ResourceColor;
  lineLimit?: number;
  icon?: string;
  iconPosition?: LabelIconPosition;
}

interface LabelParams {
  text: string;
  font: number;
  textColor: ResourceColor;
  backgroundColor: ResourceColor;
  lineLimit?: number;
  icon?: string;
  iconPosition?: LabelIconPosition;
}

function getTagLabelFont(size: LabelSize, fonts: SemanticFontScheme): number {
  switch (size) {
    case LabelSize.s:
      return fonts.caption3Regular.size;
    case LabelSize.m:
      return fonts.caption2Regular.size;
    case LabelSize.l:
      return fonts.caption1Regular.size;
    default:
      return fonts.caption2Regular.size;
  }
}

function getTitleLabelFont(size: LabelSize, fonts: SemanticFontScheme): number {
  switch (size) {
    case LabelSize.s:
      return fonts.caption2Bold.size;
    case LabelSize.m:
      return fonts.caption1Bold.size;
    case LabelSize.l:
      return fonts.title3Bold.size;
    default:
      return fonts.caption1Bold.size;
  }
}

function getSubTitleLabelFont(size: LabelSize, fonts: SemanticFontScheme): number {
  switch (size) {
    case LabelSize.s:
      return fonts.caption3Regular.size;
    case LabelSize.m:
      return fonts.caption2Regular.size;
    case LabelSize.l:
      return fonts.caption1Regular.size;
    default:
      return fonts.caption2Regular.size;
  }
}

function getItemLabelFont(size: LabelSize, fonts: SemanticFontScheme): number {
  switch (size) {
    case LabelSize.s:
      return fonts.caption2Regular.size;
    case LabelSize.m:
      return fonts.caption1Regular.size;
    case LabelSize.l:
      return fonts.body4Regular.size;
    default:
      return fonts.caption1Regular.size;
  }
}

function getDangerLabelFont(size: LabelSize, fonts: SemanticFontScheme): number {
  switch (size) {
    case LabelSize.s:
      return fonts.caption2Regular.size;
    case LabelSize.m:
      return fonts.caption1Regular.size;
    case LabelSize.l:
      return fonts.body4Regular.size;
    default:
      return fonts.caption1Regular.size;
  }
}

function getTagLabelTextColor(colorType: TagLabelColor, colors: SemanticColorScheme): ResourceColor {

  switch (colorType) {
    case TagLabelColor.white:
    case TagLabelColor.blue:
    case TagLabelColor.green:
    case TagLabelColor.gray:
    case TagLabelColor.orange:
    case TagLabelColor.red:
      return colors.buttonColorPrimaryDefault;
    default:
      return colors.buttonColorPrimaryDefault;
  }
}

function getTagLabelBackgroundColor(colorType: TagLabelColor, colors: SemanticColorScheme): ResourceColor {

  switch (colorType) {
    case TagLabelColor.white:
    case TagLabelColor.blue:
    case TagLabelColor.green:
    case TagLabelColor.gray:
    case TagLabelColor.orange:
    case TagLabelColor.red:
      return Color.Transparent;
    default:
      return Color.Transparent;
  }
}

@Builder
export function TagLabel(params: TagLabelParams) {
  TagLabelInternal({
    labelSize: params.size,
    text: params.text,
    colorType: params.colorType
  })
}

@Builder
export function TitleLabel(params: TitleLabelParams) {
  TitleLabelInternal({
    labelSize: params.size,
    text: params.text
  })
}

@Builder
export function SubTitleLabel(params: SubTitleLabelParams) {
  SubTitleLabelInternal({
    labelSize: params.size,
    text: params.text,
    iconPath: params.icon ?? '',
    iconPosition: params.iconPosition ?? LabelIconPosition.start
  })
}

@Builder
export function ItemLabel(params: ItemLabelParams) {
  ItemLabelInternal({
    labelSize: params.size,
    text: params.text,
    iconPath: params.icon ?? '',
    iconPosition: params.iconPosition ?? LabelIconPosition.start
  })
}

@Builder
export function DangerLabel(params: DangerLabelParams) {
  DangerLabelInternal({
    labelSize: params.size,
    text: params.text,
    iconPath: params.icon ?? '',
    iconPosition: params.iconPosition ?? LabelIconPosition.start
  })
}

@Builder
export function CustomLabel(params: CustomLabelParams) {
  LabelInternal({
    text: params.text,
    font: params.font,
    textColor: params.textColor,
    bgColor: params.backgroundColor ?? Color.Transparent,
    lineLimit: params.lineLimit ?? 1,
    iconPath: params.icon ?? '',
    iconPosition: params.iconPosition ?? LabelIconPosition.start
  })
}

@Component
struct TagLabelInternal {
  @Prop labelSize: LabelSize = LabelSize.m;
  @Prop text: string = '';
  @Prop colorType: TagLabelColor = TagLabelColor.blue;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    LabelInternal({
      text: this.text,
      font: this.getFont(),
      textColor: this.getTextColor(),
      bgColor: this.getBackgroundColor(),
      lineLimit: 1,
      iconPath: '',
      iconPosition: LabelIconPosition.start
    })
  }

  private getFont(): number {
    const fonts = FontScheme;
    return getTagLabelFont(this.labelSize, fonts);
  }

  private getTextColor(): ResourceColor {

    return getTagLabelTextColor(this.colorType, this.themeState.colors);
  }

  private getBackgroundColor(): ResourceColor {
    return getTagLabelBackgroundColor(this.colorType, this.themeState.colors);
  }
}

@Component
struct TitleLabelInternal {
  @Prop labelSize: LabelSize = LabelSize.m;
  @Prop text: string = '';
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    LabelInternal({
      text: this.text,
      font: this.getFont(),
      textColor: this.getTextColor(),
      bgColor: this.getBackgroundColor(),
      lineLimit: 1,
      iconPath: '',
      iconPosition: LabelIconPosition.start
    })
  }

  private getFont(): number {
    return getTitleLabelFont(this.labelSize, this.themeState.fonts);
  }

  private getTextColor(): ResourceColor {
    return this.themeState.colors.textColorPrimary;
  }

  private getBackgroundColor(): ResourceColor {
    return Color.Transparent;
  }
}

@Component
struct SubTitleLabelInternal {
  @Prop labelSize: LabelSize = LabelSize.m;
  @Prop text: string = '';
  @Prop iconPath: string = '';
  @Prop iconPosition: LabelIconPosition = LabelIconPosition.start;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    LabelInternal({
      text: this.text,
      font: this.getFont(),
      textColor: this.getTextColor(),
      bgColor: this.getBackgroundColor(),
      lineLimit: 1,
      iconPath: this.iconPath,
      iconPosition: this.iconPosition
    })
  }

  private getFont(): number {
    const fonts = FontScheme;
    return getSubTitleLabelFont(this.labelSize, fonts);
  }

  private getTextColor(): ResourceColor {
    return this.themeState.colors.textColorSecondary;
  }

  private getBackgroundColor(): ResourceColor {
    return Color.Transparent;
  }
}

@Component
struct ItemLabelInternal {
  @Prop labelSize: LabelSize = LabelSize.m;
  @Prop text: string = '';
  @Prop iconPath: string = '';
  @Prop iconPosition: LabelIconPosition = LabelIconPosition.start;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    LabelInternal({
      text: this.text,
      font: this.getFont(),
      textColor: this.getTextColor(),
      bgColor: this.getBackgroundColor(),
      lineLimit: 1,
      iconPath: this.iconPath,
      iconPosition: this.iconPosition
    })
  }

  private getFont(): number {
    const fonts = FontScheme;
    return getItemLabelFont(this.labelSize, fonts);
  }

  private getTextColor(): ResourceColor {
    return this.themeState.colors.textColorPrimary;
  }

  private getBackgroundColor(): ResourceColor {
    return Color.Transparent;
  }
}

@Component
struct DangerLabelInternal {
  @Prop labelSize: LabelSize = LabelSize.m;
  @Prop text: string = '';
  @Prop iconPath: string = '';
  @Prop iconPosition: LabelIconPosition = LabelIconPosition.start;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    LabelInternal({
      text: this.text,
      font: this.getFont(),
      textColor: this.getTextColor(),
      bgColor: this.getBackgroundColor(),
      lineLimit: 1,
      iconPath: this.iconPath,
      iconPosition: this.iconPosition
    })
  }

  private getFont(): number {
    const fonts = FontScheme;
    return getDangerLabelFont(this.labelSize, fonts);
  }

  private getTextColor(): ResourceColor {
    return this.themeState.colors.textColorError;
  }

  private getBackgroundColor(): ResourceColor {
    return Color.Transparent;
  }
}

@Component
struct LabelInternal {
  @Prop text: string = '';
  @Prop font: number = 14;
  @Prop textColor: ResourceColor = Color.Black;
  @Prop bgColor: ResourceColor = Color.Transparent;
  @Prop lineLimit: number = 1;
  @Prop iconPath: string = '';
  @Prop iconPosition: LabelIconPosition = LabelIconPosition.start;

  @Builder
  buildWithIcon() {
    Row({ space: 4 }) {
      if (this.iconPosition === LabelIconPosition.start) {
        Image(this.iconPath)
          .width(14)
          .height(14)
          .objectFit(ImageFit.Contain)
      }

      Text(this.text)
        .fontSize(this.font)
        .fontColor(this.textColor)
        .maxLines(this.lineLimit)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.iconPosition === LabelIconPosition.end) {
        Image(this.iconPath)
          .width(14)
          .height(14)
          .objectFit(ImageFit.Contain)
      }
    }
    .padding({ left: 4, right: 4 })
    .backgroundColor(this.bgColor)
    .borderRadius(4)
  }

  @Builder
  buildWithoutIcon() {
    Text(this.text)
      .fontSize(this.font)
      .fontColor(this.textColor)
      .maxLines(this.lineLimit)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .padding({ left: 4, right: 4 })
      .backgroundColor(this.bgColor)
      .borderRadius(4)
  }

  build() {
    if (this.hasIcon()) {
      this.buildWithIcon()
    } else {
      this.buildWithoutIcon()
    }
  }

  private hasIcon(): boolean {
    return this.iconPath !== undefined && this.iconPath.length > 0;
  }
} 