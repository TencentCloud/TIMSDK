//
//  TUICustomerServicePluginCollectionCell.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginCollectionCell.h"
#import "TUICustomerServicePluginDataProvider.h"
#import "TUICustomerServicePluginDataProvider+CalculateSize.h"
#import <TUICore/TUICore.h>

@implementation TUICustomerServicePluginCollectionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_collection_content_text_color", @"#368DFF");
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(TUICustomerServicePluginBranchCellWidth - TUICustomerServicePluginBranchCellMargin * 2);
        make.height.mas_equalTo([TUICustomerServicePluginDataProvider calcCollectionCellHeightOfContent:self.contentLabel.text]);
    }];
}

@end


@interface TUICustomerServicePluginCollectionCell() <UITableViewDelegate, UITableViewDataSource, TUINotificationProtocol>

@end

@implementation TUICustomerServicePluginCollectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupHeaderLabel];
        [self setupListCollectionViews];
        [self setupInputCollectionViews];
        
        [TUICore registerEvent:TUICore_TUIChatNotify
                        subKey:TUICore_TUIChatNotify_KeyboardWillHideSubKey
                        object:self];
    }
    return self;
}

- (void)setupHeaderLabel {
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.font = [UIFont systemFontOfSize:16];
    _headerLabel.numberOfLines = 0;
    _headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _headerLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_collection_header_text_color", @"#000000");
    _headerLabel.backgroundColor = [UIColor clearColor];
    [self.container addSubview:_headerLabel];
}

- (void)setupListCollectionViews {
    _itemsTableView = [[UITableView alloc] init];
    _itemsTableView.tableFooterView = [[UIView alloc] init];
//        _itemsTableView.backgroundColor = TUICoreDynamicColor(@"customer_service_brance_bg_color", @"#FFFFFF");
    _itemsTableView.backgroundColor = [UIColor clearColor];
    _itemsTableView.delegate = self;
    _itemsTableView.dataSource = self;
    _itemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_itemsTableView registerClass:[TUICustomerServicePluginCollectionItemCell class] forCellReuseIdentifier:@"item_cell"];
    _itemsTableView.hidden = YES;
    [self.container addSubview:_itemsTableView];
}

- (void)setupInputCollectionViews {
    _inputTextField = [[UITextField alloc] init];
    _inputTextField.backgroundColor = TUICustomerServicePluginDynamicColor(@"customer_service_collection_textfield_bg_color", @"#FFFFFF");
    _inputTextField.hidden = YES;
    _inputTextField.font = [UIFont systemFontOfSize:16];
    [self.container addSubview:_inputTextField];
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 20)];
    blankView.backgroundColor = [UIColor clearColor];
    _inputTextField.leftViewMode = UITextFieldViewModeAlways;
    _inputTextField.leftView = blankView;
    
    _confirmButton = [UIButton new];
    _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_confirmButton setTitleColor:TUICustomerServicePluginDynamicColor(@"customer_service_collection_textfield_text_color", @"#000000")
                    forState:UIControlStateNormal];
    [_confirmButton setImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_collection_submit_img", @"submit") forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(onConfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.hidden = YES;
    [self.container addSubview:_confirmButton];
}

- (void)hideListCollectionViews {
    self.itemsTableView.hidden = YES;
    self.inputTextField.hidden = NO;
    self.confirmButton.hidden = NO;
}

- (void)hideInputCollectionViews {
    self.itemsTableView.hidden = NO;
    self.inputTextField.hidden = YES;
    self.confirmButton.hidden = YES;
}

- (void)onConfirmButtonClicked:(UIButton *)sender {
    self.inputTextField.userInteractionEnabled = NO;
    
    NSString *content = self.inputTextField.text;
    [TUICustomerServicePluginDataProvider sendTextMessage:content];
}

- (void)fillWithData:(TUICustomerServicePluginCollectionCellData *)data {
    [super fillWithData:data];
    
    self.customData = data;
    self.headerLabel.text = data.header;
    
    if (data.type == 1) {
        [self hideInputCollectionViews];
        [self.itemsTableView reloadData];
    } else {
        [self hideListCollectionViews];
        self.inputTextField.text = self.customData.selectedContent;
        
        BOOL canFill = self.customData.selectedContent.length == 0;
        self.inputTextField.enabled = canFill;
        self.confirmButton.enabled = canFill;
    }
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

// Override, the size of bubble content.
+ (CGSize)getContentSize:(TUICustomerServicePluginCollectionCellData *)data {
    if (data.type == 1) {
        return [TUICustomerServicePluginDataProvider calcCollectionCellSize:data.header items:data.items];
    } else {
        return [TUICustomerServicePluginDataProvider calcCollectionInputCellSize:data.header];
    }
}

- (void)updateConstraints {
    [super updateConstraints];

    if (self.customData.type == 1) {
        CGFloat cellHeight = [TUICustomerServicePluginDataProvider calcBranchCellSize:self.customData.header
                                                                  items:self.customData.items].height;
        CGSize tableViewSize = [TUICustomerServicePluginDataProvider calcCollectionCellSizeOfTableView:self.customData.items];
        CGSize headerSize= [TUICustomerServicePluginDataProvider calcCollectionCellSizeOfHeader:self.customData.header];
        
        self.container
            .mm_width(TUICustomerServicePluginBranchCellWidth)
            .mm_height(cellHeight);
        
        [self.headerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
            make.top.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
            make.width.mas_equalTo(headerSize.width);
            make.height.mas_equalTo(headerSize.height);
        }];
        
        [self.itemsTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(0);
            make.top.mas_equalTo(self.headerLabel.mas_bottom).offset(TUICustomerServicePluginBranchCellInnerMargin);
            make.width.mas_equalTo(tableViewSize.width);
            make.height.mas_equalTo(tableViewSize.height);
        }];
    } else {
        self.container
            .mm_width(TUICustomerServicePluginInputCellWidth)
            .mm_height([TUICustomerServicePluginDataProvider calcCollectionInputCellSize:self.customData.header].height);
        
        [self.headerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
            make.top.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
            make.width.mas_equalTo([TUICustomerServicePluginDataProvider calcCollectionInputCellSizeOfHeader:self.customData.header].width);
            make.height.mas_equalTo([TUICustomerServicePluginDataProvider calcCollectionInputCellSizeOfHeader:self.customData.header].height);
        }];
        
        [self.inputTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
            make.top.mas_equalTo(self.headerLabel.mas_bottom).offset(6);
            make.width.mas_equalTo(TUICustomerServicePluginInputCellWidth - TUICustomerServicePluginBranchCellMargin * 2 - 40);
            make.height.mas_equalTo(36);
        }];
        
        [self setupInputTextFieldCorners];
        
        [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.inputTextField.mas_trailing);
            make.top.mas_equalTo(self.headerLabel.mas_bottom).offset(6);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(36);
        }];
    }
}

- (void)setupInputTextFieldCorners {
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.inputTextField.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = bezierPath.CGPath;
    self.inputTextField.layer.mask = layer;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TUICustomerServicePluginDataProvider calcCollectionCellHeightOfTableView:self.customData.items row:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.customData.items.count <= indexPath.row) {
        return;
    }
    NSString *content = self.customData.items[indexPath.row];
    [TUICustomerServicePluginDataProvider sendTextMessage:content];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.customData.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.customData.items.count <= indexPath.row) {
        return nil;
    }
    NSString *content = self.customData.items[indexPath.row];
    TUICustomerServicePluginCollectionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item_cell" forIndexPath:indexPath];
    cell.contentLabel.text = content;
    // tell constraints they need updating
    [cell setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [cell updateConstraintsIfNeeded];

    [cell layoutIfNeeded];
    return cell;
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIChatNotify] &&
        [subKey isEqualToString:TUICore_TUIChatNotify_KeyboardWillHideSubKey]) {
        [self.inputTextField resignFirstResponder];
    }
}


@end
