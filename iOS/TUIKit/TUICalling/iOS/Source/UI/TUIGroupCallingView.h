//
//  TUIGroupCallingView.h
//  TUICalling
//
//  Created by noah on 2021/9/3.
//

#import <UIKit/UIKit.h>
#import "TUICallingBaseView.h"
@class CallUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupCallingView : TUICallingBaseView

/// 初始化页面
- (instancetype)initWithUser:(CallUserModel *)user isVideo:(BOOL)isVideo isCallee:(BOOL)isCallee;

@end

NS_ASSUME_NONNULL_END
