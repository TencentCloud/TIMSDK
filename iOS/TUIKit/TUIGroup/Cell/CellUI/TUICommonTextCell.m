//
//  TUICommonTextCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUICommonTextCell.h"
#import "TUIDefine.h"

@implementation TUICommonTextCellData
- (instancetype)init {
    self = [super init];
    self.keyEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    return self;
}

@end

@interface TUICommonTextCell()
@property TUICommonTextCellData *textData;
@end

@implementation TUICommonTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        _keyLabel = self.textLabel;
        _keyLabel.textColor = [UIColor d_colorWithColorLight:[UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1/1.0] dark:UIColor.lightGrayColor];
        _keyLabel.font = [UIFont systemFontOfSize:16.0];
        
        _valueLabel = self.detailTextLabel;
        _valueLabel.textColor = [UIColor d_colorWithColorLight:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0] dark:UIColor.lightGrayColor];
        _valueLabel.font = [UIFont systemFontOfSize:16.0];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    if (self.textData.keyEdgeInsets.left) {
        self.keyLabel.mm_left(self.textData.keyEdgeInsets.left);
    }
    
    if (self.textData.keyEdgeInsets.top) {
        self.keyLabel.mm_top(self.textData.keyEdgeInsets.top);
    }
    
    if (self.textData.keyEdgeInsets.bottom) {
        self.keyLabel.mm_bottom(self.textData.keyEdgeInsets.bottom);
    }
    
    if (self.textData.keyEdgeInsets.right) {
        self.keyLabel.mm_right(self.textData.keyEdgeInsets.right);
    }
}

- (void)fillWithData:(TUICommonTextCellData *)textData
{
    [super fillWithData:textData];

    self.textData = textData;
    RAC(_keyLabel, text) = [RACObserve(textData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(textData, value) takeUntil:self.rac_prepareForReuseSignal];

    if (textData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.textData.keyColor) {
        self.keyLabel.textColor = self.textData.keyColor;
    }
    
    if (self.textData.valueColor) {
        self.valueLabel.textColor = self.textData.valueColor;
    }
}

@end
