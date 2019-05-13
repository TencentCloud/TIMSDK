//
//  TFriendController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/29.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TFriendProfileController.h"
#import "TRichMenuCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "TTextEditController.h"
#import "KVOController/KVOController.h"
#import "TIMFriendshipManager.h"
#import "ChatViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"


@TCServiceRegister(TFriendProfileControllerServiceProtocol, TFriendProfileController)

@interface TFriendProfileController ()
{
    TIMFriend *_friendProfile;
}
@property NSArray *dataList;
@property BOOL isInBlackList;
@property BOOL modified;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    

    
    [self.tableView registerClass:[TRichMenuCell class] forCellReuseIdentifier:kRichMenuCellReuseIdentifier];
}

- (void)loadData
{
    @mm_weakify(self)
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        TRichMenuCellData *data = TRichMenuCellData.new;
        data.type = ERichCell_Text;
        data.desc = @"昵称";
        data.value = self.friendProfile.profile.nickname;
        if (data.value.length == 0)
        {
            data.value = @"无";
        }
        data;
    })];
    [list addObject:({
        TRichMenuCellData *data = TRichMenuCellData.new;
        data.type = ERichCell_TextNext;
        data.desc = @"备注名";
        data.value = self.friendProfile.remark;
        if (data.value.length == 0)
        {
            data.value = @"无";
        }
        data.onSelectAction = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
            @mm_strongify(self);
            TTextEditController *vc = [[TTextEditController alloc] initWithText:self.friendProfile.remark];
            vc.title = @"修改备注";
            vc.textValue = self.friendProfile.remark;
            [self.navigationController pushViewController:vc animated:YES];
            [self.KVOControllerNonRetaining observe:vc keyPath:@"textValue" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
               self.modified = YES;
                [[TIMFriendshipManager sharedInstance] modifyFriend:self.friendProfile.identifier
                                                             values:@{TIMFriendTypeKey_Remark: change[NSKeyValueChangeNewKey]}
                                                               succ:^{
                                                                   self.friendProfile.remark = change[NSKeyValueChangeNewKey];
                                                                   [self loadData];
                                                               } fail:nil];
            }];
        };
        data;
    })];
    [list addObject:({
        TRichMenuCellData *data = TRichMenuCellData.new;
        data.type = ERichCell_Switch;
        data.desc = @"加入黑名单";
        data.switchValue = self.isInBlackList;
        data.onSwitchAction = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
            @mm_strongify(self)
            if (cell.onSwitch.on) {
                [[TIMFriendshipManager sharedInstance] addBlackList:@[self.friendProfile.identifier] succ:^(NSArray<TIMFriendResult *> *results) {
                    menu.switchValue = YES;
                } fail:nil];
            } else {
                [[TIMFriendshipManager sharedInstance] deleteBlackList:@[self.friendProfile.identifier] succ:^(NSArray<TIMFriendResult *> *results) {
                    menu.switchValue = NO;
                } fail:nil];
            }
        };
        data;
    })];
    
    self.dataList = list;
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
    TRichMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:kRichMenuCellReuseIdentifier forIndexPath:indexPath];
 
    cell.data = self.dataList[indexPath.row];
 
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.mm_w, 120)];
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [header addSubview:avatarView];
    if (self.friendProfile.profile.faceURL) {
        [avatarView sd_setImageWithURL:[NSURL URLWithString:self.friendProfile.profile.faceURL] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_head")]];
    } else {
        [avatarView setImage:[UIImage imageNamed:TUIKitResource(@"default_head")]];
    }
    avatarView.layer.cornerRadius = 40;
    avatarView.layer.masksToBounds = YES;
    avatarView.mm_width(80).mm_height(80).mm_center();
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [header addSubview:label];
    label.textAlignment = NSTextAlignmentCenter;
    label.mm_width(header.mm_w).mm_top(avatarView.mm_maxY+10).mm_height(20);
    label.text = _friendProfile.identifier;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.mm_w, 80)];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [footer addSubview:btn1];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 setTitle:@"删除好友" forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor redColor]];
    [btn1 addTarget:self action:@selector(onDeleteFriend) forControlEvents:UIControlEventTouchUpInside];
    btn1.mm_width(footer.mm_w/2-20).mm_height(48).mm_top(20).mm__centerX(footer.mm_w/4);

    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [footer addSubview:btn2];
    [btn2 setTitle:@"发送消息" forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor blueColor]];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.mm_width(footer.mm_w/2-20).mm_height(48).mm_top(20).mm__centerX(footer.mm_w/4*3);
    [btn2 addTarget:self action:@selector(onSendMessage) forControlEvents:UIControlEventTouchUpInside];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
}
     
- (void)onDeleteFriend
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

- (void)onSendMessage
{
    TConversationCellData *data = [[TConversationCellData alloc] init];
    data.convId = self.friendProfile.identifier;
    data.convType = TConv_Type_C2C;
    data.title = self.friendProfile.identifier;
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversation = data;
    [self.navigationController pushViewController:chat animated:YES];
}

@end
