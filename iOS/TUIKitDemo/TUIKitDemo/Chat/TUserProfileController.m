//
//  TProfileController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TUserProfileController.h"
#import "TPersonalCommonCell.h"
#import "TButtonCell.h"
#import "THeader.h"
#import "TAlertView.h"
#import "TRichMenuCell.h"
#import "TRichMenuCellData.h"
#import "TTextEditController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ChatViewController.h"

@import ImSDK;

@interface TUserProfileController ()
@property NSMutableArray<TRichMenuCellData *> *dataList;
@property BOOL isSelfProfile;
@end

@implementation TUserProfileController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView registerClass:[TRichMenuCell class] forCellReuseIdentifier:kRichMenuCellReuseIdentifier];
    
    [self loadData];
}

- (void)loadData
{
    self.isSelfProfile = ([self.profile.identifier isEqualToString:[[TIMManager sharedInstance] getLoginUser]]);
                        
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        TRichMenuCellData *data = TRichMenuCellData.new;
        data.type = ERichCell_Text;
        data.desc = @"昵称";
        data.value = self.profile.nickname;
        if (data.value.length == 0)
        {
            data.value = @"无";
        }
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
    if (self.profile.faceURL) {
        [avatarView sd_setImageWithURL:[NSURL URLWithString:self.profile.faceURL] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_head")]];
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
    label.text = self.profile.identifier;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.isSelfProfile)
        return nil;
    
    UITableViewHeaderFooterView *footer = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.mm_w, 80)];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [footer addSubview:btn2];
    [btn2 setTitle:@"发送消息" forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor blueColor]];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.mm_left(20).mm_height(48).mm_top(20).mm_flexToRight(20);
    [btn2 addTarget:self action:@selector(onSendMessage) forControlEvents:UIControlEventTouchUpInside];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
}

- (void)onSendMessage
{
    TConversationCellData *data = [[TConversationCellData alloc] init];
    data.convId = self.profile.identifier;
    data.convType = TConv_Type_C2C;
    data.title = self.profile.identifier;
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversation = data;
    [self.navigationController pushViewController:chat animated:YES];
}
@end
