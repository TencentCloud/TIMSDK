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
    
    return self;
}

@end

@interface TCommonTextCell()
@property TCommonTextCellData *textData;
@end

@implementation TCommonTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        _keyLabel = self.textLabel;
        
        _valueLabel = self.detailTextLabel;
        
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
}
@end
