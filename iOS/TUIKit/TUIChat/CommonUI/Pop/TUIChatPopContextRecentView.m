//
//  TUIChatPopContextRecentView.m
//  TUIChat
//
//  Created by wyl on 2022/10/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatPopContextRecentView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIFitButton.h>

@interface TUIChatPopContextRecentView ()
@property(nonatomic, strong) NSMutableArray *sectionIndexInGroup;
@property(nonatomic, strong) NSMutableArray *pageCountInGroup;
@property(nonatomic, strong) NSMutableArray *groupIndexInSection;
@property(nonatomic, strong) NSMutableDictionary *itemIndexs;
@property(nonatomic, assign) NSInteger sectionCount;
@end
@implementation TUIChatPopContextRecentView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self defaultLayout];
}

- (void)defaultLayout {
    [self setupCorner];
    [self setupDefaultArray];
}

- (void)setupCorner {
    UIRectCorner corner = UIRectCornerAllCorners;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(kScale390(22), kScale390(22))];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setupDefaultArray {
    NSMutableArray *faceArray = [NSMutableArray array];
    TUIFaceGroup *defaultFaceGroup = [self findFaceGroupAboutType];
    if (defaultFaceGroup) {
        [faceArray addObject:defaultFaceGroup];
    }
    [self setData:faceArray];
}

- (void)setData:(NSMutableArray *)data {
    _faceGroups = data;
    _sectionIndexInGroup = [NSMutableArray array];
    _groupIndexInSection = [NSMutableArray array];
    _itemIndexs = [NSMutableDictionary dictionary];

    NSInteger sectionIndex = 0;
    for (NSInteger groupIndex = 0; groupIndex < _faceGroups.count; ++groupIndex) {
        TUIFaceGroup *group = _faceGroups[groupIndex];
        [_sectionIndexInGroup addObject:@(sectionIndex)];
        int itemCount = group.rowCount * group.itemCountPerRow;
        int sectionCount = ceil(group.faces.count * 1.0 / (itemCount - 0));
        for (int sectionIndex = 0; sectionIndex < sectionCount; ++sectionIndex) {
            [_groupIndexInSection addObject:@(groupIndex)];
        }
        sectionIndex += sectionCount;
    }
    _sectionCount = sectionIndex;

    for (NSInteger curSection = 0; curSection < _sectionCount; ++curSection) {
        NSNumber *groupIndex = _groupIndexInSection[curSection];
        NSNumber *groupSectionIndex = _sectionIndexInGroup[groupIndex.integerValue];
        TUIFaceGroup *face = _faceGroups[groupIndex.integerValue];
        NSInteger itemCount = face.rowCount * face.itemCountPerRow;
        NSInteger groupSection = curSection - groupSectionIndex.integerValue;
        for (NSInteger itemIndex = 0; itemIndex < itemCount; ++itemIndex) {
            // transpose line/row
            NSInteger row = itemIndex % face.rowCount;
            NSInteger column = itemIndex / face.rowCount;
            NSInteger reIndex = face.itemCountPerRow * row + column + groupSection * itemCount;
            [_itemIndexs setObject:@(reIndex) forKey:[NSIndexPath indexPathForRow:itemIndex inSection:curSection]];
        }
    }

    [self createBtns];

    if (self.needShowbottomLine) {
        float margin = 20;

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(margin, self.frame.size.height - 1, self.frame.size.width - 2 * margin, 0.5)];
        ;
        [self addSubview:line];
        line.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    }
}

- (NSArray *)getChatPopMenuQueue {
    NSArray *emojis = [[NSUserDefaults standardUserDefaults] objectForKey:@"TUIChatPopMenuQueue"];
    if (emojis && [emojis isKindOfClass:[NSArray class]]) {
        if (emojis.count > 0) {
            return emojis;
        }
    }
    return [NSArray arrayWithContentsOfFile:TUIChatFaceImagePath(@"emoji/emojiRecentDefaultList.plist")];
}

- (TUIFaceGroup *)findFaceGroupAboutType {
    // emoji group
    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [self getChatPopMenuQueue];
    for (NSDictionary *dic in emojis) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [dic objectForKey:@"face_name"];
        NSString *path = [NSString stringWithFormat:@"emoji/%@", name];
        NSString *localizableName = [TUIGlobalization g_localizedStringForKey:name bundle:@"TUIChatFace"];
        data.name = name;
        data.path = TUIChatFaceImagePath(path);
        data.localizableName = localizableName;
        [emojiFaces addObject:data];
    }
    if (emojiFaces.count != 0) {
        TUIFaceGroup *emojiGroup = [[TUIFaceGroup alloc] init];
        emojiGroup.faces = emojiFaces;
        emojiGroup.groupIndex = 0;
        emojiGroup.groupPath = TUIChatFaceImagePath(@"emoji/");
        emojiGroup.menuPath = TUIChatFaceImagePath(@"emoji/menu");
        emojiGroup.rowCount = 1;
        emojiGroup.itemCountPerRow = 7;
        emojiGroup.needBackDelete = NO;

        return emojiGroup;
    }

    return nil;
}

- (void)createBtns {
    if (self.subviews) {
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
    }
    int groupIndex = [_groupIndexInSection[0] intValue];
    TUIFaceGroup *group = _faceGroups[groupIndex];
    int tag = 0;
    float margin = kScale390(8);
    float padding = kScale390(8);

    UIButton *preBtn = nil;
    for (TUIFaceCellData *cellData in group.faces) {
        UIButton *button = [self buttonWithCellImage:[[TUIImageCache sharedInstance] getFaceFromCache:cellData.path] Tag:tag];
        [self addSubview:button];
        if (tag == 0) {
            button.mm_width(kScale390(20)).mm_height(kScale390(20)).mm_left(margin).mm_top(kScale390(10));
        } else {
            button.mm_width(kScale390(20)).mm_height(kScale390(20)).mm_left(preBtn.mm_x + preBtn.mm_w + padding).mm_top(kScale390(10));
        }
        tag++;
        preBtn = button;
    }

    self.arrowButton = [self buttonWithCellImage:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_emoji_more")] Tag:999];
    [self addSubview:self.arrowButton];

    self.arrowButton.mm_width(kScale390(24)).mm_height(kScale390(24)).mm_right(margin).mm_top(kScale390(8));
    if (isRTL()) {
        for (UIView *subview in self.subviews) {
            [subview resetFrameToFitRTL];
        }
    }
}

- (UIButton *)buttonWithCellImage:(UIImage *)img Tag:(NSInteger)tag {
    TUIFitButton *actionButton = [TUIFitButton buttonWithType:UIButtonTypeCustom];
    actionButton.imageSize = CGSizeMake(kScale390(24), kScale390(24));
    [actionButton setImage:img forState:UIControlStateNormal];
    actionButton.contentMode = UIViewContentModeScaleAspectFit;
    [actionButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    actionButton.tag = tag;
    return actionButton;
}

- (void)onClick:(UIButton *)btn {
    if (btn.tag == 999) {
        if (_delegate && [_delegate respondsToSelector:@selector(popRecentViewClickArrow:)]) {
            [_delegate popRecentViewClickArrow:self];
            btn.selected = !btn.selected;
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(popRecentViewClickface:tag:)]) {
            [_delegate popRecentViewClickface:self tag:btn.tag];
        }
    }
}

@end

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
