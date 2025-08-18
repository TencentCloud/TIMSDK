
export class SemanticSpacingScheme {
  public iconTextSpacing: number; 
  public smallSpacing: number; 
  public iconIconSpacing: number; 
  public bubbleSpacing: number; 
  public contentSpacing: number; 
  public normalSpacing: number;
  public titleSpacing: number; 
  public cardSpacing: number; 
  public largeSpacing: number;
  public maxSpacing: number; 

  constructor(
    iconTextSpacing: number,
    smallSpacing: number,
    iconIconSpacing: number,
    bubbleSpacing: number,
    contentSpacing: number,
    normalSpacing: number,
    titleSpacing: number,
    cardSpacing: number,
    largeSpacing: number,
    maxSpacing: number
  ) {
    this.iconTextSpacing = iconTextSpacing;
    this.smallSpacing = smallSpacing;
    this.iconIconSpacing = iconIconSpacing;
    this.bubbleSpacing = bubbleSpacing;
    this.contentSpacing = contentSpacing;
    this.normalSpacing = normalSpacing;
    this.titleSpacing = titleSpacing;
    this.cardSpacing = cardSpacing;
    this.largeSpacing = largeSpacing;
    this.maxSpacing = maxSpacing;
  }
}
class Spacings {
  static Spacing4: number = 4;
  static Spacing8: number = 8;
  static Spacing12: number = 12;
  static Spacing16: number = 16;
  static Spacing20: number = 20;
  static Spacing24: number = 24;
  static Spacing32: number = 32;
  static Spacing40: number = 40;
  static Spacing56: number = 56;
  static Spacing72: number = 72;
}
export const SpacingScheme = new SemanticSpacingScheme(
  Spacings.Spacing4,
  Spacings.Spacing8,
  Spacings.Spacing12,
  Spacings.Spacing16,
  Spacings.Spacing20,
  Spacings.Spacing24,
  Spacings.Spacing32,
  Spacings.Spacing40,
  Spacings.Spacing56,
  Spacings.Spacing72
); 