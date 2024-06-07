//
//  TUIGroupCreateController_Minimalist.m
//  TUIContact
//
//  Created by wyl on 2022/8/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupCreateController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIFloatViewController.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import "TUIContactUserPanelHeaderView_Minimalist.h"
#import "TUIGroupTypeListController_Minimalist.h"

@interface TUIGroupPortraitSelectAvatarCollectionCell_Minimalist : UICollectionViewCell

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIImageView *selectedView;
@property(nonatomic, strong) UIView *maskView;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) TUISelectAvatarCardItem *cardItem;

- (void)updateSelectedUI;

@end

@implementation TUIGroupPortraitSelectAvatarCollectionCell_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        [self.imageView setUserInteractionEnabled:YES];

        self.imageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;

        self.imageView.layer.borderWidth = 2;

        self.imageView.layer.masksToBounds = YES;

        [self.contentView addSubview:self.imageView];

        [self.imageView addSubview:self.selectedView];

        [self setupMaskView];
    }

    return self;
}

- (void)layoutSubviews {
    [self updateCellView];
    self.selectedView.frame = CGRectMake(self.imageView.frame.size.width - 16 - 4, 4, 16, 16);
}

- (void)updateCellView {
    [self updateSelectedUI];
    [self updateImageView];
    [self updateMaskView];
}

- (void)updateSelectedUI {
    if (self.cardItem.isSelect) {
        self.imageView.layer.borderColor = TIMCommonDynamicColor(@"", @"#006EFF").CGColor;
        self.selectedView.hidden = NO;
    } else {
        if (self.cardItem.isDefaultBackgroundItem) {
            self.imageView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.1].CGColor;
        } else {
            self.imageView.layer.borderColor = UIColor.clearColor.CGColor;
        }
        self.selectedView.hidden = YES;
    }
}

- (void)updateImageView {
    if (self.cardItem.isGroupGridAvatar) {
        [self updateNormalGroupGridAvatar];
    } else {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.cardItem.posterUrlStr]
                          placeholderImage:TIMCommonBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head_img")];
    }
}
- (void)updateMaskView {
    if (self.cardItem.isDefaultBackgroundItem) {
        self.maskView.hidden = NO;
        self.maskView.frame = CGRectMake(0, self.imageView.frame.size.height - 28, self.imageView.frame.size.width, 28);
        [self.descLabel sizeToFit];
        self.descLabel.tui_mm_center();
    } else {
        self.maskView.hidden = YES;
    }
}

- (void)updateNormalGroupGridAvatar {
    if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cardItem.cacheGroupGridAvatarImage) {
        [self.imageView sd_setImageWithURL:nil placeholderImage:self.cardItem.cacheGroupGridAvatarImage];
    }
}

- (void)setupMaskView {
    self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.maskView.backgroundColor = [UIColor tui_colorWithHex:@"cccccc"];
    [self.imageView addSubview:self.maskView];
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.text = TIMCommonLocalizableString(TUIKitDefaultBackground);
    self.descLabel.textColor = [UIColor whiteColor];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    [self.maskView addSubview:self.descLabel];
    [self.descLabel sizeToFit];
    self.descLabel.tui_mm_center();
}

- (void)setCardItem:(TUISelectAvatarCardItem *)cardItem {
    _cardItem = cardItem;
}

- (UIImageView *)selectedView {
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _selectedView.image = [UIImage imageNamed:TIMCommonImagePath(@"icon_avatar_selected")];
    }
    return _selectedView;
}

@end

static NSString *const reuseIdentifier = @"TUISelectAvatarCollectionCell";

@interface TUIGroupCreatePortrait_Minimalist : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, copy) void (^onClick)(TUISelectAvatarCardItem *data);
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *dataArr;
@property(nonatomic, strong) TUISelectAvatarCardItem *currentSelectCardItem;
@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, copy) NSString *profilFaceURL;
@property(nonatomic, strong) UIImage *cacheGroupGridAvatarImage;
- (void)loadData;

@end

@implementation TUIGroupCreatePortrait_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    [self initControl];

    return self;
}

- (void)initControl {
    UICollectionViewFlowLayout *flowLayout = [[TUICollectionRTLFitFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.sectionInset = UIEdgeInsetsMake(6, 0, 0, 15);
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    // Register cell classes
    [self.collectionView registerClass:[TUIGroupPortraitSelectAvatarCollectionCell_Minimalist class] forCellWithReuseIdentifier:reuseIdentifier];

    self.dataArr = [NSMutableArray arrayWithCapacity:3];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame =
        CGRectMake(kScale390(15), self.bounds.origin.y, self.bounds.size.width - kScale390(33) - kScale390(15), self.bounds.size.height);
}

#define GroupAvatarURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/group-avatar/group_avatar_%d.png", x]
#define GroupAvatarCount 24

- (void)loadData {
    if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cacheGroupGridAvatarImage) {
        TUISelectAvatarCardItem *cardItem = [self creatGroupGridAvatarCardItem];
        [self.dataArr addObject:cardItem];
    }
    for (int i = 0; i < GroupAvatarCount; i++) {
        TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:GroupAvatarURL(i + 1)];
        [self.dataArr addObject:cardItem];
    }
    [self.collectionView reloadData];
}

- (TUISelectAvatarCardItem *)creatCardItemByURL:(NSString *)urlStr {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = urlStr;
    cardItem.isSelect = NO;
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL]) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (TUISelectAvatarCardItem *)creatGroupGridAvatarCardItem {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = nil;
    cardItem.isSelect = NO;
    cardItem.isGroupGridAvatar = YES;
    cardItem.cacheGroupGridAvatarImage = self.cacheGroupGridAvatarImage;
    if (!self.profilFaceURL) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (void)setCurrentSelectCardItem:(TUISelectAvatarCardItem *)currentSelectCardItem {
    _currentSelectCardItem = currentSelectCardItem;
    if (_currentSelectCardItem) {
        [self.rightButton setTitleColor:TIMCommonDynamicColor(@"", @"#006EFF") forState:UIControlStateNormal];
    } else {
        [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}
- (void)rightBarButtonClick {
    if (!self.currentSelectCardItem) {
        return;
    }

    if (self.onClick) {
        self.onClick(self.currentSelectCardItem);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = kScale390(50);

    CGFloat height = kScale390(50);

    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kScale390(6), 0, kScale390(15), 0);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArr count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIGroupPortraitSelectAvatarCollectionCell_Minimalist *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                                            forIndexPath:indexPath];
    // Configure the cell

    if (indexPath.row < self.dataArr.count) {
        cell.cardItem = self.dataArr[indexPath.row];
    }

    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self recoverSelectedStatus];

    TUIGroupPortraitSelectAvatarCollectionCell_Minimalist *cell =
        (TUIGroupPortraitSelectAvatarCollectionCell_Minimalist *)[self.collectionView cellForItemAtIndexPath:indexPath];

    if (cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (TUIGroupPortraitSelectAvatarCollectionCell_Minimalist *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    if (self.currentSelectCardItem == cell.cardItem) {
        self.currentSelectCardItem = nil;
    } else {
        cell.cardItem.isSelect = YES;
        [cell updateSelectedUI];
        self.currentSelectCardItem = cell.cardItem;
    }
    if (self.onClick) {
        self.onClick(self.currentSelectCardItem);
    }
}

- (void)recoverSelectedStatus {
    NSInteger index = 0;
    for (TUISelectAvatarCardItem *card in self.dataArr) {
        if (self.currentSelectCardItem == card) {
            card.isSelect = NO;
            break;
        }
        index++;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    TUIGroupPortraitSelectAvatarCollectionCell_Minimalist *cell =
        (TUIGroupPortraitSelectAvatarCollectionCell_Minimalist *)[self.collectionView cellForItemAtIndexPath:indexPath];

    if (cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (TUIGroupPortraitSelectAvatarCollectionCell_Minimalist *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    [cell updateSelectedUI];
}
@end

@interface TUIGroupCreateController_Minimalist () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UITextField *groupNameTextField;
@property(nonatomic, strong) UITextField *groupIDTextField;
@property(nonatomic, assign) BOOL keyboardShown;
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UITextView *describeTextView;
@property(nonatomic, assign) CGRect describeTextViewRect;
@property(nonatomic, strong) TUIGroupCreatePortrait_Minimalist *createPortraitView;
@property(nonatomic, strong) TUIContactUserPanelHeaderView_Minimalist *userPanelHeaderView;
@property(nonatomic, strong) UIImage *submitShowImage;
@property(nonatomic, strong) UIImage *cacheGroupGridAvatarImage;

@end

@implementation TUIGroupCreateController_Minimalist

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.mm_width(self.view.mm_w).mm_flexToBottom(0);
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    NSMutableParagraphStyle *paragraphPlaceholderStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphPlaceholderStyle.firstLineHeadIndent = 0;
    paragraphPlaceholderStyle.headIndent = 0;
    paragraphPlaceholderStyle.alignment = isRTL()?NSTextAlignmentLeft:NSTextAlignmentRight;
    NSDictionary *attributesPlaceholder =
        @{NSFontAttributeName : [UIFont systemFontOfSize:kScale390(16)], NSParagraphStyleAttributeName : paragraphPlaceholderStyle};

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.firstLineHeadIndent = 0;
    paragraphStyle.alignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;

    NSDictionary *attributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:kScale390(16)], NSParagraphStyleAttributeName : paragraphStyle};

    self.groupNameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.groupNameTextField.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    self.groupNameTextField.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.groupNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TIMCommonLocalizableString(TUIKitCreatGroupNamed_Placeholder)
                                                                                    attributes:attributesPlaceholder];
    self.groupNameTextField.delegate = self;

    if (IS_NOT_EMPTY_NSSTRING(self.createGroupInfo.groupName)) {
        self.groupNameTextField.attributedText = [[NSAttributedString alloc] initWithString:self.createGroupInfo.groupName attributes:attributes];
    }
    self.groupIDTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.groupIDTextField.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    self.groupIDTextField.keyboardType = UIKeyboardTypeDefault;
    self.groupIDTextField.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.groupIDTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TIMCommonLocalizableString(TUIKitCreatGroupID_Placeholder)
                                                                                  attributes:attributesPlaceholder];
    self.groupIDTextField.delegate = self;

    [self updateRectAndTextForDescribeTextView:self.describeTextView];

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(ChatsNewGroupText)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    [self creatGroupAvatarImage];
}

- (UITextView *)describeTextView {
    if (!_describeTextView) {
        _describeTextView = [[UITextView alloc] init];
        _describeTextView.backgroundColor = [UIColor clearColor];
        _describeTextView.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        _describeTextView.editable = NO;
        _describeTextView.scrollEnabled = NO;
        _describeTextView.textContainerInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    }
    return _describeTextView;
}
- (TUIGroupCreatePortrait_Minimalist *)createPortraitView {
    if (!_createPortraitView) {
        _createPortraitView = [[TUIGroupCreatePortrait_Minimalist alloc] initWithFrame:CGRectZero];
        UIImageView *headImage = [[UIImageView alloc] initWithImage:DefaultGroupAvatarImageByGroupType(self.createGroupInfo.groupType)];

        if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cacheGroupGridAvatarImage) {
            _createPortraitView.cacheGroupGridAvatarImage = self.cacheGroupGridAvatarImage;
            [headImage sd_setImageWithURL:[NSURL URLWithString:self.createGroupInfo.faceURL] placeholderImage:self.cacheGroupGridAvatarImage];
        }
        self.submitShowImage = headImage.image;
        [_createPortraitView loadData];
    }
    return _createPortraitView;
}
- (void)creatGroupAvatarImage {
    if (!TUIConfig.defaultConfig.enableGroupGridAvatar) {
        return;
    }
    if (_cacheGroupGridAvatarImage) {
        return;
    }
    NSMutableArray *muArray = [NSMutableArray array];
    for (TUICommonContactSelectCellData *cellData in self.createContactArray) {
        if (cellData.avatarUrl.absoluteString.length > 0) {
            [muArray addObject:cellData.avatarUrl.absoluteString];
        } else {
            [muArray addObject:@"about:blank"];
        }
    }
    // currentUser
    [muArray addObject:[TUILogin getFaceUrl] ?: @""];

    @weakify(self);
    [TUIGroupAvatar createGroupAvatar:muArray
                             finished:^(UIImage *groupAvatar) {
                               @strongify(self);
                               self.cacheGroupGridAvatarImage = groupAvatar;
                               [self.tableView reloadData];
                             }];
}

- (void)updateRectAndTextForDescribeTextView:(UITextView *)describeTextView {
    __block NSString *descStr = @"";
    [self.class getfomatDescribeType:self.createGroupInfo.groupType
                          completion:^(NSString *groupTypeStr, NSString *groupTypeDescribeStr) {
                            descStr = groupTypeDescribeStr;
                          }];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 18;
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft];
    NSDictionary *dictionary = @{
        NSFontAttributeName : [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName : [UIColor tui_colorWithHex:@"#888888"],
        NSParagraphStyleAttributeName : paragraphStyle
    };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:descStr attributes:dictionary];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [descStr length])];
    NSString *inviteTipstring = TIMCommonLocalizableString(TUIKitCreatGroupType_Desc_Highlight);
    [attributedString addAttribute:NSLinkAttributeName value:@"https://cloud.tencent.com/product/im" range:[descStr rangeOfString:inviteTipstring]];
    self.describeTextView.attributedText = attributedString;

    CGRect rect =
        [self.describeTextView.text boundingRectWithSize:CGSizeMake(self.view.mm_w - 32, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSParagraphStyleAttributeName : paragraphStyle}
                                                 context:nil];
    self.describeTextViewRect = rect;
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 2) {
        return kScale390(144);
    } else if (indexPath.section == 3) {
        return kScale390(60);
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{ return 4; }

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];

    if (section == 1) {
        [view addSubview:self.describeTextView];
        _describeTextView.mm_width(_describeTextViewRect.size.width).mm_height(_describeTextViewRect.size.height).mm_top(kScale390(12)).mm_left(kScale390(13));
    }
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 1 ? _describeTextViewRect.size.height + 20 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];

    UILabel *sectionTitleLabel = [[UILabel alloc] init];

    if (section == 2 || section == 3) {
        [view addSubview:sectionTitleLabel];
        sectionTitleLabel.font = [UIFont boldSystemFontOfSize:kScale390(16)];
        sectionTitleLabel.rtlAlignment = TUITextRTLAlignmentLeading;
        if (section == 2) {
            sectionTitleLabel.text = TIMCommonLocalizableString(TUIKitCreatGroupAvatar);
        } else if (section == 3) {
            sectionTitleLabel.text = TIMCommonLocalizableString(TUIKitCreateMemebers);
        }

        [sectionTitleLabel sizeToFit];
        [sectionTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(kScale390(16));
            make.top.mas_equalTo(kScale390(12));
            make.size.mas_equalTo(sectionTitleLabel.frame.size);
        }];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2 || section == 3) {
        return kScale390(44);
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupName"];
            [cell.contentView addSubview:self.groupNameTextField];
            cell.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
            [self.groupNameTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(cell.contentView.mas_trailing);
                make.leading.mas_equalTo(cell.contentView.mas_leading).mas_offset(10);
                make.height.mas_equalTo(cell.contentView);
                make.centerY.mas_equalTo(cell.contentView);
            }];
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupID"];
            cell.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
            [cell.contentView addSubview:self.groupIDTextField];
            [self.groupIDTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(cell.contentView.mas_trailing);
                make.leading.mas_equalTo(cell.contentView.mas_leading).mas_offset(10);
                make.height.mas_equalTo(cell.contentView);
                make.width.mas_equalTo(cell.contentView);
                make.centerY.mas_equalTo(cell.contentView);
            }];
            return cell;
        }
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupType"];
        cell.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *leftTextLabel = [[UILabel alloc] init];
        [cell.contentView addSubview:leftTextLabel];
        leftTextLabel.mm_width(cell.contentView.mm_w).mm_height(cell.contentView.mm_h).mm_left(kScale390(16));
        leftTextLabel.text = TIMCommonLocalizableString(TUIKitCreatGroupType);
        leftTextLabel.textColor = [UIColor grayColor];
        leftTextLabel.font = [UIFont systemFontOfSize:kScale390(16)];
        cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.class getfomatDescribeType:self.createGroupInfo.groupType
                              completion:^(NSString *groupTypeStr, NSString *groupTypeDescribeStr) {
                                cell.detailTextLabel.text = groupTypeStr;
                              }];

        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupChoose"];
        [cell.contentView addSubview:self.createPortraitView];
        [self.createPortraitView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(cell.contentView);
            make.height.mas_equalTo(kScale390(144));
            make.width.mas_equalTo(cell.contentView);
            make.centerY.mas_equalTo(cell.contentView);
        }];
        @weakify(self);
        self.createPortraitView.onClick = ^(TUISelectAvatarCardItem *data) {
          @strongify(self);
          if (data.posterUrlStr.length > 0) {
              @strongify(self);
              self.createGroupInfo.faceURL = data.posterUrlStr;
          } else {
              self.createGroupInfo.faceURL = nil;
          }
        };
        return cell;
    } else if (indexPath.section == 3) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserPanel"];
        self.userPanelHeaderView = [[TUIContactUserPanelHeaderView_Minimalist alloc] init];
        [cell.contentView addSubview:self.userPanelHeaderView];
        [self.userPanelHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(cell.contentView);
            make.height.mas_equalTo(kScale390(57));
            make.width.mas_equalTo(cell.contentView);
            make.centerY.mas_equalTo(cell.contentView);
        }];
        self.userPanelHeaderView.selectedUsers = [NSMutableArray arrayWithArray:self.createContactArray];
        @weakify(self);
        self.userPanelHeaderView.clickCallback = ^{
          @strongify(self);
          self.createContactArray = self.userPanelHeaderView.selectedUsers;
          [self.userPanelHeaderView.userPanel reloadData];
          [self.tableView reloadData];
        };
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.section == 1) {
        TUIGroupTypeListController_Minimalist *vc = [[TUIGroupTypeListController_Minimalist alloc] init];
        vc.cacheGroupType = self.createGroupInfo.groupType;
        vc.title = @"";
        TUIFloatViewController *floatVC = [[TUIFloatViewController alloc] init];
        [floatVC appendChildViewController:(id)vc topMargin:kScale390(87.5)];
        [floatVC.topGestureView setTitleText:TIMCommonLocalizableString(TUIKitGroupProfileType)
                                subTitleText:@""
                                 leftBtnText:TIMCommonLocalizableString(TUIKitCreateCancel)
                                rightBtnText:@""];
        floatVC.topGestureView.rightButton.hidden = YES;
        floatVC.topGestureView.subTitleLabel.hidden = YES;
        [self presentViewController:floatVC animated:YES completion:nil];

        @weakify(self);
        __weak typeof(floatVC) weakFloatVC = floatVC;
        vc.selectCallBack = ^(NSString *_Nonnull groupType) {
          @strongify(self);
          self.createGroupInfo.groupType = groupType;
          [self updateRectAndTextForDescribeTextView:self.describeTextView];
          [self.tableView reloadData];

          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakFloatVC floatDismissViewControllerAnimated:YES
                                                 completion:^{
                                                 }];
          });
        };

    } else if (indexPath.section == 2) {
        [self didTapToChooseAvatar];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - textField
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.groupNameTextField) {
        if (textField.text.length > 10) {
            textField.text = [textField.text substringToIndex:10];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Check for total length
    if (textField == self.groupIDTextField) {
        NSUInteger lengthOfString = string.length;
        // Check for total length
        NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
        if (proposedNewLength > 16) {
            return NO;
        }
        return YES;
    }
    return YES;
}

#pragma mark - format
+ (void)getfomatDescribeType:(NSString *)groupType completion:(void (^)(NSString *groupTypeStr, NSString *groupTypeDescribeStr))completion {
    if (!completion) {
        return;
    }
    NSString *desc = @"";
    if ([groupType isEqualToString:@"Work"]) {
        desc = [NSString
            stringWithFormat:@"%@\n%@", TIMCommonLocalizableString(TUIKitCreatGroupType_Work_Desc), TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Work), desc);
    } else if ([groupType isEqualToString:@"Public"]) {
        desc = [NSString
            stringWithFormat:@"%@\n%@", TIMCommonLocalizableString(TUIKitCreatGroupType_Public_Desc), TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Public), desc);
    } else if ([groupType isEqualToString:@"Meeting"]) {
        desc = [NSString stringWithFormat:@"%@\n%@", TIMCommonLocalizableString(TUIKitCreatGroupType_Meeting_Desc),
                                          TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Meeting), desc);
    } else if ([groupType isEqualToString:@"Community"]) {
        desc = [NSString stringWithFormat:@"%@\n%@", TIMCommonLocalizableString(TUIKitCreatGroupType_Community_Desc),
                                          TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Community), desc);
    } else {
        completion(groupType, groupType);
    }
}

#pragma mark - action

- (void)didTapToChooseAvatar {
    TUISelectAvatarController *vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeGroupAvatar;
    vc.createGroupType = self.createGroupInfo.groupType;
    vc.cacheGroupGridAvatarImage = self.cacheGroupGridAvatarImage;
    vc.profilFaceURL = self.createGroupInfo.faceURL;
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self);
    vc.selectCallBack = ^(NSString *_Nonnull urlStr) {
      if (urlStr.length > 0) {
          @strongify(self);
          self.createGroupInfo.faceURL = urlStr;
      } else {
          self.createGroupInfo.faceURL = nil;
      }
      [self.tableView reloadData];
    };
}
- (void)finishTask {
    self.createGroupInfo.groupName = self.groupNameTextField.text;
    self.createGroupInfo.groupID = self.groupIDTextField.text;

    V2TIMGroupInfo *info = self.createGroupInfo;
    if (!info) {
        return;
    }
    if (!self.createContactArray) {
        return;
    }

    BOOL isCommunity = [info.groupType isEqualToString:@"Community"];
    BOOL hasTGSPrefix = [info.groupID hasPrefix:@"@TGS#_"];
    
    
    if (self.groupIDTextField.text.length > 0 ) {
        if (isCommunity && !hasTGSPrefix) {
            NSString *toastMsg = TIMCommonLocalizableString(TUICommunityCreateTipsMessageRuleError);
            [TUITool makeToast:toastMsg duration:3.0 idposition:TUICSToastPositionBottom];
            return;
        }
        
        if (!isCommunity && hasTGSPrefix) {
            NSString *toastMsg = TIMCommonLocalizableString(TUIGroupCreateTipsMessageRuleError);
            [TUITool makeToast:toastMsg duration:3.0 idposition:TUICSToastPositionBottom];
            return;
        }
    }
    

    NSMutableArray *members = [NSMutableArray array];
    for (TUICommonContactSelectCellData *item in self.createContactArray) {
        V2TIMCreateGroupMemberInfo *member = [[V2TIMCreateGroupMemberInfo alloc] init];
        member.userID = item.identifier;
        member.role = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
        [members addObject:member];
    }

    NSString *showName = [TUILogin getNickName] ?: [TUILogin getUserID];

    @weakify(self);
    [[V2TIMManager sharedInstance] createGroup:info
        memberList:members
        succ:^(NSString *groupID) {
          @strongify(self);
          NSString *content = TIMCommonLocalizableString(TUIGroupCreateTipsMessage);
          if ([info.groupType isEqualToString:GroupType_Community]) {
              content = TIMCommonLocalizableString(TUICommunityCreateTipsMessage);
          }
          NSDictionary *dic = @{
              @"version" : @(GroupCreate_Version),
              BussinessID : BussinessID_GroupCreate,
              @"opUser" : showName,
              @"content" : content,
              @"cmd" : [info.groupType isEqualToString:GroupType_Community] ? @1 : @0
          };
          NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
          V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
          [[V2TIMManager sharedInstance] sendMessage:msg
                                            receiver:nil
                                             groupID:groupID
                                            priority:V2TIM_PRIORITY_DEFAULT
                                      onlineUserOnly:NO
                                     offlinePushInfo:nil
                                            progress:nil
                                                succ:nil
                                                fail:nil];
          self.createGroupInfo.groupID = groupID;
          // wait for a second to ensure the group created message arrives first
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.submitCallback) {
                self.submitCallback(YES, self.createGroupInfo, self.submitShowImage);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
          });
        }
        fail:^(int code, NSString *msg) {
          @strongify(self);
          if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
              [TUITool postUnsupportNotificationOfService:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunity)
                                              serviceDesc:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunityDesc)
                                                debugOnly:YES];
          } else {
              NSString *toastMsg = nil;
              toastMsg = [TUITool convertIMError:code msg:msg];
              if (toastMsg.length == 0) {
                  toastMsg = [NSString stringWithFormat:@"%ld", (long)code];
              }
              [TUITool hideToastActivity];
              [TUITool makeToast:toastMsg duration:3.0 idposition:TUICSToastPositionBottom];
          }
          if (self.submitCallback) {
              self.submitCallback(NO, self.createGroupInfo, self.submitShowImage);
              [self dismissViewControllerAnimated:YES completion:nil];
          }
        }];
}
#pragma mark - TUIChatFloatSubViewControllerProtocol
- (void)floatControllerLeftButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)floatControllerRightButtonClick {
    [self finishTask];
}

@end
