//
//  TUIEvaluationCell.h
//  TUIChat
//
//  Created by summeryxia on 2022/6/10.
//

#import "TUIBubbleMessageCell.h"
#import "TUIEvaluationCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIEvaluationCell : TUIBubbleMessageCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) NSMutableArray *starImageArray;

- (void)fillWithData:(TUIEvaluationCellData *)data;

@end

NS_ASSUME_NONNULL_END
