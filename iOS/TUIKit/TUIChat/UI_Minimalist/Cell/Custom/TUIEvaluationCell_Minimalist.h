//
//  TUIEvaluationCell.h
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import "TUIEvaluationCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIEvaluationCell_Minimalist : TUIBubbleMessageCell_Minimalist

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *commentLabel;
@property(nonatomic, strong) NSMutableArray *starImageArray;

- (void)fillWithData:(TUIEvaluationCellData *)data;

@end

NS_ASSUME_NONNULL_END
