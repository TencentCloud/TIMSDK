//
//  TUIGroupMemberCellData_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupMemberCellData_Minimalist : TUICommonCellData
@property(nonatomic, strong) NSString *identifier;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) UIImage *avatarImage;

@property(nonatomic, strong) NSString *avatarUrl;

@property(nonatomic, assign) BOOL showAccessory;

@property(nonatomic, copy) NSString *detailName;

@property NSInteger tag;
@end

NS_ASSUME_NONNULL_END
