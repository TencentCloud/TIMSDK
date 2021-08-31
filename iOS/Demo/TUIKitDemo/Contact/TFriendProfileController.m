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
#import "TTextEditController.h"
#import "ChatViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIAvatarViewController.h"
#import "TUIKit.h"
#import "TCUtil.h"

@TCServiceRegister(TUIFriendProfileControllerServiceProtocol, TFriendProfileController)

@interface TFriendProfileController ()
@property NSArray<NSArray *> *dataList;
@property BOOL isInBlackList;
@property BOOL modified;
@property V2TIMUserFullInfo *userFullInfo;
@property V2TIMReceiveMessageOpt receiveOpt;
@end

@implementation TFriendProfileController
@synthesize friendProfile;

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
//            [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendInfoUpdate object:self.friendProfile];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLongPressGesture];
    [[V2TIMManager sharedInstance] getBlackList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        for (V2TIMFriendInfo *friend in infoList) {
            if ([friend.userID isEqualToString:self.friendProfile.userID])
            {
                self.isInBlackList = true;
                break;
            }
        }
        [self loadData];;
    } fail:nil];
    
    [[V2TIMManager sharedInstance] getC2CReceiveMessageOpt:@[self.friendProfile.userID]
                                                      succ:^(NSArray<V2TIMUserReceiveMessageOptInfo *> *optList) {
        for (V2TIMReceiveMessageOptInfo *info in optList) {
            if ([info.userID isEqual:self.friendProfile.userID]) {
                self.receiveOpt = info.receiveOpt;
                [self loadData];
                break;
            }
        }
    } fail:nil];

    self.userFullInfo = self.friendProfile.userFullInfo;

    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TCommonSwitchCell class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"CardCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"ButtonCell"];

    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;

    self.title = NSLocalizedString(@"ProfileDetails", nil); // @"详细资料";
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

    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TCommonTextCellData *data = TCommonTextCellData.new;
            data.key = NSLocalizedString(@"ProfileAlia", nil); // @"备注名";
            data.value = self.friendProfile.friendRemark;
            if (data.value.length == 0)
            {
                data.value = NSLocalizedString(@"None", nil); // @"无";
            }
            data.showAccessory = YES;
            data.cselector = @selector(onChangeRemark:);
            data.reuseId = @"TextCell";
            data;
        })];
        [inlist addObject:({
            TCommonSwitchCellData *data = TCommonSwitchCellData.new;
            data.title = NSLocalizedString(@"ProfileBlocked", nil); // @"加入黑名单";
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
            TCommonSwitchCellData *data = TCommonSwitchCellData.new;
            data.title = NSLocalizedString(@"ProfileMessageDoNotDisturb", nil); // @"消息免打扰";
            data.on = (self.receiveOpt == V2TIM_NOT_RECEIVE_MESSAGE);
            data.cswitchSelector =  @selector(onMessageDoNotDisturb:);
            data.reuseId = @"SwitchCell";
            data;
        })];
        
        [inlist addObject:({
            TCommonSwitchCellData *data = TCommonSwitchCellData.new;
            data.title = NSLocalizedString(@"ProfileStickyonTop", nil); // @"置顶聊天";
            data.on = NO;
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
            __weak typeof(self) weakSelf = self;
            [V2TIMManager.sharedInstance getConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID] succ:^(V2TIMConversation *conv) {
                data.on = conv.isPinned;
                [weakSelf.tableView reloadData];
            } fail:^(int code, NSString *desc) {
                
            }];
#else
            if ([[[TUILocalStorage sharedInstance] topConversationList] containsObject:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID]]) {
                data.on = YES;
            }
#endif
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
            data.title = NSLocalizedString(@"ProfileSendMessages", nil); // @"发送消息";
            data.style = ButtonBule;
            data.cbuttonSelector = @selector(onSendMessage:);
            data.reuseId = @"ButtonCell";
            data;
        })];
        [inlist addObject:({
            TUIButtonCellData *data = TUIButtonCellData.new;
            data.title = NSLocalizedString(@"ProfileDeleteFirend", nil); // @"删除好友";
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
        [[V2TIMManager sharedInstance] addToBlackList:@[self.friendProfile.userID] succ:nil fail:nil];
        [TCUtil report:Action_Addblacklist actionSub:@"" code:@(0) msg:@"addblacklist"];
    } else {
        [[V2TIMManager sharedInstance] deleteFromBlackList:@[self.friendProfile.userID] succ:nil fail:nil];
        [TCUtil report:Action_Deleteblacklist actionSub:@"" code:@(0) msg:@"deleteblacklist"];
    }
}

/**
 *点击 修改备注 按钮后所执行的函数。包含数据的获取与请求回调
 */
- (void)onChangeRemark:(TCommonTextCell *)cell
{
    TTextEditController *vc = [[TTextEditController alloc] initWithText:self.friendProfile.friendRemark];
    vc.title = NSLocalizedString(@"ProfileEditAlia", nil); // @"修改备注";
    vc.textValue = self.friendProfile.friendRemark;
    [self.navigationController pushViewController:vc animated:YES];

    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *value) {
        @strongify(self)
        self.modified = YES;
        self.friendProfile.friendRemark = value;
        [[V2TIMManager sharedInstance] setFriendInfo:self.friendProfile succ:^{
            [self loadData];
            [NSNotificationCenter.defaultCenter postNotificationName:@"FriendInfoChangedNotification" object:self.friendProfile];
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

    NSObject *data = self.dataList[indexPath.section][indexPath.row];
    //原本的写法会使得子类重写的方法无法被调用，所以此处使用了“我”界面的写法。
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
        //设置 profileCard 的委托
        cell.delegate = self;
        [cell fillWithData:(TUIProfileCardCellData *)data];
        return cell;

    }   else if([data isKindOfClass:[TUIButtonCellData class]]){
        TUIButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if(!cell){
            cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
        }
        [cell fillWithData:(TUIButtonCellData *)data];
        return cell;

    }  else if([data isKindOfClass:[TCommonTextCellData class]]) {
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonTextCellData *)data];
        return cell;

    }  else if([data isKindOfClass:[TCommonSwitchCellData class]]) {
        TCommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonSwitchCellData *)data];
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TCommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}


/**
 *点击 删除好友 后执行的函数，包括好友信息获取和请求回调
 */
- (void)onDeleteFriend:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] deleteFromFriendList:@[self.friendProfile.userID] deleteType:V2TIM_FRIEND_TYPE_BOTH succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
        weakSelf.modified = YES;
        [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"c2c_%@",weakSelf.friendProfile.userID] callback:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } fail:nil];
}

/**
 *点击 发送消息 后执行的函数，默认跳转到对应好友的聊天界面
 */
- (void)onSendMessage:(id)sender
{
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = [NSString stringWithFormat:@"c2c_%@",self.userFullInfo.userID];
    data.userID = self.friendProfile.userID;
    data.title = [self.friendProfile.userFullInfo showName];
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = data;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *操作 消息免打扰 开关后执行的函数
 */
- (void)onMessageDoNotDisturb:(TCommonSwitchCell *)cell
{
    V2TIMReceiveMessageOpt opt;
    if (cell.switcher.on) {
        opt = V2TIM_NOT_RECEIVE_MESSAGE;
    } else {
        opt = V2TIM_RECEIVE_MESSAGE;
    }
    [[V2TIMManager sharedInstance] setC2CReceiveMessageOpt:@[self.friendProfile.userID] opt:opt succ:nil fail:nil];
}

/**
 *操作 置顶 开关后执行的函数，将对应好友添加/移除置顶队列
 */
- (void)onTopMostChat:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 操作失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [THelper makeToast:errorMessage];
        }];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 操作失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [THelper makeToast:errorMessage];
        }];
    }
}

/**
 *  以下两个函数实现了在好友界面长按的复制功能。
 */
- (void)addLongPressGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAtCell:)];
    [self.tableView addGestureRecognizer:longPress];
}

-(void) didLongPressAtCell:(UILongPressGestureRecognizer *)longPress {
    if(longPress.state == UIGestureRecognizerStateBegan){
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath *pathAtView = [self.tableView indexPathForRowAtPoint:point];
        NSObject *data = [self.tableView cellForRowAtIndexPath:pathAtView];

        //长按 TCommonTextCell，可以复制 cell 内的字符串。
        if([data isKindOfClass:[TCommonTextCell class]]){
            TCommonTextCell *textCell = (TCommonTextCell *)data;
            if(textCell.textData.value && ![textCell.textData.value isEqualToString:@"未设置"]){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = textCell.textData.value;
                NSString *toastString = [NSString stringWithFormat:@"已将 %@ 复制到粘贴板",textCell.textData.key];
                [THelper makeToast:toastString];
            }
        }else if([data isKindOfClass:[TUIProfileCardCell class]]){
            //长按 profileCard，复制好友的账号。
            TUIProfileCardCell *profileCard = (TUIProfileCardCell *)data;
            if(profileCard.cardData.identifier){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.cardData.identifier;
                NSString *toastString = [NSString stringWithFormat:@"已将该用户账号复制到粘贴板"];
                [THelper makeToast:toastString];
            }

        }
    }
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
