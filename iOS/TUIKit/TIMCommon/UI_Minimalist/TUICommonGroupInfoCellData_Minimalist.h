//
//  TUICommonGroupInfoCellData_Minimalist.h
//  TIMCommon
//
//  Created by yiliangwang on 2024/12/26.
//  Copyright © 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupButtonCellData_Minimalist : TUICommonCellData
@property(nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property TUIButtonStyle style;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, assign) BOOL hideSeparatorLine;
@property(nonatomic, assign) BOOL isInfoPageLeftButton;
@end

@interface TUIGroupMemberCellData_Minimalist : TUICommonCellData
@property(nonatomic, strong) NSString *identifier;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) UIImage *avatarImage;

@property(nonatomic, strong) NSString *avatarUrl;

@property(nonatomic, assign) BOOL showAccessory;

@property(nonatomic, copy) NSString *detailName;

@property NSInteger tag;
@end

@interface TUICommonGroupInfoCellData_Minimalist : NSObject

@end

NS_ASSUME_NONNULL_END
