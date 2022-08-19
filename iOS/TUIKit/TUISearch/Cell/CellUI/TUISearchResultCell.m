//
//  TUISearchResultCell.m
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import "TUIDefine.h"
#import "TUISearchResultCell.h"
#import "TUISearchResultCellModel.h"
#import "TUICommonModel.h"
#import "TUIThemeManager.h"
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
    self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");

    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    
    _title_label = [[UILabel alloc] init];
    _title_label.text = @"";
    _title_label.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
    _title_label.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_title_label];
    
    _detail_title = [[UILabel alloc] init];
    _detail_title.text = @"";
    _detail_title.textColor =  TUICoreDynamicColor(@"form_subtitle_color", @"#888888");
    _detail_title.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_detail_title];
    
    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = TUICoreDynamicColor(@"separator_color", @"#DBDBDB");
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
    
    /**
     * 修改默认头像
     * Setup default avatar
     */
    if (cellModel.groupID.length > 0) {
        /**
         * 群组, 则将群组默认头像修改成上次使用的头像
         * If it is a group, change the group default avatar to the last used avatar
         */
        UIImage *avatar = nil;
        if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", cellModel.groupID];
            NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
            avatar = [TUIGroupAvatar getCacheAvatarForGroup:cellModel.groupID number:(UInt32)member];
        }
        cellModel.avatarImage = avatar ? avatar : DefaultGroupAvatarImageByGroupType(cellModel.groupType);
    }

    @weakify(self)
    [[RACObserve(cellModel,avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
        @strongify(self)
        if (cellModel.groupID.length > 0) {
            /**
             * 群组头像
             * Group avatar
             */
            if (IS_NOT_EMPTY_NSSTRING(faceUrl)) {
                /**
                 * 外部有手动设置群头像
                 * The group avatar has been manually set externally
                 */
                [self.avatarView sd_setImageWithURL:[NSURL URLWithString:faceUrl]
                                      placeholderImage:self.cellModel.avatarImage];
            } else {
                /**
                 * 外部未设置群头像，如果允许合成头像，则采用合成头像；反之则使用默认头像
                 * The group avatar has not been set externally. If the synthetic avatar is allowed, the synthetic avatar will be used; otherwise, the default avatar will be used.
                 */
                if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
                    /**
                     * 允许合成头像，则采用合成头像
                     * 1. 异步根据群成员个数来获取缓存的合成头像
                     * 2. 如果有缓存，则直接使用缓存的合成头像
                     * 3. 如果没有缓存，则重新合成新头像
                     *
                     * 注意：
                     * 1. 由于「异步获取缓存」和「合成头像」耗时较长，容易引起 cell 的复用问题，故需要根据 groupID 来确认是否直接赋值。
                     * 2. 使用 SDWebImage 来实现占位，因为 SDWebImage 内部已经处理了 cell 的复用问题
                     *
                     * If the synthetic avatar is allowed, the synthetic avatar will be used
                     * 1. Asynchronously obtain the cached synthetic avatar according to the number of group members
                     * 2. If the cache is hit, use the cached synthetic avatar directly
                     * 3. If the cache is not hit, recompose a new avatar
                     *
                     * Note:
                     * 1. Since "asynchronously obtaining cached avatars" and "synthesizing avatars" take a long time, it is easy to cause cell reuse problems, so it is necessary to confirm whether to assign values directly according to groupID.
                     * 2. Use SDWebImage to implement placeholder, because SDWebImage has already dealt with the problem of cell reuse
                     */
                    
                    
                    // 1. 获取缓存
                    // 1. Obtain group avatar from cache
                    
                    // fix: 由于 getCacheGroupAvatar 需要请求网络，断网时，由于并没有设置 headImageView，此时当前会话发消息，会话会上移，复用了第一条会话的头像，导致头像错乱
                    // fix: Th getCacheGroupAvatar needs to request the network. When the network is disconnected, since the headImageView is not set, the current conversation sends a message, the conversation is moved up, and the avatar of the first conversation is reused, resulting in confusion of the avatar.
                    [self.avatarView sd_setImageWithURL:nil
                                          placeholderImage:cellModel.avatarImage];
                    [TUIGroupAvatar getCacheGroupAvatar:cellModel.groupID callback:^(UIImage *avatar, NSString *groupID) {
                        @strongify(self)
                        if ([groupID isEqualToString:self.cellModel.groupID]) {
                            // 1.1 callback 回调时，cell 未被复用
                            // 1.1 When the callback is invoked, the cell is not reused
                            
                            if (avatar != nil) {
                                // 2. 有缓存，直接赋值
                                // 2. Hit the cache and assign directly
                                [self.avatarView sd_setImageWithURL:nil
                                                      placeholderImage:avatar];
                            } else {
                                // 3. 没有缓存，异步合成新头像
                                // 3. Synthesize new avatars asynchronously without hitting cache
                                
                                [self.avatarView sd_setImageWithURL:nil
                                                      placeholderImage:cellModel.avatarImage];
                                [TUIGroupAvatar fetchGroupAvatars:cellModel.groupID placeholder:cellModel.avatarImage callback:^(BOOL success, UIImage *image, NSString *groupID) {
                                    @strongify(self)
                                    if ([groupID isEqualToString:self.cellModel.groupID]) {
                                        // callback 回调时，cell 未被复用
                                        // When the callback is invoked, the cell is not reused
                                        [self.avatarView sd_setImageWithURL:nil placeholderImage:success?image:DefaultGroupAvatarImageByGroupType(self.cellModel.groupType)];
                                    } else {
                                        // callback 回调时，cell 已经被复用至其他的 groupID。由于新的 groupID 合成头像时会触发新的 callback，此处忽略
                                        // When the callback is invoked, the cell has been reused to other groupIDs. Since a new callback will be triggered when the new groupID synthesizes new avatar, it is ignored here
                                    }
                                }];
                            }
                        } else {
                            // 1.2 callback 回调时，cell 已经被复用至其他的 groupID。由于新的 groupID 获取缓存时会触发新的 callback，此处忽略
                            // 1.2 When the callback is invoked, the cell has been reused to other groupIDs. Since a new callback will be triggered when the new groupID gets the cache, it is ignored here
                        }
                    }];
                } else {
                    /**
                     * 不允许使用合成头像，直接使用默认头像
                     * Synthetic avatars are not allowed, use the default avatar directly
                     */
                    [self.avatarView sd_setImageWithURL:nil
                                          placeholderImage:cellModel.avatarImage];
                }
            }
        } else {
            /**
             * 个人头像
             * Personal avatar
             */
            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:faceUrl]
                                  placeholderImage:self.cellModel.avatarImage];
        }
    }];
}

@end

@interface IUSearchView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUSearchView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
