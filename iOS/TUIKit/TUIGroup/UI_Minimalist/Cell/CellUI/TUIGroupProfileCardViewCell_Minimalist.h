//
//  TUIGroupProfileCardViewCell_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//

#import <TIMCommon/TIMCommonModel.h>
#import "TUIGroupProfileCardCellData_Minimalist.h"

@class V2TIMGroupInfo;

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupProfileHeaderItemView_Minimalist : UIView
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, copy) void(^messageBtnClickBlock)(void);
@end

@interface TUIGroupProfileHeaderView_Minimalist : UIView
@property (nonatomic, strong) UIImageView *headImg;
@property (nonatomic, copy) void(^headImgClickBlock)(void);
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, copy) void(^editBtnClickBlock)(void);
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UIView *functionListView;
@property (nonatomic,strong) NSArray<TUIGroupProfileHeaderItemView_Minimalist *> *itemViewList;
@property (nonatomic,strong) V2TIMGroupInfo *groupInfo;

@end

@interface TUIGroupProfileCardViewCell_Minimalist : TUICommonTableViewCell
@property (nonatomic,strong) TUIGroupProfileHeaderView_Minimalist *headerView;
@property (nonatomic, strong) TUIGroupProfileCardCellData_Minimalist *cardData;
- (void)fillWithData:(TUIGroupProfileCardCellData_Minimalist *)data;

@property (nonatomic,strong) NSArray<TUIGroupProfileHeaderItemView_Minimalist *> *itemViewList;

@end

NS_ASSUME_NONNULL_END
