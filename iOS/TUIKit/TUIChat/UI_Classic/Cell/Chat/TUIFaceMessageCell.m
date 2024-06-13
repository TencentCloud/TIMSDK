//
//  FaceMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFaceMessageCell.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIFaceMessageCell ()
@end

@implementation TUIFaceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    
    CGFloat topMargin = 0;
    CGFloat height = self.container.mm_h;
    if (self.messageData.messageContainerAppendSize.height > 0) {
        topMargin = 10;
        CGFloat tagViewTopPadding = 6;
         height = self.container.mm_h - topMargin - self.messageData.messageContainerAppendSize.height - tagViewTopPadding;
        self.bubbleView.hidden = NO;
    } else {
        self.bubbleView.hidden = YES;
    }
    [self.face mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
        make.centerX.mas_equalTo(self.container.mas_centerX);
        make.top.mas_equalTo(topMargin);
        make.width.mas_equalTo(self.container);
    }];
    
    
}
- (void)fillWithData:(TUIFaceMessageCellData *)data {
    // set data
    [super fillWithData:data];
    self.faceData = data;
    UIImage *image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:TUIChatFaceImagePath(@"ic_unknown_image")];
    }
    _face.image = image;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIFaceMessageCellData.class], @"data must be kind of TUIFaceMessageCellData");
    TUIFaceMessageCellData *faceCellData = (TUIFaceMessageCellData *)data;
    UIImage *image = [[TUIImageCache sharedInstance] getFaceFromCache:faceCellData.path];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:TUIChatFaceImagePath(@"ic_unknown_image")];
    }
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    if (imageHeight > TFaceMessageCell_Image_Height_Max) {
        imageHeight = TFaceMessageCell_Image_Height_Max;
        imageWidth = image.size.width / image.size.height * imageHeight;
    }
    if (imageWidth > TFaceMessageCell_Image_Width_Max) {
        imageWidth = TFaceMessageCell_Image_Width_Max;
        imageHeight = image.size.height / image.size.width * imageWidth;
    }
    return CGSizeMake(imageWidth, imageHeight);
}

@end
