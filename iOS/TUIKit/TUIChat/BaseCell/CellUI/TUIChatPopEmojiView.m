//
//  TUIChatPopEmojiView.m
//  TUIChat
//
//  Created by wyl on 2022/4/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatPopEmojiView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@interface TUIChatPopEmojiView ()

@end
@implementation TUIChatPopEmojiView

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    CGFloat width = (self.frame.size.width - TChatEmojiView_Padding * 2 - TChatEmojiView_Margin * (group.itemCountPerRow - 1)) / group.itemCountPerRow;

    CGFloat height = (collectionView.frame.size.height - TChatEmojiView_MarginTopBottom * (group.rowCount - 1)) / group.rowCount;
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self defaultLayout];
    [self updateFrame];
    [self updateCorner];
}

- (void)defaultLayout {
    self.faceFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.faceFlowLayout.minimumLineSpacing = TChatEmojiView_Margin;
    self.faceFlowLayout.minimumInteritemSpacing = TChatEmojiView_MarginTopBottom;
    self.faceFlowLayout.sectionInset = UIEdgeInsetsMake(0, TChatEmojiView_Padding, 0, TChatEmojiView_Padding);
    self.faceCollectionView.collectionViewLayout = self.faceFlowLayout;
}

- (void)updateFrame {
    self.faceCollectionView.frame = CGRectMake(0, TChatEmojiView_CollectionOffsetY, self.frame.size.width, TChatEmojiView_CollectionHeight);
    self.pageControl.frame =
        CGRectMake(0, TChatEmojiView_CollectionOffsetY + self.faceCollectionView.frame.size.height, self.frame.size.width, TChatEmojiView_Page_Height);
}

- (void)updateCorner {
    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y - 1, self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corner cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
- (void)setData:(NSMutableArray *)data {
    [super setData:data];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TFaceCell_ReuseId forIndexPath:indexPath];
    cell.face.contentMode = UIViewContentModeScaleAspectFill;
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    int itemCount = group.rowCount * group.itemCountPerRow;
    if (indexPath.row == itemCount - 1 && group.needBackDelete) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        data.path = TUIChatFaceImagePath(@"del_normal");
        [cell setData:data];
    } else {
        NSNumber *index = [self.itemIndexs objectForKey:indexPath];
        if (index.integerValue < group.faces.count) {
            TUIFaceCellData *data = group.faces[index.integerValue];
            [cell setData:data];
        } else {
            [cell setData:nil];
        }
    }
    return cell;
}
@end
