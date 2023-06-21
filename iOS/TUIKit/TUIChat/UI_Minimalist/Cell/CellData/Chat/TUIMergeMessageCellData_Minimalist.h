//
//  TUIMergeMessageCellData_Minimalist.h
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIBubbleMessageCellData_Minimalist.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMergeMessageCellData_Minimalist : TUIBubbleMessageCellData_Minimalist

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSArray<NSString *> *abstractList;
@property(nonatomic, strong) V2TIMMergerElem *mergerElem;
@property(nonatomic, assign) CGSize abstractSize;
- (NSAttributedString *)abstractAttributedString;

@end

NS_ASSUME_NONNULL_END
