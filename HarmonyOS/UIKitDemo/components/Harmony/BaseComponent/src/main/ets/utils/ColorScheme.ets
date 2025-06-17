import { Colors } from '../utils/Colors'

export default interface ColorScheme {
  // text & icon
  textColorPrimary: string;
  textColorSecondary: string;
  textColorTertiary: string;
  textColorDisable: string;
  textColorButton: string;
  textColorButtonDisabled: string;
  textColorLink: string;
  textColorLinkHover: string;
  textColorLinkActive: string;
  textColorLinkDisabled: string;
  textColorAntiPrimary: string;
  textColorAntiSecondary: string;
  textColorWarning: string;
  textColorSuccess: string;
  textColorError: string;

  // background
  bgColorTopBar: string;
  bgColorOperate: string;
  bgColorDialog: string;
  bgColorDialogModule: string;
  bgColorEntryCard: string;
  bgColorFunction: string;
  bgColorBottomBar: string;
  bgColorInput: string;
  bgColorBubbleReciprocal: string;
  bgColorBubbleOwn: string;
  bgColorDefault: string;
  bgColorTagMask: string;
  bgColorElementMask: string;
  bgColorMask: string;
  bgColorMaskDisappeared: string;
  bgColorMaskBegin: string;

  // border
  strokeColorPrimary: string;
  strokeColorSecondary: string;
  strokeColorModule: string;

  // shadow
  shadowColor: string;

  // status
  listColorDefault: string;
  listColorHover: string;
  listColorFocused: string;

  // button
  buttonColorPrimaryDefault: string;
  buttonColorPrimaryHover: string;
  buttonColorPrimaryActive: string;
  buttonColorPrimaryDisabled: string;
  buttonColorSecondaryDefault: string;
  buttonColorSecondaryHover: string;
  buttonColorSecondaryActive: string;
  buttonColorSecondaryDisabled: string;
  buttonColorAccept: string;
  buttonColorHangupDefault: string;
  buttonColorHangupDisabled: string;
  buttonColorHangupHover: string;
  buttonColorHangupActive: string;
  buttonColorOn: string;
  buttonColorOff: string;

  // dropdown
  dropdownColorDefault: string;
  dropdownColorHover: string;
  dropdownColorActive: string;

  // scrollbar
  scrollbarColorDefault: string;
  scrollbarColorHover: string;

  // floating
  floatingColorDefault: string;
  floatingColorOperate: string;

  // checkbox
  checkboxColorSelected: string;

  // toast
  toastColorWarning: string;
  toastColorSuccess: string;
  toastColorError: string;
  toastColorDefault: string;

  // tag
  tagColorLevel1: string;
  tagColorLevel2: string;
  tagColorLevel3: string;
  tagColorLevel4: string;

  // switch
  switchColorOff: string;
  switchColorOn: string;
  switchColorButton: string;

  // slider
  sliderColorFilled: string;
  sliderColorEmpty: string;
  sliderColorButton: string;

  // tab
  tabColorSelected: string;
  tabColorUnselected: string;
  tabColorOption: string;
}

// 主题基础配置
class DefaultTheme implements ColorScheme {
  // text & icon
  textColorPrimary: string = Colors.Black2;
  textColorSecondary: string = Colors.Black4;
  textColorTertiary: string = Colors.Black5;
  textColorDisable: string = Colors.Black6;
  textColorButton: string = Colors.White1;
  textColorButtonDisabled: string = Colors.White1;
  textColorLink: string = Colors.ThemeLight6;
  textColorLinkHover: string = Colors.ThemeLight5;
  textColorLinkActive: string = Colors.ThemeLight7;
  textColorLinkDisabled: string = Colors.ThemeLight2;
  textColorAntiPrimary: string = Colors.Black2;
  textColorAntiSecondary: string = Colors.Black4;
  textColorWarning: string = Colors.OrangeLight6;
  textColorSuccess: string = Colors.GreenLight6;
  textColorError: string = Colors.RedLight6;
  // background
  bgColorTopBar: string = Colors.GrayLight1;
  bgColorOperate: string = Colors.White1;
  bgColorDialog: string = Colors.White1;
  bgColorDialogModule: string = Colors.GrayLight2;
  bgColorEntryCard: string = Colors.GrayLight2;
  bgColorFunction: string = Colors.GrayLight2;
  bgColorBottomBar: string = Colors.White1;
  bgColorInput: string = Colors.GrayLight2;
  bgColorBubbleReciprocal: string = Colors.GrayLight2;
  bgColorBubbleOwn: string = Colors.ThemeLight2;
  bgColorDefault: string = Colors.GrayLight2;
  bgColorTagMask: string = Colors.White4;
  bgColorElementMask: string = Colors.Black6;
  bgColorMask: string = Colors.Black4;
  bgColorMaskDisappeared: string = Colors.White7;
  bgColorMaskBegin: string = Colors.White1;
  // border
  strokeColorPrimary: string = Colors.GrayLight3;
  strokeColorSecondary: string = Colors.GrayLight2;
  strokeColorModule: string = Colors.GrayLight3;
  // shadow
  shadowColor: string = Colors.Black8;
  // status
  listColorDefault: string = Colors.White1;
  listColorHover: string = Colors.GrayLight1;
  listColorFocused: string = Colors.ThemeLight1;
  // button
  buttonColorPrimaryDefault: string = Colors.ThemeLight6;
  buttonColorPrimaryHover: string = Colors.ThemeLight5;
  buttonColorPrimaryActive: string = Colors.ThemeLight7;
  buttonColorPrimaryDisabled: string = Colors.ThemeLight2;
  buttonColorSecondaryDefault: string = Colors.GrayLight2;
  buttonColorSecondaryHover: string = Colors.GrayLight1;
  buttonColorSecondaryActive: string = Colors.GrayLight3;
  buttonColorSecondaryDisabled: string = Colors.GrayLight1;
  buttonColorAccept: string = Colors.GreenLight6;
  buttonColorHangupDefault: string = Colors.RedLight6;
  buttonColorHangupDisabled: string = Colors.RedLight2;
  buttonColorHangupHover: string = Colors.RedLight5;
  buttonColorHangupActive: string = Colors.RedLight7;
  buttonColorOn: string = Colors.White1;
  buttonColorOff: string = Colors.Black5;
  // dropdown
  dropdownColorDefault: string = Colors.White1;
  dropdownColorHover: string = Colors.GrayLight1;
  dropdownColorActive: string = Colors.ThemeLight1;
  // scrollbar
  scrollbarColorDefault: string = Colors.Black7;
  scrollbarColorHover: string = Colors.Black6;
  // floating
  floatingColorDefault: string = Colors.White1;
  floatingColorOperate: string = Colors.GrayLight2;
  // checkbox
  checkboxColorSelected: string = Colors.ThemeLight6;
  // toast
  toastColorWarning: string = Colors.OrangeLight1;
  toastColorSuccess: string = Colors.GreenLight1;
  toastColorError: string = Colors.RedLight1;
  toastColorDefault: string = Colors.ThemeLight1;
  // tag
  tagColorLevel1: string = Colors.AccentTurquoiseLight;
  tagColorLevel2: string = Colors.ThemeLight5;
  tagColorLevel3: string = Colors.AccentPurpleLight;
  tagColorLevel4: string = Colors.AccentMagentaLight;
  // switch
  switchColorOff: string = Colors.GrayLight4;
  switchColorOn: string = Colors.ThemeLight6;
  switchColorButton: string = Colors.White1;
  // slider
  sliderColorFilled: string = Colors.ThemeLight6;
  sliderColorEmpty: string = Colors.GrayLight3;
  sliderColorButton: string = Colors.White1;
  // tab
  tabColorSelected: string = Colors.ThemeLight2;
  tabColorUnselected: string = Colors.GrayLight2;
  tabColorOption: string = Colors.GrayLight3;
}

class LightColorTheme extends DefaultTheme {
}

class DarkColorTheme extends DefaultTheme {
  // text & icon
  override textColorPrimary: string = Colors.White2;
  override textColorSecondary: string = Colors.White4;
  override textColorTertiary: string = Colors.White6;
  override textColorDisable: string = Colors.White7;
  override textColorButton: string = Colors.White1;
  override textColorButtonDisabled: string = Colors.White5;
  override textColorLink: string = Colors.ThemeDark6;
  override textColorLinkHover: string = Colors.ThemeDark5;
  override textColorLinkActive: string = Colors.ThemeDark7;
  override textColorLinkDisabled: string = Colors.ThemeDark2;
  override textColorAntiPrimary: string = Colors.Black2;
  override textColorAntiSecondary: string = Colors.Black4;
  override textColorWarning: string = Colors.OrangeDark6;
  override textColorSuccess: string = Colors.GreenDark6;
  override textColorError: string = Colors.RedDark6;
  // background
  override bgColorTopBar: string = Colors.GrayDark1;
  override bgColorOperate: string = Colors.GrayDark2;
  override bgColorDialog: string = Colors.GrayDark2;
  override bgColorDialogModule: string = Colors.GrayDark3;
  override bgColorEntryCard: string = Colors.GrayDark3;
  override bgColorFunction: string = Colors.GrayDark4;
  override bgColorBottomBar: string = Colors.GrayDark3;
  override bgColorInput: string = Colors.GrayDark3;
  override bgColorBubbleReciprocal: string = Colors.GrayDark3;
  override bgColorBubbleOwn: string = Colors.ThemeDark7;
  override bgColorDefault: string = Colors.GrayDark1;
  override bgColorTagMask: string = Colors.Black4;
  override bgColorElementMask: string = Colors.Black6;
  override bgColorMask: string = Colors.Black4;
  override bgColorMaskDisappeared: string = Colors.Black8;
  override bgColorMaskBegin: string = Colors.Black2;
  // border
  override strokeColorPrimary: string = Colors.GrayDark4;
  override strokeColorSecondary: string = Colors.GrayDark3;
  override strokeColorModule: string = Colors.GrayDark5;
  // shadow
  override shadowColor: string = Colors.Black8;
  // status
  override listColorDefault: string = Colors.GrayDark2;
  override listColorHover: string = Colors.GrayDark3;
  override listColorFocused: string = Colors.ThemeDark2;
  // button
  override buttonColorPrimaryDefault: string = Colors.ThemeDark6;
  override buttonColorPrimaryHover: string = Colors.ThemeDark5;
  override buttonColorPrimaryActive: string = Colors.ThemeDark7;
  override buttonColorPrimaryDisabled: string = Colors.ThemeDark2;
  override buttonColorSecondaryDefault: string = Colors.GrayDark4;
  override buttonColorSecondaryHover: string = Colors.GrayDark3;
  override buttonColorSecondaryActive: string = Colors.GrayDark5;
  override buttonColorSecondaryDisabled: string = Colors.GrayDark3;
  override buttonColorAccept: string = Colors.GreenDark6;
  override buttonColorHangupDefault: string = Colors.RedDark6;
  override buttonColorHangupDisabled: string = Colors.RedDark2;
  override buttonColorHangupHover: string = Colors.RedDark5;
  override buttonColorHangupActive: string = Colors.RedDark7;
  override buttonColorOn: string = Colors.White1;
  override buttonColorOff: string = Colors.Black5;
  // dropdown
  override dropdownColorDefault: string = Colors.GrayDark3;
  override dropdownColorHover: string = Colors.GrayDark4;
  override dropdownColorActive: string = Colors.GrayDark2;
  // scrollbar
  override scrollbarColorDefault: string = Colors.White7;
  override scrollbarColorHover: string = Colors.White6;
  // floating
  override floatingColorDefault: string = Colors.GrayDark3;
  override floatingColorOperate: string = Colors.GrayDark4;
  // checkbox
  override checkboxColorSelected: string = Colors.ThemeDark5;
  // toast
  override toastColorWarning: string = Colors.OrangeDark2;
  override toastColorSuccess: string = Colors.GreenDark2;
  override toastColorError: string = Colors.RedDark2;
  override toastColorDefault: string = Colors.ThemeDark2;
  // tag
  override tagColorLevel1: string = Colors.AccentTurquoiseDark;
  override tagColorLevel2: string = Colors.ThemeDark5;
  override tagColorLevel3: string = Colors.AccentPurpleDark;
  override tagColorLevel4: string = Colors.AccentMagentaDark;
  // switch
  override switchColorOff: string = Colors.GrayDark4;
  override switchColorOn: string = Colors.ThemeDark5;
  override switchColorButton: string = Colors.White1;
  // slider
  override sliderColorFilled: string = Colors.ThemeDark5;
  override sliderColorEmpty: string = Colors.GrayDark5;
  override sliderColorButton: string = Colors.White1;
  // tab
  override tabColorSelected: string = Colors.GrayDark5;
  override tabColorUnselected: string = Colors.GrayDark4;
  override tabColorOption: string = Colors.GrayDark4;
}

// 自定义主题示例
class BlueTheme extends DefaultTheme {
  primary: string = '#1890FF';
  // text: string = Color.Pink;
  card: string = '#E6F7FF';
}

export {
  ColorScheme, DefaultTheme, LightColorTheme, DarkColorTheme, BlueTheme
};