//
//  TUIBadgeView.h
//  TUIKitDemo
//
//  Created by harvy on 2021/10/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIBadgeViewClearCallback)(void);

@interface TUIBadgeView : UIView

@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) TUIBadgeViewClearCallback clearCallback;

@end

NS_ASSUME_NONNULL_END
