//
//  TProfileController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo 用户信息视图
 *  本文件实现了用户信息的视图，在您想要查看其他用户信息时提供UI
 *  在这里，用户是指非好友身份的其他用户
 *  好友信息视图请查看TUIKitDemo/Contact/TFriendProfileController
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */

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
#import "TUIImageViewController.h"
#import "TUIAvatarViewController.h"


@TCServiceRegister(TUIUserProfileControllerServiceProtocol, TUserProfileController)

@interface TUserProfileController ()
@property NSMutableArray<NSArray *> *dataList;
@end

@implementation TUserProfileController
{
    V2TIMUserFullInfo *_userFullInfo;
    ProfileControllerAction _actionType;
    TUIGroupPendencyCellData *_groupPendency;
    TCommonPendencyCellData *_pendency;
}

@synthesize userFullInfo = _userFullInfo;
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

    self.title = NSLocalizedString(@"ProfileDetails", nil); // @"详细资料";
    self.clearsSelectionOnViewWillAppear = YES;

    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"CardCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"ButtonCell"];

    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;

    [self loadData];
}


/**
 * 加载视图信息
 */
- (void)loadData
{
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUIProfileCardCellData *personal = [[TUIProfileCardCellData alloc] init];
            personal.identifier = self.userFullInfo.userID;
            personal.avatarImage = DefaultAvatarImage;
            personal.avatarUrl = [NSURL URLWithString:self.userFullInfo.faceURL];
            personal.name = [self.userFullInfo showName];
            personal.genderString = [self.userFullInfo showGender];
            personal.signature = [self.userFullInfo showSignature];
            personal.reuseId = @"CardCell";
            personal;
        })];
        inlist;
    })];

    //当用户状态为请求添加好友/请求添加群组时，视图加载出验证消息模块
    if (self.pendency || self.groupPendency) {
        [list addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TCommonTextCellData *data = TCommonTextCellData.new;
                data.key = NSLocalizedString(@"FriendAddVerificationMessage",  nil); // @"验证消息";
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

    //当用户为陌生人时，在当前视图给出"加好友"按钮
    if (self.actionType == PCA_ADD_FRIEND) {
        [[V2TIMManager sharedInstance] checkFriend:@[self.userFullInfo.userID] checkType:V2TIM_FRIEND_TYPE_BOTH succ:^(NSArray<V2TIMFriendCheckResult *> *resultList) {
            if (resultList.count == 0) {
                return;
            }
            V2TIMFriendCheckResult *result = resultList.firstObject;
            if (result.relationType == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relationType == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
                return;
            }
            
            [self.dataList addObject:({
                NSMutableArray *inlist = @[].mutableCopy;
                [inlist addObject:({
                    TUIButtonCellData *data = TUIButtonCellData.new;
                    data.title = NSLocalizedString(@"FriendAddTitle", nil); // @"加好友";
                    data.style = ButtonGreen;
                    data.cbuttonSelector = @selector(onAddFriend);
                    data.reuseId = @"ButtonCell";
                    data;
                })];
                inlist;
            })];
            
            [self.tableView reloadData];
                    
        } fail:^(int code, NSString *desc) {
            NSLog(@"");
        }];
    }

    //当用户请求添加使用者为好友时，在当前视图给出"同意"、"拒绝"，使当前用户进行选择
    if (self.actionType == PCA_PENDENDY_CONFIRM) {
        [self.dataList addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = NSLocalizedString(@"Accept", nil);
                data.style = ButtonGreen;
                data.cbuttonSelector = @selector(onAgreeFriend);
                data.reuseId = @"ButtonCell";
                data;
            })];
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = NSLocalizedString(@"Decline", nil);
                data.style = ButtonRedText;
                data.cbuttonSelector =  @selector(onRejectFriend);
                data.reuseId = @"ButtonCell";
                data;
            })];
            inlist;
        })];
    }

    //当用户请求加入群组时，在当前视图给出"同意"、"拒绝"，使当前群组管理员进行选择
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
/**
 *  tableView数据源函数
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TCommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    TCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    //如果是 profileCard 的话，添加委托。
    if([cell isKindOfClass:[TUIProfileCardCell class]]){
        TUIProfileCardCell *cardCell = (TUIProfileCardCell *)cell;
        cardCell.delegate = self;
        cell = cardCell;
    }
    [cell fillWithData:data];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TCommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

/**
 *  点击 发送信息 按钮后执行的函数
 */
- (void)onSendMessage
{
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = [NSString stringWithFormat:@"c2c_%@",self.userFullInfo.userID];
    data.userID = self.userFullInfo.userID;
    data.title = [self.userFullInfo showName];
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = data;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *  点击 加好友 按钮后执行的函数
 */
- (void)onAddFriend
{
    FriendRequestViewController *vc = [FriendRequestViewController new];
    vc.profile = self.userFullInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  点击 同意(好友) 按钮后执行的函数
 */
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

-(void)didSelectAvatar{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData.avatarUrl = [NSURL URLWithString:self.userFullInfo.faceURL];
    NSArray *list = self.dataList;
    NSLog(@"%@",list);

    [self.navigationController pushViewController:image animated:YES];
}

/**
 *  点击头像查看大图的委托实现
 */
-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

@end
