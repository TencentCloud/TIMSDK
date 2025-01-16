//
//  TUIGroupRequestViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/5/20.
//  Copyright © 2019 Tencent. All rights reserved.
//
#import "TUIGroupRequestViewController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUIGroupButtonCell_Minimalist.h"
#import "TUIProfileCardCell_Minimalist.h"

@interface TUIGroupRequestViewController_Minimalist () <UITableViewDataSource, UITableViewDelegate, TUIProfileCardDelegate>
@property UITableView *tableView;
@property UITextView *addMsgTextView;
@property TUIProfileCardCellData_Minimalist *cardCellData;
@end

@implementation TUIGroupRequestViewController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.mm_fill();
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.addMsgTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.addMsgTextView.font = [UIFont systemFontOfSize:14];
    self.addMsgTextView.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    self.addMsgTextView.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.firstLineHeadIndent = kScale390(12.5);
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:kScale390(16)], NSParagraphStyleAttributeName : paragraphStyle};
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance]
        getUsersInfo:@[ loginUser ]
                succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                  NSString *text = [NSString stringWithFormat:TIMCommonLocalizableString(GroupRequestJoinGroupFormat), [[infoList firstObject] showName]];
                  self.addMsgTextView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
                }
                fail:^(int code, NSString *msg){
                }];

    TUIProfileCardCellData_Minimalist *data = [TUIProfileCardCellData_Minimalist new];
    data.name = self.groupInfo.groupName;
    data.identifier = self.groupInfo.groupID;
    data.signature = [NSString stringWithFormat:@"%@: %@", TIMCommonLocalizableString(TUIKitCreatGroupType), self.groupInfo.groupType];
    data.showSignature = YES;
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
        return kScale390(123);
    }
    if (indexPath.section == 2) {
        return kScale390(42);
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
    label.textColor = [UIColor tui_colorWithHex:@"000000"];
    label.font = [UIFont systemFontOfSize:14.0];

    label.frame = CGRectMake(kScale390(16), kScale390(12), self.tableView.bounds.size.width - 20, kScale390(28));
    [view addSubview:label];

    return section == 1 ? view : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kScale390(10);
    }
    if (section == 1) {
        return kScale390(40);
    }
    if (section == 2) {
        return kScale390(20);
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
        TUIProfileCardCell_Minimalist *cell = [[TUIProfileCardCell_Minimalist alloc] initWithStyle:UITableViewCellStyleDefault
                                                                                   reuseIdentifier:@"TPersonalCommonCell_ReuseId"];
        cell.delegate = self;
        [cell fillWithData:self.cardCellData];
        return cell;
    }
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddWord"];
        [cell.contentView addSubview:self.addMsgTextView];
        self.addMsgTextView.mm_width(Screen_Width).mm_height(kScale390(123));
        return cell;
    }
    if (indexPath.section == 2) {
        TUIGroupButtonCell_Minimalist *cell = [[TUIGroupButtonCell_Minimalist alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"send"];
        TUIGroupButtonCellData_Minimalist *cellData = [[TUIGroupButtonCellData_Minimalist alloc] init];
        cellData.title = TIMCommonLocalizableString(Send);
        cellData.style = ButtonBule;
        cellData.cselector = @selector(onSend);
        cellData.textColor = [UIColor tui_colorWithHex:@"#147AFF"];
        [cell fillWithData:cellData];
        return cell;
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.addMsgTextView endEditing:YES];
}
- (void)onSend {
    // display toast with an activity spinner
    [TUITool makeToastActivity];
    [[V2TIMManager sharedInstance] joinGroup:self.groupInfo.groupID
        msg:self.addMsgTextView.text
        succ:^{
          [TUITool hideToastActivity];
          [self showHud:YES msgText:TIMCommonLocalizableString(send_success)];
        }
        fail:^(int code, NSString *desc) {
          [TUITool hideToastActivity];
          NSString *msg = [TUITool convertIMError:code msg:desc];
          [self showHud:NO msgText:msg];
          if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
              [TUITool postUnsupportNotificationOfService:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunity)
                                              serviceDesc:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunityDesc)
                                                debugOnly:YES];
          }
        }];
}

- (void)didTapOnAvatar:(TUIProfileCardCell_Minimalist *)cell {
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}
- (void)showHud:(BOOL)isSuccess msgText:(NSString *)msgText {
    UIView *hudView = [[UIView alloc] init];
    hudView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    hudView.backgroundColor = [UIColor tui_colorWithHex:@"#000000" alpha:0.6];

    UIView *msgView = [[UIView alloc] init];
    [hudView addSubview:msgView];
    msgView.layer.masksToBounds = YES;
    msgView.layer.cornerRadius = kScale390(10);
    msgView.backgroundColor = [UIColor tui_colorWithHex:@"FFFFFF"];

    UIImageView *icon = [[UIImageView alloc] init];
    [msgView addSubview:icon];
    icon.image = isSuccess ? [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_add_success")]
                           : [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_add_failed")];

    UILabel *descLabel = [[UILabel alloc] init];
    [msgView addSubview:descLabel];
    descLabel.font = [UIFont systemFontOfSize:kScale390(14)];
    descLabel.text = msgText;
    [descLabel sizeToFit];

    icon.frame = CGRectMake(kScale390(12), kScale390(10), kScale390(16), kScale390(16));
    descLabel.frame = CGRectMake(icon.frame.origin.x + icon.frame.size.width + kScale390(8), kScale390(8), descLabel.frame.size.width, kScale390(20));
    msgView.frame = CGRectMake(0, 0, descLabel.frame.origin.x + descLabel.frame.size.width + kScale390(12), kScale390(36));
    msgView.mm__centerX(hudView.mm_centerX);
    msgView.mm__centerY(hudView.mm_centerY);

    [[UIApplication sharedApplication].keyWindow showToast:hudView
                                                  duration:3.0
                                                  position:TUICSToastPositionCenter
                                                completion:^(BOOL didTap){

                                                }];
}
@end
