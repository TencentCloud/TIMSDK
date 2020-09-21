//
//  TUISelectMemberViewController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
@import ImSDK;

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectedFinished)(NSMutableArray <UserModel *> *modelList);

@interface TUISelectMemberViewController : UIViewController
@property(nonatomic,copy) NSString *groupId;
@property(nonatomic,strong) SelectedFinished selectedFinished;
@end

NS_ASSUME_NONNULL_END
