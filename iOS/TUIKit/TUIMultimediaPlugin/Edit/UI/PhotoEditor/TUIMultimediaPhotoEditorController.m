// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaPhotoEditorController.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaCommonEditorControlView.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterSelectController.h"
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleEditController.h"
#import "TUIMultimediaPlugin/TUIMultimediaConstant.h"

@interface TUIMultimediaPhotoEditorController () <TUIMultimediaCommonEditorControlViewDelegate, TUIMultimediaPasterSelectControllerDelegate> {
    TUIMultimediaPasterSelectController *_pasterSelectController;
    TUIMultimediaSubtitleEditController *_subtitleEditController;
    UIImageView *_imgView;
    TUIMultimediaCommonEditorControlView *_ctrlView;
    BOOL _originNavgationBarHidden;
}

@end

@implementation TUIMultimediaPhotoEditorController
- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    _pasterSelectController = [[TUIMultimediaPasterSelectController alloc] init];
    _pasterSelectController.delegate = self;
    _pasterSelectController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    _subtitleEditController = [[TUIMultimediaSubtitleEditController alloc] init];
    _subtitleEditController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    _ctrlView = [[TUIMultimediaCommonEditorControlView alloc] initWithConfig:TUIMultimediaCommonEditorConfig.configForPhotoEditor];
    [self.view addSubview:_ctrlView];
    _ctrlView.delegate = self;
    [_ctrlView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self.view);
    }];

    _imgView = [[UIImageView alloc] init];
    _imgView.image = _photo;
    _ctrlView.previewSize = _photo.size;
    [_ctrlView.previewView addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(_ctrlView.previewView);
    }];
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
- (void)setPhoto:(UIImage *)photo {
    _photo = photo;
    _imgView.image = photo;
    _ctrlView.previewSize = photo.size;
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

- (void)onCommonEditorControlViewComplete:(nonnull TUIMultimediaCommonEditorControlView *)view stickers:(nonnull NSArray<TUIMultimediaSticker *> *)stickers {
    if (_completeCallback == nil) {
        return;
    }
    
    NSString* outFilePath = [self getOutFilePath];
    BOOL isSaveImageSuccess = [self saveImageAsJPEG:_photo filePath:outFilePath];
    if (isSaveImageSuccess) {
        _completeCallback([NSURL fileURLWithPath:outFilePath], PHOTO_EDIT_RESULT_CODE_GENERATE_SUCCESS);
    } else {
        _completeCallback(nil, PHOTO_EDIT_RESULT_CODE_GENERATE_FAIL);
    }
}

- (BOOL)saveImageAsJPEG:(UIImage *)image filePath:(NSString *)filePath {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    BOOL success = [imageData writeToFile:filePath atomically:YES];
    if (!success) {
        NSLog(@"Failed to save image as JPEG file. filePath is %@", filePath);
    }
    return success;
}


-(NSString*) getOutFilePath{
    NSDate* currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString* currentDateString = [dateFormatter stringFromDate:currentDate];
    NSString* outFileName = [NSString stringWithFormat:@"%@-%u-temp.jpg", currentDateString, arc4random()];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:outFileName];
}

- (void)onCommonEditorControlViewNeedAddPaster:(TUIMultimediaCommonEditorControlView *)view {
    _ctrlView.modifyButtonsHidden = YES;
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
    [_ctrlView addPaster:image];
    _ctrlView.modifyButtonsHidden = NO;
    [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
- (void)onPasterSelectControllerExit:(TUIMultimediaPasterSelectController *)c {
    _ctrlView.modifyButtonsHidden = NO;
    [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
