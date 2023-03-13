//
//  TUIGroupProfileCardViewCell_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//

#import "TUICommonModel.h"
#import "TUIGroupProfileCardCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupProfileHeaderItemView_Minimalist : UIView
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, copy) void(^messageBtnClickBlock)(void);
@end

@interface TUIGroupProfileHeaderView_Minimalist : UIView
@property (nonatomic, strong) UIImageView *headImg;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *idLabel;

@property (nonatomic, strong) TUIGroupProfileHeaderItemView_Minimalist * itemMessage;
@property (nonatomic, strong) TUIGroupProfileHeaderItemView_Minimalist * itemAudio;
@property (nonatomic, strong) TUIGroupProfileHeaderItemView_Minimalist * itemVideo;

@end

@interface TUIGroupProfileCardViewCell_Minimalist : TUICommonTableViewCell
@property (nonatomic,strong) TUIGroupProfileHeaderView_Minimalist *headerView;
@property (nonatomic, strong) TUIGroupProfileCardCellData_Minimalist *cardData;
- (void)fillWithData:(TUIGroupProfileCardCellData_Minimalist *)data;
@end

NS_ASSUME_NONNULL_END
