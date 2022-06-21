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
    CGFloat labelY = 0;
    CGFloat labelX = _indicator.hidden ? 0 : (_indicator.frame.origin.x + _indicator.frame.size.width + TUINaviBarIndicatorView_Margin);
    _label.frame = CGRectMake(labelX, labelY, labelSize.width, NavBar_Height);
    self.frame = CGRectMake(0, 0, labelX + labelSize.width + TUINaviBarIndicatorView_Margin, NavBar_Height);
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
    return 48;
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
            //对于背景色为绿色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
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
            //对于背景色为蓝色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
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

//本函数实现了生成纯色背景的功能，从而配合 setBackgroundImage: forState: 来实现高亮时纯色按钮的点击反馈。
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

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIUnReadView（会话未读数）
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
//                          TUIConversationPin（会话置顶）
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
//                          TUIGroupAvatar（九宫格群头像）
//
/////////////////////////////////////////////////////////////////////////////////
#define groupAvatarWidth (48*[[UIScreen mainScreen] scale])
@implementation TUIGroupAvatar

+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger avatarCount = group.count > 9 ? 9 : group.count;
        CGFloat width = groupAvatarWidth / 3 * 0.90;
        CGFloat space3 = (groupAvatarWidth - width * 3) / 4;                      // 三张图时的边距（图与图之间的边距）
        CGFloat space2 = (groupAvatarWidth - width * 2 + space3) / 2;             // 两张图时的边距
        CGFloat space1 = (groupAvatarWidth - width) / 2;                          // 一张图时的边距
        __block CGFloat y = avatarCount > 6 ? space3 : (avatarCount > 3 ? space2 : space1);
        __block CGFloat x = avatarCount  % 3 == 0 ? space3 : (avatarCount % 3 == 2 ? space2 : space1);
        width = avatarCount > 4 ? width : (avatarCount > 1 ? (groupAvatarWidth - 3 * space3) / 2 : groupAvatarWidth );  // 重新计算width；
        
        if (avatarCount == 1) {                                          // 1,2,3,4 张图不同
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
            __block NSInteger count = 0;               //下载图片完成的计数
            for (NSInteger i = avatarCount - 1; i >= 0; i--) {
                NSString *avatarUrl = [group objectAtIndex:i];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                [view addSubview:imageView];
                [imageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:DefaultAvatarImage completed:^(UIImage * _Nullable image,
                                                                                                                              NSError * _Nullable error,
                                                                                                                              SDImageCacheType cacheType,
                                                                                                                              NSURL * _Nullable imageURL) {
                    count ++ ;
                    if (count == avatarCount) {     //图片全部下载完成
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
    // 获取群组前9个成员的头像url
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        int i = 0;
        NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
        for (V2TIMGroupMemberFullInfo* member in memberList) {
            if (member.faceURL.length > 0) {
                [groupMemberAvatars addObject:member.faceURL];
                i++;
            }
            if (i == 9) {
                break;
            }
        }
        
        // 存储当前获取到的群组头像信息
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
        [NSUserDefaults.standardUserDefaults setInteger:groupMemberAvatars.count forKey:key];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        // 创建九宫格头像
        [TUIGroupAvatar createGroupAvatar:groupMemberAvatars finished:^(UIImage *groupAvatar) {
            @strongify(self)
            // 缓存
            UIImage *avatar = groupAvatar;
            [self cacheGroupAvatar:avatar number:(UInt32)groupMemberAvatars.count groupID:groupID];
            
            // 回调
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

/// 缓存群组头像
/// @param avatar 图片
/// 取缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化取不到缓存
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

/// 获取缓存群组头像
/// 缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化要引起头像改变
+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void(^)(UIImage *))imageCallBack {
    if (groupID == nil || groupID.length == 0) {
        if (imageCallBack) {
            imageCallBack(nil);
        }
        return;
    }
    [[V2TIMManager sharedInstance] getGroupsInfo:@[groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *groupInfo = groupResultList.firstObject;
        if (!groupInfo) {
            imageCallBack(nil);
            return;
        }
        UInt32 memberNum = groupInfo.info.memberCount;
        //限定1-9的范围
        memberNum = MAX(1, memberNum);
        memberNum = MIN(memberNum, 9);;
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath, groupID, (unsigned int)memberNum];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        UIImage *avatar = nil;
        BOOL success = [fileManager fileExistsAtPath:filePath];

        if (success) {
            avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
            // 存储当前获取到的群组头像信息
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
            [NSUserDefaults.standardUserDefaults setInteger:memberNum forKey:key];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        imageCallBack(avatar);
    } fail:^(int code, NSString *msg) {
        imageCallBack(nil);
    }];
}


/// 同步获取本地缓存的群组头像
/// @param groupId 群id
/// @param memberNum 群成员个数, 最多返回9个成员的拼接头像
+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum
{
    //限定1-9的范围
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
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIImageCache（图像资源、表情资源缓存与加载）
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
        [strongSelf.resourceCache setValue:image forKey:key];
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
        [strongSelf.faceCache setValue:image forKey:key];
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
            image = [_faceCache objectForKey:TUIChatFaceImagePath(@"del_normal")];
        }
    }
    return image;
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactSelectCellData（通讯录联系人信息）
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
//                          TUICommonContactListPickerCell（通讯录多选视图的cell）
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

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIContactListPickerOnCancel（通讯录多选视图）
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
    [self.accessoryBtn setTitle:[NSString stringWithFormat:@" %@ ", TUIKitLocalizableString(Confirm)] forState:UIControlStateNormal]; // @" 确定 "
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
        //iOS15新增特性：滑动边界样式
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
    [self popViewControllerAnimated:YES];
}

- (UIColor *)tintColor
{
    return TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //push的时候隐藏底部tabbar
    if(self.viewControllers.count != 0){
        viewController.hidesBottomBarWhenPushed = YES;
        self.tabBarController.tabBar.hidden = YES;
        
        UIImage *image = TUIDemoDynamicImage(@"nav_back_img", [UIImage imageNamed:@"ic_back_white"]);
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        viewController.navigationItem.leftBarButtonItems = @[back];
        viewController.navigationItem.leftItemsSupplementBackButton = NO;
    }
    [super pushViewController:viewController animated:animated];
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
        //如果堆栈内的视图控制器数量为1 说明只有根控制器，将currentShowVC 清空，为了下面的方法禁用侧滑手势
        self.currentShowVC = Nil;
    }
    else{
        //将push进来的视图控制器赋值给currentShowVC
        self.currentShowVC = viewController;
    }

    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.viewControllers.count == 1) {// 禁止首页的侧滑返回
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        }else{
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.currentShowVC == self.topViewController) {
            //如果 currentShowVC 存在说明堆栈内的控制器数量大于 1 ，允许激活侧滑手势
            return YES;
        }
        return NO;
    }
    return YES;
}

@end

@implementation UIAlertController (TUITheme)

+ (void)load {
    // 只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hookMethod:self originSelector:@selector(addAction:) swizzledSelector:@selector(tuitheme_addAction:) classMethod:NO];
    });
}
 
- (void)tuitheme_addAction:(UIAlertAction *)action {
    if (action.style == UIAlertActionStyleDefault || action.style == UIAlertActionStyleCancel) {
        UIColor *tempColor = TUICoreDynamicColor(@"primary_theme_color", @"#147AFF");
        [action setValue:tempColor forKey:@"_titleTextColor"];
    }
    [self tuitheme_addAction:action];
}

+ (void)hookMethod:(Class)cls originSelector:(SEL)originSelector swizzledSelector:(SEL)swizzledSelector classMethod:(BOOL)clsMethod {
    
    Method origin_method;
    Method swizzled_method;
    
    if (clsMethod) {
        // 类方法
        origin_method = class_getClassMethod(cls, originSelector);
        swizzled_method = class_getClassMethod(cls, swizzledSelector);
    } else {
        // 实例(对象)方法
        origin_method = class_getInstanceMethod(cls, originSelector);
        swizzled_method = class_getInstanceMethod(cls, swizzledSelector);
    }
    
    BOOL addSuccess = class_addMethod(cls,
                                      originSelector,
                                      method_getImplementation(swizzled_method),
                                      method_getTypeEncoding(swizzled_method)
                                      );
    if (addSuccess) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(origin_method),
                            method_getTypeEncoding(origin_method)
                            );
    } else {
        method_exchangeImplementations(origin_method, swizzled_method);
    }
}

@end
