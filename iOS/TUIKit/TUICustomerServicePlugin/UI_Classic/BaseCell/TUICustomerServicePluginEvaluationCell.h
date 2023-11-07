//
//  TUICustomerServicePluginEvaluationCell.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import <TIMCommon/TUIMessageCell.h>
#import "TUICustomerServicePluginEvaluationCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginEvaluationCell : TUIMessageCell

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, strong) NSMutableArray *scoreButtonArray;


@property (nonatomic, strong) TUICustomerServicePluginEvaluationCellData *customData;

- (void)fillWithData:(TUICustomerServicePluginEvaluationCellData *)data;


@end

NS_ASSUME_NONNULL_END
