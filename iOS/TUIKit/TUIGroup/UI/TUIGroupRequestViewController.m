//
//  TUIGroupRequestViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/5/20.
//  Copyright © 2019年 Tencent. All rights reserved.
//
#import "TUIGroupRequestViewController.h"
#import "TUICommonModel.h"
#import "TUIProfileCardCell.h"
#import "TUIDefine.h"
#import "TUIAvatarViewController.h"

@interface TUIGroupRequestViewController ()<UITableViewDataSource, UITableViewDelegate, TUIProfileCardDelegate>
@property UITableView *tableView;
@property UITextView  *addMsgTextView;
@property TUIProfileCardCellData *cardCellData;
@end

@implementation TUIGroupRequestViewController

- (void)viewDidLoad {
    //初始化视图内容信息
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.mm_fill();
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.addMsgTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.addMsgTextView.font = [UIFont systemFontOfSize:14];
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        self.addMsgTextView.text = [NSString stringWithFormat:TUIKitLocalizableString(GroupRequestJoinGroupFormat), [[infoList firstObject] showName]]; // "%@ 申请加入群聊
    } fail:^(int code, NSString *msg) {
    }];
    TUIProfileCardCellData *data = [TUIProfileCardCellData new];
    data.name = self.groupInfo.groupName;
    data.identifier = self.groupInfo.groupID;
    data.avatarImage = DefaultGroupAvatarImage;
    data.avatarUrl = [NSURL URLWithString:self.groupInfo.faceURL];
    self.cardCellData = data;

    self.title = TUIKitLocalizableString(GroupJoin);
    
    [TUITool addUnsupportNotificationInVC:self];
}

- (void)dealloc {
    NSLog(@"%s dealloc", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *tableView委托函数
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        return [self.cardCellData heightOfWidth:Screen_Width];
    }
    if (indexPath.section == 1) {
        return 120;
    }
    if (indexPath.section == 2) {
        return 54;
    }
    return 0.;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = TUIKitLocalizableString(please_fill_in_verification_information); // @"填写验证信息";
    label.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    label.font = [UIFont systemFontOfSize:14.0];
    
    label.frame = CGRectMake(10, 0, self.tableView.bounds.size.width - 20, 40);
    [view addSubview:label];
    
    return section == 1 ? view : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40;
    }
    if (section == 2) {
        return 10;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TUIProfileCardCell *cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TPersonalCommonCell_ReuseId"];
        //设置 profileCard 的委托
        cell.delegate = self;
        [cell fillWithData:self.cardCellData];
        return cell;
    }
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddWord"];
        [cell.contentView addSubview:self.addMsgTextView];
        self.addMsgTextView.mm_width(Screen_Width).mm_height(120);
        return cell;
    }
    if (indexPath.section == 2) {
        TUIButtonCell *cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"send"];
        TUIButtonCellData *cellData = [[TUIButtonCellData alloc] init];
        cellData.title = TUIKitLocalizableString(Send);
        cellData.style = ButtonWhite;
        cellData.cselector = @selector(onSend);
        cellData.textColor = [UIColor colorWithRed:20/255.0 green:122/255.0 blue:255/255.0 alpha:1/1.0];
        [cell fillWithData:cellData];
        return cell;
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/**
 *点击 发送 按钮后执行的函数，包括信息收集和请求回调
 */
- (void)onSend
{
    // display toast with an activity spinner
    [TUITool makeToastActivity];
    [[V2TIMManager sharedInstance] joinGroup:self.groupInfo.groupID msg:self.addMsgTextView.text succ:^{
        [TUITool hideToastActivity];
        [TUITool makeToast:TUIKitLocalizableString(send_success)
                 duration:3.0
                 idposition:TUICSToastPositionBottom];
    } fail:^(int code, NSString *desc) {
        [TUITool hideToastActivity];
        [TUITool makeToastError:code msg:desc];
        if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
            [TUITool postUnsupportNotificationOfService:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceCommunity) serviceDesc:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceCommunityDesc) debugOnly:YES];
        }
    }];
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
