#import <UIKit/UIKit.h>
#import "TCommonCell.h"



typedef enum : NSUInteger {
    ButtonGreen,
    ButtonWhite,
    ButtonRedText,
} TUIButtonStyle;

@interface TUIButtonCellData : TCommonCellData
@property (nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property TUIButtonStyle style;
@end

@interface TUIButtonCell : TCommonTableViewCell
@property (nonatomic, strong) UIButton *button;
@property TUIButtonCellData *buttonData;

- (void)fillWithData:(TUIButtonCellData *)data;
@end
