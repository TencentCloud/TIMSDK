// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaDrawCtrlView.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaColorPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaSplitter.h"
#import "TUIMultimediaPlugin/TUIMultimediaImageUtil.h"
#import "TUIMultimediaPlugin/TUIMultimediaDrawView.h"
#import "TUIMultimediaPlugin/TUIMultimediaSticker.h"

#define FunctionButtonColorNormal TUIMultimediaPluginDynamicColor(@"editor_func_btn_normal_color", @"#FFFFFF")
#define FunctionButtonColorDisabled TUIMultimediaPluginDynamicColor(@"editor_func_btn_disabled_color", @"#6D6D6D")

@interface TUIMultimediaDrawCtrlView () <TUIMultimediaColorPanelDelegate, TUIMultimediaDrawViewDelegate> {
    TUIMultimediaColorPanel *_colorPanel;
    UIButton *_btnRedo;
    UIButton *_btnUndo;
    TUIMultimediaSplitter *_vertical_splitter;
}
@end

@implementation TUIMultimediaDrawCtrlView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initCtrlView];
        [self initDrawView];
    }
    return self;
}

- (void)initCtrlView {
    self.backgroundColor = TUIMultimediaPluginDynamicColor(@"editor_draw_panel_bg_color", @"#3333337F");
    
    _colorPanel = [[TUIMultimediaColorPanel alloc] init];
    _colorPanel.delegate = self;
    [self addSubview:_colorPanel];
    
    UIImage *imgUndo = TUIMultimediaPluginBundleThemeImage(@"editor_undo_img", @"undo");
    _btnUndo = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_btnUndo];
    _btnUndo.enabled = NO;
    [_btnUndo addTarget:self action:@selector(onBtnUndoClicked) forControlEvents:UIControlEventTouchUpInside];
    [_btnUndo setImage:[TUIMultimediaImageUtil imageFromImage:imgUndo withTintColor:FunctionButtonColorNormal] forState:UIControlStateNormal];
    [_btnUndo setImage:[TUIMultimediaImageUtil imageFromImage:imgUndo withTintColor:FunctionButtonColorDisabled] forState:UIControlStateDisabled];
    
    UIImage *imgRedo = TUIMultimediaPluginBundleThemeImage(@"editor_redo_img", @"redo");
    _btnRedo = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_btnRedo];
    _btnRedo.enabled = NO;
    [_btnRedo addTarget:self action:@selector(onBtnRedoClicked) forControlEvents:UIControlEventTouchUpInside];
    [_btnRedo setImage:[TUIMultimediaImageUtil imageFromImage:imgRedo withTintColor:FunctionButtonColorNormal] forState:UIControlStateNormal];
    [_btnRedo setImage:[TUIMultimediaImageUtil imageFromImage:imgRedo withTintColor:FunctionButtonColorDisabled] forState:UIControlStateDisabled];
    
    TUIMultimediaSplitter * horizontal_splitter = [[TUIMultimediaSplitter alloc] init];
    [self addSubview:horizontal_splitter];
    horizontal_splitter.axis = UILayoutConstraintAxisHorizontal;
    
     _vertical_splitter = [[TUIMultimediaSplitter alloc] init];
    [self addSubview:_vertical_splitter];
    _vertical_splitter.axis = UILayoutConstraintAxisVertical;
    
    [_btnRedo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).inset(5);
        make.centerY.equalTo(_colorPanel);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_btnUndo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_colorPanel);
        make.right.equalTo(_btnRedo.mas_left).inset(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_colorPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).inset(5);
        make.right.equalTo(_btnUndo.mas_left).inset(10);
        make.height.mas_equalTo(32);
    }];
    [horizontal_splitter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(3);
        make.top.equalTo(_colorPanel.mas_bottom).inset(5);
        make.height.mas_equalTo(5);
    }];
    [_vertical_splitter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).inset(3);
        make.bottom.equalTo(horizontal_splitter.mas_top).inset(3);
        make.left.equalTo(_colorPanel.mas_right).inset(3);
        make.width.mas_equalTo(5);
    }];
}

- (void)initDrawView {
    _drawView = [[TUIMultimediaDrawView alloc] init];
    _drawView.userInteractionEnabled = NO;
    UITapGestureRecognizer *drawTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapDrawView:)];
    [_drawView addGestureRecognizer:drawTapRec];
    _drawView.delegate = self;
}

- (void) setDrawEnable:(BOOL)drawEnable {
    _drawView.userInteractionEnabled = drawEnable;
    self.hidden = !drawEnable;
}

- (void) setDrawMode:(enum DrawMode)drawMode {
    _drawMode = drawMode;
    _drawView.drawMode = drawMode;
    [self updateUIAccordingToDrawMode];
    [self flushRedoUndoState];
}

- (TUIMultimediaSticker *)drawSticker {
    if (_drawView != nil && _drawView.pathCount > 0) {
        TUIMultimediaSticker *drawSticker = [[TUIMultimediaSticker alloc] init];
        drawSticker.image = [TUIMultimediaImageUtil imageFromView:_drawView];
        drawSticker.frame = _drawView.frame;
        return drawSticker;
    }
    return nil;
}

- (void)onTapDrawView:(UITapGestureRecognizer *)rec {
    self.hidden = !self.hidden;
    [self.delegate onIsDrawCtrlViewDrawing:self.hidden];
}

- (void)flushRedoUndoState {
    _btnUndo.enabled = _drawView.canUndo;
    _btnRedo.enabled = _drawView.canRedo;
}

-(void)clearAllDraw {
    [_drawView clear];
}

-(void) updateUIAccordingToDrawMode{
    if (_drawMode == GRAFFITI) {
        _colorPanel.hidden = NO;
        _vertical_splitter.hidden = NO;
        
        [_btnRedo mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).inset(5);
            make.centerY.equalTo(_colorPanel);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        [_btnUndo mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_colorPanel);
            make.right.equalTo(_btnRedo.mas_left).inset(20);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
    } else {
        _colorPanel.hidden = YES;
        _vertical_splitter.hidden = YES;
        
        [_btnUndo mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_colorPanel);
            make.centerX.equalTo(self.mas_trailing).multipliedBy(0.25);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        [_btnRedo mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_colorPanel);
            make.centerX.equalTo(self.mas_trailing).multipliedBy(0.75);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
}

#pragma mark - TUIMultimediaColorPanelDelegate protocol
- (void)onColorPanel:(TUIMultimediaColorPanel *)panel selectColor:(UIColor *)color {
    _drawView.color = color;
}

- (void)onBtnUndoClicked {
    [_drawView undo];
    [self flushRedoUndoState];
}

- (void)onBtnRedoClicked {
    [_drawView redo];
    [self flushRedoUndoState];
}

#pragma mark - TUIMultimediaDrawViewDelegate
- (void)drawViewPathListChanged:(TUIMultimediaDrawView *)v {
    [self flushRedoUndoState];
}

- (void)drawViewDrawStarted:(TUIMultimediaDrawView *)v {
    [self.delegate onIsDrawCtrlViewDrawing:YES];
    self.hidden = YES;
}

- (void)drawViewDrawEnded:(TUIMultimediaDrawView *)v {
    [self.delegate onIsDrawCtrlViewDrawing:NO];
    self.hidden = NO;
}

@end
