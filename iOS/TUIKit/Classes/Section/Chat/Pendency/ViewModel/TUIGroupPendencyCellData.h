//
//  TUIGroupPendencyCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import "TCommonCell.h"
@class TIMGroupPendencyItem;

NS_ASSUME_NONNULL_BEGIN

#define TUIGroupPendencyCellData_onPendencyChanged @"TUIGroupPendencyCellData_onPendencyChanged"

@interface TUIGroupPendencyCellData : TCommonCellData

@property(nonatomic,strong) NSString* groupId;
@property(nonatomic,strong) NSString* fromUser;
@property(nonatomic,strong) NSString* toUser;

@property (readonly) TIMGroupPendencyItem *pendencyItem;

@property NSURL *avatarUrl;
@property NSString *title;
@property NSString *requestMsg;
@property BOOL isAccepted;
@property BOOL isRejectd;
@property SEL cbuttonSelector;

- (instancetype)initWithPendency:(TIMGroupPendencyItem *)args;

- (void)accept;
- (void)reject;
@end

NS_ASSUME_NONNULL_END
