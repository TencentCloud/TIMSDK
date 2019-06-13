//
//  ChatViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "ChatViewController.h"
#import "GroupInfoController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUserProfileController.h"
#import "TIMFriendshipManager.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "MyCustomCell.h"

#define CUSTOM 0

@interface ChatViewController () <TUIChatControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) TUIChatController *chat;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:_conversationData.convType receiver:_conversationData.convId];
    _chat = [[TUIChatController alloc] initWithConversation:conv];
    _chat.delegate = self;
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];
    
    self.title = _conversationData.title;
#if CUSTOM
    NSMutableArray *moreMenus = [NSMutableArray arrayWithArray:_chat.moreMenus];
    [moreMenus addObject:({
        TUIInputMoreCellData *data = [TUIInputMoreCellData new];
        data.image = [UIImage imageNamed:@"Doge"];
        data.title = @"Doge";
        data;
    })];
    _chat.moreMenus = moreMenus;
#endif
    //left
    [self setupNavigator];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [_chat saveDraft];
    }
}

- (void)setupNavigator
{
    //left    
    
    //right
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    if(_conversationData.convType == TIM_C2C){
        [rightButton setImage:[UIImage tk_imageNamed:@"person_nav"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage tk_imageNamed:@"person_nav_hover"] forState:UIControlStateHighlighted];
    }
    else if(_conversationData.convType == TIM_GROUP){
        [rightButton setImage:[UIImage tk_imageNamed:(@"group_nav")] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage tk_imageNamed:(@"group_nav_hover")] forState:UIControlStateHighlighted];
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}


- (void)rightBarButtonClick
{
    if (_conversationData.convType == TIM_C2C) {
        @weakify(self)
        [[TIMFriendshipManager sharedInstance] getFriendList:^(NSArray<TIMFriend *> *friends) {
            @strongify(self)
            for (TIMFriend *firend in friends) {
                if ([firend.identifier isEqualToString:self.conversationData.convId]) {
                    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
                    if ([vc isKindOfClass:[UIViewController class]]) {
                        vc.friendProfile = firend;
                        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                        return;
                    }
                }
            }
            
            [[TIMFriendshipManager sharedInstance] getUsersProfile:@[self.conversationData.convId] forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
                TUserProfileController *myProfile = [[TUserProfileController alloc] init];
                myProfile.userProfile = profiles.firstObject;
                myProfile.actionType = PCA_ADD_FRIEND;
                [self.navigationController pushViewController:myProfile animated:YES];
            } fail:^(int code, NSString *msg) {
                
            }];
        } fail:^(int code, NSString *msg) {
            
        }];
        

        
    } else {
        GroupInfoController *groupInfo = [[GroupInfoController alloc] init];
        groupInfo.groupId = _conversationData.convId;
        [self.navigationController pushViewController:groupInfo animated:YES];
    }
}

- (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell
{
    if ([cell.data.title isEqualToString:@"Doge"]) {
        MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:MsgDirectionOutgoing];
        cellData.text = @"欢迎欢迎欢迎欢迎";
        cellData.link = @"www.qq.com";
        
        cellData.innerMessage = [[TIMMessage alloc] init];
        TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
        [cellData.innerMessage addElem:custom_elem];
        
        [chatController sendMessage:cellData];
    }
}

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(TIMMessage *)msg
{
#if CUSTOM
    TIMElem *elem = [msg getElem:0];
    if([elem isKindOfClass:[TIMCustomElem class]]){
        MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
        cellData.text = @"欢迎欢迎欢迎欢迎";
        cellData.link = @"www.qq.com";
        return cellData;
    }
#endif
    return nil;
}

- (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)data
{
#if CUSTOM
    if ([data isKindOfClass:[MyCustomCellData class]]) {
        MyCustomCell *myCell = [[MyCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
        [myCell fillWithData:(MyCustomCellData *)data];
        return myCell;
    }
#endif
    return nil;
}


@end
