//
//  TCommonSwitchCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TCommonSwitchCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"

@implementation TCommonSwitchCellData
- (instancetype)init {
    self = [super init];
    _margin = 15;
    return self;
}

@end

@interface TCommonSwitchCell()
@property TCommonSwitchCellData *switchData;
@end

@implementation TCommonSwitchCell

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
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.font = kRichCellTextFont;
        [self.contentView addSubview:_titleLabel];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        _switcher = [[UISwitch alloc] init];
        self.accessoryView = _switcher;
        [self.contentView addSubview:_switcher];
        [_switcher addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventValueChanged];
        
        _titleLabel.mm_width(120).mm_height(self.contentView.mm_h).mm__centerY(self.contentView.mm_h / 2);
        
        _titleLabel.textColor = [UIColor blackColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)fillWithData:(TCommonSwitchCellData *)switchData
{
    [super fillWithData:switchData];
    
    self.switchData = switchData;
    
    _titleLabel.text = switchData.title;
    [_switcher setOn:switchData.isOn];
    
    _titleLabel.mm_left(switchData.margin);
}

- (void)switchClick
{
    if (self.switchData.cswitchSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.switchData.cswitchSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.switchData.cswitchSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
    
}
@end
