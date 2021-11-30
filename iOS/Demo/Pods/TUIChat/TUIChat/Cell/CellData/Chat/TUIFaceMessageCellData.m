//
//  TFaceMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIFaceMessageCellData.h"
#import "TUIDefine.h"

@implementation TUIFaceMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMFaceElem *elem = message.faceElem;
    TUIFaceMessageCellData *faceData = [[TUIFaceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    faceData.groupIndex = elem.index;
    faceData.faceName = [[NSString alloc] initWithData:elem.data encoding:NSUTF8StringEncoding];
    for (TUIFaceGroup *group in [TUIConfig defaultConfig].faceGroups) {
        if(group.groupIndex == faceData.groupIndex){
            NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
            faceData.path = path;
            break;
        }
    }
    faceData.reuseId = TFaceMessageCell_ReuseId;
    return faceData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TUIKitLocalizableString(TUIKitMessageTypeAnimateEmoji); // @"[动画表情]";
}

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
