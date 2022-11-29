//
//  TUIAddCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUIAddCellState) {
    TAddCell_State_UnSelect,
    TAddCell_State_Selected,
    TAddCell_State_Solid,
};

@interface TUIAddCellData : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) TUIAddCellState state;
@end

NS_ASSUME_NONNULL_END
