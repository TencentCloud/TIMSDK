#import "TUIGroupMemberCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation TGroupMemberCellData

@end

@implementation TUIGroupMemberCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    _head = [[UIImageView alloc] init];
    _head.layer.cornerRadius = 5;
    [_head.layer setMasksToBounds:YES];
    [self.contentView addSubview:_head];

    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:13]];
    [_name setTextColor:[UIColor grayColor]];
    _name.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_name];
}

- (void)defaultLayout
{
    CGSize headSize = [[self class] getSize];
    _head.frame = CGRectMake(0, 0, headSize.width, headSize.width);
    _name.frame = CGRectMake(0, _head.frame.origin.y + _head.frame.size.height + TGroupMemberCell_Margin, _head.frame.size.width, TGroupMemberCell_Name_Height);
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        _head.layer.masksToBounds = YES;
        _head.layer.cornerRadius = _head.frame.size.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        _head.layer.masksToBounds = YES;
        _head.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
}

- (void)setData:(TGroupMemberCellData *)data
{
    _data = data;

    if (data.avatarUrl) {
        // 外部有传入头像路径，直接使用路径加载，防止头像闪烁
        [self.head sd_setImageWithURL:[NSURL URLWithString:data.avatarUrl] placeholderImage:data.avatarImage?:DefaultAvatarImage];
    } else {
        // 如果外部只传入了 user_id，则使用默认的id形式加载
        if (data.avatarImage) {
            self.head.image = data.avatarImage;
        } else {
            self.head.image = DefaultAvatarImage;
            [[V2TIMManager sharedInstance] getUsersInfo:@[data.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                if (infoList.firstObject) {
                    [self.head sd_setImageWithURL:[NSURL URLWithString:infoList.firstObject.faceURL] placeholderImage:DefaultAvatarImage];
                };
            } fail:nil];
        }
    }
    if (data.name.length) {
        self.name.text = data.name;
    } else {
        self.name.text = data.identifier;
    }
    [self defaultLayout];
}

+ (CGSize)getSize {
    CGSize headSize = TGroupMemberCell_Head_Size;
    if (headSize.width * TGroupMembersCell_Column_Count + TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1) > Screen_Width) {
        CGFloat wd = (Screen_Width - (TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1))) / TGroupMembersCell_Column_Count;
        headSize = CGSizeMake(wd, wd);
    }
    return CGSizeMake(headSize.width, headSize.height + TGroupMemberCell_Name_Height + TGroupMemberCell_Margin);
}
@end
