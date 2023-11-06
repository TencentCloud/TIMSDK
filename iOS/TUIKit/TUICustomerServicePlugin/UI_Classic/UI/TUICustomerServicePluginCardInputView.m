//
//  TUICustomerServicePluginCardInputView.m
//  Masonry
//
//  Created by xia on 2023/6/13.
//

#import "TUICustomerServicePluginCardInputView.h"
#import "TUICustomerServicePluginDataProvider.h"
#import <TUICore/TUIDefine.h>
#import <TIMCommon/TIMDefine.h>

@interface TUICustomerServicePluginCardInputItemCell()

@end

@implementation TUICustomerServicePluginCardInputItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.numberOfLines = 1;
        _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _descLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_card_item_desc_text_color", @"#999999");
        [self.contentView addSubview:_descLabel];
        
        _inputTextField = [[UITextField alloc] init];
        _inputTextField.backgroundColor = TUICustomerServicePluginDynamicColor(@"customer_service_card_input_bg_color", @"#F9F9F9");
        _inputTextField.layer.cornerRadius = 8;
        _inputTextField.layer.masksToBounds = YES;
        _inputTextField.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_card_input_text_color", @"#000000");
        _inputTextField.font = [UIFont systemFontOfSize:14];
        _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:_inputTextField];
        
        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 20)];
        blankView.backgroundColor = [UIColor clearColor];
        _inputTextField.leftViewMode = UITextFieldViewModeAlways;
        _inputTextField.leftView = blankView;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(12);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(21);
    }];
    
    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.descLabel.mas_trailing).offset(8);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.mm_w - self.descLabel.mm_maxX - 20);
        make.height.mas_equalTo(46);
    }];
}

@end

@interface TUICustomerServicePluginCardInputView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *defaultInfo;
@property(nonatomic, assign) BOOL isKeyboardVisible;
@property(nonatomic, assign) CGRect oldFrame;

@end

@implementation TUICustomerServicePluginCardInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self addNotification];
    }
    return self;
}

- (void)setupViews {
    UIColor *color = TUICustomerServicePluginDynamicColor(@"customer_service_card_bg_color", @"#000000");
    self.backgroundColor = [color colorWithAlphaComponent:0.5];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    [self addGestureRecognizer:tap];
    
    [self addSubview:self.backView];
    
    [self.backView addSubview:self.headerLabel];
    [self.backView addSubview:self.itemsTableView];
    [self.backView addSubview:self.submitButton];
    [self.backView addSubview:self.closeButton];
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)onTapped:(UITapGestureRecognizer *)recognizer {
    [self endEditing:YES];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(Screen_Height - 378);
        make.width.mas_equalTo(Screen_Width);
        make.height.mas_equalTo(378);
    }];
    
    [self.headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(25);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(20);
        make.top.mas_equalTo(22);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(24);
    }];
    
    float tableViewHeight = self.defaultInfo.count * self.itemsTableView.rowHeight;
    [self.itemsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(self.headerLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(self.backView.mas_width);
        make.height.mas_equalTo(tableViewHeight);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(self.itemsTableView.mas_bottom).offset(20);
        make.width.mas_equalTo(self.backView.mas_width).offset(-20 * 2);
        make.height.mas_equalTo(46);
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.defaultInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.defaultInfo.count <= indexPath.row) {
        return nil;
    }
    NSDictionary *info = self.defaultInfo[indexPath.row];
    TUICustomerServicePluginCardInputItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item_cell" forIndexPath:indexPath];
    cell.descLabel.text = info[@"desc"];
    cell.inputTextField.placeholder = info[@"placeHolder"];
    
    // TODO: debug 用，发布注意删掉
    if (info[@"content"]) {
        cell.inputTextField.text = info[@"content"];
    }
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
    return cell;
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.isKeyboardVisible) {
        return;
    }
    self.oldFrame = self.backView.frame;

    NSValue *keyBoardEndFrame = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [keyBoardEndFrame CGRectValue];

    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       [self setFrame:CGRectMake(self.frame.origin.x,
                                                 self.frame.origin.y - endFrame.size.height,
                                                 self.frame.size.width,
                                                 self.frame.size.height)];
                     }
                     completion:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    self.isKeyboardVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.isKeyboardVisible) {
        return;
    }
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       [self setFrame:CGRectMake(0, 0, self.oldFrame.size.width, self.oldFrame.size.height)];
                     }
                     completion:nil];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.isKeyboardVisible = NO;
}


#pragma mark - Getter
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = TUICustomerServicePluginDynamicColor(@"customer_service_card_backview_bg_color", @"#FFFFFF");
    }
    return _backView;
}

- (UILabel *)headerLabel {
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.font = [UIFont systemFontOfSize:18];
        _headerLabel.numberOfLines = 0;
        _headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _headerLabel.text = TIMCommonLocalizableString(TUICustomerServiceFillProductInfo);
        _headerLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_card_header_text_color", @"#000000");
    }
    return _headerLabel;
}

- (UITableView *)itemsTableView {
    if (!_itemsTableView) {
        _itemsTableView = [[UITableView alloc] init];
        _itemsTableView.tableFooterView = [[UIView alloc] init];
    //        _itemsTableView.backgroundColor = TUICoreDynamicColor(@"customer_service_brance_bg_color", @"#FFFFFF");
        _itemsTableView.backgroundColor = [UIColor clearColor];
        _itemsTableView.delegate = self;
        _itemsTableView.dataSource = self;
        _itemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _itemsTableView.rowHeight = 56;
        [_itemsTableView registerClass:[TUICustomerServicePluginCardInputItemCell class] forCellReuseIdentifier:@"item_cell"];
    }
    return _itemsTableView;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton new];
        [_submitButton setTitle:TIMCommonLocalizableString(TUICustomerServiceSubmitProductInfo) forState:UIControlStateNormal];
        _submitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_submitButton setTitleColor:TUICustomerServicePluginDynamicColor(@"customer_service_card_submit_text_color", @"#FFFFFF")
                            forState:UIControlStateNormal];
        _submitButton.layer.cornerRadius = 4;
        _submitButton.layer.masksToBounds = YES;
        [_submitButton setBackgroundColor:TUICustomerServicePluginDynamicColor(@"customer_service_card_submit_bg_color", @"#006EFF")];
        [_submitButton addTarget:self
                          action:@selector(onSubmitButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (void)onSubmitButtonClicked:(UIButton *)sender {
    NSString *header = [self getCellOfRow:0].inputTextField.text;
    NSString *desc = [self getCellOfRow:1].inputTextField.text;
    NSString *pic = [self getCellOfRow:2].inputTextField.text;
    NSString *url = [self getCellOfRow:3].inputTextField.text;
    
    // TODO: 输入要做安全校验
    if (header.length == 0 || desc.length == 0 || pic.length == 0) {
        return;
    }
    
    NSDictionary *dict = @{@"src": BussinessID_Src_CustomerService_Card,
                           @"content": @{@"header": header,
                                         @"desc": desc,
                                         @"pic": pic,
                                         @"url": url}
    };
    NSData *data = [TUITool dictionary2JsonData:dict];
    [TUICustomerServicePluginDataProvider sendCustomMessage:data];
    
    [self removeFromSuperview];
}

- (TUICustomerServicePluginCardInputItemCell *)getCellOfRow:(int)row {
    if (row >= self.defaultInfo.count) {
        return nil;
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
    return (TUICustomerServicePluginCardInputItemCell *)[self.itemsTableView cellForRowAtIndexPath:index];
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton new];
        [_closeButton setTitle:TIMCommonLocalizableString(TUICustomerServiceClose) forState:UIControlStateNormal];
        _closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_closeButton setTitleColor:TUICustomerServicePluginDynamicColor(@"customer_service_card_close_text_color", @"#3370FF")
                           forState:UIControlStateNormal];
        [_closeButton addTarget:self
                         action:@selector(onCloseButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)onCloseButtonClicked:(UIButton *)sender {
    [self removeFromSuperview];
}

- (NSArray *)defaultInfo {
    return @[
        @{@"desc": TIMCommonLocalizableString(TUICustomerServiceName),
          @"placeHolder": TIMCommonLocalizableString(TUICustomerServiceFillProductName),
          @"content": @"手工编织皮革提包2023新品女士迷你简约大方高端有档次"
        },
        @{@"desc": TIMCommonLocalizableString(TUICustomerServiceDesc),
          @"placeHolder": TIMCommonLocalizableString(TUICustomerServiceFillProductDesc),
          @"content": @"¥788"
        },
        @{@"desc": TIMCommonLocalizableString(TUICustomerServicePic),
          @"placeHolder": TIMCommonLocalizableString(TUICustomerServiceFillPicLink),
          @"content": @"https://qcloudimg.tencent-cloud.cn/raw/a811f634eab5023f973c9b224bc07a51.png"
        },
        @{@"desc": TIMCommonLocalizableString(TUICustomerServiceJumpLink),
          @"placeHolder": TIMCommonLocalizableString(TUICustomerServiceFillJumpLink),
          @"content": @"https://cloud.tencent.com/document/product/269"
        }
    ];
}


@end
