//
//  TUIChatPopMenu.m
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//

#import "TUIChatPopMenu.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#define maxColumns 4    // 一排最多放 4 个
#define kContainerInsets UIEdgeInsetsMake(3, 0, 3, 0)
#define kActionWidth 54
#define kActionHeight 65
#define kActionMargin 5
#define kSepartorHeight 0.5
#define kSepartorLRMargin 10
#define kArrowSize CGSizeMake(15, 10)

@implementation TUIChatPopMenuAction

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image callback:(TUIChatPopMenuActionCallback)callback
{
    if (self = [super init]) {
        self.title = title;
        self.image = image;
        self.callback = callback;
    }
    return self;
}

@end


@interface TUIChatPopMenu () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *containerView;
 
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, assign) CGPoint arrawPoint;

@property (nonatomic, assign) CGFloat adjustHeight;

@property (nonatomic, strong) NSMutableDictionary *actionCallback;

@property (nonatomic, strong) CAShapeLayer *arrowLayer;

@end

@implementation TUIChatPopMenu

- (void)addAction:(TUIChatPopMenuAction *)action
{
    if (action) {
        [self.actions addObject:action];
    }
}

- (void)removeAllAction {
    [self.actions removeAllObjects];
}

- (void)setArrawPosition:(CGPoint)point adjustHeight:(CGFloat)adjustHeight
{
    point = CGPointMake(point.x, point.y - NavBar_Height);
    self.arrawPoint = point;
    self.adjustHeight = adjustHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tap.delegate = self;
        pan.delegate = self;
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:pan];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(hide) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];

    }
    return self;
}

- (void)onTap:(UIGestureRecognizer *)tap
{
    [self hide];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)hide
{
    if (self.hideCallback) {
        self.hideCallback();
    }
    [self removeFromSuperview];
}

- (void)showInView:(UIView *)window
{
    if (window == nil) {
        window = UIApplication.sharedApplication.keyWindow;
    }

    self.frame = window.bounds;
    [window addSubview:self];
    
    // 绘制子视图
    [self layoutSubview];
}

- (void)layoutSubview {
    [self prepareContainerView];
    [self setupContainerPosition];
}

- (void)setupContainerPosition
{
    // 计算坐标，并修正，默认箭头朝下
    CGFloat minTopBottomMargin = 100;
    CGFloat minLeftRightMargin = 50;
    CGFloat containerW = self.containerView.bounds.size.width;
    CGFloat containerH = self.containerView.bounds.size.height;
    CGFloat upContainerY = self.arrawPoint.y + self.adjustHeight + kArrowSize.height;   // 如果箭头朝上，containerY
    
    // 默认箭头朝下
    CGFloat containerX = self.arrawPoint.x - 0.5 * containerW;
    CGFloat containerY = self.arrawPoint.y - kArrowSize.height - containerH - NavBar_Height;
    BOOL top = NO;     // 箭头朝下
    CGFloat arrawX = 0.5 * containerW;
    CGFloat arrawY = kArrowSize.height + containerH;
    
    // 修正纵向
    if (containerY < minTopBottomMargin) {
        // 此时 container 太靠上了，计划将箭头调整为朝上
        if (upContainerY + containerH + minTopBottomMargin > self.superview.bounds.size.height) {
            // 朝上也不行，超出了屏幕 ==> 保持箭头朝下，移动 self.arrawPoint
            top = NO;
            self.arrawPoint = CGPointMake(self.arrawPoint.x, self.arrawPoint.y + minTopBottomMargin - containerY);
            containerY = self.arrawPoint.y - kArrowSize.height - containerH;
            
        } else {
            // 箭头可以朝上
            top = YES;
            self.arrawPoint = CGPointMake(self.arrawPoint.x, self.arrawPoint.y + self.adjustHeight - NavBar_Height - 5);
            arrawY = - kArrowSize.height;
            containerY = self.arrawPoint.y + kArrowSize.height;
        }
    }
    
    // 修正横向
    if (containerX < minLeftRightMargin) {
        // 此时 container 太靠左了，需要往右靠
        CGFloat offset = (minLeftRightMargin - containerX);
        arrawX = arrawX - offset;
        containerX = containerX + offset;
        if (arrawX < 20) {
            arrawX = 20;
        }
        
    } else if (containerX + containerW + minLeftRightMargin > self.bounds.size.width) {
        // 此时container 太靠右了，需要往左靠
        CGFloat offset = containerX + containerW + minLeftRightMargin - self.bounds.size.width;
        arrawX = arrawX + offset;
        containerX = containerX - offset;
        if (arrawX > containerW - 20) {
            arrawX = containerW - 20;
        }
    }

    self.containerView.frame = CGRectMake(containerX, containerY, containerW, containerH);
    
    // 绘制 箭头
    self.arrowLayer = [[CAShapeLayer alloc] init];
    self.arrowLayer.path = [self arrawPath:CGPointMake(arrawX, arrawY) directionTop:top].CGPath;
    self.arrowLayer.fillColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF").CGColor;
    [self.containerView.layer addSublayer:self.arrowLayer];
}

- (void)prepareContainerView
{
    if (self.containerView) {
        [self.containerView removeFromSuperview];
        self.containerView = nil;
    }
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowRadius = 5;
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.cornerRadius = 5;
    [self addSubview:self.containerView];
    
    int i = 0;
    for (TUIChatPopMenuAction *action in self.actions) {
        UIButton *actionButton = [self buttonWithAction:action tag:[self.actions indexOfObject:action]];
        [self.containerView addSubview:actionButton];
        i++;
        if (i == maxColumns && i < self.actions.count ) {
            UIView *separtorView = [[UIView alloc] init];
            separtorView.backgroundColor =  TUICoreDynamicColor(@"separator_color", @"#39393B");
            [self.containerView addSubview:separtorView];
            i = 0;
        }
    }
    
    // 计算当前 container 的宽高
    int rows = (self.actions.count % maxColumns == 0) ? (int)self.actions.count / maxColumns : (int)(self.actions.count / maxColumns) + 1;
    int columns = self.actions.count < maxColumns ? (int)self.actions.count : maxColumns;
    CGFloat width = kActionWidth * columns + kActionMargin * (columns + 1) + kContainerInsets.left + kContainerInsets.right;
    CGFloat height = kActionHeight * rows + (rows - 1) * kSepartorHeight + kContainerInsets.top + kContainerInsets.bottom;
    self.containerView.bounds = CGRectMake(0, 0, width, height);
    
    // 更新子视图的布局
    [self updateLayout];
}

- (void)updateLayout
{
    int columns = self.actions.count < maxColumns ? (int)self.actions.count : maxColumns;
    CGFloat containerWidth = kActionWidth * columns + kActionMargin * (columns + 1) + kContainerInsets.left + kContainerInsets.right;
    
    int i = 0;
    int currentRow = 0;
    int currentColumn = 0;
    for (UIView *subView in self.containerView.subviews) {
        if ([subView isKindOfClass:UIButton.class]) {
            currentRow = i / maxColumns;
            currentColumn = i % maxColumns;
            
            CGFloat x = kContainerInsets.left + (currentColumn + 1) * kActionMargin + currentColumn * kActionWidth;
            CGFloat y = kContainerInsets.top + currentRow * kActionHeight + currentRow * kSepartorHeight;
            subView.frame = CGRectMake(x, y, kActionWidth, kActionHeight);
            
            i++;
        } else {
            // 分割线
            CGFloat y = (currentRow + 1) * kActionHeight + kContainerInsets.top;
            CGFloat width = containerWidth - 2 * kSepartorLRMargin - kContainerInsets.left - kContainerInsets.right;
            subView.frame = CGRectMake(kSepartorLRMargin, y, width, kSepartorHeight);
        }
    }
}

- (UIBezierPath *)arrawPath:(CGPoint)point directionTop:(BOOL)top
{
    CGSize arrowSize = kArrowSize;
    UIBezierPath *arrowPath = [[UIBezierPath alloc] init];
    [arrowPath moveToPoint:point];
    if (top) {
        // 上箭头
        [arrowPath addLineToPoint:CGPointMake(point.x + arrowSize.width * 0.5, point.y + arrowSize.height)];
        [arrowPath addLineToPoint:CGPointMake(point.x - arrowSize.width * 0.5, point.y + arrowSize.height)];
    } else {
        // 下箭头
        [arrowPath addLineToPoint:CGPointMake(point.x + arrowSize.width * 0.5, point.y - arrowSize.height)];
        [arrowPath addLineToPoint:CGPointMake(point.x - arrowSize.width * 0.5, point.y - arrowSize.height)];
    }
    [arrowPath closePath];
    return arrowPath;
}

- (UIButton *)buttonWithAction:(TUIChatPopMenuAction *)action tag:(NSInteger)tag
{
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionButton setTitleColor:
     TUIChatDynamicColor(@"chat_pop_menu_text_color", @"#444444") forState:UIControlStateNormal];
    actionButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [actionButton setTitle:action.title forState:UIControlStateNormal];
    [actionButton setImage:action.image forState:UIControlStateNormal];
    actionButton.contentMode = UIViewContentModeScaleAspectFit;
    [actionButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    actionButton.tag = tag;
    
    CGSize imageSize = CGSizeMake(20, 20);
    CGSize titleSize = actionButton.titleLabel.frame.size;
    CGSize textSize = [actionButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:actionButton.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + 8);
    actionButton.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    actionButton.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
    
    [self.actionCallback setObject:action.callback forKey:@(tag)];
    
    return actionButton;
}

- (void)onClick:(UIButton *)button
{
    if (![self.actionCallback.allKeys containsObject:@(button.tag)]) {
        [self hide];
        return;
    }
    
    TUIChatPopMenuActionCallback callback = [self.actionCallback objectForKey:@(button.tag)];
    if (callback) {
        callback();
    }
    [self hide];
}

- (NSMutableArray *)actions
{
    if (_actions == nil) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}

- (NSMutableDictionary *)actionCallback
{
    if (_actionCallback == nil) {
        _actionCallback = [NSMutableDictionary dictionary];
    }
    return _actionCallback;
}

//MARK: ThemeChanged
- (void)applyBorderTheme {
    if (_arrowLayer) {
        _arrowLayer.fillColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF").CGColor;
    }
}

- (void)onThemeChanged {
    [self applyBorderTheme];
}


@end
