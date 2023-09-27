//
//  TUIChatPopRecentView.m
//  TUIChat
//
//  Created by wyl on 2022/5/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatPopRecentView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIFitButton.h>

@interface TUIChatPopRecentView ()

@property(nonatomic, strong) NSMutableArray *sectionIndexInGroup;
@property(nonatomic, strong) NSMutableArray *pageCountInGroup;
@property(nonatomic, strong) NSMutableArray *groupIndexInSection;
@property(nonatomic, strong) NSMutableDictionary *itemIndexs;
@property(nonatomic, assign) NSInteger sectionCount;

@end

@implementation TUIChatPopRecentView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self defaultLayout];
    
    if (isRTL()) {
        for (UIView *subview in self.subviews) {
            if ([subview respondsToSelector:@selector(resetFrameToFitRTL)]) {
                [subview resetFrameToFitRTL];
            }
        }
    }

}

- (void)defaultLayout {
    [self setupCorner];
    [self setupDefaultArray];
}

- (void)setupCorner {
    UIRectCorner corner = UIRectCornerTopRight | UIRectCornerTopLeft;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(5, 5)];
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
    float margin = 20;
    float padding = 12;

    UIButton *preBtn = nil;
    for (TUIFaceCellData *cellData in group.faces) {
        UIButton *button = [self buttonWithCellImage:[[TUIImageCache sharedInstance] getFaceFromCache:cellData.path] Tag:tag];
        [self addSubview:button];
        if (tag == 0) {
            button.mm_sizeToFit().mm_left(margin).mm__centerY(self.mm_centerY);
        } else {
            button.mm_sizeToFit().mm_left(preBtn.mm_x + preBtn.mm_w + padding).mm__centerY(self.mm_centerY);
        }
        tag++;
        preBtn = button;
    }

    self.arrowButton = [self buttonWithCellImage:TUIChatBundleThemeImage(@"chat_icon_emojiArrowDown_img", @"emojiArrowDown") Tag:999];
    [self addSubview:self.arrowButton];
    [self.arrowButton setImage:TUIChatBundleThemeImage(@"chat_icon_emojiArrowUp_img", @"emojiArrowUp") forState:UIControlStateSelected];
    self.arrowButton.mm_width(25).mm_height(25).mm_right(margin).mm__centerY(self.mm_centerY);
}

- (UIButton *)buttonWithCellImage:(UIImage *)img Tag:(NSInteger)tag {
    TUIFitButton *actionButton = [TUIFitButton buttonWithType:UIButtonTypeCustom];
    actionButton.imageSize = CGSizeMake(25, 25);
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
