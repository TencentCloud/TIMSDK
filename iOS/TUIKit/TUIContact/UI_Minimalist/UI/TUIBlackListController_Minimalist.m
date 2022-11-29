//
//  TUIBlackListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUIBlackListController_Minimalist.h"
#import "ReactiveObjC.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@interface TUIBlackListController_Minimalist ()<V2TIMFriendshipListener>

@property (nonatomic, strong) UILabel *noDataTipsLabel;

@end

@implementation TUIBlackListController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TUIKitLocalizableString(TUIKitContactsBlackList);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TUICoreDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.tableView.delaysContentTouches = NO;

    if (!self.viewModel) {
        self.viewModel = TUIBlackListViewDataProvider.new;
        @weakify(self)
        [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
            @strongify(self)
            if ([(NSNumber *)finished boolValue])
                [self.tableView reloadData];
        }];
        [self.viewModel loadBlackList];
    }

    [self.tableView registerClass:[TUICommonContactCell class] forCellReuseIdentifier:@"FriendCell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    
    [[V2TIMManager sharedInstance] addFriendListener:self];
    
    [self.tableView addSubview:self.noDataTipsLabel];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.noDataTipsLabel.frame = CGRectMake(10, 60, self.view.bounds.size.width - 20, 40);
}

#pragma mark - V2TIMFriendshipListener
- (void)onBlackListAdded:(NSArray<V2TIMFriendInfo *>*)infoList {
    [self.viewModel loadBlackList];
}

- (void)onBlackListDeleted:(NSArray*)userIDList {
    [self.viewModel loadBlackList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.noDataTipsLabel.hidden = (self.viewModel.blackListData.count != 0);
    return self.viewModel.blackListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    TUICommonContactCellData *data = self.viewModel.blackListData[indexPath.row];
    data.cselector = @selector(didSelectBlackList:);
    [cell fillWithData:data];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

-(void)didSelectBlackList:(TUICommonContactCell *)cell
{
    if (self.didSelectCellBlock) {
        self.didSelectCellBlock(cell);
    }
}

- (UILabel *)noDataTipsLabel
{
    if (_noDataTipsLabel == nil) {
        _noDataTipsLabel = [[UILabel alloc] init];
        _noDataTipsLabel.textColor = TUIContactDynamicColor(@"contact_add_contact_nodata_tips_text_color", @"#999999");
        _noDataTipsLabel.font = [UIFont systemFontOfSize:14.0];
        _noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noDataTipsLabel.text = TUIKitLocalizableString(TUIKitContactNoBlockList);
    }
    return _noDataTipsLabel;
}

@end
