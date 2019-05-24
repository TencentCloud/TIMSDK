//
//  AddMemberController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AddMemberController.h"
#import "GroupInfoController.h"
#import "GroupMemberController.h"
#import "TGroupMemberController.h"
#import "TGroupInfoController.h"
#import "TAddMemberController.h"
#import "TAddCell.h"
#import "TUIKit.h"
#import "TAlertView.h"

@interface AddMemberController ()<TAddMemberControllerDelegate, TAlertViewDelegate>

@end

@implementation AddMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    TAddMemberController *add = [[TAddMemberController alloc] init];
    add.groupId = _groupId;
    add.delegate = self;
    [self addChildViewController:add];
    [self.view addSubview:add.view];
}

- (void)didCancelInAddMemberController:(TAddMemberController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addMemberController:(TAddMemberController *)controller didAddMemberResult:(TAddMemberResult *)result
{
    if(result.code != 0){
        TAlertView *alert = [[TAlertView alloc] initWithTitle:@"添加出错"];
        [alert showInWindow:self.view.window];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
        if([_presenter isKindOfClass:[GroupInfoController class]]){
            TGroupInfoController *tGroupInfo = (TGroupInfoController *)_presenter.childViewControllers[0];
            [tGroupInfo updateData];
        }
        else if([_presenter isKindOfClass:[GroupMemberController class]]){
            TGroupMemberController *tGroupMember = (TGroupMemberController *)_presenter.childViewControllers[0];
            [tGroupMember updateData];
        }
    }
}
@end
