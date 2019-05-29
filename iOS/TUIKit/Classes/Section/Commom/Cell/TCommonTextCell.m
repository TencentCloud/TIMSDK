//
//  TCommonTextCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TCommonTextCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"

@implementation TCommonTextCellData
- (instancetype)init {
    self = [super init];
    _margin = 15;
    return self;
}
@end

@interface TCommonTextCell()
@property TCommonTextCellData *textData;
@end

@implementation TCommonTextCell

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
        _keyLabel = [[UILabel alloc] init];
        _keyLabel.adjustsFontSizeToFitWidth = YES;
        _valueLabel.font = kRichCellTextFont;
        [self.contentView addSubview:_keyLabel];
        _keyLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.adjustsFontSizeToFitWidth = YES;
        _valueLabel.font = kRichCellTextFont;
        [self.contentView addSubview:_valueLabel];
        _valueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        _valueLabel.textAlignment = NSTextAlignmentRight;
        
        _keyLabel.mm_width(120).mm_height(self.contentView.mm_h).mm__centerY(self.contentView.mm_h / 2);
        _valueLabel.mm_width(120).mm_height(self.contentView.mm_h).mm__centerY(self.contentView.mm_h / 2);
        
        _keyLabel.textColor = [UIColor blackColor];
        _valueLabel.textColor = [UIColor grayColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)fillWithData:(TCommonTextCellData *)textData
{
    [super fillWithData:textData];
    
    self.textData = textData;
    
    _keyLabel.text = textData.key;
    _valueLabel.text = textData.value;
    
    if (textData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _keyLabel.mm_left(textData.margin);
    if (self.accessoryView || self.accessoryType != UITableViewCellAccessoryNone) {
        _valueLabel.mm_right(0);
    } else {
        _valueLabel.mm_right(textData.margin);
    }
}
@end
