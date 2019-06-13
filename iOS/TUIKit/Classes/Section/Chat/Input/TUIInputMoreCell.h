//
//  TMoreCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/22.
//

#import <UIKit/UIKit.h>

@interface TUIInputMoreCellData : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;

@property (class, nonatomic, assign) TUIInputMoreCellData *photoData;
@property (class, nonatomic, assign) TUIInputMoreCellData *pictureData;
@property (class, nonatomic, assign) TUIInputMoreCellData *videoData;
@property (class, nonatomic, assign) TUIInputMoreCellData *fileData;

@end

@interface TUIInputMoreCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) TUIInputMoreCellData *data;

- (void)fillWithData:(TUIInputMoreCellData *)data;

+ (CGSize)getSize;
@end



