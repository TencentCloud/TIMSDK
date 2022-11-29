#import "TUIBubbleMessageCell_Minimalist.h"
#import "TUITextMessageCellData_Minimalist.h"
#import "TUITextView.h"
#import "TUIChatDefine.h"

@interface TUITextMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist<UITextViewDelegate>

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


@property TUITextMessageCellData_Minimalist *textData;

- (void)fillWithData:(TUITextMessageCellData_Minimalist *)data;

@end

