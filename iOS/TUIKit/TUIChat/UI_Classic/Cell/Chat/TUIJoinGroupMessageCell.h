
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TUISystemMessageCell.h>
#import "TUIJoinGroupMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

@class TUIJoinGroupMessageCell;

@protocol TUIJoinGroupMessageCellDelegate <NSObject>

@optional

- (void)didTapOnNameLabel:(TUIJoinGroupMessageCell *)cell;

- (void)didTapOnSecondNameLabel:(TUIJoinGroupMessageCell *)cell;

- (void)didTapOnRestNameLabel:(TUIJoinGroupMessageCell *)cell withIndex:(NSInteger)index;

@end

@interface TUIJoinGroupMessageCell : TUISystemMessageCell

@property TUIJoinGroupMessageCellData *joinData;

@property(nonatomic, weak) id<TUIJoinGroupMessageCellDelegate> joinGroupDelegate;

@end

NS_ASSUME_NONNULL_END
