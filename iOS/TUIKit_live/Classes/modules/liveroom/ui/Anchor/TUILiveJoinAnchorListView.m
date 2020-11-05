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
        self.backgroundColor = UIColor.clearColor;
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
    self.acceptBtn.backgroundColor = [UIColor colorWithRed:0.0 green:98.0 / 255 blue:227 / 255.0 alpha:1.0];
    self.acceptBtn.layer.cornerRadius = 4.0;
    
    self.rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    self.rejectBtn.backgroundColor = [UIColor colorWithRed:255.0 green:78.0 / 255 blue:66.0 / 255.0 alpha:1.0];
    self.rejectBtn.layer.cornerRadius = 4.0;
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textColor = UIColor.whiteColor;
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
        make.top.leading.equalTo(self).offset(10);
        make.left.equalTo(self).offset(20);
        make.bottom.equalTo(self).offset(-10);
        make.width.mas_equalTo(40);
    }];
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-15);
        make.right.equalTo(self).offset(-20);
        make.width.mas_equalTo(75);
    }];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-15);
        make.right.equalTo(self.rejectBtn.mas_left).offset(-20);
        make.width.mas_equalTo(75);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.coverImage.mas_trailing).offset(5);
        make.top.equalTo(self).offset(5);
        make.bottom.trailing.equalTo(self).offset(-5);
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
        _anchorTableView.backgroundColor = UIColor.clearColor;
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
    return 60;;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.frame = CGRectMake(0, 40, tableView.bounds.size.width, 50);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"申请上麦列表";
    headerLabel.textColor = UIColor.whiteColor;
    headerLabel.backgroundColor = [UIColor colorWithRed:19.0 / 255.0 green:35.0 / 255.0 blue:63.0 / 255.0 alpha:1.0];
    headerLabel.userInteractionEnabled = YES;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(self.bounds.size.width * 4.0 / 5.0, 0, self.bounds.size.width / 5.0, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
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
