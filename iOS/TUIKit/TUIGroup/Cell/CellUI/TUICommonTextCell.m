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
        _keyLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        
        _valueLabel = self.detailTextLabel;
        _valueLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.changeColorWhenTouched = YES;
    }
    return self;
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
}

@end
