//
//  TUIGroupMemberCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGroupMemberCellData : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *name;
@property NSInteger tag;
@end

@interface TUIGroupMemberCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *head;
@property (nonatomic, strong) UILabel *name;
+ (CGSize)getSize;
- (void)setData:(TGroupMemberCellData *)data;
@end
