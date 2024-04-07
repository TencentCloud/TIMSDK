//
//  TUIStyleSelectViewController.m
//  TUIKitDemo
//
//  Created by wyl on 2022/11/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIStyleSelectViewController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIStyleSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setCellModel:(TUIStyleSelectCellModel *)cellModel {
    _cellModel = cellModel;

    self.nameLabel.text = cellModel.styleName;
    self.nameLabel.textColor = cellModel.selected ? RGBA(0, 110, 255, 1) : TIMCommonDynamicColor(@"form_title_color", @"#000000");
    self.chooseIconView.hidden = !cellModel.selected;
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)setupViews {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.chooseIconView];
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    
    [self.chooseIconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.trailing.mas_equalTo(-16);
    }];

    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(self.chooseIconView.mas_leading).mas_offset(-2);
        make.height.mas_equalTo(self.nameLabel.font.lineHeight);
        make.centerY.mas_equalTo(self.contentView);
    }];
}
- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16.0];
        _nameLabel.text = @"1233";
        _nameLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        _nameLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
    }
    return _nameLabel;
}

- (UIImageView *)chooseIconView {
    if (_chooseIconView == nil) {
        _chooseIconView = [[UIImageView alloc] init];
        _chooseIconView.image = TIMCommonBundleImage(@"default_choose");
    }
    return _chooseIconView;
}

@end

@implementation TUIStyleSelectCellModel

@end

@interface TUIStyleSelectViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *datas;

@property(nonatomic, strong) TUIStyleSelectCellModel *selectModel;

@end

@implementation TUIStyleSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
    [self prepareData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.standardAppearance = appearance;
        /**
         * iOS15 ：
         * New feature in iOS15: sliding border style
         */
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;

    } else {
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
    }
    self.navigationController.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    self.navigationController.navigationBarHidden = NO;
}

- (UIColor *)tintColor {
    return TIMCommonDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;

    /**
     * Not setting it will cause some problems such as confusion in position, no animation, etc.
     */
    self.definesPresentationContext = YES;

    self.navigationController.navigationBarHidden = NO;
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(TIMAppSelectStyle)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    UIImage *image = TIMCommonDynamicImage(@"nav_back_img", [UIImage imageNamed:@"ic_back_white"]);
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    image = [image rtl_imageFlippedForRightToLeftLayoutDirection];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = YES;

    [self.view addSubview:self.tableView];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareData {
    TUIStyleSelectCellModel *classic = [[TUIStyleSelectCellModel alloc] init];
    classic.styleID = @"Classic";
    classic.styleName = TIMCommonLocalizableString(TUIKitClassic);
    classic.selected = NO;

    TUIStyleSelectCellModel *mini = [[TUIStyleSelectCellModel alloc] init];
    mini.styleID = @"Minimalist";
    mini.styleName = TIMCommonLocalizableString(TUIKitMinimalist);
    mini.selected = NO;

    self.datas = [NSMutableArray arrayWithArray:@[ classic, mini ]];

    NSString *styleID = [[NSUserDefaults standardUserDefaults] objectForKey:@"StyleSelectkey"];

    for (TUIStyleSelectCellModel *cellModel in self.datas) {
        if ([cellModel.styleID isEqual:styleID]) {
            cellModel.selected = YES;
            self.selectModel = cellModel;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIStyleSelectCellModel *cellModel = self.datas[indexPath.row];
    TUIStyleSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.cellModel = cellModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TUIStyleSelectCellModel *cellModel = self.datas[indexPath.row];

    [[NSUserDefaults standardUserDefaults] setValue:cellModel.styleID forKey:@"StyleSelectkey"];
    [NSUserDefaults.standardUserDefaults synchronize];
    /**
     * Handling UI selection
     */
    self.selectModel.selected = NO;
    cellModel.selected = YES;
    self.selectModel = cellModel;
    [tableView reloadData];

    /**
     * Notify page dynamic refresh
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([weakSelf.delegate respondsToSelector:@selector(onSelectStyle:)]) {
          [weakSelf.delegate onSelectStyle:cellModel];
      }
    });
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#FFFFFF");
        [_tableView registerClass:TUIStyleSelectCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (void)setBackGroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    self.tableView.backgroundColor = color;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

+ (NSString *)getCurrentStyleSelectID {
    NSString *styleID = [[NSUserDefaults standardUserDefaults] objectForKey:@"StyleSelectkey"];
    if (IS_NOT_EMPTY_NSSTRING(styleID)) {
        return styleID;
    } else {
        // First Init
        NSString *initStyleID = kTUIKitFirstInitAppStyleID;
        [[NSUserDefaults standardUserDefaults] setValue:initStyleID forKey:@"StyleSelectkey"];
        [NSUserDefaults.standardUserDefaults synchronize];
        return initStyleID;
    }
}

+ (BOOL)isClassicEntrance {
    NSString *styleID = [self.class getCurrentStyleSelectID];
    if ([styleID isKindOfClass:NSString.class]) {
        if (styleID.length > 0) {
            if ([styleID isEqualToString:@"Classic"]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
