#import "TUIBubbleMessageCell.h"
#import "TUITextMessageCellData.h"

@class TUITextView;

typedef void(^TUIChatSelectAllContentCallback)(BOOL);

@interface TUITextMessageCell : TUIBubbleMessageCell<UITextViewDelegate>

/**
 *  展示文本消息的内容容器
 *  TextView for display text message content
 */
@property (nonatomic, strong) TUITextView *textView;

/**
 *  选中文本内容
 *  Selected text content
 */
@property (nonatomic, strong) NSString *selectContent;

/**
 *  选中全部文本回调
 *  Callback for selected all text
 */
@property (nonatomic, strong) TUIChatSelectAllContentCallback selectAllContentContent;


@property TUITextMessageCellData *textData;

- (void)fillWithData:(TUITextMessageCellData *)data;

@end


@interface TUITextView : UITextView
@end
