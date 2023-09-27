//
//  TUIContactCommonTextCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonContactTextCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUICommonContactTextCellData_Minimalist
- (instancetype)init {
    self = [super init];
    self.keyEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];
    if (self.enableMultiLineValue) {
        NSString *str = self.value;
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:16]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(280, 999)
                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil]
                          .size;
        height = size.height + 30;
    }
    return height;
}

@end

@interface TUICommonContactTextCell_Minimalist ()
@property TUICommonContactTextCellData_Minimalist *textData;
@end

@implementation TUICommonContactTextCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
       
        _keyLabel = [[UILabel alloc] init];
        _keyLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#444444");
        _keyLabel.font = [UIFont systemFontOfSize:16.0];
        [self.contentView addSubview:_keyLabel];
        [_keyLabel setRtlAlignment:TUITextRTLAlignmentTrailing];
        
        _valueLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_valueLabel];

        _valueLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
        _valueLabel.font = [UIFont systemFontOfSize:16.0];
        [_valueLabel setRtlAlignment:TUITextRTLAlignmentTrailing];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)fillWithData:(TUICommonContactTextCellData_Minimalist *)textData {
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
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {

    [super updateConstraints];

    [self.keyLabel sizeToFit];
    [self.keyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.keyLabel.frame.size);
        make.leading.mas_equalTo(self.contentView).mas_offset(self.textData.keyEdgeInsets.left);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.valueLabel sizeToFit];
    [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.keyLabel.mas_trailing).mas_offset(10);
        if (self.textData.showAccessory) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
        }
        else {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-20);
        }
        make.centerY.mas_equalTo(self.contentView);
    }];
}
@end
