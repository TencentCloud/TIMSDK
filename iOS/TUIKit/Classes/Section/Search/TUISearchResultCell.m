//
//  TUISearchResultCell.m
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import "THeader.h"
#import <MMLayout/UIView+MMLayout.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUISearchResultCell.h"
#import "TUISearchResultCellModel.h"
#import "CreatGroupAvatar.h"
#import "UIColor+TUIDarkMode.h"

@interface TUISearchResultCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *title_label;
@property (nonatomic, strong) UILabel *detail_title;
@property (nonatomic, strong) UIView *separtorView;
@property (nonatomic, strong) TUISearchResultCellModel *cellModel;

@end

@implementation TUISearchResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    
    _title_label = [[UILabel alloc] init];
    _title_label.text = @"";
    _title_label.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]]; // [UIColor blackColor];
    _title_label.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_title_label];
    
    _detail_title = [[UILabel alloc] init];
    _detail_title.text = @"";
    _detail_title.textColor = [UIColor darkGrayColor];
    _detail_title.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_detail_title];
    
    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.contentView addSubview:_separtorView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarView.mm_x = 10;
    self.avatarView.mm_w = 40;
    self.avatarView.mm_h = 40;
    self.avatarView.mm_centerY = self.contentView.mm_centerY;
    
    self.title_label.mm_x = self.avatarView.mm_maxX + 10;
    self.detail_title.mm_x = self.avatarView.mm_maxX + 10;
    
    [self.title_label sizeToFit];
    [self.detail_title sizeToFit];
    
    self.separtorView.frame = CGRectMake(self.avatarView.mm_maxX, self.contentView.mm_h - 1, self.contentView.mm_w, 1);
    
    NSString *title = self.title_label.text;
    if (title.length == 0) {
        title = self.title_label.attributedText.string;
    }
    NSString *detail = self.detail_title.text;
    if (detail.length == 0) {
        detail = self.detail_title.attributedText.string;
    }
    if (title.length && self.detail_title.text.length) {
        self.title_label.mm_y = self.avatarView.mm_y;
        self.detail_title.mm_b = self.avatarView.mm_b;
    }else {
        self.title_label.mm_centerY = self.avatarView.mm_centerY;
        self.detail_title.mm_centerY = self.avatarView.mm_centerY;
    }
}

- (void)fillWithData:(TUISearchResultCellModel *)cellModel
{
    self.cellModel = cellModel;
    
    self.title_label.text = nil;
    self.title_label.attributedText = nil;
    self.detail_title.text = nil;
    self.detail_title.attributedText = nil;
    
    self.title_label.text = cellModel.title;
    if (cellModel.titleAttributeString) {
        self.title_label.attributedText = cellModel.titleAttributeString;
    }
    self.detail_title.text = cellModel.details;
    if (cellModel.detailsAttributeString) {
        self.detail_title.attributedText = cellModel.detailsAttributeString;
    }
    
    
    if (cellModel.groupID.length > 0) {
        // 群组, 则将群组默认头像修改成上次使用的头像
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", cellModel.groupID];
        NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
        UIImage *avatar = [CreatGroupAvatar getCacheAvatarForGroup:cellModel.groupID number:(UInt32)member];
        if (avatar) {
            cellModel.avatarImage = avatar;
        }
    }

    @weakify(self)
    [[RACObserve(cellModel,avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *x) {
        @strongify(self)
        if (cellModel.groupID.length > 0) { //群组
            // fix: 由于getCacheGroupAvatar需要请求网络，断网时，由于并没有设置headImageView，此时当前会话发消息，会话会上移，复用了第一条会话的头像，导致头像错乱
            self.avatarView.image = cellModel.avatarImage;
            [CreatGroupAvatar getCacheGroupAvatar:cellModel.groupID callback:^(UIImage *avatar) {
                @strongify(self)
                if (avatar != nil) { //已缓存群组头像
                    self.avatarView.image = avatar;
                } else { //未缓存群组头像
                    // 先设置占位
                    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:x]
                                          placeholderImage:cellModel.avatarImage];
                    
                    // 异步实时获取头像
                    [CreatGroupAvatar fetchGroupAvatars:cellModel.groupID placeholder:cellModel.avatarImage callback:^(BOOL success, UIImage *image, NSString *groupID) {
                        @strongify(self)
                        if ([groupID isEqualToString:self.cellModel.groupID]) {
                            // 需要判断下，防止复用问题
                            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:x] placeholderImage:image];
                        }
                    }];
                }
            }];
        } else {//个人头像
            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:x]
                                  placeholderImage:cellModel.avatarImage];
        }
    }];
}


@end
