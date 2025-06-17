@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message = 'Welcome';
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}

export { EmojiPicker } from './EmojiPicker';
export { EmojiDataManager, EmojiItem, EmojiCategory } from '../data/EmojiData';
export { LocalizationUtils } from '../utils/LocalizationUtils';