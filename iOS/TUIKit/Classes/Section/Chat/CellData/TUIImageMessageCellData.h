//
//  TUIImageMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIImageType)
{
    TImage_Type_Thumb,
    TImage_Type_Large,
    TImage_Type_Origin,
};

@interface TUIImageItem : NSObject
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) TUIImageType type;
@end

@interface TUIImageMessageCellData : TUIMessageCellData
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIImage *largeImage;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSUInteger thumbProgress;
@property (nonatomic, assign) NSUInteger originProgress;
@property (nonatomic, assign) NSUInteger largeProgress;
@property (nonatomic, assign) NSUInteger uploadProgress;

- (void)downloadImage:(TUIImageType)type;
- (void)decodeImage:(TUIImageType)type;

- (NSString *)getImagePath:(TUIImageType)type isExist:(BOOL *)isExist;
@end

NS_ASSUME_NONNULL_END
