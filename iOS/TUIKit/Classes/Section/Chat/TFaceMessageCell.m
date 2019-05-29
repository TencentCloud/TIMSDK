//
//  FaceMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/10/8.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TFaceMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"


@implementation TFaceMessageCellData
@end

@interface TFaceMessageCell ()
@end

@implementation TFaceMessageCell

- (CGSize)getContainerSize:(TFaceMessageCellData *)data
{
    UIImage *image = [[[TUIKit sharedInstance] getConfig] getFaceFromCache:data.path];
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    if(imageHeight > TFaceMessageCell_Image_Height_Max){
        imageHeight = TFaceMessageCell_Image_Height_Max;
        imageWidth = image.size.width / image.size.height * imageHeight;
    }
    if (imageWidth > TFaceMessageCell_Image_Width_Max){
        imageWidth = TFaceMessageCell_Image_Width_Max;
        imageHeight = image.size.height / image.size.width * imageWidth;
    }
    return CGSizeMake(imageWidth, imageHeight);
}

- (void)setupViews
{
    [super setupViews];
    
    _face = [[UIImageView alloc] init];
    _face.contentMode = UIViewContentModeScaleAspectFit;
    [super.container addSubview:_face];
}

- (void)setData:(TFaceMessageCellData *)data;
{
    //set data
    [super setData:data];
    _face.image = [[[TUIKit sharedInstance] getConfig] getFaceFromCache:data.path];;
    //update layout
    _face.frame = super.container.bounds;
}
@end
