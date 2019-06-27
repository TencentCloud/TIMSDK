//
//  TProfileController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TUserProfileController.h"
#import "TUIProfileCardCell.h"
#import "TUIButtonCell.h"
#import "THeader.h"
#import "TTextEditController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ChatViewController.h"
#import "FriendRequestViewController.h"
#import "TCommonTextCell.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"
#import "TUIKit.h"
#import "TUIGroupPendencyCellData.h"
#import "TCommonPendencyCellData.h"
@import ImSDK;

@TCServiceRegister(TUIUserProfileControllerServiceProtocol, TUserProfileController)

@interface TUserProfileController ()
@property NSMutableArray<NSArray *> *dataList;
@end

@implementation TUserProfileController
{
    TIMUserProfile *_userProfile;
    ProfileControllerAction _actionType;
    TUIGroupPendencyCellData *_groupPendency;
    TCommonPendencyCellData *_pendency;
}

@synthesize userProfile = _userProfile;
@synthesize actionType = _actionType;
@synthesize groupPendency = _groupPendency;
@synthesize pendency = _pendency;

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    return self;
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详细资料";

    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"CardCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"ButtonCell"];
    
    [self loadData];
}

- (void)loadData
{
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUIProfileCardCellData *personal = [[TUIProfileCardCellData alloc] init];
            personal.identifier = self.userProfile.identifier;
            personal.avatarImage = DefaultAvatarImage;
            personal.name = [self.userProfile showName];
            personal.signature = [self.userProfile showSignature];
            personal.reuseId = @"CardCell";
            personal;
        })];
        inlist;
    })];
    
    if (self.pendency || self.groupPendency) {
        [list addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TCommonTextCellData *data = TCommonTextCellData.new;
                data.key = @"验证消息";
                if (self.pendency) {
                    data.value = self.pendency.addWording;
                } else if (self.groupPendency) {
                    data.value = self.groupPendency.requestMsg;
                }
                data.reuseId = @"TextCell";
                data;
            })];
            inlist;
        })];
    }
    
    
    self.dataList = list;
    
    if (self.actionType == PCA_ADD_FRIEND) {
        TIMFriendCheckInfo *ck = TIMFriendCheckInfo.new;
        ck.users = @[self.userProfile.identifier];
        ck.checkType = TIM_FRIEND_CHECK_TYPE_BIDIRECTION;
        [[TIMFriendshipManager sharedInstance] checkFriends:ck succ:^(NSArray<TIMCheckFriendResult *> *results) {
            TIMCheckFriendResult *result = results.firstObject;
            if (result.resultType == TIM_FRIEND_RELATION_TYPE_MY_UNI || result.resultType == TIM_FRIEND_RELATION_TYPE_BOTHWAY) {
                return;
            }
            
            
            [self.dataList addObject:({
                NSMutableArray *inlist = @[].mutableCopy;
                [inlist addObject:({
                    TUIButtonCellData *data = TUIButtonCellData.new;
                    data.title = @"加好友";
                    data.style = ButtonGreen;
                    data.cbuttonSelector = @selector(onAddFriend);
                    data.reuseId = @"ButtonCell";
                    data;
                })];
                inlist;
            })];
            [self.tableView reloadData];
        } fail:^(int code, NSString *msg) {
            
        }];
    }
    
    if (self.actionType == PCA_PENDENDY_CONFIRM) {
        [self.dataList addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = @"同意";
                data.style = ButtonGreen;
                data.cbuttonSelector = @selector(onAgreeFriend);
                data.reuseId = @"ButtonCell";
                data;
            })];
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = @"拒绝";
                data.style = ButtonRedText;
                data.cbuttonSelector =  @selector(onRejectFriend);
                data.reuseId = @"ButtonCell";
                data;
            })];
            inlist;
        })];
    }
    
    if (self.actionType == PCA_GROUP_CONFIRM) {
        [self.dataList addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = @"同意";
                data.style = ButtonGreen;
                data.cbuttonSelector = @selector(onAgreeGroup);
                data.reuseId = @"ButtonCell";
                data;
            })];
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = @"拒绝";
                data.style = ButtonRedText;
                data.cbuttonSelector =  @selector(onRejectGroup);
                data.reuseId = @"ButtonCell";
                data;
            })];
            inlist;
        })];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TCommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    TCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    [cell fillWithData:data];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TCommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}


- (void)onSendMessage
{
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.convId = self.userProfile.identifier;
    data.convType = TIM_C2C;
    data.title = [self.userProfile showName];
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = data;
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)onAddFriend
{
    FriendRequestViewController *vc = [FriendRequestViewController new];
    vc.profile = self.userProfile;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onAgreeFriend
{
    [self.pendency agree];
}

- (void)onRejectFriend
{
    [self.pendency reject];
}

- (void)onAgreeGroup
{
    [self.groupPendency accept];
}

- (void)onRejectGroup
{
    [self.groupPendency reject];
}

- (UIView *)toastView
{
    return [UIApplication sharedApplication].keyWindow;
}


@end
