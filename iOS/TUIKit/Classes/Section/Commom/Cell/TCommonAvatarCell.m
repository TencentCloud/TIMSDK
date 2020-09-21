#import "TCommonAvatarCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"


@implementation TCommonAvatarCellData
- (instancetype)init {
    self = [super init];
    if(self){
         _avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin;
}

@end

@interface TCommonAvatarCell()
@property TCommonAvatarCellData *avatarData;
@end

@implementation TCommonAvatarCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        [self setupViews];
         //self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)fillWithData:(TCommonAvatarCellData *) avatarData
{
    [super fillWithData:avatarData];

    self.avatarData = avatarData;

    RAC(_keyLabel, text) = [RACObserve(avatarData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(avatarData, value) takeUntil:self.rac_prepareForReuseSignal];
     @weakify(self)
    [[RACObserve(avatarData, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
    }];

    if (avatarData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setupViews
{
    CGSize headSize = TPersonalCommonCell_Image_Size;
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(TPersonalCommonCell_Margin, TPersonalCommonCell_Margin, headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFit;

    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }

    [self addSubview:_avatar];

    _keyLabel = self.textLabel;
    _valueLabel = self.detailTextLabel;

    [self addSubview:_keyLabel];
    [self addSubview:_valueLabel];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    //_avatar.mm_top(self.mm_maxY - TPersonalCommonCell_Margin).mm_left(self.mm_maxX - 100);
    _avatar.mm_left(self.mm_maxX - 120);

}

@end
