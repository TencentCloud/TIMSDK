//
//  TUISelectUserTableViewCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
#import "MMLayout/UIView+MMLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUISelectMemberCell : UITableViewCell
- (void)fillWithData:(UserModel *)model isSelect:(BOOL)isSelect;
@end

NS_ASSUME_NONNULL_END
