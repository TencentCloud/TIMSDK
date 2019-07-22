#import "TUIImageMessageCellData.h"
#import "THelper.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/SDImageCache.h"

@import ImSDK;

@implementation TUIImageItem
@end

@interface TUIImageMessageCellData ()
@property (nonatomic, assign) BOOL isDownloading;
@end

@implementation TUIImageMessageCellData
- (id)init
{
    self = [super init];
    if(self){
        _uploadProgress = 100;
    }
    return self;
}

- (NSString *)getImagePath:(TUIImageType)type isExist:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if(self.direction == MsgDirectionOutgoing) {
        //上传方本地原图是否有效
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Image_Path, _path.lastPathComponent];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }
    
    if(!*isExist) {
        //查看本地是否存在
        TUIImageItem *tImageItem = [self getTImageItem:type];
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Image_Path, tImageItem.uuid];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }
    
    return path;
}



- (void)downloadImage:(TUIImageType)type
{
    BOOL isExist = NO;
    NSString *path = [self getImagePath:type isExist:&isExist];
    if(isExist)
    {
        [self decodeImage:type];
        return;
    }
 
    if(self.isDownloading) {
        return;
    }
    self.isDownloading = YES;
    
    //网络下载
    TIMImage *imImage = [self getIMImage:type];
    
    @weakify(self)
    [imImage getImage:path progress:^(NSInteger curSize, NSInteger totalSize) {
        @strongify(self)
        [self updateProgress:curSize * 100 / totalSize withType:type];
    } succ:^{
        @strongify(self)
        self.isDownloading = NO;
        [self updateProgress:100 withType:type];
        [self decodeImage:type];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        self.isDownloading = NO;
    }];
}

- (void)updateProgress:(NSUInteger)progress withType:(TUIImageType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type == TImage_Type_Thumb)
            self.thumbProgress = progress;
        if (type == TImage_Type_Large)
            self.largeProgress = progress;
        if (type == TImage_Type_Origin)
            self.originProgress = progress;
    });
}

- (void)decodeImage:(TUIImageType)type
{
    BOOL isExist = NO;
    NSString *path = [self getImagePath:type isExist:&isExist];
    if(!isExist)
    {
        return;
    }
    
    void (^finishBlock)(UIImage *) = ^(UIImage *image){
        if (type == TImage_Type_Thumb) {
            self.thumbImage = image;
            self.thumbProgress = 100;
            self.uploadProgress = 100;
        }
        if (type == TImage_Type_Large) {
            self.largeImage = image;
            self.largeProgress = 100;
        }
        if (type == TImage_Type_Origin) {
            self.originImage = image;
            self.originProgress = 100;
        }
    };
    
    NSString *cacheKey = [path substringFromIndex:TUIKit_Image_Path.length];
    
    
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheKey];
    if (cacheImage) {
        finishBlock(cacheImage);
    } else {
        [THelper asyncDecodeImage:path complete:^(NSString *path, UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SDImageCache sharedImageCache] storeImageToMemory:image forKey:cacheKey];
                finishBlock(image);
            });
        }];
    }
}

- (TUIImageItem *)getTImageItem:(TUIImageType)type
{
    for (TUIImageItem *item in self.items) {
        if(item.type == type){
            return item;
        }
    }
    return nil;
}

- (TIMImage *)getIMImage:(TUIImageType)type
{
    TIMMessage *imMsg = self.innerMessage;
    for (int i = 0; i < imMsg.elemCount; ++i) {
        TIMElem *imElem = [imMsg getElem:i];
        if([imElem isKindOfClass:[TIMImageElem class]]){
            TIMImageElem *imImageElem = (TIMImageElem *)imElem;
            for (TIMImage *imImage in imImageElem.imageList) {
                if(type == TImage_Type_Thumb && imImage.type == TIM_IMAGE_TYPE_THUMB){
                    return imImage;
                }
                else if(type == TImage_Type_Origin && imImage.type == TIM_IMAGE_TYPE_ORIGIN){
                    return imImage;
                }
                else if(type == TImage_Type_Large && imImage.type == TIM_IMAGE_TYPE_LARGE){
                    return imImage;
                }
            }
            break;
        }
    }
    return nil;
}

- (CGSize)contentSize
{
    CGSize size = CGSizeZero;
    BOOL isDir = NO;
    if(![self.path isEqualToString:@""] &&
       [[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&isDir]){
        if(!isDir){
            size = [UIImage imageWithContentsOfFile:self.path].size;
        }
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in self.items) {
            if(item.type == TImage_Type_Thumb){
                size = item.size;
            }
        }
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in self.items) {
            if(item.type == TImage_Type_Large){
                size = item.size;
            }
        }
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in self.items) {
            if(item.type == TImage_Type_Origin){
                size = item.size;
            }
        }
    }

    if(CGSizeEqualToSize(size, CGSizeZero)){
        return size;
    }
    if(size.height > size.width){
        size.width = size.width / size.height * TImageMessageCell_Image_Height_Max;
        size.height = TImageMessageCell_Image_Height_Max;
    } else {
        size.height = size.height / size.width * TImageMessageCell_Image_Width_Max;
        size.width = TImageMessageCell_Image_Width_Max;
    }
    return size;
}
@end
