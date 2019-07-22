#import "TUIMenuCell.h"
#import "THeader.h"
#import "TUIKit.h"

@implementation TMenuCellData
@end

@implementation TUIMenuCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = TMenuCell_UnSelected_Background_Color;
    _menu = [[UIImageView alloc] init];
    [self addSubview:_menu];
}

- (void)defaultLayout
{
}

- (void)setData:(TMenuCellData *)data
{
    //set data
    _menu.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    if(data.isSelected){
        self.backgroundColor = TMenuCell_Selected_Background_Color;
    }
    else{
        self.backgroundColor = TMenuCell_UnSelected_Background_Color;
    }
    //update layout
    CGSize size = self.frame.size;
    _menu.frame = CGRectMake(TMenuCell_Margin, TMenuCell_Margin, size.width - 2 * TMenuCell_Margin, size.height - 2 * TMenuCell_Margin);
    _menu.contentMode = UIViewContentModeScaleAspectFit;
    
}
@end
