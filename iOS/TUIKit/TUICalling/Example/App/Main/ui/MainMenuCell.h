//
//  MainMenuCell.h
//  TRTCDemo
//
//  Created by LiuXiaoya on 2020/1/13.
//  Copyright © 2020 rushanting. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MainMenuItem;

@interface MainMenuCell : UICollectionViewCell

@property (nonatomic, strong) MainMenuItem *item;

@end

@interface MainMenuItem : NSObject

@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *content;
@property (strong, nonatomic, readonly) UIImage *icon;
@property (copy, nonatomic, readonly) void (^selectBlock)(void);

- (instancetype)initWithIcon:(UIImage *)image
                       title:(NSString *)title
                     content:(NSString *)content
                    onSelect:(void(^)(void))selectBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
