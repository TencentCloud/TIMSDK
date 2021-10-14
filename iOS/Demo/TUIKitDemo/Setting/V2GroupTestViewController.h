//
//  V2GroupTestViewController.h
//  TUIKitDemo
//
//  Created by xiangzhang on 2020/3/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2GroupTestViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *createGroupName;
@property (weak, nonatomic) IBOutlet UITextField *createGroupType;
@property (weak, nonatomic) IBOutlet UITextField *defaultMembers;
@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UITextField *notification;
@property (weak, nonatomic) IBOutlet UITextField *introduction;
@property (weak, nonatomic) IBOutlet UITextField *customKey;
@property (weak, nonatomic) IBOutlet UITextField *customValue;
@property (weak, nonatomic) IBOutlet UITextField *isAllMuted;
@property (weak, nonatomic) IBOutlet UITextField *groupAddOpt;
@property (weak, nonatomic) IBOutlet UITextField *faceURL;
@property (weak, nonatomic) IBOutlet UITextField *receiveOpt;
@property (weak, nonatomic) IBOutlet UITextField *memberID;
@property (weak, nonatomic) IBOutlet UITextField *nameCard;
@property (weak, nonatomic) IBOutlet UITextField *addMemberID;
@property (weak, nonatomic) IBOutlet UITextView *eventInfo;
@end

NS_ASSUME_NONNULL_END
