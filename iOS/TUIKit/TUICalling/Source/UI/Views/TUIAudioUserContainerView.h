//
//  TUIAudioUserContainerView.h
//  TUICalling
//
//  Created by noah on 2021/8/30.
//

#import <UIKit/UIKit.h>
@class CallUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUIAudioUserContainerView : UIView

/// 配置用户信息视图
/// @param userModel 数据Modle
/// @param text 等待文本
- (void)configUserInfoViewWith:(CallUserModel *)userModel showWaitingText:(NSString *)text;

///配置用户名的字体颜色/文本内容
/// @param textColor 字体颜色
- (void)setUserNameTextColor:(UIColor *)textColor;

@end

NS_ASSUME_NONNULL_END
