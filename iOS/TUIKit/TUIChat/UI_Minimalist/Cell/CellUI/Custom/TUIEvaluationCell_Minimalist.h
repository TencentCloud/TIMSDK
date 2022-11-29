//
//  TUIEvaluationCell.h
//  TUIChat
//
//  Created by summeryxia on 2022/6/10.
//

#import "TUIBubbleMessageCell_Minimalist.h"
#import "TUIEvaluationCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIEvaluationCell_Minimalist : TUIBubbleMessageCell_Minimalist

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) NSMutableArray *starImageArray;

- (void)fillWithData:(TUIEvaluationCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
