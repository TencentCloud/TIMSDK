//
//  TUISelectGroupMemberViewController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import <UIKit/UIKit.h>
#import "TUISelectGroupMemberCell.h"
#import <TIMCommon/TIMDefine.h>
#import "TUIGroupDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUISelectGroupMemberViewController_Minimalist : UIViewController
@property(nonatomic,copy) NSString *groupId;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,strong) SelectedFinished selectedFinished;
@property(nonatomic,assign) TUISelectMemberOptionalStyle optionalStyle;
@property(nonatomic,strong) NSArray *selectedUserIDList;
@property(nonatomic,copy) NSString *userData;
@end

NS_ASSUME_NONNULL_END
