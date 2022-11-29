//
//  FaceMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIFaceMessageCell.h"
#import "TUIDefine.h"

@interface TUIFaceMessageCell ()
@end

@implementation TUIFaceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _face = [[UIImageView alloc] init];
        _face.contentMode = UIViewContentModeScaleAspectFit;
        [self.container addSubview:_face];
        _face.mm_fill();
        _face.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat topMargin = 0;
    CGFloat height = self.container.mm_h;
    
    if (self.messageData.messageModifyReactsSize.height > 0) {
        topMargin = 10;
        height = (self.container.mm_h - self.messageData.messageModifyReactsSize.height - topMargin);
        self.bubbleView.hidden = NO;
    }
    else {
        self.bubbleView.hidden = YES;
    }
    _face.mm_height(height ).mm_left(0).mm_top(topMargin).mm_width(self.container.mm_w);

    _face.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}
- (void)fillWithData:(TUIFaceMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.faceData = data;

    _face.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];;
}

@end
