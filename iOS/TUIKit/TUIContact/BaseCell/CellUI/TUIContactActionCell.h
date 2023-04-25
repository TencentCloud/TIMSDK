//
//  TUIContactActionCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//

#import <UIKit/UIKit.h>
#import "TUIContactActionCellData.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactActionCell : TUICommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property TUIUnReadView *unRead;

@property (readonly) TUIContactActionCellData *actionData;

- (void)fillWithData:(TUIContactActionCellData *)contactData;

@end

NS_ASSUME_NONNULL_END
