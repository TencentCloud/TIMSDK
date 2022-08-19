//
//  TUISelectGroupMemberViewController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import <UIKit/UIKit.h>
#import "TUISelectGroupMemberCell.h"
#import "TUIDefine.h"
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUISelectMemberOptionalStyle) {
    TUISelectMemberOptionalStyleNone            = 0,
    TUISelectMemberOptionalStyleAtAll           = 1 << 0,
    TUISelectMemberOptionalStyleTransferOwner   = 1 << 1,
    TUISelectMemberOptionalStylePublicMan       = 1 << 2
};

typedef void(^SelectedFinished)(NSMutableArray <TUIUserModel *> *modelList);

@interface TUISelectGroupMemberViewController : UIViewController
@property(nonatomic,copy) NSString *groupId;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,strong) SelectedFinished selectedFinished;
@property(nonatomic,assign) TUISelectMemberOptionalStyle optionalStyle;
@end

NS_ASSUME_NONNULL_END
