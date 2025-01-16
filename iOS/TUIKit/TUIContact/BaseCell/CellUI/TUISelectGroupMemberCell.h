//
//  TUISelectMemberCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/8/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUISelectGroupMemberCell : UITableViewCell
- (void)fillWithData:(TUIUserModel *)model isSelect:(BOOL)isSelect;
@end

NS_ASSUME_NONNULL_END
