//
//  TUIContactProfileCardCell_Minimalist.h
//  TUIContact
//
//  Created by cologne on 2023/2/1.
//

#import <UIKit/UIKit.h>
#import "TUIContactProfileCardCellData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIContactProfileCardCell_Minimalist : TUICommonTableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) TUIContactProfileCardCellData_Minimalist *cardData;
@property (nonatomic, weak)  id<TUIProfileCardDelegate> delegate;
- (void)fillWithData:(TUIContactProfileCardCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
