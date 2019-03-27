//
//  AddChatViewController.m
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/22.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import "AddChatViewController.h"
#import "ChatViewController.h"
#import "ImSDK.h"

@interface AddChatViewController ()

@end

@implementation AddChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)closeVC:(NSButton *)sender {
    [self dismissViewController:self];
}

- (IBAction)addGroup:(id)sender {
    if(_userId.stringValue.length == 0){
        return;
    }

    NSString *groupName = [NSString stringWithFormat:@"%@、%@", [[TIMManager sharedInstance] getLoginUser], _userId.stringValue];
    NSMutableArray *members = [NSMutableArray array];
    TIMCreateGroupMemberInfo *member = [[TIMCreateGroupMemberInfo alloc] init];
    member.member = _userId.stringValue;
    member.role = TIM_GROUP_MEMBER_ROLE_MEMBER;
    [members addObject:member];
    
    TIMCreateGroupInfo *info = [[TIMCreateGroupInfo alloc] init];
    info.groupName = groupName;
    info.groupType = @"Private";
    info.setAddOpt = false;
    info.membersInfo = members;
    
    __weak typeof(self) ws = self;
    [[TIMGroupManager sharedInstance] createGroup:info succ:^(NSString *groupId) {
        TIMMessage *tip = [[TIMMessage alloc] init];
        TIMCustomElem *custom = [[TIMCustomElem alloc] init];
        custom.data = [@"group_create" dataUsingEncoding:NSUTF8StringEncoding];
        custom.ext = [NSString stringWithFormat:@"\"%@\"创建群组", [[TIMManager sharedInstance] getLoginUser]];
        [tip addElem:custom];
        TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:groupId];
        [conv sendMessage:tip succ:nil fail:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ChatViewController *vc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
            TConversationCellData *conversation = [[TConversationCellData alloc] init];
            conversation.convType = TConv_Type_Group;
            conversation.convId = groupId;
            conversation.title = groupName;
            vc.conversation = conversation;
            [ws presentViewControllerAsModalWindow:vc];
            
        });
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
}

- (IBAction)addC2C:(id)sender {
    ChatViewController *vc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    TConversationCellData *conversation = [[TConversationCellData alloc] init];
    conversation.convType = TConv_Type_C2C;
    conversation.convId = _userId.stringValue;
    conversation.title = _userId.stringValue;
    vc.conversation = conversation;
    [self presentViewControllerAsModalWindow:vc];
}

@end
