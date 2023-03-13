//
//  TUIContactActionCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//

#import <UIKit/UIKit.h>
#import "TUIContactActionCellData_Minimalist.h"
#import "TUICommonModel.h"
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactActionCell_Minimalist : TUICommonTableViewCell

@property UILabel *titleLabel;
@property TUIUnReadView *unRead;

@property (readonly) TUIContactActionCellData_Minimalist *actionData;

- (void)fillWithData:(TUIContactActionCellData_Minimalist *)contactData;

@end

NS_ASSUME_NONNULL_END
