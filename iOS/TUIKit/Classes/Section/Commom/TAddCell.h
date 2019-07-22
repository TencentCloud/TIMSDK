#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TAddCellState) {
    TAddCell_State_UnSelect,
    TAddCell_State_Selected,
    TAddCell_State_Solid,
};

@interface TAddCellData : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) TAddCellState state;
@end

@interface TAddCell : UITableViewCell
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
+ (CGFloat)getHeight;
- (void)setData:(TAddCellData *)data;
@end
