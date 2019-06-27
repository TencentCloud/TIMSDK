//
//  TUIGroupPendencyViewModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import <Foundation/Foundation.h>
@class TUIGroupPendencyCellData;



NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupPendencyViewModel : NSObject

@property (readonly) NSArray *dataList;
@property BOOL hasNextData;
@property BOOL isLoading;
@property int unReadCnt;
@property NSString *groupId;
- (void)loadData;
- (void)loadNextData;

- (void)acceptData:(TUIGroupPendencyCellData *)data;
- (void)removeData:(TUIGroupPendencyCellData *)data;

@end

NS_ASSUME_NONNULL_END
