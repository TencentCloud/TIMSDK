//
//  TGroupMemberCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGroupMemberCellData : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) SEL selector;
@end

@interface TGroupMemberCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *head;
@property (nonatomic, strong) UILabel *name;
+ (CGSize)getSize;
- (void)setData:(TGroupMemberCellData *)data;
@end
