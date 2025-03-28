// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaCropControlView.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaImageUtil.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"

#import "TUIMultimediaCropView.h"
#import "TUIMultimediaCommonEditorControlView.h"

@interface TUIMultimediaCropControlView()<TUIMultimediaCropDelegate> {
    TUIMultimediaCommonEditorControlView* _editorControl;
    TUIMultimediaCropView *_cropView;
    UIButton* _restoreButton;
    UIButton* _rotationButton;
    UIButton* _confirmButton;
    UIButton* _cancelButton;
}
@end

@implementation TUIMultimediaCropControlView
- (instancetype)initWithFrame:(CGRect)frame editorControl:(TUIMultimediaCommonEditorControlView*)editorControl{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _editorControl = editorControl;
        [self initUI];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
#pragma mark -  UI init

- (void)initUI {
    _cropView = [[TUIMultimediaCropView alloc] initWithFrame:self.frame];
    [self addSubview:_cropView];
    [_cropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self);
    }];
    _cropView.delegate = self;
    
    _restoreButton = [self addFuncitonButtonWithText:[TUIMultimediaCommon localizedStringForKey:@"restore"]
                                              action:@selector(onResetBtnClicked) bottomOffset:-75 leftOffset:7.5 rightOffset:0 size:CGSizeMake(80, 22)];
    _cancelButton = [self addFunctionButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_crop_cancel", @"crop_cancel")
                                              action:@selector(onCancelBtnClicked) bottomOffset:-25 leftOffset:35 rightOffset:0 size:CGSizeMake(25, 25)];
    _confirmButton = [self addFunctionButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_crop_confirm", @"crop_ok")
                                              action:@selector(onConfirmBtnClicked) bottomOffset:-25 leftOffset:0 rightOffset:-32.5 size:CGSizeMake(30, 28)];
    _rotationButton = [self addFunctionButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_crop_rotation", @"crop_rotation")
                                              action:@selector(onRotationBtnClicked) bottomOffset:-75 leftOffset:0 rightOffset:-35 size:CGSizeMake(25, 25)];
    
    _restoreButton.enabled = NO;
}

-(void)show {
    self.hidden = NO;
    _cropView.preViewFrame = _editorControl.previewView.frame;
    [_cropView reset];
    _restoreButton.enabled = NO;
}

- (void)changeResetButtonStatus {
    _restoreButton.enabled = ![self isApproximateSize:[_cropView getCropRect].size size2:_editorControl.previewView.frame.size];
}

-(void)onResetBtnClicked {
    [_editorControl previewRotationToZero];
    _cropView.preViewFrame = _editorControl.previewView.frame;
    [_cropView reset];
    _restoreButton.enabled = NO;
}

-(void)onRotationBtnClicked {
    CGRect cropRect = [_cropView getCropRect];
    CGPoint rotationCenter = CGPointMake(CGRectGetMidX(cropRect), CGRectGetMidY(cropRect));
    [_editorControl previewRotation90:rotationCenter];
    [_cropView rotation90];
    _restoreButton.enabled = YES;
}

-(void)onCancelBtnClicked {
    self.hidden = YES;
    if (_delegate != nil) {
        [_delegate onCancelCrop];
    }
}

-(void)onConfirmBtnClicked {
    self.hidden = YES;
    if (_delegate != nil) {
        if (_restoreButton.isEnabled) {
            [_delegate onConfirmCrop:[_cropView getCropRect]];
        } else {
            [_delegate onCancelCrop];
        }
    }
}

-(UIButton*) addFuncitonButtonWithText:(NSString*)text action:(SEL)actionSel bottomOffset:(int)bottomOffset
                            leftOffset:(int)leftOffset rightOffset:(int)rightOffset size:(CGSize)size {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:button];
    button.backgroundColor = [UIColor clearColor];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        if (leftOffset > 0) {
            make.leading.equalTo(self).offset(leftOffset);
        }
        
        if (rightOffset < 0) {
            make.trailing.equalTo(self).offset(rightOffset);
        }
        
        make.bottom.equalTo(self).offset(bottomOffset);
        make.size.mas_equalTo(size);
    }];
    [button addTarget:self action:actionSel forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor]  forState:UIControlStateDisabled];
    return button;
}

- (UIButton *)addFunctionButtonWithImage:(UIImage *)image action:(SEL)actionSel bottomOffset:(int)bottomOffset
                              leftOffset:(int)leftOffset rightOffset:(int)rightOffset size:(CGSize)size{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:button];
    UIImage *imgNormal = [TUIMultimediaImageUtil imageFromImage:image withTintColor:
                          TUIMultimediaPluginDynamicColor(@"editor_func_btn_normal_color", @"#FFFFFF")];
    [button setImage:imgNormal forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [button addTarget:self action:actionSel forControlEvents:UIControlEventTouchUpInside];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        if (leftOffset > 0) {
            make.leading.equalTo(self).offset(leftOffset);
        }
        
        if (rightOffset < 0) {
            make.trailing.equalTo(self).offset(rightOffset);
        }
        
        make.bottom.equalTo(self).offset(bottomOffset);
        make.size.mas_equalTo(size);
    }];
    return button;
}


-(BOOL)isApproximateSize:(CGSize)size1 size2:(CGSize)size2 {
    return ABS(size1.width - size1.width ) < 1 && ABS(size1.height - size2.height) < 1;
}

#pragma mark -  TUIMultimediaCropViewDelegate
- (void)onStartCrop {
    _editorControl.isStartCrop = YES;
    _restoreButton.enabled = YES;
}

- (void)onCropComplete:(CGFloat)scale centerPoint:(CGPoint)centerPoint offset:(CGPoint)offset {
    _editorControl.isStartCrop = NO;
    _editorControl.previewLimitRect = [_cropView getCropRect];
    [_editorControl previewScale:scale center:centerPoint];
    [_editorControl previewMove:offset];
}

@end
