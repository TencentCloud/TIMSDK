//
//  TUIGroupButtonCell_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TUICommonGroupInfoCellData_Minimalist.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupButtonCell_Minimalist : TUICommonTableViewCell
@property(nonatomic, strong) UIButton *button;
@property(nonatomic, strong) TUIGroupButtonCellData_Minimalist *buttonData;

- (void)fillWithData:(TUIGroupButtonCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
