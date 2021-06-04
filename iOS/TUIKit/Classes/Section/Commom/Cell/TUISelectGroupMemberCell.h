//
//  TUISelectUserTableViewCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import <UIKit/UIKit.h>
#import "MMLayout/UIView+MMLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject<NSCopying>
@property(nonatomic,copy) NSString *userId;  //userId
@property(nonatomic,copy) NSString *name;    //昵称
@property(nonatomic,copy) NSString *avatar;  //头像
@end

@interface TUISelectGroupMemberCell : UITableViewCell
- (void)fillWithData:(UserModel *)model isSelect:(BOOL)isSelect;
@end

NS_ASSUME_NONNULL_END
