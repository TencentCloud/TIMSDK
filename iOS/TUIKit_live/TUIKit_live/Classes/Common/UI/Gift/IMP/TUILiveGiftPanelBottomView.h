//
//  TUILiveGiftBottomView.h
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUILiveGiftBottomBussinessType) {
    TUILiveGiftBottomBussinessTypeCharge    = 1000,     // 充值
};

typedef void(^TUILiveGiftBottomViewActionClick)(TUILiveGiftBottomBussinessType type, id __nullable info);

@interface TUILiveGiftPanelBottomView : UIView
@property (nonatomic, copy) TUILiveGiftBottomViewActionClick onClick;
@end

NS_ASSUME_NONNULL_END
