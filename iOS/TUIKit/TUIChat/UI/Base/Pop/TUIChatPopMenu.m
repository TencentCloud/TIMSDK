//
//  TUIChatPopMenu.m
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//

#import "TUIChatPopMenu.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#import "TUIChatPopEmojiView.h"
#import "TUIChatPopRecentView.h"
#import "TUIChatPopActionsView.h"
#define maxColumns 5    // 一排最多放 5 个
#define kContainerInsets UIEdgeInsetsMake(3, 0, 3, 0)
#define kActionWidth 54
#define kActionHeight 65
#define kActionMargin 5
#define kSepartorHeight 0.5
#define kSepartorLRMargin 10
#define kArrowSize CGSizeMake(15, 10)
#define kEmojiHeight 44

@implementation TUIChatPopMenuAction

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                         rank:(NSInteger)rank
                     callback:(TUIChatPopMenuActionCallback)callback {
    if (self = [super init]) {
        self.title = title;
        self.image = image;
        self.rank = rank;
        self.callback = callback;
    }
    return self;
}


@end


@interface TUIChatPopMenu () <UIGestureRecognizerDelegate,TFaceViewDelegate,TUIChatPopRecentEmojiDelegate>

@property (nonatomic, strong) UIView *emojiContainerView; //emojiRecent视图和emoji二级页视图

@property (nonatomic, strong) UIView *containerView;
 
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, assign) CGPoint arrawPoint;

@property (nonatomic, assign) CGFloat adjustHeight;

@property (nonatomic, strong) NSMutableDictionary *actionCallback;

@property (nonatomic, strong) CAShapeLayer *arrowLayer;

@property (nonatomic, assign) CGFloat emojiHeight;

@property (nonatomic, strong) TUIChatPopRecentView *emojiRecentView;

@property (nonatomic, strong) TUIChatPopEmojiView *emojiAdvanceView;

@property (nonatomic, strong) TUIChatPopActionsView *actionsView;

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
        if ([TUIChatConfig defaultConfig].enablePopMenuEmojiReactAction) {
            self.emojiHeight = kEmojiHeight;
        }
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(hideWithAnimation) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];

    }
    return self;
}

- (void)onTap:(UIGestureRecognizer *)tap
{
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
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            if (self.hideCallback) {
                self.hideCallback();
            }
            [self removeFromSuperview];
        }
    }];
}

- (void)hideByClickButton:(UIButton *)button callback:(void (^ __nullable)(void ))callback {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            if (callback){
                callback();
            }
            if (self.hideCallback) {
                self.hideCallback();
            }
            [self removeFromSuperview];
        }
    }];
    
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
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
    
    [self updateActionByRank];
    
    if ([TUIChatConfig defaultConfig].enablePopMenuEmojiReactAction) {
        [self prepareEmojiView];
    }
    
    [self prepareContainerView];
    
    if ([TUIChatConfig defaultConfig].enablePopMenuEmojiReactAction) {
        [self setupEmojiSubView];
    }
    
    [self setupContainerPosition];
    
    // 更新子视图的布局
    [self updateLayout];
    
}

- (void)updateActionByRank {
    NSArray *ageSortResultArray = [self.actions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            TUIChatPopMenuAction *per1 = obj1;
            TUIChatPopMenuAction *per2 = obj2;
            return per1.rank > per2.rank ? NSOrderedDescending : NSOrderedAscending;
        }];
    NSMutableArray *filterArray = [NSMutableArray arrayWithArray:ageSortResultArray];
    
    self.actions = [NSMutableArray arrayWithCapacity:10];
    
    [filterArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TUIChatPopMenuAction *per1 = obj;
        if (per1.rank == 4 ) {
            if ([TUIChatConfig defaultConfig].enablePopMenuReferenceAction) {
                [self.actions addObject:per1];
            }
        }
        else if (per1.rank == 5) {
            if ([TUIChatConfig defaultConfig].enablePopMenuReplyAction) {
                [self.actions addObject:per1];
            }
        }
        else {
            [self.actions addObject:per1];
        }
    }];

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
    CGFloat containerY = self.arrawPoint.y - kArrowSize.height - containerH - StatusBar_Height - self.emojiHeight ;
    BOOL top = NO;     // 箭头朝下
    CGFloat arrawX = 0.5 * containerW;
    CGFloat arrawY = kArrowSize.height + containerH - 1.5;
    
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
            self.arrawPoint = CGPointMake(self.arrawPoint.x, self.arrawPoint.y + self.adjustHeight - StatusBar_Height - 5 );
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
    
    self.emojiContainerView.frame = CGRectMake(containerX, containerY, containerW, MAX(self.emojiHeight + containerH, 200));
    self.containerView.frame = CGRectMake(containerX, containerY+self.emojiHeight, containerW, containerH);
    


    // 绘制 箭头
    self.arrowLayer = [[CAShapeLayer alloc] init];
    self.arrowLayer.path = [self arrawPath:CGPointMake(arrawX, arrawY) directionTop:top].CGPath;
    self.arrowLayer.fillColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF").CGColor;
    if (top) {
        if (self.emojiContainerView) {
            [self.emojiContainerView.layer addSublayer:self.arrowLayer];
        }
        else {
            [self.containerView.layer addSublayer:self.arrowLayer];
        }
    }
    else {
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
- (void)prepareContainerView
{
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
        if (i == maxColumns && i < self.actions.count ) {
            UIView *separtorView = [[UIView alloc] init];
            separtorView.backgroundColor =  TUICoreDynamicColor(@"separator_color", @"#39393B");
            separtorView.hidden = YES;
            [self.actionsView addSubview:separtorView];
            i = 0;
        }
    }
    
    // 计算当前 container 的宽高
    int rows = (self.actions.count % maxColumns == 0) ? (int)self.actions.count / maxColumns : (int)(self.actions.count / maxColumns) + 1;
    int columns = self.actions.count < maxColumns ? (int)self.actions.count : maxColumns;
    if ([TUIChatConfig defaultConfig].enablePopMenuEmojiReactAction) {
        columns = maxColumns ;
    }
    CGFloat width = kActionWidth * columns + kActionMargin * (columns + 1) + kContainerInsets.left + kContainerInsets.right;
    CGFloat height = kActionHeight * rows + (rows - 1) * kSepartorHeight + kContainerInsets.top + kContainerInsets.bottom;
    
    self.emojiContainerView.frame = CGRectMake(0, 0, width, self.emojiHeight + height);
    self.containerView.frame = CGRectMake(0, self.emojiHeight, width, height);
}

- (void)setupEmojiSubView {
    //表情一级页
    [self setupEmojiRecentView];
    //二级页
    [self setupEmojiAdvanceView];
}
- (void)setupEmojiRecentView {
    self.emojiRecentView = [[TUIChatPopRecentView alloc] initWithFrame:CGRectZero] ;
    [self.emojiContainerView addSubview:_emojiRecentView];
    _emojiRecentView.frame = CGRectMake(0, 0, self.emojiContainerView.mm_w, self.emojiHeight);
    _emojiRecentView.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
    _emojiRecentView.needShowbottomLine = YES;
    _emojiRecentView.delegate = self;
}
- (void)setupEmojiAdvanceView {
    self.emojiAdvanceView = [[TUIChatPopEmojiView alloc] initWithFrame:CGRectZero] ;
    [self.emojiContainerView addSubview:_emojiAdvanceView];
    
    [_emojiAdvanceView setData:(id)[TUIConfig defaultConfig].chatPopDetailGroups];
    _emojiAdvanceView.delegate = self;
    _emojiAdvanceView.alpha = 0;
    _emojiAdvanceView.faceCollectionView.scrollEnabled = YES;
    _emojiAdvanceView.faceCollectionView.delaysContentTouches = NO;
    _emojiAdvanceView.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
    _emojiAdvanceView.faceCollectionView.backgroundColor = _emojiAdvanceView.backgroundColor;
}
- (void)updateLayout
{
    
    self.emojiAdvanceView.frame = CGRectMake(0, self.emojiHeight - 0.5, self.emojiContainerView.mm_w ,  TChatEmojiView_CollectionHeight + 10 +  TChatEmojiView_Page_Height  );
    self.actionsView.frame = CGRectMake(0, -0.5, self.containerView.frame.size.width ,  self.containerView.frame.size.height);

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
    

    [actionButton addTarget:self action:@selector(buttonHighlightedEnter:) forControlEvents:UIControlEventTouchDown];
    [actionButton addTarget:self action:@selector(buttonHighlightedEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [actionButton addTarget:self action:@selector(buttonHighlightedExit:) forControlEvents:UIControlEventTouchDragExit];
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

- (void)buttonHighlightedEnter:(UIButton *)sender
{
    
    sender.backgroundColor = TUIChatDynamicColor(@"", @"#006EFF19");
}
- (void)buttonHighlightedExit:(UIButton *)sender
{
    sender.backgroundColor = [UIColor clearColor];
}
- (void)onClick:(UIButton *)button
{
    if (![self.actionCallback.allKeys containsObject:@(button.tag)]) {
        [self hideWithAnimation];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [self hideByClickButton:button callback:^() {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        TUIChatPopMenuActionCallback callback = [strongSelf.actionCallback objectForKey:@(button.tag)];
        if (callback) {
            callback();
        }
    }];

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

//MARK: TFaceViewDelegate
- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceGroup *group = faceView.faceGroups[indexPath.section];
    
    TUIFaceCellData *face = group.faces[indexPath.row];
    if(indexPath.section == 0){
        
        NSString *faceName = face.name;
        NSLog(@"FaceName:%@",faceName);
        [self updateRecentMenuQueue:faceName];
        if (self.reactClickCallback) {
            self.reactClickCallback(faceName);
        }
    }

}

- (NSArray *)getChatPopMenuQueue {
    NSArray *emojis = [[NSUserDefaults standardUserDefaults] objectForKey:@"TUIChatPopMenuQueue"];
    if (emojis &&[emojis isKindOfClass:[NSArray class]]) {
        if (emojis.count > 0) {
            return emojis;
        }
    }
    return [NSArray  arrayWithContentsOfFile:TUIChatFaceImagePath(@"emoji/emojiRecentDefaultList.plist")];
}
- (void)updateRecentMenuQueue:(NSString *)faceName {
    
    NSArray *emojis = [self getChatPopMenuQueue];
    NSMutableArray *muArray = [NSMutableArray arrayWithArray:emojis];
    
    BOOL hasInQueue = NO;
    for (NSDictionary *dic in emojis) {
        NSString *name = [dic objectForKey:@"face_name"];
        if ([name isEqualToString:faceName]) {
            hasInQueue = YES;
        }
    }
    if (hasInQueue) {
        return;
    }
    
    [muArray removeObjectAtIndex:0];
    [muArray addObject:@{@"face_name":faceName,
                         @"face_id":@""
                       }];
    [[NSUserDefaults standardUserDefaults] setObject:muArray forKey:@"TUIChatPopMenuQueue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//MARK: TUIChatPopRecentEmojiDelegate
- (void)popRecentViewClickArrow:(TUIChatPopRecentView *)faceView{
    if (faceView.arrowButton.selected) {
        [self hideDetailPage];
    }
    else {
        [self showDetailPage];
    }
    
}
- (void)popRecentViewClickface:(TUIChatPopRecentView *)faceView tag:(NSInteger)tag {
    TUIFaceGroup *group = faceView.faceGroups[0];
    TUIFaceCellData *face = group.faces[tag];
    NSString *faceName = face.name;
    NSLog(@"FaceName:%@",faceName);
    if (self.reactClickCallback) {
        self.reactClickCallback(faceName);
    }
}
- (void)showDetailPage {
    self.containerView.alpha = 0;
    self.emojiAdvanceView.alpha = 1;
}
- (void)hideDetailPage {
    self.emojiAdvanceView.alpha = 0;
    self.containerView.alpha = 1;
}
@end
