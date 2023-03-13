//
//  TCommonCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//

#import "TUICommonModel.h"
#import "TUIGlobalization.h"
#import "UIView+TUILayout.h"
#import "NSString+TUIUtil.h"
#import "TUITool.h"
#import "TUIDarkModel.h"
#import "TUIThemeManager.h"
#import <objc/runtime.h>

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIUserFullInfo
//
/////////////////////////////////////////////////////////////////////////////////
@implementation V2TIMUserFullInfo (TUIUserFullInfo)

- (NSString *)showName
{
    if ([NSString isEmpty:self.nickName])
        return self.userID;
    return self.nickName;
}

- (NSString *)showGender
{
    if (self.gender == V2TIM_GENDER_MALE)
        return TUIKitLocalizableString(Male);
    if (self.gender == V2TIM_GENDER_FEMALE)
        return TUIKitLocalizableString(Female);
    return TUIKitLocalizableString(Unsetted);
}

- (NSString *)showSignature
{
    if (self.selfSignature == nil)
        return TUIKitLocalizableString(TUIKitNoSelfSignature);
    return [NSString stringWithFormat:TUIKitLocalizableString(TUIKitSelfSignatureFormat), self.selfSignature];
}

- (NSString *)showAllowType
{
    if (self.allowType == V2TIM_FRIEND_ALLOW_ANY) {
        return TUIKitLocalizableString(TUIKitAllowTypeAcceptOne);
    }
    if (self.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        return TUIKitLocalizableString(TUIKitAllowTypeNeedConfirm);
    }
    if (self.allowType == V2TIM_FRIEND_DENY_ANY) {
        return TUIKitLocalizableString(TUIKitAllowTypeDeclineAll);
    }
    return nil;
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIUserModel
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIUserModel

- (id)copyWithZone:(NSZone *)zone{
    TUIUserModel * model = [[TUIUserModel alloc] init];
    model.userId = self.userId;
    model.name = self.name;
    model.avatar = self.avatar;
    return model;
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIScrollView
//
/////////////////////////////////////////////////////////////////////////////////

static void *ScrollViewBoundsChangeNotificationContext = &ScrollViewBoundsChangeNotificationContext;

@interface TUIScrollView ()

@property (nonatomic, readonly) CGFloat imageAspectRatio;
@property (nonatomic) CGRect initialImageFrame;
@property (strong, nonatomic, readonly) UITapGestureRecognizer *tap;

@end

@implementation TUIScrollView

@synthesize tap = _tap;

#pragma mark - Tap to Zoom

-(UITapGestureRecognizer *)tap {
    if (_tap == nil) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToZoom:)];
        _tap.numberOfTapsRequired = 2;
    }
    return _tap;
}

- (void)tapToZoom:(UIGestureRecognizer *)gestureRecognizer {
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGPoint tapLocation = [gestureRecognizer locationInView:self.imageView];
        CGFloat zoomRectWidth = self.imageView.frame.size.width / self.maximumZoomScale;
        CGFloat zoomRectHeight = self.imageView.frame.size.height / self.maximumZoomScale;
        CGFloat zoomRectX = tapLocation.x - zoomRectWidth * 0.5;
        CGFloat zoomRectY = tapLocation.y - zoomRectHeight * 0.5;
        CGRect zoomRect = CGRectMake(zoomRectX, zoomRectY, zoomRectWidth, zoomRectHeight);
        [self zoomToRect:zoomRect animated:YES];
    }
}


#pragma mark - Private Methods

- (void)configure {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self startObservingBoundsChange];
}

- (void)setImageView:(UIImageView *)imageView {
    if (_imageView.superview == self) {
        [_imageView removeGestureRecognizer:self.tap];
        [_imageView removeFromSuperview];
    }
    if (imageView) {
        _imageView = imageView;
        _initialImageFrame = CGRectNull;
        _imageView.userInteractionEnabled = YES;
        [_imageView addGestureRecognizer:self.tap];
        [self addSubview:imageView];
    }
}

- (CGFloat)imageAspectRatio {
    if (self.imageView.image) {
        return self.imageView.image.size.width / self.imageView.image.size.height;
    }
    return 1;
}

- (CGSize)rectSizeForAspectRatio: (CGFloat)ratio
                    thatFitsSize: (CGSize)size
{
    CGFloat containerWidth = size.width;
    CGFloat containerHeight = size.height;
    CGFloat resultWidth = 0;
    CGFloat resultHeight = 0;
    
    if ((ratio <= 0) || (containerHeight <= 0)) {
        return size;
    }
    
    if (containerWidth / containerHeight >= ratio) {
        resultHeight = containerHeight;
        resultWidth = containerHeight * ratio;
    }
    else {
        resultWidth = containerWidth;
        resultHeight = containerWidth / ratio;
    }
    
    return CGSizeMake(resultWidth, resultHeight);
}

- (void)scaleImageForScrollViewTransitionFromBounds: (CGRect)oldBounds
                                           toBounds: (CGRect)newBounds
{
    CGPoint oldContentOffset = CGPointMake(
                                           oldBounds.origin.x,
                                           oldBounds.origin.y
                                           );
    CGSize oldSize = oldBounds.size;
    CGSize newSize = newBounds.size;
    
    CGSize containedImageSizeOld = [self rectSizeForAspectRatio: self.imageAspectRatio
                                                   thatFitsSize: oldSize];
    
    CGSize containedImageSizeNew = [self rectSizeForAspectRatio: self.imageAspectRatio
                                                   thatFitsSize: newSize];
    
    if (containedImageSizeOld.height <= 0) {
        containedImageSizeOld = containedImageSizeNew;
    }
    
    CGFloat orientationRatio = (
                                containedImageSizeNew.height /
                                containedImageSizeOld.height
                                );
    
    CGAffineTransform t = CGAffineTransformMakeScale(
                                                     orientationRatio,
                                                     orientationRatio
                                                     );
    
    self.imageView.frame = CGRectApplyAffineTransform(self.imageView.frame, t);
    
    self.contentSize = self.imageView.frame.size;
    
    CGFloat xOffset = (oldContentOffset.x + oldSize.width * 0.5) * orientationRatio - newSize.width * 0.5;
    CGFloat yOffset = (oldContentOffset.y + oldSize.height * 0.5) * orientationRatio - newSize.height * 0.5;
    
    xOffset -= MAX(xOffset + newSize.width - self.contentSize.width, 0);
    yOffset -= MAX(yOffset + newSize.height - self.contentSize.height, 0);
    xOffset += MAX(-xOffset, 0);
    yOffset += MAX(-yOffset, 0);
    
    self.contentOffset = CGPointMake(xOffset, yOffset);
}

- (void)setupInitialImageFrame {
    if (self.imageView.image && CGRectEqualToRect(self.initialImageFrame, CGRectNull)) {
        CGSize imageViewSize = [self rectSizeForAspectRatio:self.imageAspectRatio
                                               thatFitsSize:self.bounds.size];
        self.initialImageFrame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
        self.imageView.frame = self.initialImageFrame;
        self.contentSize = self.initialImageFrame.size;
    }
}

#pragma mark - KVO

- (void)startObservingBoundsChange {
    [self addObserver:self
           forKeyPath:@"bounds"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:ScrollViewBoundsChangeNotificationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == ScrollViewBoundsChangeNotificationContext) {
        CGRect oldRect = ((NSValue *)change[NSKeyValueChangeOldKey]).CGRectValue;
        CGRect newRect = ((NSValue *)change[NSKeyValueChangeNewKey]).CGRectValue;
        if (! CGSizeEqualToSize(oldRect.size, newRect.size)) {
            [self scaleImageForScrollViewTransitionFromBounds: oldRect
                                                     toBounds: newRect];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bounds"];
}

#pragma mark - UIScrollView

- (void)setContentOffset:(CGPoint)contentOffset
{
    const CGSize contentSize = self.contentSize;
    const CGSize scrollViewSize = self.bounds.size;
    
    if (contentSize.width < scrollViewSize.width)
    {
        contentOffset.x = - (scrollViewSize.width - contentSize.width) * 0.5;
    }
    
    if (contentSize.height < scrollViewSize.height)
    {
        contentOffset.y = - (scrollViewSize.height - contentSize.height) * 0.5;
    }
    
    [super setContentOffset:contentOffset];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupInitialImageFrame];
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIPopView
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIPopView ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation TUIPopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [_tableView reloadData];
}

- (void)showInWindow:(UIWindow *)window
{
    [window addSubview:self];
    __weak typeof(self) ws = self;
    self.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 1;
    } completion:nil];
}

- (void)setupViews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:pan];
    
    self.backgroundColor = [UIColor clearColor];
    CGSize arrowSize = TUIPopView_Arrow_Size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + arrowSize.height, self.frame.size.width, self.frame.size.height - arrowSize.height)];
    self.frame = [UIScreen mainScreen].bounds;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = TUIDemoDynamicColor(@"pop_bg_color", @"#FFFFFF");
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.scrollEnabled = NO;
    _tableView.layer.cornerRadius = 5.0;
    [self addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TUIPopCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIPopCell *cell = [tableView dequeueReusableCellWithIdentifier:TUIPopCell_ReuseId];
    if(!cell){
        cell = [[TUIPopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TUIPopCell_ReuseId];
    }
    [cell setData:_data[indexPath.row]];
    if(indexPath.row == _data.count - 1){
        cell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_delegate && [_delegate respondsToSelector:@selector(popView:didSelectRowAtIndex:)]){
        [_delegate popView:self didSelectRowAtIndex:indexPath.row];
    }
    [self hide];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] set];

    CGSize arrowSize = TUIPopView_Arrow_Size;
    UIBezierPath *arrowPath = [[UIBezierPath alloc] init];
    [arrowPath moveToPoint:_arrowPoint];
    [arrowPath addLineToPoint:CGPointMake(_arrowPoint.x + arrowSize.width * 0.5, _arrowPoint.y + arrowSize.height)];
    [arrowPath addLineToPoint:CGPointMake(_arrowPoint.x - arrowSize.width * 0.5, _arrowPoint.y + arrowSize.height)];
    [arrowPath closePath];
    [arrowPath fill];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
     }
    return YES;
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [self hide];
}

- (void)hide
{
    __weak typeof(self) ws = self;
    self.alpha = 1;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 0;
    } completion:^(BOOL finished) {
        if([ws superview]){
            [ws removeFromSuperview];
        }
    }];
}
@end

@implementation TUIPopCellData
@end

@implementation TUIPopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];

    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:15];
    _title.textColor = TUIDemoDynamicColor(@"pop_text_color", @"#444444");
    _title.numberOfLines = 0;
    [self addSubview:_title];

    [self setSeparatorInset:UIEdgeInsetsMake(0, TUIPopCell_Padding, 0, 0)];
}

- (void)layoutSubviews
{
    CGFloat headHeight = TUIPopCell_Height - 2 * TUIPopCell_Padding;
    self.image.frame = CGRectMake(TUIPopCell_Padding, TUIPopCell_Padding, headHeight, headHeight);
    self.image.center = CGPointMake(self.image.center.x, self.contentView.center.y);
    
    CGFloat titleWidth = self.frame.size.width - 2 * TUIPopCell_Padding - TUIPopCell_Margin - _image.frame.size.width;
    self.title.frame = CGRectMake(_image.frame.origin.x + _image.frame.size.width + TUIPopCell_Margin, TUIPopCell_Padding, titleWidth, self.contentView.bounds.size.height);
    self.title.center = CGPointMake(self.title.center.x, self.contentView.center.y);
}

- (void)setData:(TUIPopCellData *)data
{
    _image.image = data.image;
    _title.text = data.title;
}

+ (CGFloat)getHeight
{
    return TUIPopCell_Height;
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIModifyView
//
/////////////////////////////////////////////////////////////////////////////////
#define kContainerWidth Screen_Width
#define kContainerHeight kContainerWidth * 3 / 4

@implementation TUIModifyViewData
- (instancetype)init {
    if (self = [super init]) {
        self.enableNull = NO;
    }
    return self;
}
@end

@interface TUIModifyView () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL keyboardShowing;
@property (nonatomic, strong) TUIModifyViewData *data;
@property (nonatomic, strong) UIButton *closeBtn;
@end

@implementation TUIModifyView
- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

    self.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];

    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

    _container = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height, kContainerWidth, kContainerHeight)];
    _container.backgroundColor = TUIGroupDynamicColor(@"group_modify_container_view_bg_color", @"#FFFFFF");
    _container.layer.cornerRadius = 8;
    [_container.layer setMasksToBounds:YES];
    [self addSubview:_container];


    CGFloat buttonHeight = 46;
    CGFloat titleHeight = 63;

    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _container.frame.size.width, titleHeight)];
    _title.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:17];
    _title.textColor = TUIGroupDynamicColor(@"group_modify_title_color", @"#000000");
    _title.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_title];
    
    _hLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame), kContainerWidth, TLine_Heigh)];
    _hLine.backgroundColor = TUICoreDynamicColor(@"separator_color", @"#E4E5E9");
    [_container addSubview:_hLine];
    
    CGFloat contentMargin = 20;
    CGFloat contentWidth = _container.frame.size.width - 2 * contentMargin;
    CGFloat contentY = CGRectGetMaxY(_hLine.frame) + 17;
    CGFloat contentheight = 40;
    _content = [[UITextField alloc] initWithFrame:CGRectMake(contentMargin, contentY, contentWidth, contentheight)];
    _content.delegate = self;
    _content.backgroundColor = TUIGroupDynamicColor(@"group_modify_input_bg_color", @"#F5F5F5");
    _content.textColor = TUIGroupDynamicColor(@"group_modify_input_text_color", @"#000000");
    [_content setFont:[UIFont systemFontOfSize:16]];
    [_content.layer setMasksToBounds:YES];
    [_content.layer setCornerRadius:4.0f];
    [_content setReturnKeyType:UIReturnKeyDone];
    [_content addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    CGRect leftviewFrame = _content.frame;
    leftviewFrame.size.width = 16;
    UIView *leftview = [[UIView alloc] initWithFrame:leftviewFrame];
    _content.leftView = leftview;
    _content.leftViewMode = UITextFieldViewModeAlways;
    CGRect rightviewFrame = _content.frame;
    rightviewFrame.size.width = 16;
    rightviewFrame.origin.x = rightviewFrame.size.width - 16;
    UIView *rightView = [[UIView alloc] initWithFrame:rightviewFrame];
    _content.rightView = rightView;
    _content.rightViewMode = UITextFieldViewModeAlways;

    [_container addSubview:_content];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(_content.frame.origin.x, CGRectGetMaxY(_content.frame) + 17, contentWidth, 20)];
    _descLabel.textColor = TUIGroupDynamicColor(@"group_modify_desc_color", @"#888888");
    _descLabel.font = [UIFont systemFontOfSize:13.0];
    _descLabel.numberOfLines = 0;
    _descLabel.text = @"desc";
    [_container addSubview:_descLabel];
    
    _confirm = [[UIButton alloc] initWithFrame:CGRectMake(_content.frame.origin.x, CGRectGetMaxY(_descLabel.frame) + 30, contentWidth, buttonHeight)];
    [_confirm setTitle:TUIKitLocalizableString(Confirm) forState:UIControlStateNormal];
    [_confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:15];
    _confirm.layer.cornerRadius = 8;
    _confirm.layer.masksToBounds = YES;
    _confirm.imageView.contentMode = UIViewContentModeScaleToFill;
    [self enableConfirmButton:self.data.enableNull];
    [_confirm addTarget:self action:@selector(didConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:_confirm];
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_container.frame.size.width - 24 - 20, 0, 24, 24)];
    _closeBtn.mm__centerY(_title.mm_centerY);
    [_closeBtn setImage:[UIImage imageNamed:TUIGroupImagePath(@"ic_close_poppings")] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(didCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:_closeBtn];
    
}

- (void)setData:(TUIModifyViewData *)data
{
    _title.text = data.title;
    _content.text = data.content;
    _descLabel.text = data.desc;
    _data = data;
 
    CGRect rect = [data.desc boundingRectWithSize:CGSizeMake(self.content.bounds.size.width, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]}
                                          context:nil];
    CGRect frame = _descLabel.frame;
    frame.size.height = rect.size.height;
    _descLabel.frame = frame;
    
    [self textChanged];
}

- (void)showInWindow:(UIWindow *)window
{
    [window addSubview:self];
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.confirm.frame) + 50;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.container.frame = CGRectMake(0, Screen_Height - height, kContainerWidth, height);
    } completion:nil];
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [_content resignFirstResponder];

    if (!self.keyboardShowing) {
        [self hide];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [touch.view isEqual:self];
}

- (void)hide
{
    __weak typeof(self) ws = self;
    self.alpha = 1;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 0;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] removeObserver:ws];
        if([ws superview]){
            [ws removeFromSuperview];
        }
    }];
}

- (void)didCancel:(UIButton *)sender
{
    [self hide];
}

- (void)didConfirm:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(modifyView:didModiyContent:)]){
        [_delegate modifyView:self didModiyContent:_content.text];
    }
    [self hide];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textChanged
{
    [self enableConfirmButton:(self.content.text.length || self.data.enableNull)];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardShowing = keyboardFrame.size.height > 0;
    [self animateContainer:keyboardFrame.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animateContainer:0];
}

- (void)keyboardDidHide:(NSNotification *)notice
{
    self.keyboardShowing = NO;
}

- (void)animateContainer:(CGFloat)keyboardHeight
{
    CGFloat height = CGRectGetMaxY(self.confirm.frame) + 50;
    CGRect frame = _container.frame;
    frame.origin.y = Screen_Height - height - keyboardHeight; //(self.frame.size.height - keyboardHeight - frame.size.height) * 0.5;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.container.frame = frame;
    } completion:nil];
}

- (void)enableConfirmButton:(BOOL)enable
{
    if (enable) {
        _confirm.backgroundColor = TUIGroupDynamicColor(@"group_modify_confirm_enable_bg_color", @"147AFF");
        _confirm.enabled = YES;
    } else {
        _confirm.backgroundColor = [TUIGroupDynamicColor(@"group_modify_confirm_enable_bg_color", @"147AFF") colorWithAlphaComponent:0.3];
        _confirm.enabled = NO;
    }
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUINaviBarIndicatorView
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUINaviBarIndicatorView
- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _indicator.center = CGPointMake(0, NavBar_Height * 0.5);
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:_indicator];

    _label = [[UILabel alloc] init];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont boldSystemFontOfSize:17];
    _label.textColor = TUICoreDynamicColor(@"nav_title_text_color", @"#000000");
    [self addSubview:_label];
}

- (void)setTitle:(NSString *)title
{
    _label.textColor = TUICoreDynamicColor(@"nav_title_text_color", @"#000000");
    _label.text = title;
    [self updateLayout];
}

- (void)updateLayout
{
    [_label sizeToFit];
    CGSize labelSize = _label.bounds.size; // [_label sizeThatFits:CGSizeMake(Screen_Width, NavBar_Height)];
    CGFloat labelWidth = MIN(labelSize.width, 150);
    CGFloat labelY = 0;
    CGFloat labelX = _indicator.hidden ? 0 : (_indicator.frame.origin.x + _indicator.frame.size.width + TUINaviBarIndicatorView_Margin);
    _label.frame = CGRectMake(labelX, labelY, labelWidth, NavBar_Height);
    self.frame = CGRectMake(0, 0, labelX + labelWidth + TUINaviBarIndicatorView_Margin, NavBar_Height);
//    self.center = CGPointMake(Screen_Width * 0.5, NavBar_Height * 0.5);
}

- (void)startAnimating
{
    [_indicator startAnimating];
}

- (void)stopAnimating
{
    [_indicator stopAnimating];
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUICommonCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonCellData

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return 60;
}

- (CGFloat)estimatedHeight {
    return 60;
}

@end

@interface TUICommonTableViewCell()<UIGestureRecognizerDelegate>
@property TUICommonCellData *data;
@property UITapGestureRecognizer *tapRecognizer;
@end

@implementation TUICommonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _tapRecognizer.delegate = self;
        _tapRecognizer.cancelsTouchesInView = NO;
        
        self.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
        self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    }
    return self;
}


- (void)tapGesture:(UIGestureRecognizer *)gesture
{
    if (self.data.cselector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.data.cselector]) {
            self.selected = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.data.cselector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)fillWithData:(TUICommonCellData *)data
{
    self.data = data;
    if (data.cselector) {
        [self addGestureRecognizer:self.tapRecognizer];
    } else {
        [self removeGestureRecognizer:self.tapRecognizer];
    }
}


@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUICommonTextCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonTextCellData
- (instancetype)init {
    self = [super init];
    self.keyEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];
    if (self.enableMultiLineValue) {
        NSString *str = self.value;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(280, 999) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        height = size.height + 30;
    }
    return height;
}

@end

@interface TUICommonTextCell()
@property TUICommonTextCellData *textData;
@end

@implementation TUICommonTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
        self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
        
        _keyLabel = self.textLabel;
        _keyLabel.textColor = TUICoreDynamicColor(@"form_key_text_color", @"#444444");
        _keyLabel.font = [UIFont systemFontOfSize:16.0];
        
        _valueLabel = self.detailTextLabel;
        _valueLabel.textColor = TUICoreDynamicColor(@"form_value_text_color", @"#000000");
        _valueLabel.font = [UIFont systemFontOfSize:16.0];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    if (self.textData.keyEdgeInsets.left) {
        self.keyLabel.mm_left(self.textData.keyEdgeInsets.left);
    }
    
    if (self.textData.keyEdgeInsets.top) {
        self.keyLabel.mm_top(self.textData.keyEdgeInsets.top);
    }
    
    if (self.textData.keyEdgeInsets.bottom) {
        self.keyLabel.mm_bottom(self.textData.keyEdgeInsets.bottom);
    }
    
    if (self.textData.keyEdgeInsets.right) {
        self.keyLabel.mm_right(self.textData.keyEdgeInsets.right);
    }
}

- (void)fillWithData:(TUICommonTextCellData *)textData
{
    [super fillWithData:textData];

    self.textData = textData;
    RAC(_keyLabel, text) = [RACObserve(textData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(textData, value) takeUntil:self.rac_prepareForReuseSignal];

    if (textData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.textData.keyColor) {
        self.keyLabel.textColor = self.textData.keyColor;
    }
    
    if (self.textData.valueColor) {
        self.valueLabel.textColor = self.textData.valueColor;
    }
    
    if (self.textData.enableMultiLineValue) {
        self.valueLabel.numberOfLines = 0;
    } else {
        self.valueLabel.numberOfLines = 1;
    }
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUICommonSwitchCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonSwitchCellData
- (instancetype)init {
    self = [super init];
    _margin = 20;
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];
    if (self.desc.length > 0) {
        NSString *str = self.desc;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
        height += size.height + 10;
    }
    return height;
}

@end

@interface TUICommonSwitchCell()

@property TUICommonSwitchCellData *switchData;
@property (nonatomic,strong) UIView * leftSeparatorLine;

@end

@implementation TUICommonSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TUICoreDynamicColor(@"form_key_text_color", @"#444444");
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = TUICoreDynamicColor(@"group_modify_desc_color", @"#888888");
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.numberOfLines = 0;
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.hidden = YES;
        [self.contentView addSubview:_descLabel];
        
        _switcher = [[UISwitch alloc] init];
        _switcher.onTintColor = TUICoreDynamicColor(@"common_switch_on_color", @"#147AFF");
        self.accessoryView = _switcher;
        [self.contentView addSubview:_switcher];
        [_switcher addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventValueChanged];

        _leftSeparatorLine = [[UIView alloc] init];
        _leftSeparatorLine.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
        [self.contentView addSubview:_leftSeparatorLine];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.switchData.disableChecked) {
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.alpha = 0.4;
        _switcher.alpha = 0.4;
        self.userInteractionEnabled = NO;
    }
    else {
        _titleLabel.alpha = 1;
        _switcher.alpha = 1;
        _titleLabel.textColor = TUICoreDynamicColor(@"form_key_text_color", @"#444444");
        _switcher.onTintColor = TUICoreDynamicColor(@"common_switch_on_color", @"#147AFF");
        self.userInteractionEnabled = YES;
    }
    
    CGFloat leftMargin = 0 ;
    CGFloat padding = 5;
    if (self.switchData.displaySeparatorLine) {
        _leftSeparatorLine.mm_width(10).mm_height(2).mm_left(self.switchData.margin).mm__centerY(self.contentView.mm_h / 2);
        leftMargin  = self.switchData.margin + _leftSeparatorLine.mm_w + padding;
    }
    else {
        _leftSeparatorLine.mm_width(0).mm_height(0);
        leftMargin = self.switchData.margin;
    }
    
    if (self.switchData.desc.length > 0) {
        _descLabel.text = self.switchData.desc;
        _descLabel.hidden = NO;
        NSString *str = self.switchData.desc;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
        _titleLabel.mm_width(size.width).mm_height(24).mm_left(leftMargin).mm_top(12);
        _descLabel.mm_width(size.width).mm_height(size.height).mm_left(_titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY + 2);
    } else {
        _descLabel.text =  @"";
        _titleLabel.mm_sizeToFit().mm_left(leftMargin).mm__centerY(self.contentView.mm_h / 2);
    }
    
}

- (void)fillWithData:(TUICommonSwitchCellData *)switchData
{
    [super fillWithData:switchData];

    self.switchData = switchData;
    _titleLabel.text = switchData.title;
    [_switcher setOn:switchData.isOn];
    _descLabel.text = switchData.desc;

}

- (void)switchClick
{
    if (self.switchData.cswitchSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.switchData.cswitchSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.switchData.cswitchSelector withObject:self];
#pragma clang diagnostic pop
        }
    }

}
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIGroupPendencyCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIGroupPendencyCellData ()
@property V2TIMUserFullInfo *fromUserProfile;
@property V2TIMGroupApplication *pendencyItem;
@end

@implementation TUIGroupPendencyCellData

- (instancetype)initWithPendency:(V2TIMGroupApplication *)args {
    self = [self init];

    _pendencyItem = args;

    _groupId = args.groupID;
    _fromUser = args.fromUser;
    if (args.fromUserNickName.length > 0) {
        _title = args.fromUserNickName;
    } else {
        _title = args.fromUser;
    }
    _avatarUrl = [NSURL URLWithString:args.fromUserFaceUrl];
    _requestMsg = args.requestMsg;
    if (_requestMsg.length == 0) {
        _requestMsg = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitWhoRequestForJoinGroupFormat), _title];
    }

    return self;
}

- (void)accept
{
    [[V2TIMManager sharedInstance] acceptGroupApplication:_pendencyItem reason:TUIKitLocalizableString(TUIKitAgreedByAdministor) succ:^{
        [TUITool makeToast:TUIKitLocalizableString(Have-been-sent)];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];;
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
    self.isAccepted = YES;
}
- (void)reject
{
    [[V2TIMManager sharedInstance] refuseGroupApplication:_pendencyItem reason:TUIKitLocalizableString(TUIkitDiscliedByAdministor) succ:^{
        [TUITool makeToast:TUIKitLocalizableString(Have-been-sent)];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];;
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
    self.isRejectd = YES;
}

@end

@implementation TUIGroupPendencyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self.contentView addSubview:self.avatarView];
    self.avatarView.mm_width(54).mm_height(54).mm__centerY(38).mm_left(12);

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor darkTextColor];
    self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_top(14).mm_height(20).mm_width(120);

    self.addWordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.addWordingLabel];
    self.addWordingLabel.textColor = [UIColor lightGrayColor];
    self.addWordingLabel.font = [UIFont systemFontOfSize:15];
    self.addWordingLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY+6).mm_height(15).mm_width(self.mm_w - self.titleLabel.mm_x - 80);

    self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.accessoryView = self.agreeButton;
    [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillWithData:(TUIGroupPendencyCellData *)pendencyData
{
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    self.addWordingLabel.text = pendencyData.requestMsg;
    self.avatarView.image = DefaultAvatarImage;
    if (pendencyData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl placeholderImage:[UIImage imageNamed:TUICoreImagePath(@"default_c2c_head")]];
    }

    @weakify(self)
    [[RACObserve(pendencyData, isAccepted) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *isAccepted) {
        @strongify(self)
        if ([isAccepted boolValue]) {
            [self.agreeButton setTitle:TUIKitLocalizableString(Agreed) forState:UIControlStateNormal];
            self.agreeButton.enabled = NO;
            [self.agreeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }];
    [[RACObserve(pendencyData, isRejectd) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *isAccepted) {
        @strongify(self)
        if ([isAccepted boolValue]) {
            [self.agreeButton setTitle:TUIKitLocalizableString(Disclined) forState:UIControlStateNormal];
            self.agreeButton.enabled = NO;
            [self.agreeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }];

    if (!(pendencyData.isAccepted || pendencyData.isRejectd)) {
        [self.agreeButton setTitle:TUIKitLocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        [self.agreeButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        self.agreeButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
    }
    self.agreeButton.mm_sizeToFit().mm_width(self.agreeButton.mm_w+20);
}

- (void)agreeClick
{
    if (self.pendencyData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((touch.view == self.agreeButton)) {
        return NO;
    }
    return YES;
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIButtonCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIButtonCellData

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TButtonCell_Height;
}
@end

@implementation TUIButtonCell {
    UIView *_line;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");

    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:_button];

    [self setSeparatorInset:UIEdgeInsetsMake(0, Screen_Width, 0, 0)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.changeColorWhenTouched = YES;
    
    _line = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_line];
    _line.backgroundColor = TUICoreDynamicColor(@"separator_color", @"#DBDBDB");
}


- (void)fillWithData:(TUIButtonCellData *)data
{
    [super fillWithData:data];
    self.buttonData = data;
    [_button setTitle:data.title forState:UIControlStateNormal];
    switch (data.style) {
        case ButtonGreen: {
            [_button setTitleColor:TUICoreDynamicColor(@"form_green_button_text_color", @"#FFFFFF") forState:UIControlStateNormal];
            _button.backgroundColor = TUICoreDynamicColor(@"form_green_button_bg_color", @"#232323");
            [_button setBackgroundImage:[self imageWithColor:TUICoreDynamicColor(@"form_green_button_highlight_bg_color", @"#179A1A")] forState:UIControlStateHighlighted];
        }
            break;
        case ButtonWhite: {
            [_button setTitleColor:TUICoreDynamicColor(@"form_white_button_text_color", @"#000000") forState:UIControlStateNormal];
            _button.backgroundColor = TUICoreDynamicColor(@"form_white_button_bg_color", @"#FFFFFF");
        }
            break;
        case ButtonRedText: {
            [_button setTitleColor:TUICoreDynamicColor(@"form_redtext_button_text_color", @"#FF0000") forState:UIControlStateNormal];
            _button.backgroundColor = TUICoreDynamicColor(@"form_redtext_button_bg_color", @"#FFFFFF");

            break;
        }
        case ButtonBule:{
            [_button.titleLabel setTextColor:TUICoreDynamicColor(@"form_blue_button_text_color", @"#FFFFFF")];
            _button.backgroundColor = TUICoreDynamicColor(@"form_blue_button_bg_color", @"#1E90FF");
            [_button setBackgroundImage:[self imageWithColor:TUICoreDynamicColor(@"form_blue_button_highlight_bg_color", @"#1978D5")] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
    
    if (data.textColor) {
        [_button setTitleColor:data.textColor forState:UIControlStateNormal];
    }
    
    _line.hidden = data.hideSeparatorLine;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _button.mm_width(Screen_Width - 2 * TButtonCell_Margin)
    .mm_height(self.mm_h - TButtonCell_Margin)
    .mm_left(TButtonCell_Margin);
    
    _line.mm_width(Screen_Width)
    .mm_height(0.2)
    .mm_left(20)
    .mm_bottom(0);
}

- (void)onClick:(UIButton *)sender
{
    if (self.buttonData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.buttonData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.buttonData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if (subview != self.contentView) {
        [subview removeFromSuperview];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}




@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIFaceCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIFaceCellData
@end

@implementation TUIFaceCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    _face = [[UIImageView alloc] init];
    _face.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_face];
}

- (void)defaultLayout
{
    CGSize size = self.frame.size;
    _face.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)setData:(TUIFaceCellData *)data
{
    _face.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    [self defaultLayout];
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIFaceGroup
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIFaceGroup
@end

@implementation TUIEmojiTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    return CGRectMake(0, 0, _emojiSize.width, _emojiSize.height);
}

@end
/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIUnReadView
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIUnReadView
- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setNum:(NSInteger)num
{
    NSString *unReadStr = [[NSNumber numberWithInteger:num] stringValue];
    if (num > 99){
        unReadStr = @"99+";
    }
    _unReadLabel.text = unReadStr;
    self.hidden = (num == 0? YES: NO);
    [self defaultLayout];
}

- (void)setupViews
{
    _unReadLabel = [[UILabel alloc] init];
    _unReadLabel.text = @"11";
    _unReadLabel.font = [UIFont systemFontOfSize:12];
    _unReadLabel.textColor = [UIColor whiteColor];
    _unReadLabel.textAlignment = NSTextAlignmentCenter;
    [_unReadLabel sizeToFit];
    [self addSubview:_unReadLabel];

    self.layer.cornerRadius = (_unReadLabel.frame.size.height + TUnReadView_Margin_TB * 2)/2.0;
    [self.layer masksToBounds];
    self.backgroundColor = [UIColor redColor];
    self.hidden = YES;
}

- (void)defaultLayout
{
    [_unReadLabel sizeToFit];
    CGFloat width = _unReadLabel.frame.size.width + 2 * TUnReadView_Margin_LR;
    CGFloat height =  _unReadLabel.frame.size.height + 2 * TUnReadView_Margin_TB;
    if(width < height){
        width = height;
    }
    self.bounds = CGRectMake(0, 0, width, height);
    _unReadLabel.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11.0, *)){
        //Here is a workaround on iOS 11 UINavigationBarItem init with custom view, position issue
        UIView *view = self;
        while (![view isKindOfClass:[UINavigationBar class]] && [view superview] != nil)
        {
            view = [view superview];
            if ([view isKindOfClass:[UIStackView class]] && [view superview] != nil)
            {
                    CGFloat margin = 40.0f;
                        //margin = 4.0f;
                    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                    toItem:view.superview
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    multiplier:1.0
                                                                                    constant:margin]];
                break;
            }
        }
    }
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIConversationPin
//
/////////////////////////////////////////////////////////////////////////////////
#define TOP_CONV_KEY @"TUIKIT_TOP_CONV_KEY"
NSString *kTopConversationListChangedNotification = @"kTopConversationListChangedNotification";

@implementation TUIConversationPin
+ (instancetype)sharedInstance
{
    static TUIConversationPin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TUIConversationPin new];
    });
    return instance;
}

- (NSArray *)topConversationList
{
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    return @[];
#else
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_CONV_KEY];
    if ([list isKindOfClass:[NSArray class]]) {
        return list;
    }
    return @[];
#endif
}

- (void)addTopConversation:(NSString *)conv callback:(void(^)(BOOL success, NSString *errorMessage))callback
{
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    [V2TIMManager.sharedInstance pinConversation:conv isPinned:YES succ:^{
        if (callback) {
            callback(YES, nil);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(NO, desc);
        }
    }];
#else
    [TUITool dispatchMainAsync:^{
        NSMutableArray *list = [self topConversationList].mutableCopy;
        if ([list containsObject:conv]) {
            [list removeObject:conv];
        }
        [list insertObject:conv atIndex:0];
        [[NSUserDefaults standardUserDefaults] setValue:list forKey:TOP_CONV_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTopConversationListChangedNotification object:nil];
        if (callback) {
            callback(YES, nil);
        }
    }];
#endif
}

- (void)removeTopConversation:(NSString *)conv callback:(void(^)(BOOL success, NSString *errorMessage))callback
{
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    [V2TIMManager.sharedInstance pinConversation:conv isPinned:NO succ:^{
        if (callback) {
            callback(YES, nil);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(NO, desc);
        }
    }];
#else
    [TUITool dispatchMainAsync:^{
        NSMutableArray *list = [self topConversationList].mutableCopy;
        if ([list containsObject:conv]) {
            [list removeObject:conv];
            [[NSUserDefaults standardUserDefaults] setValue:list forKey:TOP_CONV_KEY];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTopConversationListChangedNotification object:nil];
        }
        if (callback) {
            callback(YES, nil);
        }
    }];
#endif
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIGroupAvatar
//
/////////////////////////////////////////////////////////////////////////////////
#define groupAvatarWidth (48*[[UIScreen mainScreen] scale])
@implementation TUIGroupAvatar

+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger avatarCount = group.count > 9 ? 9 : group.count;
        CGFloat width = groupAvatarWidth / 3 * 0.90;
        CGFloat space3 = (groupAvatarWidth - width * 3) / 4;
        CGFloat space2 = (groupAvatarWidth - width * 2 + space3) / 2;
        CGFloat space1 = (groupAvatarWidth - width) / 2;
        __block CGFloat y = avatarCount > 6 ? space3 : (avatarCount > 3 ? space2 : space1);
        __block CGFloat x = avatarCount  % 3 == 0 ? space3 : (avatarCount % 3 == 2 ? space2 : space1);
        width = avatarCount > 4 ? width : (avatarCount > 1 ? (groupAvatarWidth - 3 * space3) / 2 : groupAvatarWidth );
        
        if (avatarCount == 1) {
            x = 0;
            y = 0;
        }
        if (avatarCount == 2) {
            x = space3;
        } else if (avatarCount == 3) {
            x = (groupAvatarWidth -width)/2;
            y = space3;
        } else if (avatarCount == 4) {
            x = space3;
            y = space3;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, groupAvatarWidth, groupAvatarWidth)];
            [view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.6]];
            view.layer.cornerRadius = 6;
            __block NSInteger count = 0;
            for (NSInteger i = avatarCount - 1; i >= 0; i--) {
                NSString *avatarUrl = [group objectAtIndex:i];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                [view addSubview:imageView];
                [imageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:DefaultAvatarImage completed:^(UIImage * _Nullable image,
                                                                                                                              NSError * _Nullable error,
                                                                                                                              SDImageCacheType cacheType,
                                                                                                                              NSURL * _Nullable imageURL) {
                    count ++ ;
                    if (count == avatarCount) {
                        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 2.0);
                        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndPDFContext();
                        CGImageRef imageRef = image.CGImage;
                        CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, CGRectMake(0, 0, view.frame.size.width*2, view.frame.size.height*2));
                        UIImage *ansImage = [[UIImage alloc] initWithCGImage:imageRefRect];
                        CGImageRelease(imageRefRect);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (finished) {
                                finished(ansImage);
                            }
                        });
                    }
                    
                }];
                
                if (avatarCount == 3) {
                    if (i == 2) {
                        y = width + space3*2;
                        x = space3;
                    } else {
                        x += width + space3;
                    }
                } else if (avatarCount == 4) {
                    if (i % 2 == 0) {
                        y += width +space3;
                        x = space3;
                    } else {
                        x += width +space3;
                    }
                } else {
                    if (i % 3 == 0 ) {
                        y += (width + space3);
                        x = space3;
                    } else {
                        x += (width + space3);
                    }
                }
            }
        });
        
    });
    
}

+ (void)fetchGroupAvatars:(NSString *)groupID placeholder:(UIImage *)placeholder callback:(void(^)(BOOL success, UIImage *image, NSString *groupID))callback
{
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        int i = 0;
        NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
        for (V2TIMGroupMemberFullInfo* member in memberList) {
            if (member.faceURL.length > 0) {
                [groupMemberAvatars addObject:member.faceURL];
            } else {
                [groupMemberAvatars addObject:@"http://placeholder"];
            }
            if (++i == 9) {
                break;
            }
        }
        
        if (i <= 1) {
            [self asyncClearCacheAvatarForGroup:groupID];
            if (callback) {
                callback(NO, placeholder, groupID);
            }
            return;
        }
        
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
        [NSUserDefaults.standardUserDefaults setInteger:groupMemberAvatars.count forKey:key];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        [TUIGroupAvatar createGroupAvatar:groupMemberAvatars finished:^(UIImage *groupAvatar) {
            @strongify(self)
            UIImage *avatar = groupAvatar;
            [self cacheGroupAvatar:avatar number:(UInt32)groupMemberAvatars.count groupID:groupID];
            
            if (callback) {
                callback(YES, avatar, groupID);
            }
        }];
        
    } fail:^(int code, NSString *msg) {
        if (callback) {
            callback(NO, placeholder, groupID);
        }
    }];
}

+ (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum groupID:(NSString *)groupID
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (groupID == nil || groupID.length == 0) {
            return;
        }
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath, groupID, memberNum];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // check to delete old file
        NSNumber *oldValue = [defaults objectForKey:groupID];
        if ( oldValue != nil) {
            UInt32 oldMemberNum = [oldValue unsignedIntValue];
            NSString *oldFilePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath, groupID, oldMemberNum];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:oldFilePath error:nil];
        }
        
        // Save image.
        BOOL success = [UIImagePNGRepresentation(avatar) writeToFile:filePath atomically:YES];
        if (success) {
            [defaults setObject:@(memberNum) forKey:groupID];
        }
    });
}

+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void(^)(UIImage *, NSString *groupID))imageCallBack {
    if (groupID == nil || groupID.length == 0) {
        if (imageCallBack) {
            imageCallBack(nil, groupID);
        }
        return;
    }
    [[V2TIMManager sharedInstance] getGroupsInfo:@[groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *groupInfo = groupResultList.firstObject;
        if (!groupInfo) {
            imageCallBack(nil, groupID);
            return;
        }
        UInt32 memberNum = groupInfo.info.memberCount;
        memberNum = MAX(1, memberNum);
        memberNum = MIN(memberNum, 9);;
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath, groupID, (unsigned int)memberNum];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        UIImage *avatar = nil;
        BOOL success = [fileManager fileExistsAtPath:filePath];

        if (success) {
            avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
            [NSUserDefaults.standardUserDefaults setInteger:memberNum forKey:key];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        imageCallBack(avatar, groupInfo.info.groupID);
    } fail:^(int code, NSString *msg) {
        imageCallBack(nil, groupID);
    }];
}

+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum
{
    memberNum = MAX(1, memberNum);
    memberNum = MIN(memberNum, 9);;
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath,
                          groupId,(unsigned int)memberNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    UIImage *avatar = nil;
    BOOL success = [fileManager fileExistsAtPath:filePath];

    if (success) {
        avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    return avatar;
}

+ (void)asyncClearCacheAvatarForGroup:(NSString *)groupID
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* tempPath = NSTemporaryDirectory();
        for (int i = 0; i < 9; i++) {
            NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
                                  groupID,(i+1)];
            if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
                [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
            }
        }
    });
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIImageCache
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIImageCache()
@property (nonatomic, strong) NSMutableDictionary *resourceCache;
@property (nonatomic, strong) NSMutableDictionary *faceCache;
@end

@implementation TUIImageCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TUIImageCache *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TUIImageCache alloc] init];
        [UIImage d_fixResizableImage];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _resourceCache = [NSMutableDictionary dictionary];
        _faceCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addResourceToCache:(NSString *)path
{
    __weak typeof(self) ws = self;
    [TUITool asyncDecodeImage:path complete:^(NSString *key, UIImage *image) {
        __strong __typeof(ws) strongSelf = ws;
        if (key && image) {        
            [strongSelf.resourceCache setValue:image forKey:key];
        }
    }];
}

- (UIImage *)getResourceFromCache:(NSString *)path
{
    if(path.length == 0){
        return nil;
    }
    UIImage *image = [_resourceCache objectForKey:path];
    if(!image){
        image = [UIImage d_imagePath:path];
    }
    return image;
}

- (void)addFaceToCache:(NSString *)path
{
    __weak typeof(self) ws = self;
    [TUITool asyncDecodeImage:path complete:^(NSString *key, UIImage *image) {
        __strong __typeof(ws) strongSelf = ws;
        if (key && image) {
            [strongSelf.faceCache setValue:image forKey:key];
        }
    }];
}

- (UIImage *)getFaceFromCache:(NSString *)path
{
    if(path.length == 0){
        return nil;
    }
    UIImage *image = [_faceCache objectForKey:path];
    if(!image){
        image = [UIImage imageWithContentsOfFile:path];
        if (!image) {
            image = [_faceCache objectForKey:TUIChatFaceImagePath(@"ic_unknown_image")];
        }
    }
    return image;
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactSelectCellData
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonContactSelectCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    return self;
}

- (NSComparisonResult)compare:(TUICommonContactSelectCellData *)data
{
    return [self.title localizedCompare:data.title];
}

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactListPickerCell
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonContactListPickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat AVATAR_WIDTH = 35.0;
        _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, AVATAR_WIDTH, AVATAR_WIDTH)];
        [self.contentView addSubview:_avatar];
        _avatar.center = CGPointMake(AVATAR_WIDTH/2.0, AVATAR_WIDTH/2.0);
        _avatar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = _avatar.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIContactListPickerOnCancel
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIContactListPicker()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UIButton *accessoryBtn;
@end

@implementation TUIContactListPicker


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    [self initControl];
    [self setupBinding];

    return self;
}

- (void)initControl
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;

    [self.collectionView registerClass:[TUICommonContactListPickerCell class] forCellWithReuseIdentifier:@"PickerIdentifier"];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];

    [self addSubview:_collectionView];

    self.accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.accessoryBtn setBackgroundImage:TUICoreCommonBundleImage(@"icon_cell_blue_normal")
                                 forState:UIControlStateNormal];
    [self.accessoryBtn setBackgroundImage:TUICoreCommonBundleImage(@"icon_cell_blue_normal")
                                 forState:UIControlStateHighlighted];
    [self.accessoryBtn setTitle:[NSString stringWithFormat:@" %@ ", TUIKitLocalizableString(Confirm)] forState:UIControlStateNormal];
    self.accessoryBtn.enabled = NO;
    [self addSubview:self.accessoryBtn];
}

- (void)setupBinding
{
    [self addObserver:self forKeyPath:@"selectArray" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectArray"]) {
        [self.collectionView reloadData];
        NSArray *newSelectArray = change[NSKeyValueChangeNewKey];
        if ([newSelectArray isKindOfClass:NSArray.class]) {
            self.accessoryBtn.enabled = [newSelectArray count];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.selectArray count];
}

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(35, collectionView.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonContactListPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PickerIdentifier" forIndexPath:indexPath];

    TUICommonContactSelectCellData *data = self.selectArray[indexPath.row];
    if (data.avatarUrl) {
        [cell.avatar sd_setImageWithURL:data.avatarUrl placeholderImage:DefaultAvatarImage];
    } else if (data.avatarImage) {
        cell.avatar.image = data.avatarImage;
    } else {
        cell.avatar.image = DefaultAvatarImage;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.item >= self.selectArray.count) {
        return;
    }
    TUICommonContactSelectCellData *data = self.selectArray[indexPath.item];
    if (self.onCancel) {
        self.onCancel(data);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.accessoryBtn.mm_sizeToFit().mm_height(30).mm_right(15).mm_top(13);
    self.collectionView.mm_left(15).mm_height(40).mm_width(self.accessoryBtn.mm_x - 30).mm__centerY(self.accessoryBtn.mm_centerY);

}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIProfileCardCell & VC
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIProfileCardCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatarImage = DefaultAvatarImage;
        
        if([_genderString isEqualToString:TUIKitLocalizableString(Male)]){
            _genderIconImage = TUIGroupCommonBundleImage(@"male");
        }else if([_genderString isEqualToString:TUIKitLocalizableString(Female)]){
            _genderIconImage = TUIGroupCommonBundleImage(@"female");
        }else{
            _genderIconImage = nil;
        }
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin + (self.showSignature ? 24 : 0);
}

@end

@implementation TUIProfileCardCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    CGSize headSize = TPersonalCommonCell_Image_Size;
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(TPersonalCommonCell_Margin, TPersonalCommonCell_Margin, headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFit;
    _avatar.layer.cornerRadius = 4;
    _avatar.layer.masksToBounds = YES;
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAvatar)];
    [_avatar addGestureRecognizer:tapAvatar];
    _avatar.userInteractionEnabled = YES;
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self.contentView addSubview:_avatar];
    
    //CGSize genderIconSize = CGSizeMake(20, 20);
    _genderIcon = [[UIImageView alloc] init];
    _genderIcon.contentMode = UIViewContentModeScaleAspectFit;
    _genderIcon.image = self.cardData.genderIconImage;
    [self.contentView addSubview:_genderIcon];
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont boldSystemFontOfSize:18]];
    [_name setTextColor:TUICoreDynamicColor(@"form_title_color", @"#000000")];
    [self.contentView addSubview:_name];
    
    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:13]];
    [_identifier setTextColor:TUICoreDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_identifier];
    
    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    [_signature setTextColor:TUICoreDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_signature];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)fillWithData:(TUIProfileCardCellData *)data
{
    [super fillWithData:data];
    self.cardData = data;
    _signature.hidden = !data.showSignature;
    //set data
    @weakify(self)
    
    RAC(_signature, text) = [RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal];
    [[[RACObserve(data, identifier) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.identifier.text = [@"ID: " stringByAppendingString:data.identifier];
    }];
    
    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.name.text = x;
        [self.name sizeToFit];
    }];
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
    }];
    
    [[RACObserve(data, genderString) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *x) {
        @strongify(self)
        if([x isEqualToString:TUIKitLocalizableString(Male)]){
            self.genderIcon.image = TUIGroupCommonBundleImage(@"male");
        }else if([x isEqualToString:TUIKitLocalizableString(Female)]){
            self.genderIcon.image = TUIGroupCommonBundleImage(@"female");
        }else{
            self.genderIcon.image = nil;
        }
    }];
    
    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat maxLabelWidth = self.contentView.mm_w - CGRectGetMaxX(_avatar.frame) - 30;
    _name.mm_sizeToFitThan(0, _avatar.mm_h/3).mm_top(_avatar.mm_y).mm_left(_avatar.mm_maxX + TPersonalCommonCell_Margin);
    if (CGRectGetMaxX(_name.frame) >= self.contentView.mm_w) {
        _name.mm_w = maxLabelWidth;
    }
    
    _identifier.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_left(_name.mm_x);

    if (self.cardData.showSignature) {
        _identifier.mm_y = _name.mm_y + _name.mm_h + 5;
    } else {
        _identifier.mm_bottom(_avatar.mm_b);
    }
    
    _signature.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_left(_name.mm_x);
    _signature.mm_y = CGRectGetMaxY(_identifier.frame) + 5;
    if (CGRectGetMaxX(_signature.frame) >= self.contentView.mm_w) {
        _signature.mm_w = maxLabelWidth;
    }

    _genderIcon.mm_sizeToFitThan(_name.font.pointSize * 0.9, _name.font.pointSize * 0.9).mm__centerY(_name.mm_centerY).mm_left(_name.mm_x + _name.mm_w + TPersonalCommonCell_Margin);
}


-(void) onTapAvatar{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapOnAvatar:)])
        [_delegate didTapOnAvatar:self];
}

@end

@interface TUIAvatarViewController ()<UIScrollViewDelegate>
@property UIImageView *avatarView;

@property TUIScrollView *avatarScrollView;

@property UIImage *saveBackgroundImage;
@property UIImage *saveShadowImage;

@end

@implementation TUIAvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.saveBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.saveShadowImage = self.navigationController.navigationBar.shadowImage;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    //Fix  translucent = NO;
    CGRect rect = self.view.bounds;
    if (![UINavigationBar appearance].isTranslucent && [[[UIDevice currentDevice] systemVersion] doubleValue]<15.0) {
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - TabBar_Height - NavBar_Height );
    }
    self.avatarScrollView = [[TUIScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.avatarScrollView];
    self.avatarScrollView.backgroundColor = [UIColor blackColor];
    self.avatarScrollView.frame = rect;

    self.avatarView = [[UIImageView alloc] initWithImage:self.avatarData.avatarImage];
    self.avatarScrollView.imageView = self.avatarView;
    self.avatarScrollView.maximumZoomScale = 4.0;
    self.avatarScrollView.delegate = self;

    self.avatarView.image = self.avatarData.avatarImage;
    TUIProfileCardCellData *data = self.avatarData;
    /*
     @weakify(self)
    [RACObserve(data, avatarUrl) subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatarView sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
    }];
    */
    @weakify(self)
    [RACObserve(data, avatarUrl) subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatarView sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
        [self.avatarScrollView setNeedsLayout];
    }];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.avatarView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self.navigationController.navigationBar setBackgroundImage:self.saveBackgroundImage
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = self.saveShadowImage;
    }
}

@end

#define UserAvatarURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/avatar/avatar_%d.png",x]
#define UserAvatarCount 26

#define GroupAvatarURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/group-avatar/group_avatar_%d.png",x]
#define GroupAvatarCount 24

#define Community_coverURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/community-cover/community_cover_%d.png",x]
#define Community_coverCount 12

#define BackGroundCoverURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%d.png",x]

#define BackGroundCoverURL_full(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%d_full.png",x]

#define BackGroundCoverCount 7



@implementation TUISelectAvatarCardItem

@end

@interface TUISelectAvatarCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectedView;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) TUISelectAvatarCardItem *cardItem;

- (void)updateSelectedUI;

@end

@implementation TUISelectAvatarCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  
    if (self) {
    
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
        [self.imageView setUserInteractionEnabled:YES];
    
        self.imageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    
        self.imageView.layer.borderWidth = 2;

        self.imageView.layer.masksToBounds = YES;
    
        [self.contentView addSubview:self.imageView];
    
        [self.imageView addSubview:self.selectedView];
        
        [self setupMaskView];
  }
    
    return self;
    
}

- (void)layoutSubviews {

    [self updateCellView];

    self.selectedView.frame = CGRectMake(self.imageView.frame.size.width - 16 - 4 , 4 ,
                                       16 , 16);
}

- (void)updateCellView {
    [self updateSelectedUI];
    [self updateImageView];
    [self updateMaskView];
}

- (void)updateSelectedUI {
    
    if (self.cardItem.isSelect){
        self.imageView.layer.borderColor = TUICoreDynamicColor(@"", @"#006EFF").CGColor;
        self.selectedView.hidden = NO;
    }
    else {
        if (self.cardItem.isDefaultBackgroundItem) {
            self.imageView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.1].CGColor;
        }
        else {
            self.imageView.layer.borderColor = UIColor.clearColor.CGColor;
        }
        self.selectedView.hidden = YES;
    }
}

- (void)updateImageView {
    if (self.cardItem.isGroupGridAvatar) {
        [self updateNormalGroupGridAvatar];
    }
    else {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.cardItem.posterUrlStr]
                          placeholderImage:TUICoreBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head_img")];
    }
}
- (void)updateMaskView {
    if (self.cardItem.isDefaultBackgroundItem) {
        self.maskView.hidden = NO;
        self.maskView.frame = CGRectMake(0, self.imageView.frame.size.height - 28, self.imageView.frame.size.width, 28);
        [self.descLabel sizeToFit];
        self.descLabel.mm_center();
    }
    else {
        self.maskView.hidden = YES;
    }
}

- (void)updateNormalGroupGridAvatar {
    if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cardItem.cacheGroupGridAvatarImage) {
        [self.imageView sd_setImageWithURL:nil placeholderImage:self.cardItem.cacheGroupGridAvatarImage];
    }
}

- (void)setupMaskView {
    self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.maskView.backgroundColor = [UIColor tui_colorWithHex:@"cccccc"];
    [self.imageView addSubview:self.maskView];
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.text = TUIKitLocalizableString(TUIKitDefaultBackground);
    self.descLabel.textColor = [UIColor whiteColor];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    [self.maskView addSubview:self.descLabel];
    [self.descLabel sizeToFit];
    self.descLabel.mm_center();
}

- (void)setCardItem:(TUISelectAvatarCardItem *)cardItem {
    _cardItem = cardItem;
}

- (UIImageView *)selectedView {
    
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _selectedView.image = [UIImage imageNamed:TUICoreImagePath(@"icon_avatar_selected")];
    }
    return _selectedView;
}


@end

@interface TUISelectAvatarController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) TUISelectAvatarCardItem *currentSelectCardItem;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation TUISelectAvatarController

static NSString * const reuseIdentifier = @"TUISelectAvatarCollectionCell";

- (instancetype)init {
    if (self = [super init]) {
        self.selectAvatarType = TUISelectAvatarTypeUserAvatar;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NavBar_Height - StatusBar_Height);
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    [self.view addSubview:self.collectionView];
    
    self.collectionView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Register cell classes
    [self.collectionView registerClass:[TUISelectAvatarCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self setupNavigator];
    
    self.dataArr = [NSMutableArray arrayWithCapacity:3];
    
    [self loadData];
}
- (void)loadData {
    
    if (self.selectAvatarType == TUISelectAvatarTypeUserAvatar) {
        
        for (int i = 0 ; i< UserAvatarCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:UserAvatarURL(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    else if (self.selectAvatarType == TUISelectAvatarTypeGroupAvatar) {

        if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cacheGroupGridAvatarImage) {
            TUISelectAvatarCardItem *cardItem = [self creatGroupGridAvatarCardItem];
            [self.dataArr addObject:cardItem];
        }
        
        for (int i = 0 ; i< GroupAvatarCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:GroupAvatarURL(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    else if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        TUISelectAvatarCardItem *cardItem = [self creatCleanCardItem];
        [self.dataArr addObject:cardItem];
        for (int i = 0 ; i < BackGroundCoverCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:BackGroundCoverURL(i+1) fullUrl:BackGroundCoverURL_full(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    
    else {
        for (int i = 0 ; i< Community_coverCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:Community_coverURL(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    [self.collectionView reloadData];

}

- (TUISelectAvatarCardItem *)creatCardItemByURL:(NSString *)urlStr {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = urlStr;
    cardItem.isSelect = NO;
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL] ) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (TUISelectAvatarCardItem *)creatGroupGridAvatarCardItem {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = nil;
    cardItem.isSelect = NO;
    cardItem.isGroupGridAvatar = YES;
    cardItem.createGroupType = self.createGroupType;
    cardItem.cacheGroupGridAvatarImage = self.cacheGroupGridAvatarImage;
    if (!self.profilFaceURL) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (TUISelectAvatarCardItem *)creatCardItemByURL:(NSString *)urlStr fullUrl:(NSString *)fullUrl {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = urlStr;
    cardItem.fullUrlStr = fullUrl;
    cardItem.isSelect = NO;
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL]
        || [cardItem.fullUrlStr isEqualToString:self.profilFaceURL]) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (TUISelectAvatarCardItem *)creatCleanCardItem {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = nil;
    cardItem.isSelect = NO;
    cardItem.isDefaultBackgroundItem = YES;
    if (self.profilFaceURL.length == 0 ) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}
- (void)setupNavigator{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    if (self.selectAvatarType == TUISelectAvatarTypeCover) {
        [self.titleView setTitle:TUIKitLocalizableString(TUIKitChooseCover)];
    }
    else if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        [self.titleView setTitle:TUIKitLocalizableString(TUIKitChooseBackground)];
    }
    else {
        [self.titleView setTitle:TUIKitLocalizableString(TUIKitChooseAvatar)];
    }
    
    self.rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.rightButton setTitle:TUIKitLocalizableString(Save) forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItems = @[rightItem];
}

- (void)setCurrentSelectCardItem:(TUISelectAvatarCardItem *)currentSelectCardItem {
    _currentSelectCardItem = currentSelectCardItem;
    if (_currentSelectCardItem) {
        [self.rightButton setTitleColor:TUICoreDynamicColor(@"", @"#006EFF") forState:UIControlStateNormal];
    }
    else {
        [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}
- (void)rightBarButtonClick {
    
    if (!self.currentSelectCardItem) {
        return;
    }
    
    if (self.selectCallBack) {
        if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
            if (IS_NOT_EMPTY_NSSTRING(self.currentSelectCardItem.fullUrlStr)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TUITool makeToastActivity];
                });
                @weakify(self)
                [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[[NSURL URLWithString:self.currentSelectCardItem.fullUrlStr]] progress:nil completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                    @strongify(self);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [TUITool hideToastActivity];
                            [TUITool makeToast:TUIKitLocalizableString(TUIKitChooseBackgroundSuccess)];
                            if (self.selectCallBack) {
                                self.selectCallBack(self.currentSelectCardItem.fullUrlStr);
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            
                        });
                    });
                    
                }];
            }
            else {
                [TUITool makeToast:TUIKitLocalizableString(TUIKitChooseBackgroundSuccess)];
                self.selectCallBack(self.currentSelectCardItem.fullUrlStr);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            self.selectCallBack(self.currentSelectCardItem.posterUrlStr);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat margin = 15;

    CGFloat padding = 13;

    int rowCount = 4.0;

    if (self.selectAvatarType == TUISelectAvatarTypeCover ||
        self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        rowCount = 2.0;
    }
    else {
        rowCount = 4.0;
    }
    
    CGFloat width = (self.view.frame.size.width - 2 * margin - (rowCount - 1) * padding) /rowCount ;
    
    CGFloat height = 77;
    if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        height = 125;
    }
    
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(24, 15, 0, 15);
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArr count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUISelectAvatarCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // Configure the cell
    
    if (indexPath.row < self.dataArr.count) {
        cell.cardItem = self.dataArr[indexPath.row];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self recoverSelectedStatus];
    
    TUISelectAvatarCollectionCell *cell= (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    if (self.currentSelectCardItem == cell.cardItem ) {
        self.currentSelectCardItem = nil;
    }
    else {
        cell.cardItem.isSelect = YES;
        [cell updateSelectedUI];
        self.currentSelectCardItem = cell.cardItem;
    }
}

- (void)recoverSelectedStatus {
    NSInteger index = 0;
    for (TUISelectAvatarCardItem *card in self.dataArr) {
        if (self.currentSelectCardItem == card) {
            card.isSelect = NO;
            break;
        }
        index++;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    TUISelectAvatarCollectionCell *cell= (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    [cell updateSelectedUI];
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonAvatarCell & Data
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonAvatarCellData
- (instancetype)init {
    self = [super init];
    if(self){
         _avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin;
}

@end

@interface TUICommonAvatarCell()
@property TUICommonAvatarCellData *avatarData;
@end

@implementation TUICommonAvatarCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        [self setupViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(TUICommonAvatarCellData *) avatarData
{
    [super fillWithData:avatarData];

    self.avatarData = avatarData;

    RAC(_keyLabel, text) = [RACObserve(avatarData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(avatarData, value) takeUntil:self.rac_prepareForReuseSignal];
     @weakify(self)
    [[RACObserve(avatarData, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
    }];

    if (avatarData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setupViews
{
    CGSize headSize = TPersonalCommonCell_Image_Size;
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(TPersonalCommonCell_Margin, TPersonalCommonCell_Margin, headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFit;

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self addSubview:_avatar];

    _keyLabel = self.textLabel;
    _valueLabel = self.detailTextLabel;

    [self addSubview:_keyLabel];
    [self addSubview:_valueLabel];
    
    self.keyLabel.textColor = TUICoreDynamicColor(@"form_key_text_color", @"#444444");
    self.valueLabel.textColor = TUICoreDynamicColor(@"form_value_text_color", @"#000000");

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    //_avatar.mm_top(self.mm_maxY - TPersonalCommonCell_Margin).mm_left(self.mm_maxX - 100);
    CGFloat margin = self.avatarData.showAccessory ? 20 : 0;
    _avatar.mm_left(self.mm_maxX - 16 - TPersonalCommonCell_Image_Size.width - margin);

}

@end

@interface IUCoreView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUCoreView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end

@implementation TUINavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor =  self.tintColor;
        self.navigationBar.backgroundColor = self.tintColor;
        self.navigationBar.barTintColor = self.tintColor;
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance= appearance;

    }
    else {
        self.navigationBar.backgroundColor = self.tintColor;
        self.navigationBar.barTintColor = self.tintColor;
        self.navigationBar.shadowImage = [UIImage new];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    self.delegate = self;

}

- (void)back {
    if ([self.uiNaviDelegate respondsToSelector:@selector(navigationControllerDidClickLeftButton:)]) {
        [self.uiNaviDelegate navigationControllerDidClickLeftButton:self];
    }
    [self popViewControllerAnimated:YES];
}

- (UIColor *)tintColor
{
    return TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(self.viewControllers.count != 0){
        viewController.hidesBottomBarWhenPushed = YES;
        self.tabBarController.tabBar.hidden = YES;
        
        UIImage *image = self.navigationItemBackArrowImage;
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        viewController.navigationItem.leftBarButtonItems = @[back];
        viewController.navigationItem.leftItemsSupplementBackButton = NO;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIImage *)navigationItemBackArrowImage {
    if (!_navigationItemBackArrowImage) {
        _navigationItemBackArrowImage = TUICoreDynamicImage(@"nav_back_img", [UIImage imageNamed:@"ic_back_white"]);
    }
    return _navigationItemBackArrowImage;
}


// fix: https://developer.apple.com/forums/thread/660750
- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (@available(iOS 14.0, *)) {
        for (UIViewController *vc in self.viewControllers) {
            vc.hidesBottomBarWhenPushed = NO;
            self.tabBarController.tabBar.hidden = NO;
        }
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count == 1){
        /**
         * 如果堆栈内的视图控制器数量为1 说明只有根控制器，将 currentShowVC 清空，为了下面的方法禁用侧滑手势
         * If the number of view controllers in the stack is 1, it means only the root controller, clear the currentShowVC, and disable the swipe gesture for the following method
         */
        self.currentShowVC = Nil;
    }
    else{
        /**
         * 将 push 进来的视图控制器赋值给 currentShowVC
         * Assign the pushed view controller to currentShowVC
         */
        self.currentShowVC = viewController;
    }

    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.viewControllers.count == 1) {
            /**
             * 禁止首页的侧滑返回
             * Forbid the sliding back of the home page
             */
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        }else{
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    /**
     * 监听侧边滑动返回的事件
     * Listen to the event returned by the side slide
     */
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *)) {
        [viewController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf handleSideSlideReturnIfNeeded:context];
        }];
    } else {
        [viewController.transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf handleSideSlideReturnIfNeeded:context];
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.currentShowVC == self.topViewController) {
            /**
             * 如果 currentShowVC 存在说明堆栈内的控制器数量大于 1 ，允许激活侧滑手势
             * If currentShowVC exists, it means that the number of controllers in the stack is greater than 1, allowing the side slide gesture to be activated
             */
            return YES;
        }
        return NO;
    }
    return YES;
}

- (void)handleSideSlideReturnIfNeeded:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if (context.isCancelled) {
        return;
    }
    UIViewController *fromVc = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([self.uiNaviDelegate respondsToSelector:@selector(navigationControllerDidSideSlideReturn:fromViewController:)]) {
        [self.uiNaviDelegate navigationControllerDidSideSlideReturn:self fromViewController:fromVc];
    }
}

@end

@implementation UIAlertController (TUITheme)
 
- (void)tuitheme_addAction:(UIAlertAction *)action {
    if (action.style == UIAlertActionStyleDefault || action.style == UIAlertActionStyleCancel) {
        UIColor *tempColor = TUICoreDynamicColor(@"primary_theme_color", @"#147AFF");
        [action setValue:tempColor forKey:@"_titleTextColor"];
    }
    [self addAction:action];
}

@end
