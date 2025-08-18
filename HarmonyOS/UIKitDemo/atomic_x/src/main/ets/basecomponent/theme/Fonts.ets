
export class SemanticFontScheme {
  public title1Bold: FontInfo;
  public title2Bold: FontInfo;
  public title3Bold: FontInfo;
  public title4Bold: FontInfo;
  public body1Bold: FontInfo;
  public body2Bold: FontInfo;
  public body3Bold: FontInfo;
  public body4Bold: FontInfo;
  public caption1Bold: FontInfo;
  public caption2Bold: FontInfo;
  public caption3Bold: FontInfo;
  public caption4Bold: FontInfo;

  public title1Medium: FontInfo;
  public title2Medium: FontInfo;
  public title3Medium: FontInfo;
  public title4Medium: FontInfo;
  public body1Medium: FontInfo;
  public body2Medium: FontInfo;
  public body3Medium: FontInfo;
  public body4Medium: FontInfo;
  public caption1Medium: FontInfo;
  public caption2Medium: FontInfo;
  public caption3Medium: FontInfo;
  public caption4Medium: FontInfo;

  public title1Regular: FontInfo;
  public title2Regular: FontInfo;
  public title3Regular: FontInfo;
  public title4Regular: FontInfo;
  public body1Regular: FontInfo;
  public body2Regular: FontInfo;
  public body3Regular: FontInfo;
  public body4Regular: FontInfo;
  public caption1Regular: FontInfo;
  public caption2Regular: FontInfo;
  public caption3Regular: FontInfo;
  public caption4Regular: FontInfo;

  constructor(
    title1Bold: FontInfo,
    title2Bold: FontInfo,
    title3Bold: FontInfo,
    title4Bold: FontInfo,
    body1Bold: FontInfo,
    body2Bold: FontInfo,
    body3Bold: FontInfo,
    body4Bold: FontInfo,
    caption1Bold: FontInfo,
    caption2Bold: FontInfo,
    caption3Bold: FontInfo,
    caption4Bold: FontInfo,
    title1Medium: FontInfo,
    title2Medium: FontInfo,
    title3Medium: FontInfo,
    title4Medium: FontInfo,
    body1Medium: FontInfo,
    body2Medium: FontInfo,
    body3Medium: FontInfo,
    body4Medium: FontInfo,
    caption1Medium: FontInfo,
    caption2Medium: FontInfo,
    caption3Medium: FontInfo,
    caption4Medium: FontInfo,
    title1Regular: FontInfo,
    title2Regular: FontInfo,
    title3Regular: FontInfo,
    title4Regular: FontInfo,
    body1Regular: FontInfo,
    body2Regular: FontInfo,
    body3Regular: FontInfo,
    body4Regular: FontInfo,
    caption1Regular: FontInfo,
    caption2Regular: FontInfo,
    caption3Regular: FontInfo,
    caption4Regular: FontInfo
  ) {
    this.title1Bold = title1Bold;
    this.title2Bold = title2Bold;
    this.title3Bold = title3Bold;
    this.title4Bold = title4Bold;
    this.body1Bold = body1Bold;
    this.body2Bold = body2Bold;
    this.body3Bold = body3Bold;
    this.body4Bold = body4Bold;
    this.caption1Bold = caption1Bold;
    this.caption2Bold = caption2Bold;
    this.caption3Bold = caption3Bold;
    this.caption4Bold = caption4Bold;

    this.title1Medium = title1Medium;
    this.title2Medium = title2Medium;
    this.title3Medium = title3Medium;
    this.title4Medium = title4Medium;
    this.body1Medium = body1Medium;
    this.body2Medium = body2Medium;
    this.body3Medium = body3Medium;
    this.body4Medium = body4Medium;
    this.caption1Medium = caption1Medium;
    this.caption2Medium = caption2Medium;
    this.caption3Medium = caption3Medium;
    this.caption4Medium = caption4Medium;

    this.title1Regular = title1Regular;
    this.title2Regular = title2Regular;
    this.title3Regular = title3Regular;
    this.title4Regular = title4Regular;
    this.body1Regular = body1Regular;
    this.body2Regular = body2Regular;
    this.body3Regular = body3Regular;
    this.body4Regular = body4Regular;
    this.caption1Regular = caption1Regular;
    this.caption2Regular = caption2Regular;
    this.caption3Regular = caption3Regular;
    this.caption4Regular = caption4Regular;
  }
}
class Fonts {
  static Bold40: FontInfo = { size: 40, weight: FontWeight.Bold };
  static Bold36: FontInfo = { size: 36, weight: FontWeight.Bold };
  static Bold34: FontInfo = { size: 34, weight: FontWeight.Bold };
  static Bold32: FontInfo = { size: 32, weight: FontWeight.Bold };
  static Bold28: FontInfo = { size: 28, weight: FontWeight.Bold };
  static Bold24: FontInfo = { size: 24, weight: FontWeight.Bold };
  static Bold20: FontInfo = { size: 20, weight: FontWeight.Bold };
  static Bold18: FontInfo = { size: 18, weight: FontWeight.Bold };
  static Bold16: FontInfo = { size: 16, weight: FontWeight.Bold };
  static Bold14: FontInfo = { size: 14, weight: FontWeight.Bold };
  static Bold12: FontInfo = { size: 12, weight: FontWeight.Bold };
  static Bold10: FontInfo = { size: 10, weight: FontWeight.Bold };

  static Medium40: FontInfo = { size: 40, weight: FontWeight.Medium };
  static Medium36: FontInfo = { size: 36, weight: FontWeight.Medium };
  static Medium34: FontInfo = { size: 34, weight: FontWeight.Medium };
  static Medium32: FontInfo = { size: 32, weight: FontWeight.Medium };
  static Medium28: FontInfo = { size: 28, weight: FontWeight.Medium };
  static Medium24: FontInfo = { size: 24, weight: FontWeight.Medium };
  static Medium20: FontInfo = { size: 20, weight: FontWeight.Medium };
  static Medium18: FontInfo = { size: 18, weight: FontWeight.Medium };
  static Medium16: FontInfo = { size: 16, weight: FontWeight.Medium };
  static Medium14: FontInfo = { size: 14, weight: FontWeight.Medium };
  static Medium12: FontInfo = { size: 12, weight: FontWeight.Medium };
  static Medium10: FontInfo = { size: 10, weight: FontWeight.Medium };

  static Regular40: FontInfo = { size: 40, weight: FontWeight.Normal };
  static Regular36: FontInfo = { size: 36, weight: FontWeight.Normal };
  static Regular34: FontInfo = { size: 34, weight: FontWeight.Normal };
  static Regular32: FontInfo = { size: 32, weight: FontWeight.Normal };
  static Regular28: FontInfo = { size: 28, weight: FontWeight.Normal };
  static Regular24: FontInfo = { size: 24, weight: FontWeight.Normal };
  static Regular20: FontInfo = { size: 20, weight: FontWeight.Normal };
  static Regular18: FontInfo = { size: 18, weight: FontWeight.Normal };
  static Regular16: FontInfo = { size: 16, weight: FontWeight.Normal };
  static Regular14: FontInfo = { size: 14, weight: FontWeight.Normal };
  static Regular12: FontInfo = { size: 12, weight: FontWeight.Normal };
  static Regular10: FontInfo = { size: 10, weight: FontWeight.Normal };
}
export interface FontInfo {
  size: number;
  weight: FontWeight;
}
export const FontScheme = new SemanticFontScheme(
  Fonts.Bold40,
  Fonts.Bold36,
  Fonts.Bold34,
  Fonts.Bold32,
  Fonts.Bold28,
  Fonts.Bold24,
  Fonts.Bold20,
  Fonts.Bold18,
  Fonts.Bold16,
  Fonts.Bold14,
  Fonts.Bold12,
  Fonts.Bold10,

  Fonts.Medium40,
  Fonts.Medium36,
  Fonts.Medium34,
  Fonts.Medium32,
  Fonts.Medium28,
  Fonts.Medium24,
  Fonts.Medium20,
  Fonts.Medium18,
  Fonts.Medium16,
  Fonts.Medium14,
  Fonts.Medium12,
  Fonts.Medium10,

  Fonts.Regular40,
  Fonts.Regular36,
  Fonts.Regular34,
  Fonts.Regular32,
  Fonts.Regular28,
  Fonts.Regular24,
  Fonts.Regular20,
  Fonts.Regular18,
  Fonts.Regular16,
  Fonts.Regular14,
  Fonts.Regular12,
  Fonts.Regular10
); 