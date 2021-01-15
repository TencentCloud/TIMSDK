//
//  TUILiveJoinAnchorListView.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/23.
//

#import "TUILiveJoinAnchorListView.h"
#import "TRTCLiveRoomDef.h"
#import "Masonry.h"
#import "SDWebImage.h"

typedef void(^JoinCellAction)(BOOL agree);

@interface TUILiveJoinAnchorCell ()

@property(nonatomic, strong) UIImageView *coverImage;
@property(nonatomic, strong) UILabel *infoLabel;

@property(nonatomic, strong) UIButton *acceptBtn;
@property(nonatomic, strong) UIButton *rejectBtn;

@property(nonatomic, copy, nullable) JoinCellAction action;

@end

@implementation TUILiveJoinAnchorCell {
    BOOL _isViewReady;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self constructSubViews];
        [self bindInteraction];
        self.backgroundColor = UIColor.whiteColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    _isViewReady = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.action = nil;
}

- (void)constructSubViews {
    self.coverImage = [[UIImageView alloc] init];
    self.coverImage.layer.cornerRadius = 20;
    self.coverImage.layer.masksToBounds = YES;
    
    self.acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
    self.acceptBtn.backgroundColor =  [UIColor colorWithRed:255/255.0 green:83/255.0 blue:83/255.0 alpha:1/1.0];
    [self.acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.acceptBtn.layer.cornerRadius = 13.0;
    
    self.rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    self.rejectBtn.backgroundColor = [UIColor whiteColor];
    [self.rejectBtn.layer setBorderWidth:1];
    [self.rejectBtn.layer setBorderColor:[UIColor colorWithRed:255/255.0 green:83/255.0 blue:83/255.0 alpha:1/1.0].CGColor];
    [self.rejectBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:83/255.0 blue:83/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    self.rejectBtn.layer.cornerRadius = 13.0;
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textColor = UIColor.blackColor;
    self.infoLabel.font = [UIFont systemFontOfSize:15.0];
    self.infoLabel.numberOfLines = 2;
}

- (void)constructViewHierarchy {
    [self.contentView addSubview:self.coverImage];
    [self.contentView addSubview:self.acceptBtn];
    [self.contentView addSubview:self.rejectBtn];
    [self.contentView addSubview:self.infoLabel];
}

- (void)bindInteraction {
    [self.acceptBtn addTarget:self action:@selector(responseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rejectBtn addTarget:self action:@selector(responseAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutUI {
    [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(40);
    }];
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-16);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(31);
    }];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self.rejectBtn.mas_leading).offset(-12);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(31);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.coverImage.mas_trailing).offset(5);
        make.centerY.equalTo(self);
        make.trailing.equalTo(self.acceptBtn.mas_leading);
        make.height.mas_equalTo(40);
    }];
}

- (void)configWithModel:(TRTCLiveUserInfo *)model action:(JoinCellAction)action {
    self.action = action;
    if ([model.avatarURL isEqualToString:@""]) {
        NSURL *tempUrl = [NSURL URLWithString:@"https://imgcache.qq.com/qcloud/public/static//avatar0_100.20191230.png"];
        [self.coverImage sd_setImageWithURL:tempUrl];
    } else {
        [self.coverImage sd_setImageWithURL:[NSURL URLWithString:model.avatarURL]];
    }
    NSString *nameLabelText = ([model.userName isEqualToString:@""] || !model.userName) ? model.userId : model.userName;
    self.infoLabel.text = [NSString stringWithFormat:@"%@", nameLabelText];
}

- (void)responseAction:(UIButton *)sender {
    if (!self.action) {
        return;
    }
    if (sender == self.acceptBtn) {
        self.action(YES);
    } else {
        self.action(NO);
    }
}

@end

@interface TUILiveJoinAnchorListView ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)NSArray<TRTCLiveUserInfo *> *userInfos;
@property(nonatomic, strong)UITableView *anchorTableView;

@end

@implementation TUILiveJoinAnchorListView{
    BOOL _isViewReady;
}

- (UITableView *)anchorTableView {
    if (!_anchorTableView) {
        _anchorTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_anchorTableView registerClass:[TUILiveJoinAnchorCell class] forCellReuseIdentifier:@"TUILiveJoinAnchorCell"];
        _anchorTableView.delegate = self;
        _anchorTableView.dataSource = self;
        _anchorTableView.separatorColor = UIColor.clearColor;
        _anchorTableView.allowsSelection = YES;
        _anchorTableView.backgroundColor = UIColor.whiteColor;
    }
    return _anchorTableView;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    self->_isViewReady = YES;
}

- (void)constructViewHierarchy {
    [self addSubview:self.anchorTableView];
}

- (void)layoutUI {
    [self.anchorTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.width.equalTo(self);
        make.height.equalTo(self);
    }];
}

- (void)showWithUserInfos:(NSArray<TRTCLiveUserInfo *> *)infos {
    [self refreshUserInfos:infos];
    self.hidden = NO;
}

- (void)refreshUserInfos:(NSArray<TRTCLiveUserInfo *> *)infos {
    self.userInfos = infos;
    [self.anchorTableView reloadData];
}

- (void)hide {
    self.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = UIColor.clearColor;
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
        footer.textLabel.textColor = UIColor.whiteColor;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.userInfos.count > 0) {
        return @" ";
    }
    return @"暂无连麦申请";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUILiveJoinAnchorCell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[TUILiveJoinAnchorCell class]]) {
        TUILiveJoinAnchorCell *pkCell = (TUILiveJoinAnchorCell *)cell;
        if (indexPath.row < self.userInfos.count) {
            TRTCLiveUserInfo *info = self.userInfos[indexPath.row];
            @weakify(self);
            [pkCell configWithModel:info action:^(BOOL agree) {
                @strongify(self);
                if (self.delegate && [self.delegate respondsToSelector:@selector(joinAnchorListView:didRespondJoinAnchor:agree:)]) {
                    [self.delegate joinAnchorListView:self didRespondJoinAnchor:info agree:agree];
                }
                [self hide];
            }];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 63;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.frame = CGRectMake(0, 40, tableView.bounds.size.width, 50);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"申请上麦列表";
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.userInteractionEnabled = YES;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(self.bounds.size.width * 4.0 / 5.0, 0, self.bounds.size.width / 5.0, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = UIColor.clearColor;
    [cancelBtn addTarget:self action:@selector(hidePanel:) forControlEvents:UIControlEventTouchUpInside];
    [headerLabel addSubview:cancelBtn];
    
    return headerLabel;
}

- (void)hidePanel:(UIButton *)sender {
    [self hide];
    if (self.delegate && [self.delegate respondsToSelector:@selector(joinAnchorListViewDidHidden)]) {
        [self.delegate joinAnchorListViewDidHidden];
    }
}



@end
