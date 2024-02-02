//
//  TUIChatPopContextExtionView.m
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/12/1.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatPopContextExtionView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIFitButton.h>
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>

@implementation TUIChatPopContextExtionItem

- (instancetype)initWithTitle:(NSString *)title markIcon:(UIImage *)markIcon weight:(NSInteger)weight withActionHandler:(void (^)(id action))actionHandler {
    self = [super init];
    if (self) {
        _title = title;
        _markIcon = markIcon;
        _weight = weight;
        _actionHandler = actionHandler;
    }
    return self;
}

@end

@interface TUIChatPopContextExtionItemView : UIView
@property(nonatomic, strong) TUIChatPopContextExtionItem *item;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *l;
- (void)configBaseUIWithItem:(TUIChatPopContextExtionItem *)item;
@end

@implementation TUIChatPopContextExtionItemView

- (void)configBaseUIWithItem:(TUIChatPopContextExtionItem *)item {
    self.item = item;
    CGFloat itemWidth = self.frame.size.width;
    CGFloat padding = kScale390(16);
    CGFloat itemHeight = self.frame.size.height;

    UIImageView *icon = [[UIImageView alloc] init];
    [self addSubview:icon];
    icon.frame = CGRectMake(itemWidth - padding - kScale390(18), itemHeight * 0.5 - kScale390(18) * 0.5, kScale390(18), kScale390(18));
    icon.image = self.item.markIcon;

    UILabel *l = [[UILabel alloc] init];
    l.frame = CGRectMake(padding, 0, itemWidth * 0.5, itemHeight);
    l.text = self.item.title;
    l.font = item.titleFont ?: [UIFont systemFontOfSize:kScale390(16)];
    l.textAlignment = isRTL()? NSTextAlignmentRight:NSTextAlignmentLeft;
    l.textColor = item.titleColor ?: [UIColor blackColor];
    l.userInteractionEnabled = false;
    [self addSubview:l];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton addTarget:self action:@selector(buttonclick) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.frame = CGRectMake(0, 0, itemWidth, itemHeight);

    [self addSubview:backButton];

    if (item.needBottomLine) {
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor tui_colorWithHex:@"DDDDDD"];
        line.frame = CGRectMake(0, itemHeight - kScale390(0.5), itemWidth, kScale390(0.5));
        [self addSubview:line];
    }
    self.layer.masksToBounds = YES;
    if (isRTL()) {
        for (UIView *subview in self.subviews) {
            [subview resetFrameToFitRTL];
        }
    }
}

- (void)buttonclick {
    if (self.item.actionHandler) {
        self.item.actionHandler(self.item);
    }
}

@end

@interface TUIChatPopContextExtionView ()

@property(nonatomic, strong) NSMutableArray<TUIChatPopContextExtionItem *> *items;

@end

@implementation TUIChatPopContextExtionView
- (void)configUIWithItems:(NSMutableArray<TUIChatPopContextExtionItem *> *)items topBottomMargin:(CGFloat)topBottomMargin {
    if (self.subviews.count > 0) {
        for (UIView *subview in self.subviews) {
            if (subview) {
                [subview removeFromSuperview];
            }
        }
    }
    int i = 0;
    for (TUIChatPopContextExtionItem *item in items) {
        TUIChatPopContextExtionItemView *itemView = [[TUIChatPopContextExtionItemView alloc] init];
        itemView.frame = CGRectMake(0, (kScale390(40)) * i + topBottomMargin, kScale390(180), kScale390(40));
        [itemView configBaseUIWithItem:item];
        [self addSubview:itemView];
        i++;
    }
}
@end
