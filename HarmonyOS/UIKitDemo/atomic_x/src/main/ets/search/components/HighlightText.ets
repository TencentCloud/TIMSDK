
export interface TextSegment {
  text: string;
  isHighlight: boolean;
}
@Component
export struct HighlightText {
  @Prop text: string = '';
  @Prop keyword: string = ''; 
  @Prop fontSize: number = 16;
  @Prop fontWeight: FontWeight = FontWeight.Normal;
  @Prop textColor: ResourceColor = '#000000';
  @Prop maxLines: number = 2;
  @Prop highlightColor: string = '#1C66E5';
  
  
  onHighlightClick?: (highlightText: string, index: number) => void;

  build() {
    Text() {
      ForEach(this.getTextSegments(), (segment: TextSegment, index: number) => {
        if (segment.isHighlight) {
          Span(segment.text)
            .fontColor(this.highlightColor)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              if (this.onHighlightClick) {
                this.onHighlightClick(segment.text, index);
              }
            })
        } else {
          Span(segment.text)
            .fontColor(this.textColor)
            .fontWeight(this.fontWeight)
        }
      }, (segment: TextSegment, index: number) => `${index}_${segment.text}`)
    }
    .fontSize(this.fontSize)
    .maxLines(this.maxLines)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .width('100%')
  }

  
  private getTextSegments(): TextSegment[] {
    if (this.keyword && this.keyword.trim().length > 0) {
      return this.highlightByKeyword(this.text, this.keyword);
    } else {
      return this.parseHighlightText(this.text);
    }
  }

  
  private highlightByKeyword(text: string, keyword: string): TextSegment[] {
    if (!text || !keyword) {
      return [{ text: text, isHighlight: false }];
    }

    const segments: TextSegment[] = [];
    const regex = new RegExp(`(${keyword})`, 'gi');
    let lastIndex = 0;
    let match: RegExpExecArray | null = null;

    while ((match = regex.exec(text)) !== null) {
      
      if (match.index > lastIndex) {
        const normalText = text.substring(lastIndex, match.index);
        if (normalText.length > 0) {
          segments.push({ text: normalText, isHighlight: false });
        }
      }

      
      const highlightText = match[1];
      if (highlightText.length > 0) {
        segments.push({ text: highlightText, isHighlight: true });
      }

      lastIndex = regex.lastIndex;
    }

    
    if (lastIndex < text.length) {
      const remainingText = text.substring(lastIndex);
      if (remainingText.length > 0) {
        segments.push({ text: remainingText, isHighlight: false });
      }
    }

    return segments;
  }

  
  private parseHighlightText(text: string): TextSegment[] {
    if (!text || !text.includes('<span')) {
      return [{ text: text, isHighlight: false }];
    }

    const segments: TextSegment[] = [];
    const regex = /<span[^>]*>(.*?)<\/span>/gi;
    let lastIndex = 0;
    let match: RegExpExecArray | null = null;

    while ((match = regex.exec(text)) !== null) {
      
      if (match.index > lastIndex) {
        const normalText = text.substring(lastIndex, match.index);
        if (normalText.length > 0) {
          segments.push({ text: normalText, isHighlight: false });
        }
      }

      
      const highlightText = match[1];
      if (highlightText.length > 0) {
        segments.push({ text: highlightText, isHighlight: true });
      }

      lastIndex = regex.lastIndex;
    }

    
    if (lastIndex < text.length) {
      const remainingText = text.substring(lastIndex);
      if (remainingText.length > 0) {
        segments.push({ text: remainingText, isHighlight: false });
      }
    }

    return segments;
  }
} 