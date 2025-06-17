import { MessageInfo, MessageStatus } from 'chatengine/src/main/ets/pages/MessageListState';
import { ImageSizeUtil, ThemeManager, TimeUtil } from 'basecomponent';
import { MessageBody } from 'chatengine';
import { MessageListState } from 'chatengine/src/main/ets/pages/MessageListState';
import { EmojiDataManager, EmojiItem } from 'emojipicker';
import { MessageListStyle } from '../config/MessageListConfig';

/**
 * 表情文本解析结果接口
 */
interface EmojiTextSegment {
  type: 'text' | 'emoji';
  content: string;
  imageFile?: string;
}

/**
 * 解析包含表情的文本
 * @param text 原始文本
 * @returns 解析后的文本段落数组
 */
function parseEmojiText(text: string): EmojiTextSegment[] {
  const segments: EmojiTextSegment[] = [];
  const emojiRegex = /\[[a-zA-Z0-9_@\u4e00-\u9fa5]+\]/g;

  let lastIndex = 0;
  let match: RegExpExecArray | null = null;

  while ((match = emojiRegex.exec(text)) !== null) {
    // 添加表情前的文本
    if (match.index > lastIndex) {
      const textContent = text.substring(lastIndex, match.index);
      if (textContent.length > 0) {
        segments.push({
          type: 'text',
          content: textContent
        });
      }
    }

    // 查找对应的表情
    const emojiName: string = match[0];
    const allEmojis: EmojiItem[] = EmojiDataManager.getAllEmojis();
    const emoji: EmojiItem | undefined = allEmojis.find((item: EmojiItem) => item.name === emojiName);

    if (emoji) {
      // 找到对应表情，添加表情段落
      segments.push({
        type: 'emoji',
        content: emojiName,
        imageFile: emoji.imageFile
      });
    } else {
      // 未找到对应表情，作为普通文本处理
      segments.push({
        type: 'text',
        content: emojiName
      });
    }

    lastIndex = emojiRegex.lastIndex;
  }

  // 添加剩余的文本
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
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @State isRoomStyle: boolean = true;
  @State private parsedSegments: EmojiTextSegment[] = [];

  aboutToAppear() {
    this.updateParsedSegments();
  }

  aboutToUpdate() {
    this.updateParsedSegments();
  }

  /**
   * 构建混合文本和表情的内容
   */
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
    this.themeManager.currentTheme.textColorAntiPrimary :
    this.themeManager.currentTheme.textColorPrimary)
    .textOverflow({ overflow: TextOverflow.None })
    .maxLines(999)
    .wordBreak(WordBreak.BREAK_ALL)
  }

  @Builder
  buildRoomStyleMixedContent() {
    Text() {
      Span(this.message?.sender + ":").fontColor(Color.Blue)
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
    .fontSize(12)
    .fontColor('#FFFFFF')
    .backgroundColor('rgba(0, 0, 0, 0.3)')
    .padding({
      left: 8,
      right: 8,
      top: 2,
      bottom: 2
    })
    .borderRadius(10)
    .maxLines(999)
    .wordBreak(WordBreak.BREAK_ALL)
  }

  build() {
    Column() {
      // 消息内容 - 使用混合内容构建器
      if (this.isRoomStyle) {
        this.buildRoomStyleMixedContent()
      } else {
        this.buildMixedContent()
        // 时间和状态
        Row() {
          if (this.message?.status === MessageStatus.sending) {
            LoadingProgress()
              .width(12)
              .height(12)
              .margin({ right: 4 })
          }
          Text(TimeUtil.formatRelativeTime(this.message?.dateTime?.getTime() ?? 0))
            .fontSize(12)
            .fontColor(this.message?.isSelf ?
            this.themeManager.currentTheme.textColorAntiSecondary :
            this.themeManager.currentTheme.textColorTertiary)
        }
        .alignSelf(ItemAlign.End)
        .margin({ top: 4 })
      }

    }
    .alignItems(HorizontalAlign.Start)
    .constraintSize({
      maxWidth: '75%',
      minWidth: 60
    })
    .padding({
      left: 8,
      right: 8,
      top: 8,
      bottom: 6
    })
  }

  /**
   * 更新解析后的文本段落
   */
  private updateParsedSegments() {
    const text = this.messageBody?.text ?? '';
    this.parsedSegments = parseEmojiText(text);
  }
}

/**
 * TextMessageView 构建器函数
 * @param messageData 消息数据
 * @param messageListState 消息列表状态（可选）
 * @param messageListStyle 消息列表样式（可选）
 */
@Builder
export function TextMessageView(messageData: MessageInfo, messageListState?: MessageListState, messageListStyle?: MessageListStyle) {
  if (messageData && messageData.messageBody) {
    TextMessageViewContent({ 
      message: messageData, 
      messageBody: messageData.messageBody,
      isRoomStyle: messageListStyle === MessageListStyle.RoomStyle
    })
  }
}