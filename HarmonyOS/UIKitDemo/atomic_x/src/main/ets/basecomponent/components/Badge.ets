import { ThemeState } from '../theme/ThemeState'
export enum BadgeType {
  Text = 'Text',
  Dot = 'Dot'
}
@Component
export struct BadgeControl {
  @Prop text?: string | Resource
  @Prop type: BadgeType = BadgeType.Text
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance()

  build() {
    if (!this.text || this.type === BadgeType.Dot) {
      
      Row() {
      }
      .width(8)
      .height(8)
      .backgroundColor(this.themeState.colors.textColorError)
      .borderRadius(4) 
    } else {
      
      Text(this.text)
        .height(16)
        .backgroundColor(this.themeState.colors.textColorError)
        .borderRadius(8)
        .padding({
          left: 5,
          right: 5
        })
        .fontColor(this.themeState.colors.textColorButton)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .constraintSize({
          minWidth: 16
        })
    }
  }
}
export default BadgeControl