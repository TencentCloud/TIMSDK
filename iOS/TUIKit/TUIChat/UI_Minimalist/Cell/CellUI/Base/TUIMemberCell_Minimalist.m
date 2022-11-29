//
//  TUIMemberCell.m
//  TUIChat
//
//  Created by summeryxia on 2022/3/11.
//

#import "TUIMemberCell_Minimalist.h"
#import "TUIMemberCellData_Minimalist.h"
#import "TUICommonModel.h"
#import "TUIThemeManager.h"
#import "TUIDefine.h"

@interface TUIMemberDescribeCell_Minimalist()
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) TUIMemberDescribeCellData_Minimalist *cellData;

@end

@implementation TUIMemberDescribeCell_Minimalist
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView.backgroundColor = [UIColor tui_colorWithHex:@"#F9F9F9"];
    self.containerView.layer.cornerRadius = kScale390(20);
    [self addSubview:self.containerView];
    
    self.icon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:self.icon];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
    [self.containerView addSubview:self.titleLabel];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat margin = kScale390(16);
    self.containerView.frame = CGRectMake(margin, 0, self.contentView.frame.size.width - 2 * margin, kScale390(57));
    self.icon.frame = CGRectMake(kScale390(20), kScale390(20), kScale390(16), kScale390(16));
    self.titleLabel.frame = CGRectMake( self.icon.frame.origin.x + self.icon.frame.size.width + kScale390(11), kScale390(20), self.containerView.frame.size.width * 0.5, kScale390(17));
}

#pragma mark - Public
- (void)fillWithData:(TUIMemberDescribeCellData_Minimalist *)cellData {
    [super fillWithData:cellData];
    self.cellData = cellData;

    self.titleLabel.text = cellData.title;
    [self.icon setImage:cellData.icon];
    
}

@end

@interface TUIMemberCell_Minimalist()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) TUIMemberCellData_Minimalist *cellData;

@end

@implementation TUIMemberCell_Minimalist

#pragma mark - Life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
        
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(kScale390(32)).mm_height(kScale390(32)).mm__centerY(28).mm_left(kScale390(24));
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
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kScale390(14)];
        self.titleLabel.mm_left(self.avatarView.mm_maxX+kScale390(4)).mm_height(kScale390(17)).mm_width(200).mm__centerY(self.avatarView.mm_centerY);
        
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
- (void)fillWithData:(TUIMemberCellData_Minimalist *)cellData {
    [super fillWithData:cellData];
    self.cellData = cellData;

    self.titleLabel.text = cellData.title;
    [self.avatarView sd_setImageWithURL:cellData.avatarUrL
                       placeholderImage:DefaultAvatarImage];
    self.detailLabel.hidden = cellData.detail.length == 0;
    self.detailLabel.text = cellData.detail;
}

@end
