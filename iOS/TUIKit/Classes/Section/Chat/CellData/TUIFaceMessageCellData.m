//
//  TFaceMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIFaceMessageCellData.h"
#import "THeader.h"
#import "TUIKit.h"


@implementation TUIFaceMessageCellData

- (CGSize)contentSize
{
    UIImage *image = [[TUIImageCache sharedInstance] getFaceFromCache:self.path];
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

@end
