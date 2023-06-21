//
//  TUISecondConfirm.h
//  TIMCommon
//
//  Created by xiangzhang on 2023/5/15.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^TUISecondConfirmBtnClickCallback)(void);
@interface TUISecondConfirmBtnInfo : NSObject
@property(nonatomic, strong) NSString *tile;
@property(nonatomic, copy) TUISecondConfirmBtnClickCallback click;
@end

@interface TUISecondConfirm : NSObject
+ (void)show:(NSString *)title cancelBtnInfo:(TUISecondConfirmBtnInfo *)cancelBtnInfo confirmBtnInfo:(TUISecondConfirmBtnInfo *)confirmBtnInfo;
@end

NS_ASSUME_NONNULL_END
