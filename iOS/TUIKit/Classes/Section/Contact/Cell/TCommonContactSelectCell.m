
#import "TCommonContactSelectCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"

@interface TCommonContactSelectCell()
@property TCommonContactSelectCellData *selectData;
@end

@implementation TCommonContactSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.selectButton];
        [self.selectButton setImage:[UIImage imageNamed:TUIKitResource(@"icon_contact_select_normal")] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:TUIKitResource(@"icon_contact_select_pressed")] forState:UIControlStateHighlighted];
        [self.selectButton setImage:[UIImage imageNamed:TUIKitResource(@"icon_contact_select_selected")] forState:UIControlStateSelected];
        [self.selectButton setImage:[UIImage imageNamed:TUIKitResource(@"icon_contact_select_selected_disable")] forState:UIControlStateDisabled];
        self.selectButton.mm_sizeToFit().mm__centerY(self.mm_centerY).mm_left(12);
        self.selectButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(34).mm_height(34).mm__centerY(self.mm_centerY).mm_left(self.selectButton.mm_maxX+12);
        self.avatarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupBinds
{

}

- (void)fillWithData:(TCommonContactSelectCellData *)selectData
{
    [super fillWithData:selectData];
    self.selectData = selectData;
    self.titleLabel.text = selectData.title;
    if (selectData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:selectData.avatarUrl placeholderImage:DefaultAvatarImage];
    } else if (selectData.avatarImage) {
        [self.avatarView setImage:selectData.avatarImage];
    } else {
        [self.avatarView setImage:DefaultAvatarImage];
    }
    [self.selectButton setSelected:selectData.isSelected];
    self.selectButton.enabled = selectData.enabled;
}

@end
