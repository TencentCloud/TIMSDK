//
//  TUICommonContactProfileCardCell_Minimalist.h
//
//
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>

@class TUICommonContactProfileCardCell_Minimalist;

@protocol TUIContactProfileCardDelegate_Minimalist <NSObject>

- (void)didTapOnAvatar:(TUICommonContactProfileCardCell_Minimalist *)cell;

@end

@interface TUICommonContactProfileCardCellData_Minimalist : TUICommonCellData

@property(nonatomic, strong) UIImage *avatarImage;
@property(nonatomic, strong) NSURL *avatarUrl;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *signature;
@property(nonatomic, strong) UIImage *genderIconImage;
@property(nonatomic, strong) NSString *genderString;
@property BOOL showAccessory;
@property BOOL showSignature;

@end

@interface TUICommonContactProfileCardCell_Minimalist : TUICommonTableViewCell

@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UILabel *identifier;
@property(nonatomic, strong) UILabel *signature;
@property(nonatomic, strong) UIImageView *genderIcon;
@property(nonatomic, strong) TUICommonContactProfileCardCellData_Minimalist *cardData;

@property(nonatomic, weak) id<TUIContactProfileCardDelegate_Minimalist> delegate;

- (void)fillWithData:(TUICommonContactProfileCardCellData_Minimalist *)data;
@end
