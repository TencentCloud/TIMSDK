//
//  FaceMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFaceMessageCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIFaceMessageCell_Minimalist ()
@end

@implementation TUIFaceMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _face = [[UIImageView alloc] init];
        _face.contentMode = UIViewContentModeScaleAspectFit;
        [self.bubbleView addSubview:_face];
        _face.mm_fill();
        _face.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _face.backgroundColor = RGBA(236, 240, 246, 1);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _face.mm_width(kScale390(90)).mm_height(kScale390(88)).mm_left(kScale390(16)).mm_top(kScale390(8));

    _face.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}
- (void)fillWithData:(TUIFaceMessageCellData *)data {
    // set data
    [super fillWithData:data];
    self.faceData = data;

    _face.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    ;
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIFaceMessageCellData.class], @"data must be kind of TUIFaceMessageCellData");
    TUIFaceMessageCellData *faceCellData = (TUIFaceMessageCellData *)data;
    
    UIImage *image = [[TUIImageCache sharedInstance] getFaceFromCache:faceCellData.path];
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
    imageWidth += kScale390(30);
    imageHeight += kScale390(30);
    return CGSizeMake(imageWidth, imageHeight);
}

@end
