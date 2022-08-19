//
//  LanguageSelectController.m
//  TUIKitDemo
//
//  Created by harvy on 2022/1/6.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "LanguageSelectController.h"
#import "TUIDarkModel.h"
#import "TUIGlobalization.h"
#import "TUIThemeManager.h"
#import "TUIDefine.h"

@implementation LanguageSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setCellModel:(LanguageSelectCellModel *)cellModel
{
    _cellModel = cellModel;
    
    self.nameLabel.text = cellModel.languageName;
    self.chooseIconView.hidden = !cellModel.selected;
}

- (void)setupViews
{
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.chooseIconView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.chooseIconView.frame = CGRectMake(self.contentView.mm_w - 16 - 20, 0.5 * (self.contentView.mm_h - 20), 20, 20);
    self.nameLabel.frame = CGRectMake(16, 0, self.contentView.mm_w - 3 * 16 - 20, self.contentView.mm_h);
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16.0];
        _nameLabel.text = @"1233";
        _nameLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
    }
    return _nameLabel;
}

- (UIImageView *)chooseIconView
{
    if (_chooseIconView == nil) {
        _chooseIconView = [[UIImageView alloc] init];
        _chooseIconView.image = [UIImage imageNamed:@"choose"];
    }
    return _chooseIconView;
}

@end

@implementation LanguageSelectCellModel


@end

@interface LanguageSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) LanguageSelectCellModel *selectModel;

@end

@implementation LanguageSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self prepareData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor =  self.tintColor;
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.standardAppearance = appearance;
        /**
         * iOS15 新增特性：滑动边界样式
         * New feature in iOS15: sliding border style
         */
        self.navigationController.navigationBar.scrollEdgeAppearance= appearance;

    }
    else {
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = NO;

    }
    self.navigationController.navigationBarHidden = NO;

}

- (UIColor *)tintColor
{
    return TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupViews
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    /**
     * 不设置会导致一些位置错乱，无动画等问题
     * Not setting it will cause some problems such as confusion in position, no animation, etc.
     */
    self.definesPresentationContext = YES;
    
    self.navigationController.navigationBarHidden = NO;
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"ChangeLanguage", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    UIImage *image = TUIDemoDynamicImage(@"nav_back_img", [UIImage imageNamed:@"ic_back_white"]);
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = YES;
    
    [self.view addSubview:self.tableView];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareData
{
    LanguageSelectCellModel *chinese = [[LanguageSelectCellModel alloc] init];
    chinese.languageID = @"zh-Hans";
    chinese.languageName = @"简体中文";
    chinese.selected = NO;
    
    LanguageSelectCellModel *english = [[LanguageSelectCellModel alloc] init];
    english.languageID = @"en";
    english.languageName = @"English";
    english.selected = NO;
    
    self.datas = [NSMutableArray arrayWithArray:@[chinese, english]];
    
    NSString *languageID = [TUIGlobalization tk_localizableLanguageKey];
    for (LanguageSelectCellModel *cellModel in self.datas) {
        if ([cellModel.languageID isEqual:languageID]) {
            cellModel.selected = YES;
            self.selectModel = cellModel;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LanguageSelectCellModel *cellModel = self.datas[indexPath.row];
    LanguageSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.cellModel = cellModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    LanguageSelectCellModel *cellModel = self.datas[indexPath.row];
    
    /**
     * 切换语言
     * Changing language
     */
    [TUIGlobalization setCustomLanguage:cellModel.languageID];
    
    /**
     * 处理 UI 选中
     * Handling UI selection
     */
    self.selectModel.selected = NO;
    cellModel.selected = YES;
    self.selectModel = cellModel;
    [tableView reloadData];
    
    /**
     * 通知页面动态刷新
     * Notify page dynamic refresh
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(onSelectLanguage:)]) {
            [weakSelf.delegate onSelectLanguage:cellModel];
        }
    });
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_tableView registerClass:LanguageSelectCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSMutableArray *)datas
{
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

@end
