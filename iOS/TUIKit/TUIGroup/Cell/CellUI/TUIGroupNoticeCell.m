//
//  TUIGroupNoticeCell.m
//  TUIGroup
//
//  Created by harvy on 2022/1/11.
//

#import "TUIGroupNoticeCell.h"
#import "TUIThemeManager.h"

@implementation TUIGroupNoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.descLabel];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapRecognizer.delegate = self;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:tapRecognizer];
}

- (void)tapGesture:(UIGestureRecognizer *)gesture
{
    if (self.cellData.selector && self.cellData.target) {
        if ([self.cellData.target respondsToSelector:self.cellData.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.cellData.target performSelector:self.cellData.selector];
#pragma clang diagnostic pop
        }
    }
}

- (void)setCellData:(TUIGroupNoticeCellData *)cellData
{
    _cellData = cellData;
    
    self.nameLabel.text = cellData.name;
    self.descLabel.text = cellData.desc;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.nameLabel sizeToFit];
    self.nameLabel.mm_x = 20.0;
    self.nameLabel.mm_y = 12.0;
    self.nameLabel.mm_flexToRight(20);
    
    [self.descLabel sizeToFit];
    self.descLabel.mm_y = CGRectGetMaxY(self.nameLabel.frame) + 4;
    self.descLabel.mm_x = self.nameLabel.mm_x;
    self.descLabel.mm_flexToRight(30);
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"群通告";
        _nameLabel.textColor = TUICoreDynamicColor(@"form_key_text_color", @"#888888");
        _nameLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _nameLabel;
}

- (UILabel *)descLabel
{
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"neirong";
        _descLabel.textColor = TUICoreDynamicColor(@"form_subtitle_color", @"#BBBBBB");
        _descLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _descLabel;
}

@end
