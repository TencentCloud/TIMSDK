//
//  TFileMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIFileMessageCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"

@implementation TUIFileMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        self.container.layer.cornerRadius = 5;
        [self.container.layer setMasksToBounds:YES];

        _fileName = [[UILabel alloc] init];
        _fileName.font = [UIFont systemFontOfSize:15];
        _fileName.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        [self.container addSubview:_fileName];

        _length = [[UILabel alloc] init];
        _length.font = [UIFont systemFontOfSize:12];
        _length.textColor = [UIColor d_systemGrayColor];
        [self.container addSubview:_length];

        _image = [[UIImageView alloc] init];
        _image.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"msg_file")];
        _image.contentMode = UIViewContentModeScaleAspectFit;
        [self.container addSubview:_image];
    }
    return self;
}

- (void)fillWithData:(TUIFileMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.fileData = data;
    _fileName.text = data.fileName;
    _length.text = [self formatLength:data.length];

    @weakify(self)

    RACSignal *progressSignal;
    if (data.direction == MsgDirectionIncoming) {
        progressSignal = [[RACObserve(data, uploadProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged];
    } else {
        progressSignal = [[RACObserve(data, uploadProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged];
    }
    [progressSignal subscribeNext:^(NSNumber *x) {
        @strongify(self)
        int progress = [x intValue];
        if (progress >= 100 || progress == 0) {
            [self.indicator stopAnimating];
        } else {
            [self.indicator startAnimating];
        }
    }];
}

- (NSString *)formatLength:(long)length
{
    double len = length;
    NSArray *array = [NSArray arrayWithObjects:@"Bytes", @"K", @"M", @"G", @"T", nil];
    int factor = 0;
    while (len > 1024) {
        len /= 1024;
        factor++;
        if(factor >= 4){
            break;
        }
    }
    return [NSString stringWithFormat:@"%4.2f%@", len, array[factor]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize containerSize = [self.fileData contentSize];
    CGFloat imageHeight = containerSize.height - 2 * TFileMessageCell_Margin;
    CGFloat imageWidth = imageHeight;
    _image.frame = CGRectMake(containerSize.width - TFileMessageCell_Margin - imageWidth, TFileMessageCell_Margin, imageWidth, imageHeight);
    CGFloat textWidth = _image.frame.origin.x - 2 * TFileMessageCell_Margin;
    CGSize nameSize = [_fileName sizeThatFits:containerSize];
    _fileName.frame = CGRectMake(TFileMessageCell_Margin, TFileMessageCell_Margin, textWidth, nameSize.height);
    CGSize lengthSize = [_length sizeThatFits:containerSize];
    _length.frame = CGRectMake(TFileMessageCell_Margin, _fileName.frame.origin.y + nameSize.height + TFileMessageCell_Margin * 0.5, textWidth, lengthSize.height);
}
@end
