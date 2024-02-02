//
//  TUIReactContextEmojiDetailController.h
//  TUIChat
//
//  Created by wyl on 2022/10/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatFlexViewController.h"
#import <TUIChat/TUIFaceVerticalView.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIReactContextPopEmojiFaceView : TUIFaceVerticalView

@end

@interface TUIReactContextEmojiDetailController : TUIChatFlexViewController

@property(nonatomic, copy) void (^reactClickCallback)(NSString *faceName);

@end

NS_ASSUME_NONNULL_END
