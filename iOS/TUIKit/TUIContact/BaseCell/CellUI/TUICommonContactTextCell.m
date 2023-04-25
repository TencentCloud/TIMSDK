//
//  TUIContactCommonTextCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUICommonContactTextCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUICommonContactTextCellData
- (instancetype)init {
    self = [super init];
    self.keyEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];
    if (self.enableMultiLineValue) {
        NSString *str = self.value;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(280, 999) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        height = size.height + 30;
    }
    return height;
}

@end

@interface TUICommonContactTextCell()
@property TUICommonContactTextCellData *textData;
@end

@implementation TUICommonContactTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        
        _keyLabel = self.textLabel;
        _keyLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#444444");
        _keyLabel.font = [UIFont systemFontOfSize:16.0];
        
        _valueLabel = self.detailTextLabel;
        _valueLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
        _valueLabel.font = [UIFont systemFontOfSize:16.0];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
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

- (void)fillWithData:(TUICommonContactTextCellData *)textData {
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
    
    if (self.textData.enableMultiLineValue) {
        self.valueLabel.numberOfLines = 0;
    } else {
        self.valueLabel.numberOfLines = 1;
    }
}

@end
