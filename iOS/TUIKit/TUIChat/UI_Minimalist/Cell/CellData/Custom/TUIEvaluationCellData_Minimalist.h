//
//  TUIEvaluationCellData_Minimalist.h
//  TUIChat
//
//  Created by summeryxia on 2022/6/10.
//

#import "TUIBubbleMessageCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIEvaluationCellData_Minimalist : TUIBubbleMessageCellData_Minimalist

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *comment;

@end

NS_ASSUME_NONNULL_END
