//
//  TUILivePushShowResultView.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TCShowLiveTopView;
@interface TUILivePushShowResultView : UIView

typedef void (^ShowResultComplete)(void);

- (instancetype)initWithFrame:(CGRect)frame resultData:(TCShowLiveTopView *)resultData backHomepage:(ShowResultComplete)backHomepage;

@end

NS_ASSUME_NONNULL_END
