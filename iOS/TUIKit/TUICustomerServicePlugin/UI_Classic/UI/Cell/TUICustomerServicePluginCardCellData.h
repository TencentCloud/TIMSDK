//
//  TUICustomerServicePluginCardCellData.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import <TIMCommon/TUIMessageCell.h>
#import <TIMCommon/TUIBubbleMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginCardCellData : TUIBubbleMessageCellData

@property (nonatomic, copy) NSString *header;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) NSString *jumpURL;

@end

NS_ASSUME_NONNULL_END
