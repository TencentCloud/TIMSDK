
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIImageCollectionCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUITool.h>

@implementation TUIImageCollectionCell_Minimalist
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.layer.cornerRadius = 5.0;
    [self.imageView.layer setMasksToBounds:YES];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
    self.imageView.mm_fill();
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadBtn.contentMode = UIViewContentModeScaleToFill;
    [self.downloadBtn setImage:TUIChatCommonBundleImage(@"download") forState:UIControlStateNormal];
    [self.downloadBtn addTarget:self action:@selector(onDownloadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.downloadBtn];

    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMedia)];
    [self addGestureRecognizer:tap];
}

- (void)onDownloadBtnClick {
    UIImage *image = self.imageView.image;
    [[PHPhotoLibrary sharedPhotoLibrary]
        performChanges:^{
          [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        }
        completionHandler:^(BOOL success, NSError *_Nullable error) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitPictureSavedSuccess)];
            } else {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitPictureSavedFailed)];
            }
          });
        }];
}

- (void)onSelectMedia {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseMedia:)]) {
        [self.delegate onCloseMedia:self];
    }
}

- (void)fillWithData:(TUIImageMessageCellData *)data;
{
    [super fillWithData:data];
    self.imageView.image = nil;
     
    //1.Read from cache
    if ([self originImageFirst:data]) {
        return;
    }
    
    if ([self largeImageSecond:data]) {
        return;
    }
    
    if (data.thumbImage == nil) {
        [data downloadImage:TImage_Type_Thumb];
    }
    if (data.thumbImage && data.largeImage == nil) {
        [data downloadImage:TImage_Type_Large];
    }

    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
      @strongify(self);
      if (thumbImage) {
          self.imageView.image = thumbImage;
      }
    }];

    // largeImage
    [[RACObserve(data, largeImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *largeImage) {
      @strongify(self);
      if (largeImage) {
          self.imageView.image = largeImage;
      }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.downloadBtn.mm_width(31).mm_height(31).mm_right(16).mm_bottom(48);
}

- (BOOL)largeImageSecond:(TUIImageMessageCellData *)data {
    @weakify(self);
    BOOL isExist = NO;
    NSString *path = [data getImagePath:TImage_Type_Large isExist:&isExist];
    if (isExist) {
        [data decodeImage:TImage_Type_Large];
        [self fillLargeImageWithData:data];
    }
    return isExist;
}


- (BOOL)originImageFirst:(TUIImageMessageCellData *)data {
    BOOL isExist = NO;
    NSString *path = [data getImagePath:TImage_Type_Origin isExist:&isExist];
    if (isExist) {
        [data decodeImage:TImage_Type_Origin];
        [self fillOriginImageImageWithData:data];
    }
    return isExist;
}
- (void)fillOriginImageImageWithData:(TUIImageMessageCellData *)data {
    @weakify(self);
    // originImage
    [[RACObserve(data, originImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *originImage) {
      @strongify(self);
      if (originImage) {
          self.imageView.image = originImage;
      }
    }];
}


- (void)fillLargeImageWithData:(TUIImageMessageCellData *)data {
    @weakify(self);
    // largeImage
    [[RACObserve(data, largeImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *largeImage) {
      @strongify(self);
      if (largeImage) {
          self.imageView.image = largeImage;
      }
    }];
}

- (void)fillThumbImageWithData:(TUIImageMessageCellData *)data {
    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
      @strongify(self);
      if (thumbImage) {
          self.imageView.image = thumbImage;
      }
    }];
}
@end
