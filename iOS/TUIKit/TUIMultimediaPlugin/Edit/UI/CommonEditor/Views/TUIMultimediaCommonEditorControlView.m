// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaCommonEditorControlView.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCircleProgressView.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaDrawView.h"
#import "TUIMultimediaPlugin/TUIMultimediaImageUtil.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterSelectView.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterView.h"
#import "TUIMultimediaPlugin/TUIMultimediaSplitter.h"
#import "TUIMultimediaPlugin/TUIMultimediaStickerView.h"
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleView.h"
#import "TUIMultimediaPlugin/TUIMultimediaTabPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaConstant.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"
#import "TUIMultimediaPlugin/TUIMultimediaCropControlView.h"
#import "TUIMultimediaPlugin/TUIMultimediaDrawCtrlView.h"

#define FUNCTION_BUTTON_SIZE CGSizeMake(28, 28)
#define BUTTON_SEND_SIZE CGSizeMake(60, 28)

@interface TUIMultimediaCommonEditorControlView () <TUIMultimediaStickerViewDelegate, UIGestureRecognizerDelegate, TUIMultimediaDrawCtrlViewDelegate, TUIMultimediaCropControlDelegate> {
    TUIMultimediaCommonEditorConfig *_config;
    UIStackView *_stkViewButtons;
    UIButton *_btnDrawGraffiti;
    UIButton *_btnDrawMosaic;
    UIButton *_btnMusic;
    UIButton *_btnSubtitle;
    UIButton *_btnPaster;
    UIButton *_btnCrop;
    UIButton *_btnSend;
    UIButton *_btnCancel;
    
    NSMutableArray<TUIMultimediaStickerView *> *_stickerViewList;
    TUIMultimediaStickerView *_lastSelectedStickerView;
    UIView *_editContainerView;
    
    TUIMultimediaDrawView *_drawView;
    TUIMultimediaDrawCtrlView *_drawCtrlView;
    
    UIView *_generateView;
    TUIMultimediaCircleProgressView *_progressView;
    UIButton *_btnGenerateCancel;
    
    BOOL _isStartCrop;
    NSInteger _previewRotationAngle;
    TUIMultimediaCropControlView* _cropControlView;
}

@end

@implementation TUIMultimediaCommonEditorControlView
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithConfig:[[TUIMultimediaCommonEditorConfig alloc] init]];
}
- (instancetype)initWithConfig:(TUIMultimediaCommonEditorConfig *)config {
    self = [super initWithFrame:CGRectZero];
    if (self != nil) {
        _config = config;
        _sourceType = SOURCE_TYPE_RECORD;
        _isStartCrop = NO;
        _stickerViewList = [NSMutableArray array];
        [self initUI];
    }
    return self;
}

- (void)addPaster:(UIImage *)paster {
    TUIMultimediaPasterView *vpaster = [[TUIMultimediaPasterView alloc] init];
    vpaster.delegate = self;
    [_stickerViewList addObject:vpaster];
    vpaster.paster = paster;
    vpaster.center = CGPointMake(_editContainerView.bounds.size.width / 2, _editContainerView.bounds.size.height / 2);
    [_editContainerView addSubview:vpaster];
}

- (void)addSubtitle:(TUIMultimediaSubtitleInfo *)subtitle {
    TUIMultimediaSubtitleView *vsub = [[TUIMultimediaSubtitleView alloc] init];
    vsub.delegate = self;
    [_stickerViewList addObject:vsub];
    vsub.subtitleInfo = subtitle;
    vsub.center = CGPointMake(_editContainerView.bounds.size.width / 2, _editContainerView.bounds.size.height / 2);
    [_editContainerView addSubview:vsub];
}

#pragma mark crop function
- (void)previewScale:(CGFloat) scale center:(CGPoint)center {
    if (_isStartCrop) {
        return;
    }
    
    CGFloat width = _previewView.frame.size.width * scale;
    CGFloat height = _previewView.frame.size.height * scale;
    
    CGFloat left = center.x - (center.x - _previewView.frame.origin.x) * scale;
    CGFloat top = center.y - (center.y - _previewView.frame.origin.y) * scale;
    _previewView.frame = CGRectMake(left, top, width, height);
    
    for (UIView *subview in _editContainerView.subviews) {
        if ([subview isKindOfClass:[TUIMultimediaStickerView class]]) {
            TUIMultimediaStickerView* stickView = (TUIMultimediaStickerView*)subview;
            [stickView scale:scale];
        }
    }
    
    if (_cropControlView != nil) {
        [_cropControlView changeResetButtonStatus];
    }
}

- (void)previewMove:(CGPoint)offset {
    if (_isStartCrop) {
        return;
    }
    _previewView.frame = CGRectMake(_previewView.frame.origin.x + offset.x,
                                    _previewView.frame.origin.y + offset.y,
                                    _previewView.frame.size.width,
                                    _previewView.frame.size.height);
    if (_cropControlView != nil) {
        [_cropControlView changeResetButtonStatus];
    }
}


- (void)previewRotation90:(CGPoint)center {
    _previewRotationAngle = (_previewRotationAngle + 90 + 360) % 360;
    float radians = _previewRotationAngle * M_PI / 180;
    int newTop = center.y - center.x + _previewView.frame.origin.x;
    int newLeft = center.x + center.y - _previewView.frame.origin.y - _previewView.frame.size.height;
    
    _editContainerView.transform = CGAffineTransformMakeRotation(radians);
    _previewView.transform = CGAffineTransformMakeRotation(radians);
    _previewView.frame = CGRectMake(newLeft, newTop, _previewView.frame.size.width, _previewView.frame.size.height);
    
    if (_cropControlView != nil) {
        [_cropControlView changeResetButtonStatus];
    }
}

- (void)previewRotationToZero {
    _previewRotationAngle = 0;
    _editContainerView.transform = CGAffineTransformMakeRotation(0);
    _previewView.transform = CGAffineTransformMakeRotation(0);
}

- (void)previewAdjustToLimitRect {
    NSLog(@"preview adjust to limit rect");
    double scaleLimitX = _previewLimitRect.size.width * 1.0f / _previewView.frame.size.width;
    double scaleLimitY = _previewLimitRect.size.height * 1.0f / _previewView.frame.size.height;
    double scaleLimit = MAX(scaleLimitX, scaleLimitY);
    if (scaleLimit > 1.0f) {
        [self previewScale:scaleLimit center:CGPointMake(CGRectGetMidX(_previewView.frame), CGRectGetMidY(_previewView.frame))];
    }
    
    
    int maxLeft = _previewLimitRect.origin.x;
    int minLeft = _previewLimitRect.size.width + _previewLimitRect.origin.x - _previewView.frame.size.width;
    int left = MAX(MIN(_previewView.frame.origin.x , maxLeft), minLeft);
    int maxTop = _previewLimitRect.origin.y;
    int minTop = _previewLimitRect.size.height + _previewLimitRect.origin.y - _previewView.frame.size.height;
    int top = MAX(MIN(_previewView.frame.origin.y , maxTop), minTop);
    _previewView.frame = CGRectMake(left, top, _previewView.frame.size.width, _previewView.frame.size.height);
}

#pragma mark UI init
- (void)initUI {
    self.backgroundColor = UIColor.blackColor;
    
    _previewView = [[UIView alloc] init];
    [self addSubview:_previewView];
    
    [self initFuncitonBtnStackView];
    [self initGraffitiFunction];
    [self initMosaicFunction];
    [self initPasterFunciton];
    [self initSubtitleFunciton];
    [self initBGMFunction];
    [self initCropFunciton];
    [self initSendAndCancelBtn];
    [self initGenerateView];
    [self bringSubviewToFront:_stkViewButtons];
}

- (void) initFuncitonBtnStackView {
    _stkViewButtons = [[UIStackView alloc] init];
    _stkViewButtons.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_stkViewButtons];
    _stkViewButtons.axis = UILayoutConstraintAxisHorizontal;
    _stkViewButtons.alignment = UIStackViewAlignmentCenter;
    _stkViewButtons.distribution = UIStackViewDistributionEqualSpacing;
    [_stkViewButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(10);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(FUNCTION_BUTTON_SIZE.height);
    }];
}

- (void) initGraffitiFunction {
    if (!_config.drawGraffitiEnabled) {
        return;
    }
    
    _btnDrawGraffiti = [self addFunctionIconButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_scrawl_img", @"modify_scrawl")
                                    onTouchUpInside:@selector(onBtnDrawGraffitiClicked)];
    
    [self initEditContainerView];
    [self initDrawCtrlView];
}

- (void) initMosaicFunction {
    if (!_config.drawMosaicEnabled) {
        return;
    }
    
    _btnDrawMosaic = [self addFunctionIconButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"edit_mosaic_img", @"edit_mosaic")
                                    onTouchUpInside:@selector(onBtnDrawMosaicClicked)];
    
    [self initEditContainerView];
    [self initDrawCtrlView];
    _drawCtrlView.drawView.mosaciOriginalImage = _mosaciOriginalImage;
}

- (void) initPasterFunciton {
    if (!_config.pasterEnabled) {
        return;
    }
    _btnPaster = [self addFunctionIconButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_paster_img", @"modify_paster")
                                      onTouchUpInside:@selector(onBtnPasterClicked)];
    [self initEditContainerView];
}

- (void) initSubtitleFunciton {
    if (!_config.subtitleEnabled) {
        return;
    }
    _btnSubtitle = [self addFunctionIconButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_subtitle_img", @"modify_subtitle")
                                        onTouchUpInside:@selector(onBtnSubtitleClicked)];
    [self initEditContainerView];
}

- (void) initBGMFunction {
    if (!_config.musicEditEnabled) {
        return;
    }
    
    _btnMusic = [self addFunctionIconButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_music_img", @"modify_music")
                                     onTouchUpInside:@selector(onBtnMusicClicked)];
}

- (void) initCropFunciton {
    if (!_config.cropEnabled) {
        return;
    }
    
    _btnCrop = [self addFunctionIconButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_crop_img", @"modify_crop")
                                    onTouchUpInside:@selector(onBtnCropClicked)];
    [self initCropCtrlView];
}

- (void)initCropCtrlView {
    if (_cropControlView != nil) {
        return;
    }
    
    _cropControlView = [[TUIMultimediaCropControlView alloc] initWithFrame:self.frame editorControl:self];
    [self addSubview:_cropControlView];
    _cropControlView.hidden = YES;
    [_cropControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _cropControlView.delegate = self;
}

- (void)initDrawCtrlView {
    if (_drawCtrlView != nil) {
        return;
    }
    
    _drawCtrlView = [[TUIMultimediaDrawCtrlView alloc] init];
    [self addSubview:_drawCtrlView];
    [_drawCtrlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_stkViewButtons).offset(-50);
        make.bottom.equalTo(self);
    }];
    _drawCtrlView.drawEnable = NO;
    _drawCtrlView.delegate = self;
    
    [_editContainerView addSubview:_drawCtrlView.drawView];
    [_drawCtrlView.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_previewView);
    }];
}

- (void) initEditContainerView {
    if (_editContainerView != nil) {
        return;
    }
    
    _editContainerView = [[UIView alloc] init];
    [self addSubview:_editContainerView];
    _editContainerView.userInteractionEnabled = YES;
    _editContainerView.clipsToBounds = YES;
    
    UITapGestureRecognizer *containerTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapContainerView:)];
    containerTapRec.cancelsTouchesInView = NO;
    [_editContainerView addGestureRecognizer:containerTapRec];
    [_editContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_previewView);
    }];
}

- (void) initSendAndCancelBtn {
    _btnSend = [UIButton buttonWithType:UIButtonTypeSystem];
    
    if (_stkViewButtons.arrangedSubviews.count == 0) {
        [_stkViewButtons removeFromSuperview];
        [self addSubview:_btnSend];
        [_btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(BUTTON_SEND_SIZE);
            make.right.equalTo(self).inset(20);
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        }];
    } else {
        [_stkViewButtons addArrangedSubview:_btnSend];
        [_btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(BUTTON_SEND_SIZE);
        }];
    }
    
    _btnSend.backgroundColor = [[TUIMultimediaConfig sharedInstance] getThemeColor];
    [_btnSend setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnSend.layer.cornerRadius = 5;
    NSString* titile = [TUIMultimediaCommon localizedStringForKey:@"send"];
    if (_sourceType == SOURCE_TYPE_ALBUM) {
        titile = [TUIMultimediaCommon localizedStringForKey:@"done"];
    }
    [_btnSend setTitle:titile forState:UIControlStateNormal];
    [_btnSend addTarget:self action:@selector(onBtnSendClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_btnCancel];
    [_btnCancel setImage:TUIMultimediaPluginBundleThemeImage(@"editor_cancel_img", @"return_arrow") forState:UIControlStateNormal];
    [_btnCancel addTarget:self action:@selector(onBtnCancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).inset(10);
        if([[TUIGlobalization getPreferredLanguage] hasPrefix:@"ar"]) {
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-15);
        } else {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(15);
        }
    }];
}

- (void)setSourceType:(int)sourceType {
    NSLog(@"setSourceType sourceType = %d",sourceType);
    _sourceType = sourceType;
    NSString* titile = [TUIMultimediaCommon localizedStringForKey:@"send"];
    if (_sourceType == SOURCE_TYPE_ALBUM) {
        titile = [TUIMultimediaCommon localizedStringForKey:@"done"];
    }
    [_btnSend setTitle:titile forState:UIControlStateNormal];
}

- (void)initGenerateView {
    _generateView = [[UIView alloc] init];
    _generateView.backgroundColor = TUIMultimediaPluginDynamicColor(@"editor_generate_view_bg_color", @"#0000007F");
    _generateView.hidden = YES;
    [self addSubview:_generateView];
    
    _progressView = [[TUIMultimediaCircleProgressView alloc] init];
    _progressView.progressColor = [[TUIMultimediaConfig sharedInstance] getThemeColor];
    [_generateView addSubview:_progressView];
    
    _btnGenerateCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnGenerateCancel addTarget:self action:@selector(onBtnGenerateCancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [_btnGenerateCancel setTitle:[TUIMultimediaCommon localizedStringForKey:@"cancel"] forState:UIControlStateNormal];
    [_btnGenerateCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_generateView addSubview:_btnGenerateCancel];
    
    [_generateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.center.equalTo(_generateView);
    }];
    [_btnGenerateCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).inset(10);
        make.left.equalTo(self).inset(10);
        make.size.mas_equalTo(CGSizeMake(54, 32));
    }];
}

- (UIButton *)addFunctionIconButtonWithImage:(UIImage *)img onTouchUpInside:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_stkViewButtons addArrangedSubview:btn];
    UIImage *imgNormal = [TUIMultimediaImageUtil imageFromImage:img withTintColor:
                          TUIMultimediaPluginDynamicColor(@"editor_func_btn_normal_color", @"#FFFFFF")];
    UIImage *imgDisabled = [TUIMultimediaImageUtil imageFromImage:img withTintColor:
                            TUIMultimediaPluginDynamicColor(@"editor_func_btn_disabled_color", @"#6D6D6D")];
    UIImage *imgPressed = [TUIMultimediaImageUtil imageFromImage:img withTintColor:
                           TUIMultimediaPluginDynamicColor(@"editor_func_btn_pressed_color", @"#7F7F7F")];
    UIImage *imgSelected = [TUIMultimediaImageUtil imageFromImage:img withTintColor:
                            [[TUIMultimediaConfig sharedInstance] getThemeColor]];
    [btn setImage:imgNormal forState:UIControlStateNormal];
    [btn setImage:imgDisabled forState:UIControlStateDisabled];
    [btn setImage:imgPressed forState:UIControlStateHighlighted];
    [btn setImage:imgSelected forState:UIControlStateSelected];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(FUNCTION_BUTTON_SIZE);
    }];
    return btn;
}

#pragma mark Internal Functions
- (void)setDrawEnabled:(BOOL)drawGraffitiEnabled {
    if (!_config.drawGraffitiEnabled) {
        return;
    }
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
    _btnDrawGraffiti.selected = drawGraffitiEnabled;
    if(drawGraffitiEnabled) {
        _btnDrawMosaic.selected = NO;
    }
    _drawCtrlView.drawMode = GRAFFITI;
    _drawCtrlView.drawEnable = drawGraffitiEnabled;
    for (TUIMultimediaStickerView *v in _stickerViewList) {
        v.userInteractionEnabled = !drawGraffitiEnabled;
    }
}

- (void)setDrawMosaicEnabled:(BOOL)drawMosaicEnabled {
    if (!_config.drawMosaicEnabled) {
        return;
    }
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
    _btnDrawMosaic.selected = drawMosaicEnabled;
    if(drawMosaicEnabled) {
        _btnDrawGraffiti.selected = NO;
    }
    _drawCtrlView.drawMode = MOSAIC;
    _drawCtrlView.drawEnable = drawMosaicEnabled;
    for (TUIMultimediaStickerView *v in _stickerViewList) {
        v.userInteractionEnabled = !drawMosaicEnabled;
    }
}

- (NSArray<TUIMultimediaSticker *> *)getStickers {
    NSArray<TUIMultimediaSticker *> *stickers = [_stickerViewList tui_multimedia_map:^TUIMultimediaSticker *(TUIMultimediaStickerView *v) {
        [v resignFirstResponder];
        TUIMultimediaSticker *sticker = [[TUIMultimediaSticker alloc] init];
        sticker.image = [TUIMultimediaImageUtil imageFromView:v withRotate:v.rotation];
        sticker.frame = v.frame;
        return sticker;
    }];
    
    TUIMultimediaSticker *drawSticker = _drawCtrlView != nil ? _drawCtrlView.drawSticker : nil;
    if (drawSticker != nil) {
        stickers = [NSArray tui_multimedia_arrayWithArray:stickers append:@[ drawSticker ]];
    }
    return  stickers;
}

- (void) clearAllStaticker {
    if (_drawCtrlView != nil) {
        [_drawCtrlView clearAllDraw];
    }
    
    for (TUIMultimediaStickerView *v in _stickerViewList) {
        [v removeFromSuperview];
    }
    [_stickerViewList removeAllObjects];
}

#pragma mark - UIGestureRecognizer actions
- (void)onTapContainerView:(UITapGestureRecognizer *)rec {
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}

#pragma mark - Actions
- (void)onBtnSendClicked {
    [self setDrawEnabled:NO];
    [self setDrawMosaicEnabled:NO];
    [_delegate onCommonEditorControlViewComplete:self stickers:[self getStickers]];
}

- (void)onBtnCancelClicked {
    [_delegate onCommonEditorControlViewCancel:self];
}

- (void)onBtnSubtitleClicked {
    [_delegate onCommonEditorControlViewNeedModifySubtitle:[[TUIMultimediaSubtitleInfo alloc] init]
                                                  callback:^(TUIMultimediaSubtitleInfo *subtitle, BOOL isOk) {
        if (isOk) {
            [self addSubtitle:subtitle];
        }
    }];
    [self setDrawEnabled:NO];
    [self setDrawMosaicEnabled:NO];
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}
- (void)onBtnPasterClicked {
    [_delegate onCommonEditorControlViewNeedAddPaster:self];
    [self setDrawEnabled:NO];
    [self setDrawMosaicEnabled:NO];
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}

- (void)onBtnDrawGraffitiClicked {
    [self setDrawEnabled:!_btnDrawGraffiti.selected];
    _drawCtrlView.drawMode = GRAFFITI;
}

- (void)onBtnDrawMosaicClicked {
    [self setDrawMosaicEnabled:!_btnDrawMosaic.selected];
    _drawCtrlView.drawMode = MOSAIC;
}

- (void)onBtnMusicClicked {
    [self setDrawEnabled:NO];
    [self setDrawMosaicEnabled:NO];
    [_delegate onCommonEditorControlViewNeedEditMusic:self];
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}

- (void)onBtnCropClicked {
    [self setDrawEnabled:NO];
    [self setDrawMosaicEnabled:NO];
    [_cropControlView show];
    _drawCtrlView.drawEnable = NO;
    _stkViewButtons.hidden = YES;
    _btnCancel.hidden = YES;
}

- (void)onBtnGenerateCancelClicked {
    [_delegate onCommonEditorControlViewCancelGenerate:self];
    self.isGenerating = false;
    _progressView.progress = 0;
}

#pragma mark - Properties
- (BOOL)modifyButtonsHidden {
    return _stkViewButtons.hidden;
}

- (void)setModifyButtonsHidden:(BOOL)modifyButtonsHidden {
    _stkViewButtons.hidden = modifyButtonsHidden;
}

- (void)setPreviewSize:(CGSize)previewSize {
    _previewSize = previewSize;
    if (previewSize.width == 0 || previewSize.height == 0) {
        return;
    }
    
    int width = self.frame.size.width;
    int height = previewSize.height / previewSize.width * width;
    _previewView.frame = CGRectMake(0,0, width, height);
    _previewView.center = self.center;
    _previewLimitRect = _previewView.frame;
}

- (BOOL)isGenerating {
    return !_generateView.hidden;
}

- (void)setIsGenerating:(BOOL)isGenerating {
    _generateView.hidden = !isGenerating;
    _stkViewButtons.hidden = isGenerating;
    _btnCancel.hidden = isGenerating;
}

- (CGFloat)progressBarProgress {
    return _progressView.progress;
}

- (void)setProgressBarProgress:(CGFloat)progressBarProgress {
    [_progressView setProgress:progressBarProgress animated:YES];
}

- (BOOL)musicEdited {
    return _btnMusic != nil ? _btnMusic.selected : FALSE;
}

- (void)setMusicEdited:(BOOL)musicEdited {
    if (_btnMusic != nil) {
        _btnMusic.selected = musicEdited;
    }
}

-(void)setMosaciOriginalImage:(UIImage *)mosaciOriginalImage {
    _mosaciOriginalImage = mosaciOriginalImage;
    if (_drawCtrlView) {
        _drawCtrlView.drawView.mosaciOriginalImage = mosaciOriginalImage;
    }
}

#pragma mark - TUIMultimediaCropControlDelegate protocol

- (void)onCancelCrop {
    [self previewRotationToZero];
    self.previewSize =  _previewSize;
    _stkViewButtons.hidden = NO;
    _btnCancel.hidden = NO;
}

- (void)onConfirmCrop:(CGRect)cropRect {
    CGFloat cropX = (cropRect.origin.x - _previewView.frame.origin.x) / _previewView.frame.size.width;
    CGFloat cropY = (cropRect.origin.y - _previewView.frame.origin.y) / _previewView.frame.size.height;
    CGFloat cropWidth = cropRect.size.width / _previewView.frame.size.width;
    CGFloat cropHeight = cropRect.size.height / _previewView.frame.size.height;
    CGRect normalizedCropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight);
    
    CGFloat rotationAngle = _previewRotationAngle;
    if ((_previewRotationAngle + 360) % 360 != 0) {
        _previewView.hidden = YES;
    }
    [self previewRotationToZero];
    
    [_delegate onCommonEditorControlViewCrop:rotationAngle normalizedCropRect:normalizedCropRect stickers:[self getStickers]];
    _stkViewButtons.hidden = NO;
    _btnCancel.hidden = NO;
    [self clearAllStaticker];
}

#pragma mark - TUIMultimediaStickerViewDelegate protocol
- (void)onStickerViewSelected:(TUIMultimediaStickerView *)v {
    [_editContainerView bringSubviewToFront:v];
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = v;
}

- (void)onStickerViewShouldDelete:(TUIMultimediaStickerView *)v {
    [v removeFromSuperview];
    [_stickerViewList removeObject:v];
}

- (void)onStickerViewShouldEdit:(TUIMultimediaStickerView *)v {
    if ([v isKindOfClass:TUIMultimediaSubtitleView.class]) {
        TUIMultimediaSubtitleView *vsub = (TUIMultimediaSubtitleView *)v;
        vsub.hidden = YES;
        TUIMultimediaSubtitleInfo *info = vsub.subtitleInfo;
        [_delegate onCommonEditorControlViewNeedModifySubtitle:info
                                                      callback:^(TUIMultimediaSubtitleInfo *newInfo, BOOL isOk) {
            if (isOk) {
                vsub.subtitleInfo = newInfo;
            }
            vsub.hidden = NO;
        }];
    }
}

- (void)onStickerViewSizeChanged:(TUIMultimediaStickerView *)v {
}

#pragma mark -  TUIMultimediaDrawCtrlViewDelegate
- (void)onIsDrawCtrlViewDrawing:(BOOL)Hidden {
    _stkViewButtons.hidden = Hidden;
}
@end

#pragma mark -  TUIMultimediaCommonEditorConfig
@implementation TUIMultimediaCommonEditorConfig
+ (instancetype)configForVideoEditor {
    TUIMultimediaCommonEditorConfig *config = [[TUIMultimediaCommonEditorConfig alloc] init];
    config.pasterEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditPaster];
    config.subtitleEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditSubtitle];
    config.drawGraffitiEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditGraffiti];
    config.musicEditEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditBGM];
    config.cropEnabled = NO;
    config.drawMosaicEnabled = NO;
    return config;
}
+ (instancetype)configForPictureEditor {
    TUIMultimediaCommonEditorConfig *config = [[TUIMultimediaCommonEditorConfig alloc] init];
    config.pasterEnabled = [[TUIMultimediaConfig sharedInstance] isSupportPictureEditPaster];
    config.subtitleEnabled = [[TUIMultimediaConfig sharedInstance] isSupportPictureEditSubtitle];
    config.drawGraffitiEnabled = [[TUIMultimediaConfig sharedInstance] isSupportPictureEditGraffiti];
    config.drawMosaicEnabled = [[TUIMultimediaConfig sharedInstance] isSupportPictureEditMosaic];
    config.cropEnabled = [[TUIMultimediaConfig sharedInstance] isSupportPictureEditCrop];
    config.musicEditEnabled = NO;
    return config;
}
@end
