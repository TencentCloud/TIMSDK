//
//  TUIProfileCardCell_Minimalist.h
//  Masonry
//
//  Created by wyl on 2022/12/6.
//

#import <TIMCommon/TIMCommonModel.h>
#import "TUIProfileCardCellData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIProfileCardCell_Minimalist : TUICommonTableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) TUIProfileCardCellData_Minimalist *cardData;
@property (nonatomic, weak)  id<TUIProfileCardDelegate> delegate;
- (void)fillWithData:(TUIProfileCardCellData_Minimalist *)data;
@end

NS_ASSUME_NONNULL_END
