//
//  TUIGroupRequestViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/5/20.
//  Copyright © 2019 Tencent. All rights reserved.
//
#import "TUIGroupRequestViewController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@interface TUIGroupRequestViewController () <UITableViewDataSource, UITableViewDelegate, TUIProfileCardDelegate>
@property UITableView *tableView;
@property UITextView *addMsgTextView;
@property TUIProfileCardCellData *cardCellData;
@end

@implementation TUIGroupRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.mm_fill();
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.addMsgTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.addMsgTextView.font = [UIFont systemFontOfSize:14];
    self.addMsgTextView.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[ loginUser ]
                                           succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                             self.addMsgTextView.text = [NSString
                                                 stringWithFormat:TIMCommonLocalizableString(GroupRequestJoinGroupFormat), [[infoList firstObject] showName]];
                                           }
                                           fail:^(int code, NSString *msg){
                                           }];
    TUIProfileCardCellData *data = [TUIProfileCardCellData new];
    data.name = self.groupInfo.groupName;
    data.identifier = self.groupInfo.groupID;
    data.avatarImage = DefaultGroupAvatarImageByGroupType(self.groupInfo.groupType);
    data.avatarUrl = [NSURL URLWithString:self.groupInfo.faceURL];
    self.cardCellData = data;

    self.title = TIMCommonLocalizableString(GroupJoin);

    [TUITool addUnsupportNotificationInVC:self];
}

- (void)dealloc {
    NSLog(@"%s dealloc", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] init];
    label.text = TIMCommonLocalizableString(please_fill_in_verification_information);
    label.textColor = [UIColor colorWithRed:136 / 255.0 green:136 / 255.0 blue:136 / 255.0 alpha:1 / 1.0];
    label.font = [UIFont systemFontOfSize:14.0];

    label.frame = CGRectMake(10, 0, self.tableView.bounds.size.width - 20, 40);
    [view addSubview:label];

    return section == 1 ? view : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    if (section == 2) {
        return 10;
    }

    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{ return 3; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TUIProfileCardCell *cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TPersonalCommonCell_ReuseId"];
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
        cellData.title = TIMCommonLocalizableString(Send);
        cellData.style = ButtonWhite;
        cellData.cselector = @selector(onSend);
        cellData.textColor = [UIColor colorWithRed:20 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1 / 1.0];
        [cell fillWithData:cellData];
        return cell;
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)onSend {
    // display toast with an activity spinner
    [TUITool makeToastActivity];
    [[V2TIMManager sharedInstance] joinGroup:self.groupInfo.groupID
        msg:self.addMsgTextView.text
        succ:^{
          [TUITool hideToastActivity];
          [TUITool makeToast:TIMCommonLocalizableString(send_success) duration:3.0 idposition:TUICSToastPositionBottom];
        }
        fail:^(int code, NSString *desc) {
          [TUITool hideToastActivity];
          [TUITool makeToastError:code msg:desc];
          if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
              [TUITool postUnsupportNotificationOfService:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunity)
                                              serviceDesc:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunityDesc)
                                                debugOnly:YES];
          }
        }];
}

- (void)didTapOnAvatar:(TUIProfileCardCell *)cell {
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

@end
