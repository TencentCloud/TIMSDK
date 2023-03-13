//
//  TUIPollContainerCellData.h
//  TUIChat
//
//  Created by xia on 2023/1/5.
//

#import "TUIMessageCell.h"
#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIPollContainerCellData : TUIBubbleMessageCellData

@property (nonatomic, copy) NSString *businessID;
@property (nonatomic, strong) V2TIMMessage *message;
@property (nonatomic, assign) CGSize cachedSize;
@property (nonatomic, strong) UIViewController *childViewController;

@end

NS_ASSUME_NONNULL_END
