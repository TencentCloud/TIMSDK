//
//  TUIReactContextEmojiDetailController.m
//  TUIChat
//
//  Created by wyl on 2022/10/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReactContextEmojiDetailController.h"
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>
#import <TUIChat/TUIChatConfig.h>
#import <TIMCommon/NSString+TUIEmoji.h>

@implementation TUIReactContextPopEmojiFaceView

- (void)setData:(NSMutableArray *)data {
    [super setData:data];
    self.floatCtrlView.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.faceCollectionView.backgroundColor = self.backgroundColor;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.frame.size.width, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    CGFloat width = (self.frame.size.width - TFaceView_Page_Padding * 2 - TFaceView_Margin * (group.itemCountPerRow - 1)) / group.itemCountPerRow;
    CGFloat height = width ;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TFaceCell_ReuseId forIndexPath:indexPath];
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    int itemCount = group.faces.count;

    NSNumber *index = [self.itemIndexs objectForKey:indexPath];
    if (index.integerValue < group.faces.count) {
        TUIFaceCellData *data = group.faces[index.integerValue];
        [cell setData:data];
    } else {
        [cell setData:nil];
    }
    cell.face.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}


@end

@interface TUIReactContextEmojiDetailController () <TUIFaceVerticalViewDelegate>

@property(nonatomic, strong) TUIReactContextPopEmojiFaceView *faceView;

@end

@implementation TUIReactContextEmojiDetailController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNormalBottom];

    self.containerView.backgroundColor = [UIColor whiteColor];

    [self.containerView addSubview:self.faceView];
}

- (TUIReactContextPopEmojiFaceView *)faceView {
    if (!_faceView) {
        _faceView =
            [[TUIReactContextPopEmojiFaceView alloc] initWithFrame:CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                                                             self.containerView.frame.size.height - self.topGestureView.frame.size.height)];
        _faceView.delegate = self;
        [_faceView setData:(id)[TUIChatConfig defaultConfig].chatContextEmojiDetailGroups];
        _faceView.backgroundColor = [UIColor clearColor];
    }
    return _faceView;
}

- (void)updateSubContainerView {
    [super updateSubContainerView];
    _faceView.frame = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                 self.containerView.frame.size.height - self.topGestureView.frame.size.height);
}

- (void)updateRecentMenuQueue:(NSString *)faceName {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    return [service updateRecentMenuQueue:faceName];
}

- (void)faceView:(TUIFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index {
}

- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceGroup *group = faceView.faceGroups[indexPath.section];

    TUIFaceCellData *face = group.faces[indexPath.row];
    if (indexPath.section == 0) {
        NSString *faceName = face.name;
        NSLog(@"%@", faceName);
        [self updateRecentMenuQueue:faceName];
        [self dismissViewControllerAnimated:NO completion:nil];
        if (self.reactClickCallback) {
            self.reactClickCallback(faceName);
        }
    }
}

- (void)faceViewDidBackDelete:(TUIFaceView *)faceView {
    
}

@end
