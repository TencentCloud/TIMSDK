//
//  TUICallingView.h
//  TUICalling
//
//  Created by noah on 2021/8/23.
//

#import <UIKit/UIKit.h>
#import "TUICallingBaseView.h"
@class CallUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingView : TUICallingBaseView

/// 初始化页面
- (instancetype)initWithIsVideo:(BOOL)isVideo isCallee:(BOOL)isCallee;

@end

NS_ASSUME_NONNULL_END
