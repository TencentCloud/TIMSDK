//
//  TUICustomerServicePluginBranchCell.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginBranchCell.h"
#import "TUICustomerServicePluginDataProvider.h"
#import "TUICustomerServicePluginDataProvider+CalculateSize.h"
#import <TIMCommon/TIMDefine.h>

@implementation TUICustomerServicePluginBranchItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _topLine = [[UIImageView alloc] init];
        [_topLine setImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_branch_dotted_line_img", @"dotted_line")];
        [self.contentView addSubview:_topLine];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_branch_content_text_color", @"#368DFF");
        [self.contentView addSubview:_contentLabel];
        
        _arrowView = [[UIImageView alloc] init];
        [_arrowView setImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_branch_arrow_img", @"arrow")];
        [self.contentView addSubview:_arrowView];
    }
    return self;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    
    [self.topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.mm_w - TUICustomerServicePluginBranchCellMargin * 2);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(TUICustomerServicePluginBranchCellMargin);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.mm_w - TUICustomerServicePluginBranchCellMargin * 2 - 5 - 6);
        make.height.mas_equalTo([TUICustomerServicePluginDataProvider calcBranchCellHeightOfContent:self.contentLabel.text]);
    }];
    
    [self.arrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentLabel.mas_trailing).offset(6);
        make.top.mas_equalTo((self.mm_h - self.arrowView.mm_h) / 2.0);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(9);
    }];
}

@end


@interface TUICustomerServicePluginBranchCell() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation TUICustomerServicePluginBranchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.font = [UIFont systemFontOfSize:16];
        _headerLabel.numberOfLines = 0;
        _headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _headerLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_branch_header_text_color", @"#000000");
        [self.container addSubview:_headerLabel];

        _itemsTableView = [[UITableView alloc] init];
        _itemsTableView.tableFooterView = [[UIView alloc] init];
//        _itemsTableView.backgroundColor = TUICoreDynamicColor(@"customer_service_brance_bg_color", @"#FFFFFF");
        _itemsTableView.backgroundColor = [UIColor clearColor];
        _itemsTableView.delegate = self;
        _itemsTableView.dataSource = self;
        _itemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_itemsTableView registerClass:[TUICustomerServicePluginBranchItemCell class] forCellReuseIdentifier:@"item_cell"];
        [self.container addSubview:_itemsTableView];
        // _itemsTableView responds to click events first
        for (UIGestureRecognizer *gesture in self.container.gestureRecognizers) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                [self.container removeGestureRecognizer:gesture];
            }
        }
    }
    return self;
}

- (void)fillWithData:(TUICustomerServicePluginBranchCellData *)data {
    [super fillWithData:data];
    
    self.customData = data;
    self.headerLabel.text = data.header;
    [self.itemsTableView reloadData];
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

// Override, the size of bubble content.
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUICustomerServicePluginBranchCellData.class],
             @"data must be a kind of TUICustomerServicePluginBranchCellData");
    TUICustomerServicePluginBranchCellData *branchCellData = (TUICustomerServicePluginBranchCellData *)data;
    return [TUICustomerServicePluginDataProvider calcBranchCellSize:branchCellData.header
                                                              items:branchCellData.items];
}

- (void)updateConstraints {
    [super updateConstraints];

    CGFloat cellHeight = [TUICustomerServicePluginDataProvider calcBranchCellSize:self.customData.header
                                                              items:self.customData.items].height;
    CGSize tableViewSize = [TUICustomerServicePluginDataProvider calcBranchCellSizeOfTableView:self.customData.items];
    CGSize headerSize= [TUICustomerServicePluginDataProvider calcBranchCellSizeOfHeader:self.customData.header];
    
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
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TUICustomerServicePluginDataProvider calcBranchCellHeightOfTableView:self.customData.items row:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.customData.items.count <= indexPath.row) {
        return;
    }
    if (self.customData.selected) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
    TUICustomerServicePluginBranchItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item_cell" forIndexPath:indexPath];
    cell.contentLabel.text = content;
    
    // tell constraints they need updating
    [cell setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [cell updateConstraintsIfNeeded];

    [cell layoutIfNeeded];
    return cell;
}

@end
