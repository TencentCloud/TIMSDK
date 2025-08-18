import { MessageInfo, MessageStatus } from 'chatengine';
import { ImageSizeUtil, ThemeState, TimeUtil } from '../../basecomponent/Index';
import { MessageBody } from 'chatengine';
import { MessageListStore } from 'chatengine';
import { EmojiDataManager, EmojiItem } from '../../emojipicker/Index';

interface EmojiTextSegment {
  type: 'text' | 'emoji';
  content: string;
  imageFile?: string;
}

function parseEmojiText(text: string): EmojiTextSegment[] {
  const segments: EmojiTextSegment[] = [];
  const emojiRegex = /\[[a-zA-Z0-9_@\u4e00-\u9fa5]+\]/g;

  let lastIndex = 0;
  let match: RegExpExecArray | null = null;

  while ((match = emojiRegex.exec(text)) !== null) {

    if (match.index > lastIndex) {
      const textContent = text.substring(lastIndex, match.index);
      if (textContent.length > 0) {
        segments.push({
          type: 'text',
          content: textContent
        });
      }
    }


    const emojiName: string = match[0];
    const allEmojis: EmojiItem[] = EmojiDataManager.getAllEmojis();
    const emoji: EmojiItem | undefined = allEmojis.find((item: EmojiItem) => item.name === emojiName);

    if (emoji) {

      segments.push({
        type: 'emoji',
        content: emojiName,
        imageFile: emoji.imageFile
      });
    } else {

      segments.push({
        type: 'text',
        content: emojiName
      });
    }

    lastIndex = emojiRegex.lastIndex;
  }


  if (lastIndex < text.length) {
    const remainingText = text.substring(lastIndex);
    if (remainingText.length > 0) {
      segments.push({
        type: 'text',
        content: remainingText
      });
    }
  }

  return segments;
}

@Component
export struct TextMessageViewContent {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @State private parsedSegments: EmojiTextSegment[] = [];

  aboutToAppear() {
    this.updateParsedSegments();
  }

  aboutToUpdate() {
    this.updateParsedSegments();
  }

  @Builder
  buildMixedContent() {
    Text() {
      ForEach(this.parsedSegments, (segment: EmojiTextSegment, index: number) => {
        if (segment.type === 'text') {
          Span(segment.content)
        } else if (segment.type === 'emoji' && segment.imageFile) {
          ImageSpan(EmojiDataManager.getEmojiImageResource(segment.imageFile))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .verticalAlign(ImageSpanAlignment.CENTER)
        }
      }, (segment: EmojiTextSegment, index: number) => `${segment.type}_${index}_${segment.content}`)
    }
    .fontSize(16)
    .fontColor(this.message?.isSelf ?
    this.themeState.colors.textColorAntiPrimary :
    this.themeState.colors.textColorPrimary)
    .textOverflow({ overflow: TextOverflow.None })
    .maxLines(999)
    .wordBreak(WordBreak.BREAK_ALL)
  }

  build() {
    Column() {

      this.buildMixedContent()

      Row() {
        if (this.message?.status === MessageStatus.sending) {
          LoadingProgress()
            .width(12)
            .height(12)
            .margin({ right: 4 })
        }
      }
      .alignSelf(ItemAlign.End)
      .margin({ top: 4 })

    }
    .alignItems(HorizontalAlign.Start)
    .constraintSize({
      maxWidth: '100%',
      minWidth: 0
    })
    .padding({
      left: 8,
      right: 8,
      top: 8,
      bottom: 6
    })
  }

  private updateParsedSegments() {
    const text = this.messageBody?.text ?? '';
    this.parsedSegments = parseEmojiText(text);
  }
}

@Builder
export function TextMessageView(messageData: MessageInfo, MessageListStore?: MessageListStore) {
  if (messageData && messageData.messageBody) {
    TextMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody
    })
  }
}