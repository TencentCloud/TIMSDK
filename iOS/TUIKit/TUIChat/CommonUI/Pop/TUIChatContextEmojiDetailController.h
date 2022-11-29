//
//  TUIChatContextEmojiDetailController.h
//  TUIChat
//
//  Created by wyl on 2022/10/27.
//

#import "TUIChatFlexViewController.h"
#import "TUIFaceView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIContextChatPopEmojiFaceView : TUIFaceView

@end

@interface TUIChatContextEmojiDetailController : TUIChatFlexViewController

@property (nonatomic, copy) void(^reactClickCallback)(NSString *faceName);

@end

NS_ASSUME_NONNULL_END
