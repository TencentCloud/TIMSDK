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
@import ImSDK;

@TCServiceRegister(TUIUserProfileControllerServiceProtocol, TUserProfileController)

@interface TUserProfileController ()
@property NSMutableArray<TCommonTextCellData *> *dataList;
@property UITableViewHeaderFooterView *footer;
@end

@implementation TUserProfileController
{
    TIMUserProfile *_userProfile;
    ProfileControllerAction _actionType;
}

@synthesize userProfile = _userProfile;
@synthesize actionType = _actionType;

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
    
    [self loadData];
}

- (void)loadData
{
    
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        TCommonTextCellData *data = TCommonTextCellData.new;
        data.key = @"昵称";
        data.value = [self.userProfile showName];
        data;
    })];
    self.dataList = list;
    self.footer = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.mm_w, 80)];
    
    if (self.actionType == PCA_ADD_FRIEND) {
        TIMFriendCheckInfo *ck = TIMFriendCheckInfo.new;
        ck.users = @[self.userProfile.identifier];
        ck.checkType = TIM_FRIEND_CHECK_TYPE_BIDIRECTION;
        [[TIMFriendshipManager sharedInstance] checkFriends:ck succ:^(NSArray<TIMCheckFriendResult *> *results) {
            TIMCheckFriendResult *result = results.firstObject;
            if (result.resultType == TIM_FRIEND_RELATION_TYPE_MY_UNI || result.resultType == TIM_FRIEND_RELATION_TYPE_BOTHWAY) {
                return;
            }
           
            
            UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [self.footer addSubview:btn2];
            [btn2 setTitle:@"加好友" forState:UIControlStateNormal];
            [btn2 setBackgroundColor:[UIColor blueColor]];
            [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn2.mm_left(12).mm_height(48).mm_top(20).mm_flexToRight(12);
            [btn2 addTarget:self action:@selector(onAddFriend) forControlEvents:UIControlEventTouchUpInside];
            
            [self.tableView reloadData];
        } fail:^(int code, NSString *msg) {
            
        }];
    }
    
    if (self.actionType == PCA_PENDENDY_CONFIRM) {
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.footer addSubview:btn2];
        [btn2 setTitle:@"拒绝" forState:UIControlStateNormal];
        [btn2 setBackgroundColor:[UIColor redColor]];
        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn2.mm_left(12).mm_height(48).mm_top(20).mm_width((self.view.mm_w-36)/2);
        [btn2 addTarget:self action:@selector(onRejectFriend) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.footer addSubview:btn3];
        [btn3 setTitle:@"同意" forState:UIControlStateNormal];
        [btn3 setBackgroundColor:[UIColor blueColor]];
        [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn3.mm_height(48).mm_top(20).mm_width((self.view.mm_w-36)/2).mm_right(12);
        [btn3 addTarget:self action:@selector(onAgreeFriend) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
    [cell fillWithData:self.dataList[indexPath.row]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.mm_w, 120)];
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [header addSubview:avatarView];
    if (self.userProfile.faceURL) {
        [avatarView sd_setImageWithURL:[NSURL URLWithString:self.userProfile.faceURL] placeholderImage:DefaultAvatarImage];
    } else {
        [avatarView setImage:DefaultAvatarImage];
    }
    avatarView.layer.cornerRadius = 40;
    avatarView.layer.masksToBounds = YES;
    avatarView.mm_width(80).mm_height(80).mm_center();
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [header addSubview:label];
    label.textAlignment = NSTextAlignmentCenter;
    label.mm_width(header.mm_w).mm_top(avatarView.mm_maxY+10).mm_height(20);
    label.text = self.userProfile.identifier;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
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
    TIMFriendResponse *rsp = TIMFriendResponse.new;
    rsp.identifier = self.userProfile.identifier;
    rsp.responseType = TIM_FRIEND_RESPONSE_AGREE_AND_ADD;
    [[TIMFriendshipManager sharedInstance] doResponse:rsp succ:^(TIMFriendResult *result) {
        [self.toastView makeToast:@"已发送"];
    } fail:^(int code, NSString *msg) {
        [self.toastView makeToast:msg];
    }];
}

- (void)onRejectFriend
{
    TIMFriendResponse *rsp = TIMFriendResponse.new;
    rsp.identifier = self.userProfile.identifier;;
    rsp.responseType = TIM_FRIEND_RESPONSE_REJECT;
    [[TIMFriendshipManager sharedInstance] doResponse:rsp succ:^(TIMFriendResult *result) {
        [self.toastView makeToast:@"已发送"];
    } fail:^(int code, NSString *msg) {
        [self.toastView makeToast:msg];
    }];
}

- (UIView *)toastView
{
    return [UIApplication sharedApplication].keyWindow;
}
@end
