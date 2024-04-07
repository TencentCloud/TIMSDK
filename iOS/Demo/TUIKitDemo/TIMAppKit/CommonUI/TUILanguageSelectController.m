//
//  TUILanguageSelectController.m
//  TUIKitDemo
//
//  Created by harvy on 2022/1/6.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUILanguageSelectController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUILanguageSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setCellModel:(TUILanguageSelectCellModel *)cellModel {
    _cellModel = cellModel;

    self.nameLabel.text = cellModel.languageName;
    self.detailNameLabel.text = cellModel.nameInCurrentLanguage;
    self.chooseIconView.hidden = !cellModel.selected;
    self.detailNameLabel.hidden = cellModel.selected;
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)setupViews {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailNameLabel];
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
    
    if (self.detailNameLabel.isHidden) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.trailing.mas_equalTo(self.chooseIconView.mas_leading).mas_offset(-2);
            make.height.mas_equalTo(self.nameLabel.font.lineHeight);
            make.centerY.mas_equalTo(self.contentView);
        }];
    }
    else {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.trailing.mas_equalTo(self.chooseIconView.mas_leading).mas_offset(-2);
            make.top.mas_equalTo(3);
            make.height.mas_equalTo(self.nameLabel.font.lineHeight);
        }];
        
        [self.detailNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.trailing.mas_equalTo(self.chooseIconView.mas_leading).mas_offset(-2);
            make.bottom.mas_equalTo(-3);
            make.height.mas_equalTo(self.nameLabel.font.lineHeight);
        }];
    }

}
- (void)layoutSubviews {
    [super layoutSubviews];
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
- (UILabel *)detailNameLabel {
    if (_detailNameLabel == nil) {
        _detailNameLabel = [[UILabel alloc] init];
        _detailNameLabel.font = [UIFont systemFontOfSize:13.0];
        _detailNameLabel.text = @"1233";
        _detailNameLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        _detailNameLabel.textColor = [UIColor grayColor];
    }
    return _detailNameLabel;
}
- (UIImageView *)chooseIconView {
    if (_chooseIconView == nil) {
        _chooseIconView = [[UIImageView alloc] init];
        _chooseIconView.image = TIMCommonBundleImage(@"default_choose");
    }
    return _chooseIconView;
}

@end

@implementation TUILanguageSelectCellModel

@end

@interface TUILanguageSelectController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *datas;

@property(nonatomic, strong) TUILanguageSelectCellModel *selectModel;

@end

@implementation TUILanguageSelectController

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
    [_titleView setTitle:TIMCommonLocalizableString(TIMChangeLanguage)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    UIImage *image = [TIMCommonDynamicImage(@"nav_back_img", [UIImage imageNamed:TUIDemoImagePath(@"ic_back_white")]) rtl_imageFlippedForRightToLeftLayoutDirection];
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
    NSString *languageID = [TUIGlobalization tk_localizableLanguageKey];

    TUILanguageSelectCellModel *chinese = [[TUILanguageSelectCellModel alloc] init];
    chinese.languageID = @"zh-Hans";
    chinese.languageName = @"简体中文";
    chinese.nameInCurrentLanguage = TIMCommonLocalizableString(zh-Hans);
    chinese.selected = NO;

    TUILanguageSelectCellModel *english = [[TUILanguageSelectCellModel alloc] init];
    english.languageID = @"en";
    english.languageName = @"English";
    english.nameInCurrentLanguage = TIMCommonLocalizableString(en);
    english.selected = NO;
    
    TUILanguageSelectCellModel *ar = [[TUILanguageSelectCellModel alloc] init];
    ar.languageID = @"ar";
    ar.languageName = @"عربي";
    ar.nameInCurrentLanguage = TIMCommonLocalizableString(ar);
    ar.selected = NO;


    self.datas = [NSMutableArray arrayWithArray:@[ chinese, english,ar ]];

    for (TUILanguageSelectCellModel *cellModel in self.datas) {
        if ([cellModel.languageID isEqual:languageID]) {
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
    TUILanguageSelectCellModel *cellModel = self.datas[indexPath.row];
    TUILanguageSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.cellModel = cellModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TUILanguageSelectCellModel *cellModel = self.datas[indexPath.row];

    if([cellModel.languageID hasPrefix:@"ar"]) {
        [TUIGlobalization setRTLOption:YES];
    }
    else {
        [TUIGlobalization setRTLOption:NO];
    }
    /**
     * 
     * Changing language
     */
    [TUIGlobalization setPreferredLanguage:cellModel.languageID];
    [TUITool configIMErrorMap];
    /**
     *  UI 
     * Handling UI selection
     */
    self.selectModel.selected = NO;
    cellModel.selected = YES;
    self.selectModel = cellModel;
    [tableView reloadData];

    /**
     * 
     * Notify page dynamic refresh
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([weakSelf.delegate respondsToSelector:@selector(onSelectLanguage:)]) {
          [weakSelf.delegate onSelectLanguage:cellModel];
      }
    });
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_tableView registerClass:TUILanguageSelectCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

@end
