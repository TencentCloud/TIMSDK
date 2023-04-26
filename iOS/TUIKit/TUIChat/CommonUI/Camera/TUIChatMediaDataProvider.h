//
//  TUIChatMediaDataProvider.h
//  TUIChat
//
//  Created by harvy on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIChatMediaDataProviderResultCallback)(BOOL success, NSString * __nullable message, NSString * __nullable path);

@protocol TUIChatMediaDataProtocol <NSObject>

- (void)selectPhoto;
- (void)takePicture;
- (void)takeVideo;
- (void)selectFile;

@end


@protocol TUIChatMediaDataListener <NSObject>

- (void)onProvideImage:(NSString *)imageUrl;
- (void)onProvideImageError:(NSString *)errorMessage;

- (void)onProvideVideo:(NSString *)videoUrl snapshot:(NSString *)snapshotUrl duration:(NSInteger)duration;
- (void)onProvideVideoError:(NSString *)errorMessage;

- (void)onProvideFile:(NSString *)fileUrl filename:(NSString *)filename fileSize:(NSInteger)fileSize;
- (void)onProvideFileError:(NSString *)errorMessage;

@end

@interface TUIChatMediaDataProvider : NSObject <TUIChatMediaDataProtocol>

@property (nonatomic, weak) UIViewController *presentViewController;
@property (nonatomic, weak) id<TUIChatMediaDataListener> listener;

@end

NS_ASSUME_NONNULL_END
