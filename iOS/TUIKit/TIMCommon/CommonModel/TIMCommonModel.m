//
//  TIMCommonModel.m
//  TIMCommon
//
//  Created by cologne on 2023/3/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TIMCommonModel.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIPopView
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIPopView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property(nonatomic, strong) NSMutableArray *data;
@end

@implementation TUIPopView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setData:(NSMutableArray *)data {
    _data = data;
    [_tableView reloadData];
}

- (void)showInWindow:(UIWindow *)window {
    [window addSubview:self];
    __weak typeof(self) ws = self;
    self.alpha = 0;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       ws.alpha = 1;
                     }
                     completion:nil];
}

- (void)setupViews {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:pan];

    self.backgroundColor = [UIColor clearColor];
    CGSize arrowSize = TUIPopView_Arrow_Size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + arrowSize.height, self.frame.size.width,
                                                               self.frame.size.height - arrowSize.height)];
    self.frame = [UIScreen mainScreen].bounds;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = TUIDemoDynamicColor(@"pop_bg_color", @"#FFFFFF");
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.scrollEnabled = NO;
    _tableView.layer.cornerRadius = 5.0;
    [self addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TUIPopCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIPopCell *cell = [tableView dequeueReusableCellWithIdentifier:TUIPopCell_ReuseId];
    if (!cell) {
        cell = [[TUIPopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TUIPopCell_ReuseId];
    }
    [cell setData:_data[indexPath.row]];
    if (indexPath.row == _data.count - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(popView:didSelectRowAtIndex:)]) {
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

- (void)onTap:(UIGestureRecognizer *)recognizer {
    [self hide];
}

- (void)hide {
    __weak typeof(self) ws = self;
    self.alpha = 1;
    [UIView animateWithDuration:0.25
        delay:0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
          ws.alpha = 0;
        }
        completion:^(BOOL finished) {
          if ([ws superview]) {
              [ws removeFromSuperview];
          }
        }];
}
@end

@implementation TUIPopCellData
@end

@implementation TUIPopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
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

- (void)layoutSubviews {
    CGFloat headHeight = TUIPopCell_Height - 2 * TUIPopCell_Padding;
    self.image.frame = CGRectMake(TUIPopCell_Padding, TUIPopCell_Padding, headHeight, headHeight);
    self.image.center = CGPointMake(self.image.center.x, self.contentView.center.y);

    CGFloat titleWidth = self.frame.size.width - 2 * TUIPopCell_Padding - TUIPopCell_Margin - _image.frame.size.width;
    self.title.frame =
        CGRectMake(_image.frame.origin.x + _image.frame.size.width + TUIPopCell_Margin, TUIPopCell_Padding, titleWidth, self.contentView.bounds.size.height);
    self.title.center = CGPointMake(self.title.center.x, self.contentView.center.y);
    
    if (isRTL()) {
        [self.image resetFrameToFitRTL];
        [self.title resetFrameToFitRTL];
    }
}

- (void)setData:(TUIPopCellData *)data {
    _image.image = data.image;
    _title.text = data.title;
}

+ (CGFloat)getHeight {
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
@property(nonatomic, assign) BOOL keyboardShowing;
@property(nonatomic, strong) TUIModifyViewData *data;
@property(nonatomic, strong) UIButton *closeBtn;
@end

@implementation TUIModifyView
- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
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
    _title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
    _title.textColor = TUIGroupDynamicColor(@"group_modify_title_color", @"#000000");
    _title.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_title];

    _hLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame), kContainerWidth, TLine_Heigh)];
    _hLine.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#E4E5E9");
    [_container addSubview:_hLine];

    CGFloat contentMargin = 20;
    CGFloat contentWidth = _container.frame.size.width - 2 * contentMargin;
    CGFloat contentY = CGRectGetMaxY(_hLine.frame) + 17;
    CGFloat contentheight = 40;
    _content = [[UITextField alloc] initWithFrame:CGRectMake(contentMargin, contentY, contentWidth, contentheight)];
    _content.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
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
    [_confirm setTitle:TIMCommonLocalizableString(Confirm) forState:UIControlStateNormal];
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

- (void)setData:(TUIModifyViewData *)data {
    _title.text = data.title;
    _content.text = data.content;
    _descLabel.text = data.desc;
    _data = data;

    CGRect rect = [data.desc boundingRectWithSize:CGSizeMake(self.content.bounds.size.width, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0]}
                                          context:nil];
    CGRect frame = _descLabel.frame;
    frame.size.height = rect.size.height;
    _descLabel.frame = frame;

    [self textChanged];
}

- (void)showInWindow:(UIWindow *)window {
    [window addSubview:self];
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.confirm.frame) + 50;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       ws.container.frame = CGRectMake(0, Screen_Height - height, kContainerWidth, height);
                     }
                     completion:nil];
}

- (void)onTap:(UIGestureRecognizer *)recognizer {
    [_content resignFirstResponder];

    if (!self.keyboardShowing) {
        [self hide];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isEqual:self];
}

- (void)hide {
    __weak typeof(self) ws = self;
    self.alpha = 1;
    [UIView animateWithDuration:0.25
        delay:0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
          ws.alpha = 0;
        }
        completion:^(BOOL finished) {
          [[NSNotificationCenter defaultCenter] removeObserver:ws];
          if ([ws superview]) {
              [ws removeFromSuperview];
          }
        }];
}

- (void)didCancel:(UIButton *)sender {
    [self hide];
}

- (void)didConfirm:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(modifyView:didModiyContent:)]) {
        [_delegate modifyView:self didModiyContent:_content.text];
    }
    [self hide];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textChanged {
    [self enableConfirmButton:(self.content.text.length || self.data.enableNull)];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardShowing = keyboardFrame.size.height > 0;
    [self animateContainer:keyboardFrame.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self animateContainer:0];
}

- (void)keyboardDidHide:(NSNotification *)notice {
    self.keyboardShowing = NO;
}

- (void)animateContainer:(CGFloat)keyboardHeight {
    CGFloat height = CGRectGetMaxY(self.confirm.frame) + 50;
    CGRect frame = _container.frame;
    frame.origin.y = Screen_Height - height - keyboardHeight;  //(self.frame.size.height - keyboardHeight - frame.size.height) * 0.5;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       ws.container.frame = frame;
                     }
                     completion:nil];
}

- (void)enableConfirmButton:(BOOL)enable {
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
- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _indicator.center = CGPointMake(0, NavBar_Height * 0.5);
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:_indicator];

    _label = [[UILabel alloc] init];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont boldSystemFontOfSize:17];
    _label.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [self addSubview:_label];
    _maxLabelLength = 150;
}

- (void)setTitle:(NSString *)title {
    _label.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    _label.text = title;
    [self updateLayout];
}

- (void)updateLayout {
    [_label sizeToFit];
    CGSize labelSize = _label.bounds.size;  // [_label sizeThatFits:CGSizeMake(Screen_Width, NavBar_Height)];
    CGFloat labelWidth = MIN(labelSize.width, _maxLabelLength);
    CGFloat labelY = 0;
    CGFloat labelX = _indicator.hidden ? 0 : (_indicator.frame.origin.x + _indicator.frame.size.width + TUINaviBarIndicatorView_Margin);
    _label.frame = CGRectMake(labelX, labelY, labelWidth, NavBar_Height);
    self.frame = CGRectMake(0, 0, labelX + labelWidth + TUINaviBarIndicatorView_Margin, NavBar_Height);
    //    self.center = CGPointMake(Screen_Width * 0.5, NavBar_Height * 0.5);
}

- (void)startAnimating {
    [_indicator startAnimating];
}

- (void)stopAnimating {
    [_indicator stopAnimating];
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUICommonCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonCellData

- (CGFloat)heightOfWidth:(CGFloat)width {
    return 60;
}

- (CGFloat)estimatedHeight {
    return 60;
}

@end

@interface TUICommonTableViewCell () <UIGestureRecognizerDelegate>
@property TUICommonCellData *data;
@property UITapGestureRecognizer *tapRecognizer;
@end

@implementation TUICommonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _tapRecognizer.delegate = self;
        _tapRecognizer.cancelsTouchesInView = NO;

        self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    }
    return self;
}

- (void)tapGesture:(UIGestureRecognizer *)gesture {
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

- (void)fillWithData:(TUICommonCellData *)data {
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
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:16]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(280, 999)
                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil]
                          .size;
        height = size.height + 30;
    }
    return height;
}

@end

@interface TUICommonTextCell ()
@property TUICommonTextCellData *textData;
@end

@implementation TUICommonTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");

        _keyLabel = [[UILabel alloc] init];
        _keyLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#444444");
        _keyLabel.font = [UIFont systemFontOfSize:16.0];
        [self.contentView addSubview:_keyLabel];
        [_keyLabel setRtlAlignment:TUITextRTLAlignmentTrailing];
        
        _valueLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_valueLabel];
        _valueLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
        _valueLabel.font = [UIFont systemFontOfSize:16.0];
        [_valueLabel setRtlAlignment:TUITextRTLAlignmentTrailing];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(TUICommonTextCellData *)textData {
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
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];

    [self.keyLabel sizeToFit];
    [self.keyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.keyLabel.frame.size);
        make.leading.mas_equalTo(self.contentView).mas_offset(self.textData.keyEdgeInsets.left);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.valueLabel sizeToFit];
    [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.keyLabel.mas_trailing).mas_offset(10);
        if (self.textData.showAccessory) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
        }
        else {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-20);
        }
        make.centerY.mas_equalTo(self.contentView);
    }];
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
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil]
                          .size;
        height += size.height + 10;
    }
    return height;
}

@end

@interface TUICommonSwitchCell ()

@property TUICommonSwitchCellData *switchData;
@property(nonatomic, strong) UIView *leftSeparatorLine;

@end

@implementation TUICommonSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#444444");
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleLabel setRtlAlignment:TUITextRTLAlignmentLeading];
        [self.contentView addSubview:_titleLabel];

        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = TIMCommonDynamicColor(@"group_modify_desc_color", @"#888888");
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.numberOfLines = 0;
        [_descLabel setRtlAlignment:TUITextRTLAlignmentLeading];
        _descLabel.hidden = YES;
        [self.contentView addSubview:_descLabel];

        _switcher = [[UISwitch alloc] init];
        _switcher.onTintColor = TIMCommonDynamicColor(@"common_switch_on_color", @"#147AFF");
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
}

- (void)fillWithData:(TUICommonSwitchCellData *)switchData {
    [super fillWithData:switchData];

    self.switchData = switchData;
    _titleLabel.text = switchData.title;
    [_switcher setOn:switchData.isOn];
    _descLabel.text = switchData.desc;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    if (self.switchData.disableChecked) {
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.alpha = 0.4;
        _switcher.alpha = 0.4;
        self.userInteractionEnabled = NO;
    } else {
        _titleLabel.alpha = 1;
        _switcher.alpha = 1;
        _titleLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#444444");
        _switcher.onTintColor = TIMCommonDynamicColor(@"common_switch_on_color", @"#147AFF");
        self.userInteractionEnabled = YES;
    }

    CGFloat leftMargin = 0;
    CGFloat padding = 5;
    if (self.switchData.displaySeparatorLine) {
        _leftSeparatorLine.mm_width(10).mm_height(2).mm_left(self.switchData.margin).mm__centerY(self.contentView.mm_h / 2);
        leftMargin = self.switchData.margin + _leftSeparatorLine.mm_w + padding;
    } else {
        _leftSeparatorLine.mm_width(0).mm_height(0);
        leftMargin = self.switchData.margin;
    }

    if (self.switchData.desc.length > 0) {
        _descLabel.text = self.switchData.desc;
        _descLabel.hidden = NO;
        NSString *str = self.switchData.desc;
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil]
                          .size;
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(24);
            make.leading.mas_equalTo(leftMargin);
            make.top.mas_equalTo(12);
        }];
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(size.height);
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(2);
        }];
    } else {
        _descLabel.text = @"";
        [self.titleLabel sizeToFit];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.titleLabel.frame.size);
            make.leading.mas_equalTo(self.switchData.margin);
            make.centerY.mas_equalTo(self.contentView);
        }];
    }
}
- (void)switchClick {
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
    _toUser = args.toUser;
    if (args.fromUserNickName.length > 0) {
        _title = args.fromUserNickName;
    } else {
        _title = args.fromUser;
    }
    _avatarUrl = [NSURL URLWithString:args.fromUserFaceUrl];
    _requestMsg = args.requestMsg;
    if (_requestMsg.length == 0) {
        if (args.applicationType == V2TIM_GROUP_INVITE_APPLICATION_NEED_APPROVED_BY_ADMIN) {
            _requestMsg = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitInviteJoinGroupFormat), _toUser];
        } else {
            _requestMsg = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitWhoRequestForJoinGroupFormat), _title];
        }
    }

    return self;
}

- (void)accept {
    [[V2TIMManager sharedInstance] acceptGroupApplication:_pendencyItem
        reason:TIMCommonLocalizableString(TUIKitAgreedByAdministor)
        succ:^{
          [TUITool makeToast:TIMCommonLocalizableString(Have_been_sent)];
          [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];
          ;
        }
        fail:^(int code, NSString *msg) {
          [TUITool makeToastError:code msg:msg];
        }];
    self.isAccepted = YES;
}
- (void)reject {
    [[V2TIMManager sharedInstance] refuseGroupApplication:_pendencyItem
        reason:TIMCommonLocalizableString(TUIkitDiscliedByAdministor)
        succ:^{
          [TUITool makeToast:TIMCommonLocalizableString(Have_been_sent)];
          [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];
          ;
        }
        fail:^(int code, NSString *msg) {
          [TUITool makeToastError:code msg:msg];
        }];
    self.isRejectd = YES;
}

@end

@implementation TUIGroupPendencyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self.contentView addSubview:self.avatarView];
    self.avatarView.mm_width(54).mm_height(54).mm__centerY(38).mm_left(12);

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor darkTextColor];
    self.titleLabel.mm_left(self.avatarView.mm_maxX + 12).mm_top(14).mm_height(20).mm_width(120);

    self.addWordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.addWordingLabel];
    self.addWordingLabel.textColor = [UIColor lightGrayColor];
    self.addWordingLabel.font = [UIFont systemFontOfSize:15];
    self.addWordingLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY + 6).mm_height(15).mm_width(self.mm_w - self.titleLabel.mm_x - 80);

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

- (void)fillWithData:(TUIGroupPendencyCellData *)pendencyData {
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    self.addWordingLabel.text = pendencyData.requestMsg;
    self.avatarView.image = DefaultAvatarImage;
    if (pendencyData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl placeholderImage:[UIImage imageNamed:TIMCommonImagePath(@"default_c2c_head")]];
    }

    @weakify(self);
    [[RACObserve(pendencyData, isAccepted) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *isAccepted) {
      @strongify(self);
      if ([isAccepted boolValue]) {
          [self.agreeButton setTitle:TIMCommonLocalizableString(Agreed) forState:UIControlStateNormal];
          self.agreeButton.enabled = NO;
          [self.agreeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
          self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
      }
    }];
    [[RACObserve(pendencyData, isRejectd) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *isAccepted) {
      @strongify(self);
      if ([isAccepted boolValue]) {
          [self.agreeButton setTitle:TIMCommonLocalizableString(Disclined) forState:UIControlStateNormal];
          self.agreeButton.enabled = NO;
          [self.agreeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
          self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
      }
    }];

    if (!(pendencyData.isAccepted || pendencyData.isRejectd)) {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        [self.agreeButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        self.agreeButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
    }
    self.agreeButton.mm_sizeToFit().mm_width(self.agreeButton.mm_w + 20);
}

- (void)agreeClick {
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
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

- (CGFloat)heightOfWidth:(CGFloat)width {
    return TButtonCell_Height;
}
@end

@implementation TUIButtonCell {
    UIView *_line;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");

    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:_button];

    [self setSeparatorInset:UIEdgeInsetsMake(0, Screen_Width, 0, 0)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.changeColorWhenTouched = YES;

    _line = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_line];
    _line.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
}

- (void)fillWithData:(TUIButtonCellData *)data {
    [super fillWithData:data];
    self.buttonData = data;
    [_button setTitle:data.title forState:UIControlStateNormal];
    switch (data.style) {
        case ButtonGreen: {
            [_button setTitleColor:TIMCommonDynamicColor(@"form_green_button_text_color", @"#FFFFFF") forState:UIControlStateNormal];
            _button.backgroundColor = TIMCommonDynamicColor(@"form_green_button_bg_color", @"#232323");
            [_button setBackgroundImage:[self imageWithColor:TIMCommonDynamicColor(@"form_green_button_highlight_bg_color", @"#179A1A")]
                               forState:UIControlStateHighlighted];
        } break;
        case ButtonWhite: {
            [_button setTitleColor:TIMCommonDynamicColor(@"form_white_button_text_color", @"#000000") forState:UIControlStateNormal];
            _button.backgroundColor = TIMCommonDynamicColor(@"form_white_button_bg_color", @"#FFFFFF");
        } break;
        case ButtonRedText: {
            [_button setTitleColor:TIMCommonDynamicColor(@"form_redtext_button_text_color", @"#FF0000") forState:UIControlStateNormal];
            _button.backgroundColor = TIMCommonDynamicColor(@"form_redtext_button_bg_color", @"#FFFFFF");

            break;
        }
        case ButtonBule: {
            [_button.titleLabel setTextColor:TIMCommonDynamicColor(@"form_blue_button_text_color", @"#FFFFFF")];
            _button.backgroundColor = TIMCommonDynamicColor(@"form_blue_button_bg_color", @"#1E90FF");
            [_button setBackgroundImage:[self imageWithColor:TIMCommonDynamicColor(@"form_blue_button_highlight_bg_color", @"#1978D5")]
                               forState:UIControlStateHighlighted];
        } break;
        default:
            break;
    }

    if (data.textColor) {
        [_button setTitleColor:data.textColor forState:UIControlStateNormal];
    }

    _line.hidden = data.hideSeparatorLine;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _button.mm_width(Screen_Width - 2 * TButtonCell_Margin).mm_height(self.mm_h - TButtonCell_Margin).mm_left(TButtonCell_Margin);

    _line.mm_width(Screen_Width).mm_height(0.2).mm_left(20).mm_bottom(0);
}

- (void)onClick:(UIButton *)sender {
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

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    if (subview != self.contentView) {
        [subview removeFromSuperview];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
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
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews {
    _face = [[UIImageView alloc] init];
    _face.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_face];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self addGestureRecognizer:longPress];
    [self setUserInteractionEnabled:YES];
}

- (void)defaultLayout {
    CGSize size = self.frame.size;
    _face.frame = CGRectMake(0, 0, size.width, size.height);
}
#define kTUIFaceCellAllowDynamicImageShow 0
- (void)setData:(TUIFaceCellData *)data {
    if (!kTUIFaceCellAllowDynamicImageShow) {
        UIImage * image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
        SDImageFormat imageFormat = [image sd_imageFormat];
        if (SDImageFormatGIF == imageFormat ) {
            self.gifImage = image;
            if (image.images.count > 1) {
                self.staicImage = image.images[0];
            }
        }
        else {
            self.staicImage = image;
        }
        
        _face.image = self.staicImage;
    }
    else {
        _face.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    }
    [self defaultLayout];
}

- (void)onLongPress:(UILongPressGestureRecognizer *)longPress {
    if (self.longPressCallback) {
        self.longPressCallback(longPress);
    }
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIFaceGroup
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIFaceGroup

- (NSDictionary *)facesMap {
    if (!_facesMap || (_facesMap.count != _faces.count )) {
        NSMutableDictionary *faceDic = [NSMutableDictionary dictionaryWithCapacity:3];
        if (_faces.count > 0) {
            for (TUIFaceCellData *data in _faces) {
                [faceDic setObject:data.path forKey:data.name];
            }
        }
        _facesMap = [NSDictionary dictionaryWithDictionary:faceDic];
    }
    return _facesMap;
}
@end

@implementation TUIEmojiTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    return CGRectMake( 0 , -0.4* lineFrag.size.height, kTIMDefaultEmojiSize.width , kTIMDefaultEmojiSize.height);
}

@end
/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIUnReadView
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIUnReadView
- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setNum:(NSInteger)num {
    NSString *unReadStr = [[NSNumber numberWithInteger:num] stringValue];
    if (num > 99) {
        unReadStr = @"99+";
    }
    _unReadLabel.text = unReadStr;
    self.hidden = (num == 0 ? YES : NO);
    [self defaultLayout];
}

- (void)setupViews {
    _unReadLabel = [[UILabel alloc] init];
    _unReadLabel.text = @"11";
    _unReadLabel.font = [UIFont systemFontOfSize:12];
    _unReadLabel.textColor = [UIColor whiteColor];
    _unReadLabel.textAlignment = NSTextAlignmentCenter;
    [_unReadLabel sizeToFit];
    [self addSubview:_unReadLabel];

    self.layer.cornerRadius = (_unReadLabel.frame.size.height + TUnReadView_Margin_TB * 2) / 2.0;
    [self.layer masksToBounds];
    self.backgroundColor = [UIColor redColor];
    self.hidden = YES;
}

- (void)defaultLayout {
    [_unReadLabel sizeToFit];
    CGFloat width = _unReadLabel.frame.size.width + 2 * TUnReadView_Margin_LR;
    CGFloat height = _unReadLabel.frame.size.height + 2 * TUnReadView_Margin_TB;
    if (width < height) {
        width = height;
    }
    self.bounds = CGRectMake(0, 0, width, height);
    _unReadLabel.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11.0, *)) {
        // Here is a workaround on iOS 11 UINavigationBarItem init with custom view, position issue
        UIView *view = self;
        while (![view isKindOfClass:[UINavigationBar class]] && [view superview] != nil) {
            view = [view superview];
            if ([view isKindOfClass:[UIStackView class]] && [view superview] != nil) {
                CGFloat margin = 40.0f;
                // margin = 4.0f;
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
+ (instancetype)sharedInstance {
    static TUIConversationPin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [TUIConversationPin new];
    });
    return instance;
}

- (NSArray *)topConversationList {
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

- (void)addTopConversation:(NSString *)conv callback:(void (^)(BOOL success, NSString *errorMessage))callback {
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    [V2TIMManager.sharedInstance pinConversation:conv
        isPinned:YES
        succ:^{
          if (callback) {
              callback(YES, nil);
          }
        }
        fail:^(int code, NSString *desc) {
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

- (void)removeTopConversation:(NSString *)conv callback:(void (^)(BOOL success, NSString *errorMessage))callback {
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    [V2TIMManager.sharedInstance pinConversation:conv
        isPinned:NO
        succ:^{
          if (callback) {
              callback(YES, nil);
          }
        }
        fail:^(int code, NSString *desc) {
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
//                          TUICommonContactSelectCellData
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonContactSelectCellData

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    return self;
}

- (NSComparisonResult)compare:(TUICommonContactSelectCellData *)data {
    return [self.title localizedCompare:data.title];
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactListPickerCell
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUICommonContactListPickerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat avatarWidth = 35.0;
        _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, avatarWidth, avatarWidth)];
        [self.contentView addSubview:_avatar];
        _avatar.center = CGPointMake(avatarWidth / 2.0, avatarWidth / 2.0);
        _avatar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
                                   UIViewAutoresizingFlexibleBottomMargin;
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
@interface TUIContactListPicker () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic) UICollectionView *collectionView;
@property(nonatomic) UIButton *accessoryBtn;
@end

@implementation TUIContactListPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    [self initControl];
    [self setupBinding];

    return self;
}

- (void)initControl {
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
    [self.accessoryBtn setBackgroundImage:TIMCommonBundleImage(@"icon_cell_blue_normal") forState:UIControlStateNormal];
    [self.accessoryBtn setBackgroundImage:TIMCommonBundleImage(@"icon_cell_blue_normal") forState:UIControlStateHighlighted];
    [self.accessoryBtn setTitle:[NSString stringWithFormat:@" %@ ", TIMCommonLocalizableString(Confirm)] forState:UIControlStateNormal];
    self.accessoryBtn.enabled = NO;
    [self addSubview:self.accessoryBtn];
}

- (void)setupBinding {
    [self addObserver:self forKeyPath:@"selectArray" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
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

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView
                    layout:(nonnull UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.item >= self.selectArray.count) {
        return;
    }
    TUICommonContactSelectCellData *data = self.selectArray[indexPath.item];
    if (self.onCancel) {
        self.onCancel(data);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.accessoryBtn.mm_sizeToFit().mm_height(30).mm_right(15).mm_top(13);
    self.collectionView.mm_left(15).mm_height(40).mm_width(self.accessoryBtn.mm_x - 30).mm__centerY(self.accessoryBtn.mm_centerY);
    if (isRTL()) {
        [self.accessoryBtn resetFrameToFitRTL];
        [self.collectionView resetFrameToFitRTL];
    }
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIProfileCardCell & VC
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIProfileCardCellData

- (instancetype)init {
    self = [super init];
    if (self) {
        _avatarImage = DefaultAvatarImage;

        if ([_genderString isEqualToString:TIMCommonLocalizableString(Male)]) {
            _genderIconImage = TUIGroupCommonBundleImage(@"male");
        } else if ([_genderString isEqualToString:TIMCommonLocalizableString(Female)]) {
            _genderIconImage = TUIGroupCommonBundleImage(@"female");
        } else {
            _genderIconImage = nil;
        }
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin + (self.showSignature ? 24 : 0);
}

@end

@implementation TUIProfileCardCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
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

    // CGSize genderIconSize = CGSizeMake(20, 20);
    _genderIcon = [[UIImageView alloc] init];
    _genderIcon.contentMode = UIViewContentModeScaleAspectFit;
    _genderIcon.image = self.cardData.genderIconImage;
    [self.contentView addSubview:_genderIcon];

    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont boldSystemFontOfSize:18]];
    [_name setTextColor:TIMCommonDynamicColor(@"form_title_color", @"#000000")];
    [self.contentView addSubview:_name];

    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:13]];
    [_identifier setTextColor:TIMCommonDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_identifier];

    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    [_signature setTextColor:TIMCommonDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_signature];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)fillWithData:(TUIProfileCardCellData *)data {
    [super fillWithData:data];
    self.cardData = data;
    _signature.hidden = !data.showSignature;
    // set data
    @weakify(self);

    RAC(_signature, text) = [RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal];
    [[[RACObserve(data, identifier) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
      @strongify(self);
        self.identifier.text = [NSString stringWithFormat:@"%@:%@",TIMCommonLocalizableString(TUIKitIdentity),data.identifier];
    }];

    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
      @strongify(self);
      self.name.text = x;
      [self.name sizeToFit];
    }];
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
      @strongify(self);
      [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
    }];

    [[RACObserve(data, genderString) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *x) {
      @strongify(self);
      if ([x isEqualToString:TIMCommonLocalizableString(Male)]) {
          self.genderIcon.image = TUIGroupCommonBundleImage(@"male");
      } else if ([x isEqualToString:TIMCommonLocalizableString(Female)]) {
          self.genderIcon.image = TUIGroupCommonBundleImage(@"female");
      } else {
          self.genderIcon.image = nil;
      }
    }];

    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    CGSize headSize = CGSizeMake(kScale390(66), kScale390(66));

    [self.avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(headSize);
        make.top.mas_equalTo(kScale390(10));
        make.leading.mas_equalTo(kScale390(16));
    }];
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.name sizeToFit];
    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(TPersonalCommonCell_Margin);
        make.leading.mas_equalTo(self.avatar.mas_trailing).mas_offset(15);
        make.width.mas_lessThanOrEqualTo(self.name.frame.size.width);
        make.height.mas_greaterThanOrEqualTo(self.name.frame.size.height);
        make.trailing.mas_lessThanOrEqualTo(self.genderIcon.mas_leading).mas_offset(- 1);
    }];

    [self.genderIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.name.font.pointSize *0.9);
        make.centerY.mas_equalTo(self.name);
        make.leading.mas_equalTo(self.name.mas_trailing).mas_offset(1);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- 10);
    }];

    [self.identifier sizeToFit];
    [self.identifier mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.name);
        make.top.mas_equalTo(self.name.mas_bottom).mas_offset(5);
        if(self.identifier.frame.size.width > 80) {
            make.width.mas_greaterThanOrEqualTo(self.identifier.frame.size.width);
        }
        else {
            make.width.mas_greaterThanOrEqualTo(@80);
        }
        make.height.mas_greaterThanOrEqualTo(self.identifier.frame.size.height);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(-1);
    }];

    if (self.cardData.showSignature) {
        [self.signature sizeToFit];
        [self.signature mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.name);
            make.top.mas_equalTo(self.identifier.mas_bottom).mas_offset(5);
            if(self.signature.frame.size.width > 80) {
                make.width.mas_greaterThanOrEqualTo(self.signature.frame.size.width);
            }
            else {
                make.width.mas_greaterThanOrEqualTo(@80);
            }
            make.height.mas_greaterThanOrEqualTo(self.signature.frame.size.height);
            make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(-1);
        }];
        
    } else {
        self.signature.frame = CGRectZero;
    }

}

- (void)onTapAvatar {
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnAvatar:)]) [_delegate didTapOnAvatar:self];
}

@end

@interface TUIAvatarViewController () <UIScrollViewDelegate>
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    CGRect rect = self.view.bounds;
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
     @weakify(self);
    [RACObserve(data, avatarUrl) subscribeNext:^(NSURL *x) {
        @strongify(self);
        [self.avatarView sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
    }];
    */
    @weakify(self);
    [RACObserve(data, avatarUrl) subscribeNext:^(NSURL *x) {
      @strongify(self);
      [self.avatarView sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
      [self.avatarScrollView setNeedsLayout];
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.avatarView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self.navigationController.navigationBar setBackgroundImage:self.saveBackgroundImage forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = self.saveShadowImage;
    }
}

@end

#define UserAvatarURL(x) [NSString stringWithFormat:@"https://im.sdk.qcloud.com/download/tuikit-resource/avatar/avatar_%d.png", x]
#define UserAvatarCount 26

#define GroupAvatarURL(x) [NSString stringWithFormat:@"https://im.sdk.qcloud.com/download/tuikit-resource/group-avatar/group_avatar_%d.png", x]
#define GroupAvatarCount 24

#define Community_coverURL(x) [NSString stringWithFormat:@"https://im.sdk.qcloud.com/download/tuikit-resource/community-cover/community_cover_%d.png", x]
#define Community_coverCount 12

#define BackGroundCoverURL(x) \
    [NSString stringWithFormat:@"https://im.sdk.qcloud.com/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%d.png", x]

#define BackGroundCoverURL_full(x) \
    [NSString stringWithFormat:@"https://im.sdk.qcloud.com/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%d_full.png", x]

#define BackGroundCoverCount 7

@implementation TUISelectAvatarCardItem

@end

@interface TUISelectAvatarCollectionCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIImageView *selectedView;

@property(nonatomic, strong) UIView *maskView;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) TUISelectAvatarCardItem *cardItem;

- (void)updateSelectedUI;

@end

@implementation TUISelectAvatarCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
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

    self.selectedView.frame = CGRectMake(self.imageView.frame.size.width - 16 - 4, 4, 16, 16);
}

- (void)updateCellView {
    [self updateSelectedUI];
    [self updateImageView];
    [self updateMaskView];
}

- (void)updateSelectedUI {
    if (self.cardItem.isSelect) {
        self.imageView.layer.borderColor = TIMCommonDynamicColor(@"", @"#006EFF").CGColor;
        self.selectedView.hidden = NO;
    } else {
        if (self.cardItem.isDefaultBackgroundItem) {
            self.imageView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.1].CGColor;
        } else {
            self.imageView.layer.borderColor = UIColor.clearColor.CGColor;
        }
        self.selectedView.hidden = YES;
    }
}

- (void)updateImageView {
    if (self.cardItem.isGroupGridAvatar) {
        [self updateNormalGroupGridAvatar];
    } else {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.cardItem.posterUrlStr]
                          placeholderImage:TIMCommonBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head_img")];
    }
}
- (void)updateMaskView {
    if (self.cardItem.isDefaultBackgroundItem) {
        self.maskView.hidden = NO;
        self.maskView.frame = CGRectMake(0, self.imageView.frame.size.height - 28, self.imageView.frame.size.width, 28);
        [self.descLabel sizeToFit];
        self.descLabel.tui_mm_center();
    } else {
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
    self.descLabel.text = TIMCommonLocalizableString(TUIKitDefaultBackground);
    self.descLabel.textColor = [UIColor whiteColor];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    [self.maskView addSubview:self.descLabel];
    [self.descLabel sizeToFit];
    self.descLabel.tui_mm_center();
}

- (void)setCardItem:(TUISelectAvatarCardItem *)cardItem {
    _cardItem = cardItem;
}

- (UIImageView *)selectedView {
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _selectedView.image = [UIImage imageNamed:TIMCommonImagePath(@"icon_avatar_selected")];
    }
    return _selectedView;
}

@end

@interface TUISelectAvatarController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *dataArr;
@property(nonatomic, strong) TUISelectAvatarCardItem *currentSelectCardItem;
@property(nonatomic, strong) UIButton *rightButton;

@end

@implementation TUISelectAvatarController

static NSString *const reuseIdentifier = @"TUISelectAvatarCollectionCell";

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
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    [self.view addSubview:self.collectionView];

    self.collectionView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");

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
        for (int i = 0; i < UserAvatarCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:UserAvatarURL(i + 1)];
            [self.dataArr addObject:cardItem];
        }
    } else if (self.selectAvatarType == TUISelectAvatarTypeGroupAvatar) {
        if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cacheGroupGridAvatarImage) {
            TUISelectAvatarCardItem *cardItem = [self creatGroupGridAvatarCardItem];
            [self.dataArr addObject:cardItem];
        }

        for (int i = 0; i < GroupAvatarCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:GroupAvatarURL(i + 1)];
            [self.dataArr addObject:cardItem];
        }
    } else if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        TUISelectAvatarCardItem *cardItem = [self creatCleanCardItem];
        [self.dataArr addObject:cardItem];
        for (int i = 0; i < BackGroundCoverCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:BackGroundCoverURL(i + 1) fullUrl:BackGroundCoverURL_full(i + 1)];
            [self.dataArr addObject:cardItem];
        }
    }

    else {
        for (int i = 0; i < Community_coverCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:Community_coverURL(i + 1)];
            [self.dataArr addObject:cardItem];
        }
    }
    [self.collectionView reloadData];
}

- (TUISelectAvatarCardItem *)creatCardItemByURL:(NSString *)urlStr {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = urlStr;
    cardItem.isSelect = NO;
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL]) {
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
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL] || [cardItem.fullUrlStr isEqualToString:self.profilFaceURL]) {
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
    if (self.profilFaceURL.length == 0) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}
- (void)setupNavigator {
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    if (self.selectAvatarType == TUISelectAvatarTypeCover) {
        [self.titleView setTitle:TIMCommonLocalizableString(TUIKitChooseCover)];
    } else if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        [self.titleView setTitle:TIMCommonLocalizableString(TUIKitChooseBackground)];
    } else {
        [self.titleView setTitle:TIMCommonLocalizableString(TUIKitChooseAvatar)];
    }

    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.rightButton setTitle:TIMCommonLocalizableString(Save) forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItems = @[ rightItem ];
}

- (void)setCurrentSelectCardItem:(TUISelectAvatarCardItem *)currentSelectCardItem {
    _currentSelectCardItem = currentSelectCardItem;
    if (_currentSelectCardItem) {
        [self.rightButton setTitleColor:TIMCommonDynamicColor(@"", @"#006EFF") forState:UIControlStateNormal];
    } else {
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
                @weakify(self);
                [[SDWebImagePrefetcher sharedImagePrefetcher]
                    prefetchURLs:@[ [NSURL URLWithString:self.currentSelectCardItem.fullUrlStr] ]
                        progress:nil
                       completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                         @strongify(self);
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           dispatch_async(dispatch_get_main_queue(), ^{
                             [TUITool hideToastActivity];
                             [TUITool makeToast:TIMCommonLocalizableString(TUIKitChooseBackgroundSuccess)];
                             if (self.selectCallBack) {
                                 self.selectCallBack(self.currentSelectCardItem.fullUrlStr);
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                           });
                         });
                       }];
            } else {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitChooseBackgroundSuccess)];
                self.selectCallBack(self.currentSelectCardItem.fullUrlStr);
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            self.selectCallBack(self.currentSelectCardItem.posterUrlStr);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat margin = 15;

    CGFloat padding = 13;

    int rowCount = 4.0;

    if (self.selectAvatarType == TUISelectAvatarTypeCover || self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        rowCount = 2.0;
    } else {
        rowCount = 4.0;
    }

    CGFloat width = (self.view.frame.size.width - 2 * margin - (rowCount - 1) * padding) / rowCount;

    CGFloat height = 77;
    if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        height = 125;
    }

    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
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

    TUISelectAvatarCollectionCell *cell = (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    if (cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    if (self.currentSelectCardItem == cell.cardItem) {
        self.currentSelectCardItem = nil;
    } else {
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
    TUISelectAvatarCollectionCell *cell = (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    if (cell == nil) {
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
    if (self) {
        _avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin;
}

@end

@interface TUICommonAvatarCell ()
@property TUICommonAvatarCellData *avatarData;
@end

@implementation TUICommonAvatarCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(TUICommonAvatarCellData *)avatarData {
    [super fillWithData:avatarData];

    self.avatarData = avatarData;

    RAC(_keyLabel, text) = [RACObserve(avatarData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(avatarData, value) takeUntil:self.rac_prepareForReuseSignal];
    @weakify(self);
    [[RACObserve(avatarData, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
      @strongify(self);
      [self.avatar sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
    }];

    if (avatarData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
    
}

- (void)setupViews {
    _avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatar.contentMode = UIViewContentModeScaleAspectFit;

    [self addSubview:_avatar];

    _keyLabel = self.textLabel;
    _valueLabel = self.detailTextLabel;

    [self addSubview:_keyLabel];
    [self addSubview:_valueLabel];

    self.keyLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#444444");
    self.valueLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    CGSize headSize = TPersonalCommonCell_Image_Size;    
    [self.avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(headSize);
        if (self.avatarData.showAccessory) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
        }
        else {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-20);
        }
        make.centerY.mas_equalTo(self);
    }];
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];

    
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIConversationGroupItem
//
/////////////////////////////////////////////////////////////////////////////////
NSUInteger kConversationMarkStarType = V2TIM_CONVERSATION_MARK_TYPE_STAR;
@implementation TUIConversationGroupItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.unreadCount = 0;
        self.groupIndex = 0;
        self.isShow = YES;
    }
    return self;
}
@end

@implementation TUISendMessageAppendParams
+ (instancetype)defaultConfig {
    TUISendMessageAppendParams *params = [[TUISendMessageAppendParams alloc] init];
    params.priority = V2TIM_PRIORITY_NORMAL;
    return params;
}

@end
