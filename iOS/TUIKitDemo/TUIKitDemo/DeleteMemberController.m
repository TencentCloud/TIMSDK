//
//  DeleteMemberController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "DeleteMemberController.h"
#import "TDeleteMemberController.h"
#import "GroupInfoController.h"
#import "GroupMemberController.h"
#import "TGroupMemberController.h"
#import "TGroupInfoController.h"
#import "TGroupMemberCell.h"
#import "TAddCell.h"
#import "THeader.h"
#import "TAlertView.h"

@interface DeleteMemberController () <TDeleteMemberControllerDelegate>

@end

@implementation DeleteMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    TDeleteMemberController *delete = [[TDeleteMemberController alloc] init];
    delete.groupId = _groupId;
    delete.delegate = self;
    [self addChildViewController:delete];
    [self.view addSubview:delete.view];
}

- (void)didCancelInDeleteMemberController:(TDeleteMemberController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteMemberController:(TDeleteMemberController *)controller didDeleteMemberResult:(TDeleteMemberResult *)result
{
    if(result.code != 0){
        TAlertView *alert = [[TAlertView alloc] initWithTitle:@"添加出错"];
        [alert showInWindow:self.view.window];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
        NSArray *controllers = ((UINavigationController *)((UITabBarController *)self.presentingViewController).selectedViewController).viewControllers;
        UIViewController *presenter = [controllers lastObject];
        if([presenter isKindOfClass:[GroupInfoController class]]){
            TGroupInfoController *tGroupInfo = presenter.childViewControllers[0];
            [tGroupInfo updateData];
        }
        else if([presenter isKindOfClass:[GroupMemberController class]]){
            TGroupMemberController *tGroupMember = presenter.childViewControllers[0];
            [tGroupMember updateData];
        }
    }
}
@end
