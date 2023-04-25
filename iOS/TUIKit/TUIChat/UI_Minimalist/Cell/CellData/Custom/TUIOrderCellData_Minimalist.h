//
//  TUIOrderCellData_Minimalist.h
//  TUIChat
//
//  Created by xia on 2022/6/10.
//

#import <TIMCommon/TUIBubbleMessageCellData_Minimalist.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIOrderCellData_Minimalist : TUIBubbleMessageCellData_Minimalist

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *link;

@end

NS_ASSUME_NONNULL_END
