
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

- (void)fillWithData:(TUIImageMessageCellData_Minimalist *)data;
{
    [super fillWithData:data];
    self.imageView.image = nil;
    if (data.largeImage == nil) {
        [data downloadImage:TImage_Type_Large];
    }

    @weakify(self);
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
@end
