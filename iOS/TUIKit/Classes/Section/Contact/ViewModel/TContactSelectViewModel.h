//
//  TContactSelectViewModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//

#import <Foundation/Foundation.h>
@class TCommonContactSelectCellData;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ContactSelectFilterBlock)(TCommonContactSelectCellData *data);

@interface TContactSelectViewModel : NSObject

@property (readonly) NSDictionary<NSString *, NSArray<TCommonContactSelectCellData *> *> *dataDict;
@property (readonly) NSArray *groupList;

@property (readonly) BOOL isLoadFinished;

/**
 * 禁用联系人过滤器
 */
@property (copy) ContactSelectFilterBlock disableFilter;

/**
 * 显示联系人过滤器
 */
@property (copy) ContactSelectFilterBlock avaliableFilter;


- (void)loadContacts;

@end

NS_ASSUME_NONNULL_END
