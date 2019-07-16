//
//  TFriendController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/29.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo好友信息视图
 *  本文件实现了好友简介视图控制器，只在显示好友时使用该视图控制器
 *  若要显示非好友的用户信息，请查看TUIKitDemo/Chat/TUserProfileController.m
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "TFriendProfileController.h"
#import "TCommonTextCell.h"
#import "TCommonSwitchCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "TTextEditController.h"
#import "TIMFriendshipManager.h"
#import "ChatViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"

@TCServiceRegister(TUIFriendProfileControllerServiceProtocol, TFriendProfileController)

@interface TFriendProfileController ()
{
    TIMFriend *_friendProfile;
}
@property NSArray<NSArray *> *dataList;
@property BOOL isInBlackList;
@property BOOL modified;
@property TIMUserProfile *profile;
@end

@implementation TFriendProfileController

@synthesize friendProfile = _friendProfile;

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    return self;
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (parent == nil) {
        if (self.modified) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendProfileUpdate object:self.friendProfile];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
       
    [[TIMFriendshipManager sharedInstance] getBlackList:^(NSArray<TIMFriend *> *friends) {
        for (TIMFriend *friend in friends) {
            if ([friend.identifier isEqualToString:self.friendProfile.identifier])
            {
                self.isInBlackList = true;
                break;
            }
        }
        [self loadData];
    } fail:nil];
    
    self.profile = self.friendProfile.profile;
    
    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TCommonSwitchCell class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"CardCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"ButtonCell"];

    self.title = @"详细资料";
}

/**
 *初始化视图显示数据
 */
- (void)loadData
{
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUIProfileCardCellData *personal = [[TUIProfileCardCellData alloc] init];
            personal.identifier = self.profile.identifier;
            personal.avatarImage = DefaultAvatarImage;
            personal.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
            personal.name = [self.profile showName];
            personal.signature = [self.profile showSignature];
            personal.reuseId = @"CardCell";
            personal;
        })];
        inlist;
    })];
    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TCommonTextCellData *data = TCommonTextCellData.new;
            data.key = @"备注名";
            data.value = self.friendProfile.remark;
            if (data.value.length == 0)
            {
                data.value = @"无";
            }
            data.showAccessory = YES;
            data.cselector = @selector(onChangeRemark:);
            data.reuseId = @"TextCell";
            data;
        })];
        [inlist addObject:({
            TCommonSwitchCellData *data = TCommonSwitchCellData.new;
            data.title = @"加入黑名单";
            data.on = self.isInBlackList;
            data.cswitchSelector =  @selector(onChangeBlackList:);
            data.reuseId = @"SwitchCell";
            data;
        })];
        inlist;
    })];
    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TCommonTextCellData *data = TCommonTextCellData.new;
            data.key = @"所在地";
            data.value = [self.friendProfile.profile showLocation];
            data.reuseId = @"TextCell";
            data;
        })];
        [inlist addObject:({
            TCommonTextCellData *data = TCommonTextCellData.new;
            data.key = @"生日";
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"YYYY年M月d日";
            if ([self.friendProfile.profile showBirthday])
                data.value = [formatter stringFromDate:[self.friendProfile.profile showBirthday]];
            else
                data.value = @"无";
            data.reuseId = @"TextCell";
            data;
        })];
        inlist;
    })];
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TCommonSwitchCellData *data = TCommonSwitchCellData.new;
            data.title = @"置顶聊天";
            if ([[[TUILocalStorage sharedInstance] topConversationList] containsObject:self.friendProfile.identifier]) {
                data.on = YES;
            }
            data.cswitchSelector =  @selector(onTopMostChat:);
            data.reuseId = @"SwitchCell";
            data;
        })];
        inlist;
    })];
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUIButtonCellData *data = TUIButtonCellData.new;
            data.title = @"发送消息";
            data.style = ButtonGreen;
            data.cbuttonSelector = @selector(onSendMessage:);
            data.reuseId = @"ButtonCell";
            data;
        })];
        [inlist addObject:({
            TUIButtonCellData *data = TUIButtonCellData.new;
            data.title = @"删除好友";
            data.style = ButtonRedText;
            data.cbuttonSelector =  @selector(onDeleteFriend:);
            data.reuseId = @"ButtonCell";
            data;
        })];
        inlist;
    })];
    
    self.dataList = list;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)onChangeBlackList:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TIMFriendshipManager sharedInstance] addBlackList:@[self.friendProfile.identifier] succ:^(NSArray<TIMFriendResult *> *results) {
        } fail:nil];
    } else {
        [[TIMFriendshipManager sharedInstance] deleteBlackList:@[self.friendProfile.identifier] succ:^(NSArray<TIMFriendResult *> *results) {
        } fail:nil];
    }
}

/**
 *点击 修改备注 按钮后所执行的函数。包含数据的获取与请求回调
 */
- (void)onChangeRemark:(TCommonTextCell *)cell
{
    TTextEditController *vc = [[TTextEditController alloc] initWithText:self.friendProfile.remark];
    vc.title = @"修改备注";
    vc.textValue = self.friendProfile.remark;
    [self.navigationController pushViewController:vc animated:YES];

    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *value) {
        @strongify(self)
        self.modified = YES;
        [[TIMFriendshipManager sharedInstance] modifyFriend:self.friendProfile.identifier
                                                     values:@{TIMFriendTypeKey_Remark: value}
                                                       succ:^{
                                                           self.friendProfile.remark = value;
                                                           [self loadData];
                                                       } fail:nil];
    }];
}

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

/**
 *点击 删除好友 后执行的函数，包括好友信息获取和请求回调
 */
- (void)onDeleteFriend:(id)sender
{
    [[TIMFriendshipManager sharedInstance] deleteFriends:@[self.friendProfile.identifier] delType:TIM_FRIEND_DEL_BOTH succ:^(NSArray<TIMFriendResult *> *results) {
        TIMFriendResult *result = results.firstObject;
        if (result.result_code == 0) {
            self.modified = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } fail:^(int code, NSString *msg) {
        
    }];
}

/**
 *点击 发送消息 后执行的函数，默认跳转到对应好友的聊天界面
 */
- (void)onSendMessage:(id)sender
{
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.convId = self.friendProfile.identifier;
    data.convType = TIM_C2C;
    data.title = [self.friendProfile.profile showName];
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = data;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *操作 置顶 开关后执行的函数，将对应好友添加/移除置顶队列
 */
- (void)onTopMostChat:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:self.friendProfile.identifier];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:self.friendProfile.identifier];
    }
}
@end
