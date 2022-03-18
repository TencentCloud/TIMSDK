//
//  TUIAboutUsViewController.m
//  TUIKitDemo
//
//  Created by wyl on 2022/2/9.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIAboutUsViewController.h"
#import "TUINaviBarIndicatorView.h"
#import "TUIThemeManager.h"
#import "TUICommonTextCell.h"
#import "TUICancelAccountViewController.h"
#import "TCUtil.h"
@interface TUIAboutUsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation TUIAboutUsViewController

//MARK: life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self applyData];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"MeAbout", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    self.tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    [self.tableView registerClass:[TUICommonTextCell class] forCellReuseIdentifier:@"textCell"];
}

- (void)applyData {
    if (self.data) {
        [self.data removeAllObjects];
    }
    NSString *privacyUrl = @"https://privacy.qq.com/document/preview/1cfe904fb7004b8ab1193a55857f7272";
    NSString *agreeUrl = @"https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html";
    NSString *disclaimerText = NSLocalizedString(@"TUIKitAboutUsDisclaimerText", nil);
    
    NSString *personalInformationURL = @"https://privacy.qq.com/document/preview/45ba982a1ce6493597a00f8c86b52a1e";
    NSString *threePartySharingURL = @"https://privacy.qq.com/document/preview/dea84ac4bb88454794928b77126e9246";
    NSString *aboutUsUrl = @"https://cloud.tencent.com/document/product/269/59590";
    NSString *versionText = [V2TIMManager sharedInstance].getVersion;
    TUICommonTextCellData *versionData = [TUICommonTextCellData new];
    versionData.key = NSLocalizedString(@"TUIKitAboutUsSDKVersion", nil); // "SDK版本";
    versionData.value = versionText?versionText:@"";// @"版本号"
    versionData.showAccessory = NO;
    versionData.ext = @{@"event_type":@"0"};
    NSArray * keysArray = @[NSLocalizedString(@"TUIKitAboutUsPrivacyRegulations", nil)
                            ,NSLocalizedString(@"TUIKitAboutUsUserAgreement", nil)
                            ,NSLocalizedString(@"TUIKitAboutUsDisclaimer", nil)
                            ,NSLocalizedString(@"TUIKitAboutUsPersonalInformationCollectionList", nil)
                            ,NSLocalizedString(@"TUIKitAboutUs3PartySharingList", nil)
                            ,NSLocalizedString(@"TUIKitAboutUsCloseAccount", nil)
                            ,NSLocalizedString(@"TUIKitAboutUsContactUs", nil)];
    NSArray * extssArray = @[
        @{@"event_type":@"101",@"url":privacyUrl},
        @{@"event_type":@"101",@"url":agreeUrl},
        @{@"event_type":@"102",@"txt":disclaimerText},
        @{@"event_type":@"101",@"url":personalInformationURL},
        @{@"event_type":@"101",@"url":threePartySharingURL},
        @{@"event_type":@"103"},
        @{@"event_type":@"101",@"url":aboutUsUrl},
    ];
    
    NSMutableArray *clickArray = [NSMutableArray arrayWithCapacity:keysArray.count+1];
    [clickArray addObject:versionData];
    
    for (int i = 0; i < keysArray.count; i++) {
        TUICommonTextCellData *data = [TUICommonTextCellData new];
        data.key = keysArray[i];
        data.showAccessory = YES;
        data.ext = extssArray[i];
        data.cselector = @selector(click:);
        [clickArray addObject:data];
    }
    
    [self.data addObject:clickArray];
    [self.tableView reloadData];
}

//MARK: lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray arrayWithCapacity:3];
    }
    return _data;
}

//MARK: action
- (void)click:(id)data {
    if ([data isKindOfClass:[TUICommonTextCell class]]) {
        TUICommonTextCell *cell = (TUICommonTextCell*)data;
        NSDictionary *dic = cell.data.ext;
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *event_type = dic[@"event_type"];
            NSString *urlStr = dic[@"url"]?dic[@"url"]:@"";
            NSString *txt = dic[@"txt"]?dic[@"txt"]:@"";
            if ([event_type isEqualToString:@"101"]) {
                NSURL * url = [NSURL URLWithString:urlStr];
                [TCUtil openLinkWithURL:url];
            }
            else if([event_type isEqualToString:@"102"]) {
                [self showAlertWithText:txt];
            }
            else if ([event_type isEqualToString:@"103"]) {
                TUICancelAccountViewController * vc = [[TUICancelAccountViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                
            }
        }
        
    }
    
}

- (void)showAlertWithText:(NSString *)atext {

    UIAlertController *alvc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TUIKitAboutUsDisclaimer", nil) message:atext preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Accept", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alvc addAction:confirmAction];
    [self presentViewController:alvc animated:YES completion:^{
    }];
}

//MARK: delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = self.data.count;
    return sectionCount;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0 : 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    TUICommonCellData *data = array[indexPath.row];
    
    return [data heightOfWidth:Screen_Width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUICommonTextCellData class]]) {
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonTextCellData *)data];
        return cell;
    }
    return nil;
}

@end
