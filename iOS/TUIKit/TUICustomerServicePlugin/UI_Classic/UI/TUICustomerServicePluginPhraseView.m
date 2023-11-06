//
//  TUICustomerServicePluginPhraseView.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/7/4.
//

#import "TUICustomerServicePluginPhraseView.h"
#import "TUICustomerServicePluginDataProvider.h"
#import <TUICore/TUIDefine.h>
#import <TIMCommon/TIMDefine.h>

@interface TUICustomerServicePluginPhraseView() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@end

@implementation TUICustomerServicePluginPhraseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    UIColor *color = TUICustomerServicePluginDynamicColor(@"customer_service_phrase_bg_color", @"#000000");
    self.backgroundColor = [color colorWithAlphaComponent:0.5];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    [self addSubview:self.backView];
    [self.backView addSubview:self.itemsTableView];
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)setupCorners {
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.backView.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = bezierPath.CGPath;
    self.backView.layer.mask = layer;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    float tableViewHeight = 5 * self.itemsTableView.rowHeight;
    [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_bottom).offset(-tableViewHeight);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(223);
    }];
    
    self.itemsTableView.mm_fill();
    
    [self setupCorners];
}

- (void)onTapped:(UITapGestureRecognizer *)recognizer {
    [self removeFromSuperview];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.itemsTableView]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.defaultInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.defaultInfo.count <= indexPath.row) {
        return nil;
    }
    NSString *phrase = self.defaultInfo[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item_cell" forIndexPath:indexPath];
    cell.textLabel.text = phrase;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_phrase_text_color", @"#000000");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.defaultInfo.count <= indexPath.row) {
        return;
    }
    NSString *phase = self.defaultInfo[indexPath.row];
    [TUICustomerServicePluginDataProvider sendTextMessage:phase];
    [self removeFromSuperview];
}

#pragma mark - Getter
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = TUICustomerServicePluginDynamicColor(@"customer_service_phrase_backview_bg_color", @"#FFFFFF");
    }
    return _backView;
}

- (UITableView *)itemsTableView {
    if (!_itemsTableView) {
        _itemsTableView = [[UITableView alloc] init];
        _itemsTableView.tableFooterView = [[UIView alloc] init];
        _itemsTableView.backgroundColor = [UIColor clearColor];
        _itemsTableView.delegate = self;
        _itemsTableView.dataSource = self;
        _itemsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _itemsTableView.rowHeight = 44;
        _itemsTableView.bounces = NO;
        [_itemsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"item_cell"];
    }
    return _itemsTableView;
}

- (NSArray *)defaultInfo {
    return @[
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseStock),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseCheaper),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseGift),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseShipping),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseDelivery),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseArrive),
    ];
}

@end
