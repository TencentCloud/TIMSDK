//
//  TUIContactButtonCell.h
//  TUIContact
//
//  Created by wyl on 2022/12/14.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUIContactButtonCellData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIContactButtonCell_Minimalist : TUICommonTableViewCell
@property (nonatomic, strong) UIButton *button;
@property TUIContactButtonCellData_Minimalist *buttonData;

- (void)fillWithData:(TUIContactButtonCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
