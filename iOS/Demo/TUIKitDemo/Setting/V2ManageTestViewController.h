//
//  V2ManageTestViewController.h
//  TUIKitDemo
//
//  Created by xiangzhang on 2020/3/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2ManageTestViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *loginUser;
@property (weak, nonatomic) IBOutlet UISwitch *convSwitch;
@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UITextField *groupType;
@property (weak, nonatomic) IBOutlet UITextField *joinGroupID;
@property (weak, nonatomic) IBOutlet UITextField *quitGroupID;
@property (weak, nonatomic) IBOutlet UITextField *dismissGroupID;
@property (weak, nonatomic) IBOutlet UITextField *nickName;
@property (weak, nonatomic) IBOutlet UITextField *faceUrl;
@property (weak, nonatomic) IBOutlet UITextField *selfSignature;
@property (weak, nonatomic) IBOutlet UITextField *gender;
@property (weak, nonatomic) IBOutlet UITextField *allowType;
@property (weak, nonatomic) IBOutlet UITextField *customKey;
@property (weak, nonatomic) IBOutlet UITextField *customValue;
@property (weak, nonatomic) IBOutlet UITextField *inviteID;
@property (weak, nonatomic) IBOutlet UITextView *eventInfo;
@property (weak, nonatomic) IBOutlet UITextField *attributeKey;
@property (weak, nonatomic) IBOutlet UITextField *attributeValue;
@end

NS_ASSUME_NONNULL_END
