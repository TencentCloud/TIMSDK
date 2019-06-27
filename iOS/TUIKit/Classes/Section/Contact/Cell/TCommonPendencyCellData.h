//
//  TCommonPendencyCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TCommonCell.h"
@class TIMFriendPendencyItem;

NS_ASSUME_NONNULL_BEGIN

@interface TCommonPendencyCellData : TCommonCellData

@property NSString *identifier;
@property NSURL *avatarUrl;
@property NSString *title;
@property NSString *addSource;
@property NSString *addWording;
@property BOOL isAccepted;
@property SEL cbuttonSelector;

- (instancetype)initWithPendency:(TIMFriendPendencyItem *)args;

- (void)agree;
- (void)reject;

@end

NS_ASSUME_NONNULL_END
