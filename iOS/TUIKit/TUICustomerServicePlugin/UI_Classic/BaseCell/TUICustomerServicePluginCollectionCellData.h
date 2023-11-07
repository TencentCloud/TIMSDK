//
//  TUICustomerServicePluginCollectionCellData.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import <TIMCommon/TUIMessageCell.h>
#import <TIMCommon/TUIBubbleMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginCollectionCellData : TUIBubbleMessageCellData

@property (nonatomic, copy) NSString *header;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) NSString *selectedContent;
@property (nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
