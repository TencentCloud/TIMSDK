//
//  TUIChatContextEmojiDetailController.m
//  TUIChat
//
//  Created by wyl on 2022/10/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatContextEmojiDetailController.h"
#import "TUIChatConfig.h"

#define TChatEmojiView_Margin 20
#define TChatEmojiView_MarginTopBottom 17

#define TChatEmojiView_Padding 20
#define TChatEmojiView_Page_Height 30
#define TChatEmojiView_CollectionOffsetY 8
#define TChatEmojiView_CollectionHeight 107

@implementation TUIContextChatPopEmojiFaceView

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    CGFloat width = (self.frame.size.width - TChatEmojiView_Padding * 2 - TChatEmojiView_Margin * (group.itemCountPerRow - 1)) / group.itemCountPerRow;

    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self defaultLayout];
    [self updateFrame];
}

- (void)defaultLayout {
    self.faceFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.faceFlowLayout.minimumLineSpacing = TChatEmojiView_Margin;
    self.faceFlowLayout.minimumInteritemSpacing = TChatEmojiView_MarginTopBottom;
    self.faceFlowLayout.sectionInset = UIEdgeInsetsMake(0, TChatEmojiView_Padding, (Is_IPhoneX ? 0 : TChatEmojiView_Padding), TChatEmojiView_Padding);
    self.faceCollectionView.collectionViewLayout = self.faceFlowLayout;
    self.faceCollectionView.bounces = NO;
    self.faceCollectionView.delaysContentTouches = NO;
    self.faceCollectionView.pagingEnabled = NO;
    self.faceCollectionView.backgroundColor = [UIColor clearColor];
}

- (void)updateFrame {
    self.faceCollectionView.frame = CGRectMake(0, TChatEmojiView_CollectionOffsetY, self.frame.size.width, self.frame.size.height);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setData:(NSMutableArray *)data {
    [super setData:data];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TFaceCell_ReuseId forIndexPath:indexPath];
    cell.face.contentMode = UIViewContentModeScaleAspectFill;
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];

    NSNumber *index = [self.itemIndexs objectForKey:indexPath];
    if (index.integerValue < group.faces.count) {
        TUIFaceCellData *data = group.faces[index.integerValue];
        [cell setData:data];
        cell.backgroundColor = [UIColor clearColor];
    } else {
        [cell setData:nil];
    }

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int groupIndex = [self.groupIndexInSection[section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    return group.rowCount * group.itemCountPerRow;
}

@end

@interface TUIChatContextEmojiDetailController () <TUIFaceViewDelegate>

@property(nonatomic, strong) TUIContextChatPopEmojiFaceView *faceView;

@end

@implementation TUIChatContextEmojiDetailController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNormalBottom];

    self.containerView.backgroundColor = [UIColor whiteColor];

    [self.containerView addSubview:self.faceView];
}

- (TUIContextChatPopEmojiFaceView *)faceView {
    if (!_faceView) {
        _faceView =
            [[TUIContextChatPopEmojiFaceView alloc] initWithFrame:CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                                                             self.containerView.frame.size.height - self.topGestureView.frame.size.height)];
        _faceView.delegate = self;
        [_faceView setData:[TUIChatConfig defaultConfig].chatContextEmojiDetailGroups];
        _faceView.backgroundColor = [UIColor clearColor];
    }
    return _faceView;
}

- (void)updateSubContainerView {
    [super updateSubContainerView];
    _faceView.frame = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                 self.containerView.frame.size.height - self.topGestureView.frame.size.height);
}

- (void)faceView:(TUIFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index {
}

- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceGroup *group = faceView.faceGroups[indexPath.section];

    TUIFaceCellData *face = group.faces[indexPath.row];
    if (indexPath.section == 0) {
        NSString *faceName = face.name;
        NSLog(@"%@", faceName);
        [self dismissViewControllerAnimated:NO completion:nil];
        if (self.reactClickCallback) {
            self.reactClickCallback(faceName);
        }
    }
}

- (void)faceViewDidBackDelete:(TUIFaceView *)faceView {
}

@end
