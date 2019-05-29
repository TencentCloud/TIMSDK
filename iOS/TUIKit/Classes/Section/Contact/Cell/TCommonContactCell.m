//
//  TCommonFriendCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TCommonContactCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "THeader.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TCommonContactCellData.h"


@interface TCommonContactCell()
@property TCommonContactCellData *contactData;
@end

@implementation TCommonContactCell

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
        self.avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:TUIKitResource(@"default_head")]];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(34).mm_height(34).mm__centerY(28).mm_left(12);
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)fillWithData:(TCommonContactCellData *)contactData
{
    [super fillWithData:contactData];
    self.contactData = contactData;
    
    
    self.titleLabel.text = contactData.title;
    if (contactData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:contactData.avatarUrl];
    } else if (contactData.avatarImage) {
        [self.avatarView setImage:contactData.avatarImage];
    } else {
        [self.avatarView setImage:[UIImage imageNamed:TUIKitResource(@"default_head")]];
    }
}
@end
