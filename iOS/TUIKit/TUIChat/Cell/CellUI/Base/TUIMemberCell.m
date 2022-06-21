//
//  TUIMemberCell.m
//  TUIChat
//
//  Created by summeryxia on 2022/3/11.
//

#import "TUIMemberCell.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#import "TUIMemberCellData.h"

@interface TUIMemberCell()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) TUIMemberCellData *cellData;

@end

@implementation TUIMemberCell

#pragma mark - Life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
        
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(34).mm_height(34).mm__centerY(28).mm_left(12);
        if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
        } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
        }

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
        self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm_width(200).mm__centerY(self.avatarView.mm_centerY);
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        [self.contentView addSubview:self.detailLabel];
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
        self.detailLabel.mm__centerY(self.avatarView.mm_centerY);

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.detailLabel.mm_sizeToFit();
    self.detailLabel.mm_right(12);
}

#pragma mark - Public
- (void)fillWithData:(TUIMemberCellData *)cellData {
    [super fillWithData:cellData];
    self.cellData = cellData;

    self.titleLabel.text = cellData.title;
    [self.avatarView sd_setImageWithURL:cellData.avatarUrL
                       placeholderImage:DefaultAvatarImage];
    self.detailLabel.hidden = cellData.detail.length == 0;
    self.detailLabel.text = cellData.detail;
}

@end
