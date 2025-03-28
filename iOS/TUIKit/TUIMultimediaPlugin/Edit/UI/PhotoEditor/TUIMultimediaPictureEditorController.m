// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaPictureEditorController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <TXLiteAVSDK_Professional/TXPictureEditer.h>
#import <TXLiteAVSDK_Professional/TXVideoEditerTypeDef.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommonEditorControlView.h"
#import "TUIMultimediaPlugin/TUIMultimediaConstant.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterSelectController.h"
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleEditController.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaSticker.h"

@interface TUIMultimediaPictureEditorController () <TUIMultimediaCommonEditorControlViewDelegate, TUIMultimediaPasterSelectControllerDelegate> {
    TXPictureEditer *_editor;
    UIImageView *_imgView;
    
    TUIMultimediaPasterSelectController *_pasterSelectController;
    TUIMultimediaSubtitleEditController *_subtitleEditController;
    TUIMultimediaCommonEditorControlView *_commonEditCtrlView;
    BOOL _originNavgationBarHidden;
    BOOL _hasCrop;
}

@end

@implementation TUIMultimediaPictureEditorController
- (instancetype)init {
    self = [super init];
    _hasCrop = false;
    _sourceType = SOURCE_TYPE_RECORD;
    return self;
}

- (void)viewDidLoad {
    _editor = [[TXPictureEditer alloc] init];

    _pasterSelectController = [[TUIMultimediaPasterSelectController alloc] init];
    _pasterSelectController.delegate = self;
    _pasterSelectController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    _subtitleEditController = [[TUIMultimediaSubtitleEditController alloc] init];
    _subtitleEditController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    _commonEditCtrlView = [[TUIMultimediaCommonEditorControlView alloc] initWithConfig:TUIMultimediaCommonEditorConfig.configForPictureEditor];
    [self.view addSubview:_commonEditCtrlView];
    _commonEditCtrlView.delegate = self;
    _commonEditCtrlView.clipsToBounds = true;
    _commonEditCtrlView.sourceType = _sourceType;
    _commonEditCtrlView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    _commonEditCtrlView.previewSize = _srcPicture.size;
    _imgView = [[UIImageView alloc] init];
    _imgView.image = _srcPicture;
    [_commonEditCtrlView.previewView addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(_commonEditCtrlView.previewView);
    }];
    _commonEditCtrlView.mosaciOriginalImage = _srcPicture;

    UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    [self.view addGestureRecognizer:pinchRec];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)onPinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged: {
            if (gestureRecognizer.numberOfTouches < 2) {
                break;
            }
            CGPoint touchPoint1 = [gestureRecognizer locationOfTouch:0 inView:self.view];
            CGPoint touchPoint2 = [gestureRecognizer locationOfTouch:1 inView:self.view];
            CGPoint scaleCenter = CGPointMake((touchPoint1.x + touchPoint2.x) / 2, (touchPoint1.y + touchPoint2.y) / 2);
            [_commonEditCtrlView previewScale:gestureRecognizer.scale center:scaleCenter];
            gestureRecognizer.scale = 1.0f;
            break;
        }
        case UIGestureRecognizerStateEnded:
            [_commonEditCtrlView previewAdjustToLimitRect];
            break;
        default:
            break;
    }
}

- (void)onPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGPoint offset = [gestureRecognizer translationInView:self.view];
            [gestureRecognizer setTranslation:CGPointZero inView:self.view];
            [_commonEditCtrlView previewMove:offset];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [_commonEditCtrlView previewAdjustToLimitRect];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.navigationController != nil) {
        _originNavgationBarHidden = self.navigationController.navigationBarHidden;
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.navigationController != nil) {
        self.navigationController.navigationBarHidden = _originNavgationBarHidden;
    }
}

#pragma mark - Properties
- (void)setSrcPicture:(UIImage *)photo {
    _srcPicture = photo;
    _imgView.image = _srcPicture;
    _commonEditCtrlView.previewSize = _srcPicture.size;
}

- (void)setSourceType:(int)sourceType {
    NSLog(@"setSourceType sourceType = %d",sourceType);
    _sourceType = sourceType;
    if (_commonEditCtrlView != nil) {
        _commonEditCtrlView.sourceType = sourceType;
    }
}

#pragma mark - TUIMultimediaCommonEditorControlViewDelegate protocol
- (void)onCommonEditorControlViewCancel:(nonnull TUIMultimediaCommonEditorControlView *)view {
    if (_completeCallback == nil) {
        return;
    }
    _completeCallback(nil, PHOTO_EDIT_RESULT_CODE_CANCEL);
}

- (void)onCommonEditorControlViewCancelGenerate:(nonnull TUIMultimediaCommonEditorControlView *)view {
}

- (void)onCommonEditorControlViewComplete:(nonnull TUIMultimediaCommonEditorControlView *)view
                                 stickers:(nonnull NSArray<TUIMultimediaSticker *> *)stickers {
    if (_completeCallback == nil) {
        return;
    }
    
    if (stickers.count == 0) {
        NSLog(@"Return directly without edit the picture");
        UIImage* outputImage =  (_hasCrop  || _sourceType == SOURCE_TYPE_RECORD) ? _srcPicture : nil;
        _completeCallback(outputImage, _hasCrop ? VIDEO_EDIT_RESULT_CODE_GENERATE_SUCCESS : VIDEO_EDIT_RESULT_CODE_NO_EDIT);
        return;
    }
    
    [_editor setPicture:_srcPicture];
    [_editor setOutputRotation:0];
    [_editor setOutputSize:_srcPicture.size.width height:_srcPicture.size.height];
    [_editor setPasterList:[self stickercConvertToPaster:stickers rotationAngle:0]];
    @weakify(self) 
    [_editor processPicture:^(UIImage *processedPicture) {
        @strongify(self)
        self.completeCallback(processedPicture, PHOTO_EDIT_RESULT_CODE_GENERATE_SUCCESS);
    }];
}

- (void)onCommonEditorControlViewCrop:(NSInteger)rotationAngle normalizedCropRect:(CGRect)normalizedCropRect
                                      stickers:(NSArray<TUIMultimediaSticker *> *)stickers {
    [_editor setPicture:_srcPicture];
    [_editor setPasterList:[self stickercConvertToPaster:stickers rotationAngle:rotationAngle]];
    normalizedCropRect = [self adjustCropRectAccordingRotaionAngle:normalizedCropRect rotationAngle:rotationAngle];
    CGRect cropRect = CGRectMake(normalizedCropRect.origin.x * _srcPicture.size.width * _srcPicture.scale,
                                 normalizedCropRect.origin.y * _srcPicture.size.height * _srcPicture.scale,
                                 normalizedCropRect.size.width * _srcPicture.size.width * _srcPicture.scale,
                                 normalizedCropRect.size.height * _srcPicture.size.height * _srcPicture.scale);
    [_editor setCropRect:cropRect];
    

    CGSize outputSize = [self getOutputSize:cropRect.size rotationAngle:rotationAngle];
    [_editor setOutputSize:outputSize.width height:outputSize.height];
    [_editor setOutputRotation:(CGFloat)rotationAngle];
    [_editor processPicture:^(UIImage *processedPicture) {
        [self onProcessPictureForCrop:processedPicture];
    }];
}

- (CGSize) getOutputSize:(CGSize) cropRectSize rotationAngle:(CGFloat) rotationAngle {
    int outputWidth = 1080;
    int outputHeight = 1920;
    if(((int)rotationAngle + 180) % 180 == 0) {
        outputHeight = cropRectSize.height / cropRectSize.width * outputWidth;
    } else {
        outputHeight = cropRectSize.width / cropRectSize.height * outputWidth;
    }
    return CGSizeMake(outputWidth, outputHeight);
}

- (NSArray<TXPaster *> *) stickercConvertToPaster:(nonnull NSArray<TUIMultimediaSticker *> *)stickers rotationAngle:(NSInteger)rotationAngle {
    CGSize previewSize = _commonEditCtrlView.previewView.frame.size;
    return [stickers tui_multimedia_map:^TXPaster *(TUIMultimediaSticker *s) {
        TXPaster *p = [[TXPaster alloc] init];
        p.pasterImage = s.image;
        CGRect frame = CGRectMake(s.frame.origin.x / previewSize.width,
                             s.frame.origin.y / previewSize.height,
                             s.frame.size.width / previewSize.width,
                             s.frame.size.height / previewSize.height);
        p.frame = frame;
        return p;
    }];
}

- (CGRect) adjustCropRectAccordingRotaionAngle:(CGRect)normalizedCropRect rotationAngle:(CGFloat)rotationAngle {
    normalizedCropRect = CGRectMake(MIN(1.0f, MAX(normalizedCropRect.origin.x, 0)),
                                    MIN(1.0f, MAX(normalizedCropRect.origin.y, 0)),
                                    MIN(1.0f, MAX(normalizedCropRect.size.width, 0)),
                                    MIN(1.0f, MAX(normalizedCropRect.size.height, 0)));
    
    if (rotationAngle == 90) {
        normalizedCropRect = CGRectMake(normalizedCropRect.origin.y,
                                        1 - normalizedCropRect.size.width - normalizedCropRect.origin.x,
                                        normalizedCropRect.size.height,
                                        normalizedCropRect.size.width);
    } else if (rotationAngle == 180) {
        normalizedCropRect = CGRectMake(1 - normalizedCropRect.size.width - normalizedCropRect.origin.x,
                                        1 - normalizedCropRect.size.height - normalizedCropRect.origin.y,
                                        normalizedCropRect.size.width,
                                        normalizedCropRect.size.height);
    } else if (rotationAngle == 270) {
        normalizedCropRect = CGRectMake(1 - normalizedCropRect.origin.y - normalizedCropRect.size.height,
                                        normalizedCropRect.origin.x,
                                        normalizedCropRect.size.height,
                                        normalizedCropRect.size.width);
    }
    return normalizedCropRect;
}

- (void) onProcessPictureForCrop:(UIImage *) processedPicture {
    _hasCrop = true;
    _srcPicture = processedPicture;
    _commonEditCtrlView.previewView.hidden = NO;
    _commonEditCtrlView.previewSize = _srcPicture.size;
    _imgView.image = _srcPicture;
    _commonEditCtrlView.mosaciOriginalImage = _srcPicture;
}

- (void)onCommonEditorControlViewNeedAddPaster:(TUIMultimediaCommonEditorControlView *)view {
    _commonEditCtrlView.modifyButtonsHidden = YES;
    [self presentViewController:_pasterSelectController animated:NO completion:nil];
}

- (void)onCommonEditorControlViewNeedModifySubtitle:(TUIMultimediaSubtitleInfo *)info callback:(void (^)(TUIMultimediaSubtitleInfo *info, BOOL isOk))callback {
    _subtitleEditController.subtitleInfo = info;
    _subtitleEditController.callback = ^(TUIMultimediaSubtitleEditController *c, BOOL isOk) {
      [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
      if (callback != nil) {
          callback(c.subtitleInfo, isOk);
      }
    };
    [self presentViewController:_subtitleEditController animated:NO completion:nil];
}

- (void)onCommonEditorControlViewNeedEditMusic:(nonnull TUIMultimediaCommonEditorControlView *)view {
}

#pragma mark - TUIMultimediaPasterSelectControllerDelegate protocol
- (void)pasterSelectController:(TUIMultimediaPasterSelectController *)c onPasterSelected:(UIImage *)image {
    [_commonEditCtrlView addPaster:image];
    _commonEditCtrlView.modifyButtonsHidden = NO;
    [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
- (void)onPasterSelectControllerExit:(TUIMultimediaPasterSelectController *)c {
    _commonEditCtrlView.modifyButtonsHidden = NO;
    [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
