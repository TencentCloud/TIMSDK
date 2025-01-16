//
//  TUISelectGroupMemberViewController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUIContactDefine.h"
#import "TUISelectGroupMemberCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUISelectGroupMemberViewController_Minimalist : UIViewController
@property(nonatomic, copy) NSString *groupId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) SelectedFinished selectedFinished;
@property(nonatomic, assign) TUISelectMemberOptionalStyle optionalStyle;
@property(nonatomic, strong) NSArray *selectedUserIDList;
@property(nonatomic, copy) NSString *userData;
@end

NS_ASSUME_NONNULL_END
