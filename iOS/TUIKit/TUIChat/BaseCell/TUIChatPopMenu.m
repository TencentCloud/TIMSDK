//
//  TUIChatPopMenu.m
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatPopMenu.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatPopActionsView.h"
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>
#import <TUICore/TUICore.h>
#import "TUIFaceView.h"

#define maxColumns 5
#define kContainerInsets UIEdgeInsetsMake(3, 0, 3, 0)
#define kActionWidth 54
#define kActionHeight 65
#define kActionMargin 5
#define kSepartorHeight 0.5
#define kSepartorLRMargin 10
#define kArrowSize CGSizeMake(15, 10)
#define kEmojiHeight 44

@implementation TUIChatPopMenuAction

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image weight:(NSInteger)weight callback:(TUIChatPopMenuActionCallback)callback {
    if (self = [super init]) {
        self.title = title;
        self.image = image;
        self.weight = weight;
        self.callback = callback;
    }
    return self;
}

@end

@interface TUIChatPopMenu () <UIGestureRecognizerDelegate,V2TIMAdvancedMsgListener>

/**
 * emojiRecent view and emoji secondary page view
 */
@property(nonatomic, strong) UIView *emojiContainerView;

@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) NSMutableArray *actions;

@property(nonatomic, assign) CGPoint arrawPoint;

@property(nonatomic, assign) CGFloat adjustHeight;

@property(nonatomic, strong) NSMutableDictionary *actionCallback;

@property(nonatomic, strong) CAShapeLayer *arrowLayer;

@property(nonatomic, assign) CGFloat emojiHeight;

@property(nonatomic, strong) TUIChatPopActionsView *actionsView;

@property(nonatomic, assign) BOOL hasEmojiView;

@end

@implementation TUIChatPopMenu

- (void)addAction:(TUIChatPopMenuAction *)action {
    if (action) {
        [self.actions addObject:action];
    }
}

- (void)removeAllAction {
    [self.actions removeAllObjects];
}

- (void)setArrawPosition:(CGPoint)point adjustHeight:(CGFloat)adjustHeight {
    point = CGPointMake(point.x, point.y - NavBar_Height);
    self.arrawPoint = point;
    self.adjustHeight = adjustHeight;
}

- (instancetype)initWithEmojiView:(BOOL)hasEmojiView frame:(CGRect)frame {
    self.hasEmojiView = hasEmojiView;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tap.delegate = self;
        pan.delegate = self;
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:pan];
        if ([self isAddEmojiView]) {
            self.emojiHeight = kEmojiHeight;
        }

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(hideWithAnimation) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
        [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
    }
    return self;
}

- (BOOL)isAddEmojiView {
    return self.hasEmojiView && [TUIChatConfig defaultConfig].enablePopMenuEmojiReactAction;
}

- (void)onTap:(UIGestureRecognizer *)tap {
    [self hideWithAnimation];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.emojiContainerView]) {
        return NO;
    }
    if ([touch.view isDescendantOfView:self.containerView]) {
        return NO;
    }
    return YES;
}

- (void)hideWithAnimation {
    [UIView animateWithDuration:0.3
        animations:^{
          self.alpha = 0;
        }
        completion:^(BOOL finished) {
          if (finished) {
              if (self.hideCallback) {
                  self.hideCallback();
              }
              [self removeFromSuperview];
          }
        }];
}

- (void)hideByClickButton:(UIButton *)button callback:(void (^__nullable)(void))callback {
    [UIView animateWithDuration:0.3
        animations:^{
          self.alpha = 0;
        }
        completion:^(BOOL finished) {
          if (finished) {
              if (callback) {
                  callback();
              }
              if (self.hideCallback) {
                  self.hideCallback();
              }
              [self removeFromSuperview];
          }
        }];
}
- (void)showInView:(UIView *)window {
    if (window == nil) {
        window = UIApplication.sharedApplication.keyWindow;
    }

    self.frame = window.bounds;
    [window addSubview:self];

    [self layoutSubview];
}

- (void)layoutSubview {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;

    [self updateActionByRank];

    if ([self isAddEmojiView]) {
        [self prepareEmojiView];
    }

    [self prepareContainerView];

    if ([self isAddEmojiView]) {
        [self setupEmojiSubView];
    }

    [self setupContainerPosition];

    [self updateLayout];
    
    if (isRTL()) {
        [self fitRTLViews];
    }
    
}
- (void)fitRTLViews {    
    if (self.actionsView) {
        for (UIView *subview in self.actionsView.subviews) {
            if ([subview respondsToSelector:@selector(resetFrameToFitRTL)]) {
                [subview resetFrameToFitRTL];
            }
        }
    }
}
- (void)updateActionByRank {
    NSArray *ageSortResultArray = [self.actions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      TUIChatPopMenuAction *per1 = obj1;
      TUIChatPopMenuAction *per2 = obj2;
      return per1.weight > per2.weight ? NSOrderedAscending : NSOrderedDescending;
    }];
    NSMutableArray *filterArray = [NSMutableArray arrayWithArray:ageSortResultArray];

    self.actions = [NSMutableArray arrayWithArray:ageSortResultArray];
}
- (void)setupContainerPosition {
    /**
     * Calculate the coordinates and correct them, the default arrow points down
     */
    CGFloat minTopBottomMargin = (Is_IPhoneX ? (100) : (0.0));
    CGFloat minLeftRightMargin = 50;
    CGFloat containerW = self.containerView.bounds.size.width;
    CGFloat containerH = self.containerView.bounds.size.height;
    CGFloat upContainerY = self.arrawPoint.y + self.adjustHeight + kArrowSize.height;  // The containerY value when arrow points up

    /**
     * The default arrow points down
     */
    CGFloat containerX = self.arrawPoint.x - 0.5 * containerW;
    CGFloat containerY = self.arrawPoint.y - kArrowSize.height - containerH - StatusBar_Height - self.emojiHeight;
    BOOL top = NO;  // The direction of arrow, here is down
    CGFloat arrawX = 0.5 * containerW;
    CGFloat arrawY = kArrowSize.height + containerH - 1.5;

    /**
     * Corrected vertical coordinates
     */
    if (containerY < minTopBottomMargin) {
        /**
         * At this time, the container is too high, and it is planned to adjust the direction of the arrow to upward.
         */
        if (upContainerY + containerH + minTopBottomMargin > self.superview.bounds.size.height) {
            /**
             * After adjusting the upward arrow direction, it will cause the entire container to exceed the screen. At this time, the adjustment strategy is
             * changed to: keep the arrow direction downward and move self.arrawPoint
             */
            top = NO;
            self.arrawPoint = CGPointMake(self.arrawPoint.x, self.arrawPoint.y - containerY);
            containerY = self.arrawPoint.y - kArrowSize.height - containerH;

        } else {
            /**
             * Adjust the direction of the arrow to meet the requirements
             */
            top = YES;
            self.arrawPoint = CGPointMake(self.arrawPoint.x, self.arrawPoint.y + self.adjustHeight - StatusBar_Height - 5);
            arrawY = -kArrowSize.height;
            containerY = self.arrawPoint.y + kArrowSize.height;
        }
    }

    /**
     * 
     * Corrected horizontal coordinates
     */
    if (containerX < minLeftRightMargin) {
        /**
         * At this time, the container is too close to the left side of the screen and needs to move to the right
         */
        CGFloat offset = (minLeftRightMargin - containerX);
        arrawX = arrawX - offset;
        containerX = containerX + offset;
        if (arrawX < 20) {
            arrawX = 20;
        }

    } else if (containerX + containerW + minLeftRightMargin > self.bounds.size.width) {
        /**
         * At this time, the container is too close to the right side of the screen and needs to be moved to the left
         */
        CGFloat offset = containerX + containerW + minLeftRightMargin - self.bounds.size.width;
        arrawX = arrawX + offset;
        containerX = containerX - offset;
        if (arrawX > containerW - 20) {
            arrawX = containerW - 20;
        }
    }

    self.emojiContainerView.frame = CGRectMake(containerX, containerY, containerW, MAX(self.emojiHeight + containerH, 200));
    self.containerView.frame = CGRectMake(containerX, containerY + self.emojiHeight, containerW, containerH);

    /**
     * Drawing arrow
     */
    self.arrowLayer = [[CAShapeLayer alloc] init];
    self.arrowLayer.path = [self arrawPath:CGPointMake(arrawX, arrawY) directionTop:top].CGPath;
    self.arrowLayer.fillColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF").CGColor;
    if (top) {
        if (self.emojiContainerView) {
            [self.emojiContainerView.layer addSublayer:self.arrowLayer];
        } else {
            [self.containerView.layer addSublayer:self.arrowLayer];
        }
    } else {
        [self.containerView.layer addSublayer:self.arrowLayer];
    }
}

- (void)prepareEmojiView {
    if (self.emojiContainerView) {
        [self.emojiContainerView removeFromSuperview];
        self.emojiContainerView = nil;
    }

    self.emojiContainerView = [[UIView alloc] init];
    [self addSubview:self.emojiContainerView];
}
- (void)prepareContainerView {
    if (self.containerView) {
        [self.containerView removeFromSuperview];
        self.containerView = nil;
    }
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];

    self.actionsView = [[TUIChatPopActionsView alloc] init];
    self.actionsView.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
    [self.containerView addSubview:self.actionsView];

    int i = 0;
    for (TUIChatPopMenuAction *action in self.actions) {
        UIButton *actionButton = [self buttonWithAction:action tag:[self.actions indexOfObject:action]];
        [self.actionsView addSubview:actionButton];
        i++;
        if (i == maxColumns && i < self.actions.count) {
            UIView *separtorView = [[UIView alloc] init];
            separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#39393B");
            separtorView.hidden = YES;
            [self.actionsView addSubview:separtorView];
            i = 0;
        }
    }

    /**
     * Calculating the size of container
     */
    int rows = (self.actions.count % maxColumns == 0) ? (int)self.actions.count / maxColumns : (int)(self.actions.count / maxColumns) + 1;
    int columns = self.actions.count < maxColumns ? (int)self.actions.count : maxColumns;
    if ([self isAddEmojiView]) {
        columns = maxColumns;
    }
    CGFloat width = kActionWidth * columns + kActionMargin * (columns + 1) + kContainerInsets.left + kContainerInsets.right;
    CGFloat height = kActionHeight * rows + (rows - 1) * kSepartorHeight + kContainerInsets.top + kContainerInsets.bottom;

    self.emojiContainerView.frame = CGRectMake(0, 0, width, self.emojiHeight + height);
    self.containerView.frame = CGRectMake(0, self.emojiHeight, width, height);
}

- (void)setupEmojiSubView {
    [self setupEmojiRecentView];
    [self setupEmojiAdvanceView];
}
- (void)setupEmojiRecentView {
    NSDictionary *param = @{TUICore_TUIChatExtension_ChatPopMenuReactRecentView_Delegate : self};
    BOOL isRaiseEmojiExtensionSuccess = [TUICore raiseExtension:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_ClassicExtensionID
                                                     parentView:self.emojiContainerView
                                                          param:param];
    if (!isRaiseEmojiExtensionSuccess) {
        self.emojiHeight = 0;
    }
}
- (void)setupEmojiAdvanceView {
    NSDictionary *param = @{TUICore_TUIChatExtension_ChatPopMenuReactRecentView_Delegate : self};
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatPopMenuReactDetailView_ClassicExtensionID parentView:self.emojiContainerView param:param];
}

- (void)updateLayout {
    
    self.actionsView.frame = CGRectMake(0, -0.5, self.containerView.frame.size.width, self.containerView.frame.size.height);

    int columns = self.actions.count < maxColumns ? (int)self.actions.count : maxColumns;
    CGFloat containerWidth = kActionWidth * columns + kActionMargin * (columns + 1) + kContainerInsets.left + kContainerInsets.right;

    int i = 0;
    int currentRow = 0;
    int currentColumn = 0;
    for (UIView *subView in self.actionsView.subviews) {
        if ([subView isKindOfClass:UIButton.class]) {
            currentRow = i / maxColumns;
            currentColumn = i % maxColumns;

            CGFloat x = kContainerInsets.left + (currentColumn + 1) * kActionMargin + currentColumn * kActionWidth;
            CGFloat y = kContainerInsets.top + currentRow * kActionHeight + currentRow * kSepartorHeight;
            subView.frame = CGRectMake(x, y, kActionWidth, kActionHeight);

            i++;
        } else {
            CGFloat y = (currentRow + 1) * kActionHeight + kContainerInsets.top;
            CGFloat width = containerWidth - 2 * kSepartorLRMargin - kContainerInsets.left - kContainerInsets.right;
            subView.frame = CGRectMake(kSepartorLRMargin, y, width, kSepartorHeight);
        }
    }
}

- (UIBezierPath *)arrawPath:(CGPoint)point directionTop:(BOOL)top {
    CGSize arrowSize = kArrowSize;
    UIBezierPath *arrowPath = [[UIBezierPath alloc] init];
    [arrowPath moveToPoint:point];
    if (top) {
        [arrowPath addLineToPoint:CGPointMake(point.x + arrowSize.width * 0.5, point.y + arrowSize.height)];
        [arrowPath addLineToPoint:CGPointMake(point.x - arrowSize.width * 0.5, point.y + arrowSize.height)];
    } else {
        [arrowPath addLineToPoint:CGPointMake(point.x + arrowSize.width * 0.5, point.y - arrowSize.height)];
        [arrowPath addLineToPoint:CGPointMake(point.x - arrowSize.width * 0.5, point.y - arrowSize.height)];
    }
    [arrowPath closePath];
    return arrowPath;
}

- (UIButton *)buttonWithAction:(TUIChatPopMenuAction *)action tag:(NSInteger)tag {
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionButton setTitleColor:TUIChatDynamicColor(@"chat_pop_menu_text_color", @"#444444")
                       forState:UIControlStateNormal];
    actionButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
    actionButton.titleLabel.numberOfLines = 2;
    actionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [actionButton setTitle:action.title forState:UIControlStateNormal];
    [actionButton setImage:action.image forState:UIControlStateNormal];
    actionButton.contentMode = UIViewContentModeScaleAspectFit;

    [actionButton addTarget:self action:@selector(buttonHighlightedEnter:) forControlEvents:UIControlEventTouchDown];
    [actionButton addTarget:self action:@selector(buttonHighlightedEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [actionButton addTarget:self action:@selector(buttonHighlightedExit:) forControlEvents:UIControlEventTouchDragExit];
    [actionButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];

    actionButton.tag = tag;

    CGSize imageSize = CGSizeMake(20, 20);
    CGSize titleSize = actionButton.titleLabel.frame.size;
    CGSize textSize = [actionButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : actionButton.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    titleSize.width = MIN(titleSize.width, 48);
    CGFloat totalHeight = (imageSize.height + titleSize.height + 8);
    actionButton.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), 0.0, 0.0, -titleSize.width);
    actionButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(totalHeight - titleSize.height), 0);

    [self.actionCallback setObject:action.callback forKey:@(tag)];

    return actionButton;
}

- (void)buttonHighlightedEnter:(UIButton *)sender {
    sender.backgroundColor = TUIChatDynamicColor(@"", @"#006EFF19");
}
- (void)buttonHighlightedExit:(UIButton *)sender {
    sender.backgroundColor = [UIColor clearColor];
}
- (void)onClick:(UIButton *)button {
    if (![self.actionCallback.allKeys containsObject:@(button.tag)]) {
        [self hideWithAnimation];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self hideByClickButton:button
                   callback:^() {
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                     TUIChatPopMenuActionCallback callback = [strongSelf.actionCallback objectForKey:@(button.tag)];
                     if (callback) {
                         callback();
                     }
                   }];
}

- (NSMutableArray *)actions {
    if (_actions == nil) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}

- (NSMutableDictionary *)actionCallback {
    if (_actionCallback == nil) {
        _actionCallback = [NSMutableDictionary dictionary];
    }
    return _actionCallback;
}

// MARK: V2TIMAdvancedMsgListener
- (void)onRecvMessageRevoked:(NSString *)msgID operateUser:(V2TIMUserFullInfo *)operateUser reason:(NSString *)reason {
    if ([msgID isEqualToString:self.targetCellData.msgID]) {
        [self hideWithAnimation];
    }
}

// MARK: ThemeChanged
- (void)applyBorderTheme {
    if (_arrowLayer) {
        _arrowLayer.fillColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF").CGColor;
    }
}

- (void)onThemeChanged {
    [self applyBorderTheme];
}
@end
