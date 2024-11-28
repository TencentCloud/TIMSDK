// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaCommonEditorControlView.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCircleProgressView.h"
#import "TUIMultimediaPlugin/TUIMultimediaColorPanel.h"
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

#define FunctionButtonSize CGSizeMake(28, 28)
#define FunctionButtonImageEdgeInsets UIEdgeInsetsMake(0, 0, 0, 0)
#define FunctionButtonColorNormal TUIMultimediaPluginDynamicColor(@"editor_func_btn_normal_color", @"#FFFFFF")
#define FunctionButtonColorDisabled TUIMultimediaPluginDynamicColor(@"editor_func_btn_disabled_color", @"#4D4D4D")
#define FunctionButtonColorPressed TUIMultimediaPluginDynamicColor(@"editor_func_btn_pressed_color", @"#7F7F7F")
#define FunctionButtonColorSelected [[TUIMultimediaConfig sharedInstance] getThemeColor]

#define BtnSendSize CGSizeMake(60, 28)

@interface TUIMultimediaCommonEditorControlView () <TUIMultimediaStickerViewDelegate, UIGestureRecognizerDelegate, TUIMultimediaDrawViewDelegate, TUIMultimediaColorPanelDelegate> {
    TUIMultimediaCommonEditorConfig *_config;
    UIStackView *_stkViewButtons;
    UIButton *_btnDraw;
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
    TUIMultimediaColorPanel *_colorPanel;
    UIButton *_btnRedo;
    UIButton *_btnUndo;
    UIView *_drawCtrlView;
    
    UIView *_generateView;
    TUIMultimediaCircleProgressView *_progressView;
    UIButton *_btnGenerateCancel;
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

#pragma mark UI init
- (void)initUI {
    self.backgroundColor = UIColor.blackColor;
    
    _previewView = [[UIView alloc] init];
    [self addSubview:_previewView];
    
    [self initFuncitonBtnStackView];
    [self initGraffitiFunction];
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
        make.height.mas_equalTo(FunctionButtonSize.height);
    }];
}

- (void) initGraffitiFunction {
    if (!_config.drawEnabled) {
        return;
    }
    
    _btnDraw = [self addFunctionIconButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"editor_scrawl_img", @"modify_scrawl")
                                    onTouchUpInside:@selector(onBtnDrawClicked)];
    
    [self initEditContainerView];
    
    _drawView = [[TUIMultimediaDrawView alloc] init];
    [_editContainerView addSubview:_drawView];
    _drawView.delegate = self;
    _drawView.userInteractionEnabled = NO;
    [_drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_previewView);
    }];
    UITapGestureRecognizer *drawTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapDrawView:)];
    [_drawView addGestureRecognizer:drawTapRec];
    [self initDrawCtrlView];
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
}

- (void)initDrawCtrlView {
    _drawCtrlView = [[UIView alloc] init];
    [self addSubview:_drawCtrlView];
    _drawCtrlView.backgroundColor = TUIMultimediaPluginDynamicColor(@"editor_draw_panel_bg_color", @"#3333337F");
    _drawCtrlView.hidden = YES;
    
    _colorPanel = [[TUIMultimediaColorPanel alloc] init];
    _colorPanel.delegate = self;
    [_drawCtrlView addSubview:_colorPanel];
    
    UIImage *imgUndo = TUIMultimediaPluginBundleThemeImage(@"editor_undo_img", @"undo");
    UIImage *imgRedo = TUIMultimediaPluginBundleThemeImage(@"editor_redo_img", @"redo");
    _btnUndo = [UIButton buttonWithType:UIButtonTypeCustom];
    [_drawCtrlView addSubview:_btnUndo];
    _btnUndo.enabled = NO;
    [_btnUndo addTarget:self action:@selector(onBtnUndoClicked) forControlEvents:UIControlEventTouchUpInside];
    [_btnUndo setImage:[TUIMultimediaImageUtil imageFromImage:imgUndo withTintColor:FunctionButtonColorNormal] forState:UIControlStateNormal];
    [_btnUndo setImage:[TUIMultimediaImageUtil imageFromImage:imgUndo withTintColor:FunctionButtonColorDisabled] forState:UIControlStateDisabled];
    _btnRedo = [UIButton buttonWithType:UIButtonTypeCustom];
    [_drawCtrlView addSubview:_btnRedo];
    _btnRedo.enabled = NO;
    [_btnRedo addTarget:self action:@selector(onBtnRedoClicked) forControlEvents:UIControlEventTouchUpInside];
    [_btnRedo setImage:[TUIMultimediaImageUtil imageFromImage:imgRedo withTintColor:FunctionButtonColorNormal] forState:UIControlStateNormal];
    [_btnRedo setImage:[TUIMultimediaImageUtil imageFromImage:imgRedo withTintColor:FunctionButtonColorDisabled] forState:UIControlStateDisabled];
    
    TUIMultimediaSplitter *sph = [[TUIMultimediaSplitter alloc] init];
    [_drawCtrlView addSubview:sph];
    sph.axis = UILayoutConstraintAxisHorizontal;
    TUIMultimediaSplitter *spv = [[TUIMultimediaSplitter alloc] init];
    [_drawCtrlView addSubview:spv];
    spv.axis = UILayoutConstraintAxisVertical;
    
    [_drawCtrlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_stkViewButtons).offset(-50);
        make.bottom.equalTo(self);
    }];
    [_btnRedo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_drawCtrlView).inset(5);
        make.centerY.equalTo(_colorPanel);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_btnUndo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_colorPanel);
        make.right.equalTo(_btnRedo.mas_left).inset(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_colorPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_drawCtrlView).inset(5);
        make.right.equalTo(_btnUndo.mas_left).inset(10);
        make.height.mas_equalTo(32);
    }];
    [sph mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_drawCtrlView).inset(3);
        make.top.equalTo(_colorPanel.mas_bottom).inset(5);
        make.height.mas_equalTo(5);
    }];
    [spv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_drawCtrlView).inset(3);
        make.bottom.equalTo(sph.mas_top).inset(3);
        make.left.equalTo(_colorPanel.mas_right).inset(3);
        make.width.mas_equalTo(5);
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
            make.size.mas_equalTo(BtnSendSize);
            make.right.equalTo(self).inset(20);
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        }];
    } else {
        [_stkViewButtons addArrangedSubview:_btnSend];
        [_btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(BtnSendSize);
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
    UIImage *imgNormal = [TUIMultimediaImageUtil imageFromImage:img withTintColor:FunctionButtonColorNormal];
    UIImage *imgDisabled = [TUIMultimediaImageUtil imageFromImage:img withTintColor:FunctionButtonColorDisabled];
    UIImage *imgPressed = [TUIMultimediaImageUtil imageFromImage:img withTintColor:FunctionButtonColorPressed];
    UIImage *imgSelected = [TUIMultimediaImageUtil imageFromImage:img withTintColor:FunctionButtonColorSelected];
    [btn setImage:imgNormal forState:UIControlStateNormal];
    [btn setImage:imgDisabled forState:UIControlStateDisabled];
    [btn setImage:imgPressed forState:UIControlStateHighlighted];
    [btn setImage:imgSelected forState:UIControlStateSelected];
    [btn setImageEdgeInsets:FunctionButtonImageEdgeInsets];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(FunctionButtonSize);
    }];
    return btn;
}

#pragma mark Internal Functions
- (void)flushRedoUndoState {
    if (_drawView != nil) {
        _btnUndo.enabled = _drawView.canUndo;
        _btnRedo.enabled = _drawView.canRedo;
    }
}

- (void)setDrawEnabled:(BOOL)drawEnabled {
    if (!_config.drawEnabled) {
        return;
    }
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
    _btnDraw.selected = drawEnabled;
    _drawView.userInteractionEnabled = drawEnabled;
    _drawCtrlView.hidden = !drawEnabled;
    for (TUIMultimediaStickerView *v in _stickerViewList) {
        v.userInteractionEnabled = !drawEnabled;
    }
}

#pragma mark - UIGestureRecognizer actions
- (void)onTapContainerView:(UITapGestureRecognizer *)rec {
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}

- (void)onTapDrawView:(UITapGestureRecognizer *)rec {
    if (_drawCtrlView.hidden) {
        _drawCtrlView.hidden = NO;
        _stkViewButtons.hidden = NO;
    } else {
        _drawCtrlView.hidden = YES;
        _stkViewButtons.hidden = YES;
    }
}

#pragma mark - Actions
- (void)onBtnSendClicked {
    [self setDrawEnabled:NO];
    // 贴纸和字幕
    NSArray<TUIMultimediaSticker *> *stickers = [_stickerViewList tui_multimedia_map:^TUIMultimediaSticker *(TUIMultimediaStickerView *v) {
        [v resignFirstResponder];
        TUIMultimediaSticker *sticker = [[TUIMultimediaSticker alloc] init];
        sticker.image = [TUIMultimediaImageUtil imageFromView:v withRotate:v.rotation];
        sticker.frame = v.frame;
        return sticker;
    }];
    
    // 涂鸦
    if (_drawView != nil && _drawView.pathList.count > 0) {
        TUIMultimediaSticker *drawSticker = [[TUIMultimediaSticker alloc] init];
        drawSticker.image = [TUIMultimediaImageUtil imageFromView:_drawView];
        drawSticker.frame = _drawView.frame;
        stickers = [NSArray tui_multimedia_arrayWithArray:stickers append:@[ drawSticker ]];
    }
    
    [_delegate onCommonEditorControlViewComplete:self stickers:stickers];
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
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}
- (void)onBtnPasterClicked {
    [_delegate onCommonEditorControlViewNeedAddPaster:self];
    [self setDrawEnabled:NO];
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}
- (void)onBtnDrawClicked {
    [self setDrawEnabled:!_btnDraw.selected];
}

- (void)onBtnMusicClicked {
    [self setDrawEnabled:NO];
    [_delegate onCommonEditorControlViewNeedEditMusic:self];
    _lastSelectedStickerView.selected = NO;
    _lastSelectedStickerView = nil;
}

- (void)onBtnCropClicked {
    [self setDrawEnabled:NO];
    // TODO:crop
}

- (void)onBtnUndoClicked {
    [_drawView undo];
    [self flushRedoUndoState];
}

- (void)onBtnRedoClicked {
    [_drawView redo];
    [self flushRedoUndoState];
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
    [_previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(_previewView.mas_width).multipliedBy(previewSize.height / previewSize.width);
    }];
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

#pragma mark - TUIMultimediaDrawViewDelegate
- (void)drawViewPathListChanged:(TUIMultimediaDrawView *)v {
    [self flushRedoUndoState];
}
- (void)drawViewDrawStarted:(TUIMultimediaDrawView *)v {
    _stkViewButtons.hidden = YES;
    _drawCtrlView.hidden = YES;
}
- (void)drawViewDrawEnded:(TUIMultimediaDrawView *)v {
    _stkViewButtons.hidden = NO;
    _drawCtrlView.hidden = NO;
}
#pragma mark - TUIMultimediaColorPanelDelegate protocol
- (void)onColorPanel:(TUIMultimediaColorPanel *)panel selectColor:(UIColor *)color {
    _drawView.color = color;
}
@end

@implementation TUIMultimediaCommonEditorConfig
+ (instancetype)configForVideoEditor {
    TUIMultimediaCommonEditorConfig *config = [[TUIMultimediaCommonEditorConfig alloc] init];
    config.pasterEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditPaster];
    config.subtitleEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditSubtitle];
    config.drawEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditGraffiti];
    config.musicEditEnabled = [[TUIMultimediaConfig sharedInstance] isSupportVideoEditBGM];
    config.cropEnabled = NO;
    return config;
}
+ (instancetype)configForPhotoEditor {
    TUIMultimediaCommonEditorConfig *config = [[TUIMultimediaCommonEditorConfig alloc] init];
    config.pasterEnabled = NO;
    config.subtitleEnabled = NO;
    config.drawEnabled = NO;
    config.musicEditEnabled = NO;
    config.cropEnabled = NO;
    return config;
}
@end
