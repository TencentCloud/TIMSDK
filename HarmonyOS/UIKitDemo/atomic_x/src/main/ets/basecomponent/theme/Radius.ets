
export class SemanticRadiusScheme {
  public tipsRadius: number; 
  public smallRadius: number; 
  public alertRadius: number; 
  public largeRadius: number; 
  public superLargeRadius: number; 
  public roundRadius: number; 

  constructor(
    tipsRadius: number,
    smallRadius: number,
    alertRadius: number,
    largeRadius: number,
    superLargeRadius: number,
    roundRadius: number
  ) {
    this.tipsRadius = tipsRadius;
    this.smallRadius = smallRadius;
    this.alertRadius = alertRadius;
    this.largeRadius = largeRadius;
    this.superLargeRadius = superLargeRadius;
    this.roundRadius = roundRadius;
  }
}
class Radius {
  static Radius4: number = 4;
  static Radius8: number = 8;
  static Radius12: number = 12;
  static Radius16: number = 16;
  static Radius20: number = 20;
  static Radius999: number = 999;
}
export const RadiusScheme = new SemanticRadiusScheme(
  Radius.Radius4,
  Radius.Radius8,
  Radius.Radius12,
  Radius.Radius16,
  Radius.Radius20,
  Radius.Radius999
); 