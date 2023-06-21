//
//  TIMPopActionProtocol.h
//  TIMCommon
//
//  Created by wyl on 2023/4/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TIMPopActionProtocol <NSObject>

- (void)onDelete:(id)sender;

- (void)onCopyMsg:(id)sender;

- (void)onRevoke:(id)sender;

- (void)onReSend:(id)sender;

- (void)onMulitSelect:(id)sender;

- (void)onForward:(id)sender;

- (void)onReply:(id)sender;

- (void)onReference:(id)sender;

@end

NS_ASSUME_NONNULL_END
