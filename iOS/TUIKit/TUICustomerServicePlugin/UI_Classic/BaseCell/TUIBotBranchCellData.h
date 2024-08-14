//
//  TUIBotBranchCellData.h
//  TUICustomerServicePlugin
//
//  Created by lynx on 2023/10/30.
//

#import <TIMCommon/TUIMessageCell.h>
#import <TIMCommon/TUIBubbleMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BranchMsgSubType) {
    BranchMsgSubType_Welcome = 0,
    BranchMsgSubType_Clarify = 1,
};

@interface TUIBotBranchCellData : TUIBubbleMessageCellData

@property (nonatomic, assign) BranchMsgSubType subType;
@property (nonatomic, copy) NSString *header;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSUInteger pageIndex;
@property (nonatomic, strong) NSArray *pageItems;

@end

NS_ASSUME_NONNULL_END
