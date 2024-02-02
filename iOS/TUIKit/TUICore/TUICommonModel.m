//
//  TCommonCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonModel.h"
#import <objc/runtime.h>
#import "NSString+TUIUtil.h"
#import "TUIDarkModel.h"
#import "TUIGlobalization.h"
#import "TUIThemeManager.h"
#import "TUITool.h"
#import "UIView+TUILayout.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIUserFullInfo
//
/////////////////////////////////////////////////////////////////////////////////
@implementation V2TIMUserFullInfo (TUIUserFullInfo)

- (NSString *)showName {
    if ([NSString isEmpty:self.nickName]) return self.userID;
    return self.nickName;
}

- (NSString *)showGender {
    if (self.gender == V2TIM_GENDER_MALE) return TUIKitLocalizableString(Male);
    if (self.gender == V2TIM_GENDER_FEMALE) return TUIKitLocalizableString(Female);
    return TUIKitLocalizableString(Unsetted);
}

- (NSString *)showSignature {
    if (self.selfSignature == nil) return TUIKitLocalizableString(TUIKitNoSelfSignature);
    return [NSString stringWithFormat:TUIKitLocalizableString(TUIKitSelfSignatureFormat), self.selfSignature];
}

- (NSString *)showAllowType {
    if (self.allowType == V2TIM_FRIEND_ALLOW_ANY) {
        return TUIKitLocalizableString(TUIKitAllowTypeAcceptOne);
    }
    if (self.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        return TUIKitLocalizableString(TUIKitAllowTypeNeedConfirm);
    }
    if (self.allowType == V2TIM_FRIEND_DENY_ANY) {
        return TUIKitLocalizableString(TUIKitAllowTypeDeclineAll);
    }
    return nil;
}
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIUserModel
//
/////////////////////////////////////////////////////////////////////////////////
@implementation TUIUserModel

- (id)copyWithZone:(NSZone *)zone {
    TUIUserModel *model = [[TUIUserModel alloc] init];
    model.userId = self.userId;
    model.name = self.name;
    model.avatar = self.avatar;
    return model;
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIScrollView
//
/////////////////////////////////////////////////////////////////////////////////

static void *gScrollViewBoundsChangeNotificationContext = &gScrollViewBoundsChangeNotificationContext;

@interface TUIScrollView ()

@property(nonatomic, readonly) CGFloat imageAspectRatio;
@property(nonatomic) CGRect initialImageFrame;
@property(strong, nonatomic, readonly) UITapGestureRecognizer *tap;

@end

@implementation TUIScrollView

@synthesize tap = _tap;

#pragma mark - Tap to Zoom

- (UITapGestureRecognizer *)tap {
    if (_tap == nil) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToZoom:)];
        _tap.numberOfTapsRequired = 2;
    }
    return _tap;
}

- (void)tapToZoom:(UIGestureRecognizer *)gestureRecognizer {
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGPoint tapLocation = [gestureRecognizer locationInView:self.imageView];
        CGFloat zoomRectWidth = self.imageView.frame.size.width / self.maximumZoomScale;
        CGFloat zoomRectHeight = self.imageView.frame.size.height / self.maximumZoomScale;
        CGFloat zoomRectX = tapLocation.x - zoomRectWidth * 0.5;
        CGFloat zoomRectY = tapLocation.y - zoomRectHeight * 0.5;
        CGRect zoomRect = CGRectMake(zoomRectX, zoomRectY, zoomRectWidth, zoomRectHeight);
        [self zoomToRect:zoomRect animated:YES];
    }
}

#pragma mark - Private Methods

- (void)configure {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self startObservingBoundsChange];
}

- (void)setImageView:(UIImageView *)imageView {
    if (_imageView.superview == self) {
        [_imageView removeGestureRecognizer:self.tap];
        [_imageView removeFromSuperview];
    }
    if (imageView) {
        _imageView = imageView;
        _initialImageFrame = CGRectNull;
        _imageView.userInteractionEnabled = YES;
        [_imageView addGestureRecognizer:self.tap];
        [self addSubview:imageView];
    }
}

- (CGFloat)imageAspectRatio {
    if (self.imageView.image) {
        return self.imageView.image.size.width / self.imageView.image.size.height;
    }
    return 1;
}

- (CGSize)rectSizeForAspectRatio:(CGFloat)ratio thatFitsSize:(CGSize)size {
    CGFloat containerWidth = size.width;
    CGFloat containerHeight = size.height;
    CGFloat resultWidth = 0;
    CGFloat resultHeight = 0;

    if ((ratio <= 0) || (containerHeight <= 0)) {
        return size;
    }

    if (containerWidth / containerHeight >= ratio) {
        resultHeight = containerHeight;
        resultWidth = containerHeight * ratio;
    } else {
        resultWidth = containerWidth;
        resultHeight = containerWidth / ratio;
    }

    return CGSizeMake(resultWidth, resultHeight);
}

- (void)scaleImageForScrollViewTransitionFromBounds:(CGRect)oldBounds toBounds:(CGRect)newBounds {
    CGPoint oldContentOffset = CGPointMake(oldBounds.origin.x, oldBounds.origin.y);
    CGSize oldSize = oldBounds.size;
    CGSize newSize = newBounds.size;

    CGSize containedImageSizeOld = [self rectSizeForAspectRatio:self.imageAspectRatio thatFitsSize:oldSize];

    CGSize containedImageSizeNew = [self rectSizeForAspectRatio:self.imageAspectRatio thatFitsSize:newSize];

    if (containedImageSizeOld.height <= 0) {
        containedImageSizeOld = containedImageSizeNew;
    }

    CGFloat orientationRatio = (containedImageSizeNew.height / containedImageSizeOld.height);

    CGAffineTransform t = CGAffineTransformMakeScale(orientationRatio, orientationRatio);

    self.imageView.frame = CGRectApplyAffineTransform(self.imageView.frame, t);

    self.contentSize = self.imageView.frame.size;

    CGFloat xOffset = (oldContentOffset.x + oldSize.width * 0.5) * orientationRatio - newSize.width * 0.5;
    CGFloat yOffset = (oldContentOffset.y + oldSize.height * 0.5) * orientationRatio - newSize.height * 0.5;

    xOffset -= MAX(xOffset + newSize.width - self.contentSize.width, 0);
    yOffset -= MAX(yOffset + newSize.height - self.contentSize.height, 0);
    xOffset += MAX(-xOffset, 0);
    yOffset += MAX(-yOffset, 0);

    self.contentOffset = CGPointMake(xOffset, yOffset);
}

- (void)setupInitialImageFrame {
    if (self.imageView.image && CGRectEqualToRect(self.initialImageFrame, CGRectNull)) {
        CGSize imageViewSize = [self rectSizeForAspectRatio:self.imageAspectRatio thatFitsSize:self.bounds.size];
        self.initialImageFrame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
        self.imageView.frame = self.initialImageFrame;
        self.contentSize = self.initialImageFrame.size;
    }
}

#pragma mark - KVO

- (void)startObservingBoundsChange {
    [self addObserver:self
           forKeyPath:@"bounds"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:gScrollViewBoundsChangeNotificationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (context == gScrollViewBoundsChangeNotificationContext) {
        CGRect oldRect = ((NSValue *)change[NSKeyValueChangeOldKey]).CGRectValue;
        CGRect newRect = ((NSValue *)change[NSKeyValueChangeNewKey]).CGRectValue;
        if (!CGSizeEqualToSize(oldRect.size, newRect.size)) {
            [self scaleImageForScrollViewTransitionFromBounds:oldRect toBounds:newRect];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bounds"];
}

#pragma mark - UIScrollView

- (void)setContentOffset:(CGPoint)contentOffset {
    const CGSize contentSize = self.contentSize;
    const CGSize scrollViewSize = self.bounds.size;

    if (contentSize.width < scrollViewSize.width) {
        contentOffset.x = -(scrollViewSize.width - contentSize.width) * 0.5;
    }

    if (contentSize.height < scrollViewSize.height) {
        contentOffset.y = -(scrollViewSize.height - contentSize.height) * 0.5;
    }

    [super setContentOffset:contentOffset];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupInitialImageFrame];
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIGroupAvatar
//
/////////////////////////////////////////////////////////////////////////////////
#define groupAvatarWidth (48 * [[UIScreen mainScreen] scale])
@implementation TUIGroupAvatar

+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      NSInteger avatarCount = group.count > 9 ? 9 : group.count;
      CGFloat width = groupAvatarWidth / 3 * 0.90;
      CGFloat space3 = (groupAvatarWidth - width * 3) / 4;
      CGFloat space2 = (groupAvatarWidth - width * 2 + space3) / 2;
      CGFloat space1 = (groupAvatarWidth - width) / 2;
      __block CGFloat y = avatarCount > 6 ? space3 : (avatarCount > 3 ? space2 : space1);
      __block CGFloat x = avatarCount % 3 == 0 ? space3 : (avatarCount % 3 == 2 ? space2 : space1);
      width = avatarCount > 4 ? width : (avatarCount > 1 ? (groupAvatarWidth - 3 * space3) / 2 : groupAvatarWidth);

      if (avatarCount == 1) {
          x = 0;
          y = 0;
      }
      if (avatarCount == 2) {
          x = space3;
      } else if (avatarCount == 3) {
          x = (groupAvatarWidth - width) / 2;
          y = space3;
      } else if (avatarCount == 4) {
          x = space3;
          y = space3;
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, groupAvatarWidth, groupAvatarWidth)];
        [view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.6]];
        view.layer.cornerRadius = 6;
        __block NSInteger count = 0;
        for (NSInteger i = avatarCount - 1; i >= 0; i--) {
            NSString *avatarUrl = [group objectAtIndex:i];

            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
            [view addSubview:imageView];
            [imageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
                         placeholderImage:DefaultAvatarImage
                                completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                                  count++;
                                  if (count == avatarCount) {
                                      UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 2.0);
                                      [view.layer renderInContext:UIGraphicsGetCurrentContext()];
                                      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                      UIGraphicsEndPDFContext();
                                      CGImageRef imageRef = image.CGImage;
                                      CGImageRef imageRefRect =
                                          CGImageCreateWithImageInRect(imageRef, CGRectMake(0, 0, view.frame.size.width * 2, view.frame.size.height * 2));
                                      UIImage *ansImage = [[UIImage alloc] initWithCGImage:imageRefRect];
                                      CGImageRelease(imageRefRect);
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                        if (finished) {
                                            finished(ansImage);
                                        }
                                      });
                                  }
                                }];

            if (avatarCount == 3) {
                if (i == 2) {
                    y = width + space3 * 2;
                    x = space3;
                } else {
                    x += width + space3;
                }
            } else if (avatarCount == 4) {
                if (i % 2 == 0) {
                    y += width + space3;
                    x = space3;
                } else {
                    x += width + space3;
                }
            } else {
                if (i % 3 == 0) {
                    y += (width + space3);
                    x = space3;
                } else {
                    x += (width + space3);
                }
            }
        }
      });
    });
}

+ (void)fetchGroupAvatars:(NSString *)groupID placeholder:(UIImage *)placeholder callback:(void (^)(BOOL success, UIImage *image, NSString *groupID))callback {
    @tui_weakify(self);
    [[V2TIMManager sharedInstance] getGroupMemberList:groupID
        filter:V2TIM_GROUP_MEMBER_FILTER_ALL
        nextSeq:0
        succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
          @tui_strongify(self);
          int i = 0;
          NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
          for (V2TIMGroupMemberFullInfo *member in memberList) {
              if (member.faceURL.length > 0) {
                  [groupMemberAvatars addObject:member.faceURL];
              } else {
                  [groupMemberAvatars addObject:@"http://placeholder"];
              }
              if (++i == 9) {
                  break;
              }
          }

          if (i <= 1) {
              [self asyncClearCacheAvatarForGroup:groupID];
              if (callback) {
                  callback(NO, placeholder, groupID);
              }
              return;
          }

          NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
          [NSUserDefaults.standardUserDefaults setInteger:groupMemberAvatars.count forKey:key];
          [NSUserDefaults.standardUserDefaults synchronize];

          [TUIGroupAvatar createGroupAvatar:groupMemberAvatars
                                   finished:^(UIImage *groupAvatar) {
                                     @tui_strongify(self);
                                     UIImage *avatar = groupAvatar;
                                     [self cacheGroupAvatar:avatar number:(UInt32)groupMemberAvatars.count groupID:groupID];

                                     if (callback) {
                                         callback(YES, avatar, groupID);
                                     }
                                   }];
        }
        fail:^(int code, NSString *msg) {
          if (callback) {
              callback(NO, placeholder, groupID);
          }
        }];
}

+ (void)cacheGroupAvatar:(UIImage *)avatar number:(UInt32)memberNum groupID:(NSString *)groupID {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      if (groupID == nil || groupID.length == 0) {
          return;
      }
      NSString *tempPath = NSTemporaryDirectory();
      NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png", tempPath, groupID, memberNum];
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

      // check to delete old file
      NSNumber *oldValue = [defaults objectForKey:groupID];
      if (oldValue != nil) {
          UInt32 oldMemberNum = [oldValue unsignedIntValue];
          NSString *oldFilePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png", tempPath, groupID, oldMemberNum];
          NSFileManager *fileManager = [NSFileManager defaultManager];
          [fileManager removeItemAtPath:oldFilePath error:nil];
      }

      // Save image.
      BOOL success = [UIImagePNGRepresentation(avatar) writeToFile:filePath atomically:YES];
      if (success) {
          [defaults setObject:@(memberNum) forKey:groupID];
      }
    });
}

+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void (^)(UIImage *, NSString *groupID))imageCallBack {
    if (groupID == nil || groupID.length == 0) {
        if (imageCallBack) {
            imageCallBack(nil, groupID);
        }
        return;
    }
    [[V2TIMManager sharedInstance] getGroupsInfo:@[ groupID ]
        succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
          V2TIMGroupInfoResult *groupInfo = groupResultList.firstObject;
          if (!groupInfo) {
              imageCallBack(nil, groupID);
              return;
          }
          UInt32 memberNum = groupInfo.info.memberCount;
          memberNum = MAX(1, memberNum);
          memberNum = MIN(memberNum, 9);
          ;
          NSString *tempPath = NSTemporaryDirectory();
          NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png", tempPath, groupID, (unsigned int)memberNum];
          NSFileManager *fileManager = [NSFileManager defaultManager];
          UIImage *avatar = nil;
          BOOL success = [fileManager fileExistsAtPath:filePath];

          if (success) {
              avatar = [[UIImage alloc] initWithContentsOfFile:filePath];
              NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
              [NSUserDefaults.standardUserDefaults setInteger:memberNum forKey:key];
              [NSUserDefaults.standardUserDefaults synchronize];
          }
          imageCallBack(avatar, groupInfo.info.groupID);
        }
        fail:^(int code, NSString *msg) {
          imageCallBack(nil, groupID);
        }];
}

+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum {
    memberNum = MAX(1, memberNum);
    memberNum = MIN(memberNum, 9);
    ;
    NSString *tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png", tempPath, groupId, (unsigned int)memberNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    UIImage *avatar = nil;
    BOOL success = [fileManager fileExistsAtPath:filePath];

    if (success) {
        avatar = [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    return avatar;
}

+ (void)asyncClearCacheAvatarForGroup:(NSString *)groupID {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      NSString *tempPath = NSTemporaryDirectory();
      for (int i = 0; i < 9; i++) {
          NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png", tempPath, groupID, (i + 1)];
          if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
              [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
          }
      }
    });
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIImageCache
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIImageCache ()
@property(nonatomic, strong) NSMutableDictionary *resourceCache;
@property(nonatomic, strong) NSMutableDictionary *faceCache;
@end

@implementation TUIImageCache

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TUIImageCache *instance;
    dispatch_once(&onceToken, ^{
      instance = [[TUIImageCache alloc] init];
      [UIImage d_fixResizableImage];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _resourceCache = [NSMutableDictionary dictionary];
        _faceCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addResourceToCache:(NSString *)path {
    __weak typeof(self) ws = self;
    [TUITool asyncDecodeImage:path
                     complete:^(NSString *key, UIImage *image) {
                       __strong __typeof(ws) strongSelf = ws;
                       if (key && image) {
                           [strongSelf.resourceCache setValue:image forKey:key];
                       }
                     }];
}

- (UIImage *)getResourceFromCache:(NSString *)path {
    if (path.length == 0) {
        return nil;
    }
    UIImage *image = [_resourceCache objectForKey:path];
    if (!image) {
        image = [UIImage d_imagePath:path];
    }
    return image;
}

- (void)addFaceToCache:(NSString *)path {
    __weak typeof(self) ws = self;
    [TUITool asyncDecodeImage:path
                     complete:^(NSString *key, UIImage *image) {
                       __strong __typeof(ws) strongSelf = ws;
                       if (key && image) {
                           [strongSelf.faceCache setValue:image forKey:key];
                       }
                     }];
}

- (UIImage *)getFaceFromCache:(NSString *)path {
    if (path.length == 0) {
        return nil;
    }
    UIImage *image = [_faceCache objectForKey:path];
    if (!image) {
        // gif extion
        if ([path containsString:@".gif"]) {
            image = [UIImage sd_imageWithGIFData:[NSData dataWithContentsOfFile:path]];
        }
        else {
            image = [UIImage imageWithContentsOfFile:path];
            if (!image) {
                // gif
                NSString *formatPath = [path stringByAppendingString:@".gif"];
                image = [UIImage sd_imageWithGIFData:[NSData dataWithContentsOfFile:formatPath]];
            }
        }
        if (!image) {
            image = [_faceCache objectForKey:TUIChatFaceImagePath(@"ic_unknown_image")];
        }
    }
    return image;
}
@end
@interface IUCoreView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUCoreView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end

@implementation TUINavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor = self.navigationBackColor;
        self.navigationBar.backgroundColor = self.navigationBackColor;
        self.navigationBar.barTintColor = self.navigationBackColor;
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;

    } else {
        self.navigationBar.backgroundColor = self.navigationBackColor;
        self.navigationBar.barTintColor = self.navigationBackColor;
        self.navigationBar.shadowImage = [UIImage new];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (void)back {
    if ([self.uiNaviDelegate respondsToSelector:@selector(navigationControllerDidClickLeftButton:)]) {
        [self.uiNaviDelegate navigationControllerDidClickLeftButton:self];
    }
    [self popViewControllerAnimated:YES];
}

- (UIColor *)navigationBackColor {
    if (!_navigationBackColor) {
        _navigationBackColor = [self tintColor];
    }
    return _navigationBackColor;
}

- (UIColor *)tintColor {
    return TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count != 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        self.tabBarController.tabBar.hidden = YES;

        UIImage *image = self.navigationItemBackArrowImage;
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        viewController.navigationItem.leftBarButtonItems = @[ back ];
        viewController.navigationItem.leftItemsSupplementBackButton = NO;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIImage *)navigationItemBackArrowImage {
    if (!_navigationItemBackArrowImage) {
        _navigationItemBackArrowImage = TUICoreDynamicImage(@"nav_back_img", [UIImage imageNamed:TUICoreImagePath(@"nav_back")]);
    }
    return _navigationItemBackArrowImage;
}

// fix: https://developer.apple.com/forums/thread/660750
- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (@available(iOS 14.0, *)) {
        for (UIViewController *vc in self.viewControllers) {
            vc.hidesBottomBarWhenPushed = NO;
            self.tabBarController.tabBar.hidden = NO;
        }
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count == 1) {
        /**
         * 如果堆栈内的视图控制器数量为1 说明只有根控制器，将 currentShowVC 清空，为了下面的方法禁用侧滑手势
         * If the number of view controllers in the stack is 1, it means only the root controller, clear the currentShowVC, and disable the swipe gesture for
         * the following method
         */
        self.currentShowVC = Nil;
    } else {
        /**
         * 将 push 进来的视图控制器赋值给 currentShowVC
         * Assign the pushed view controller to currentShowVC
         */
        self.currentShowVC = viewController;
    }

    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.viewControllers.count == 1) {
            /**
             * 禁止首页的侧滑返回
             * Forbid the sliding back of the home page
             */
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        } else {
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    /**
     * 监听侧边滑动返回的事件
     * Listen to the event returned by the side slide
     */
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *)) {
        [viewController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
          __strong typeof(weakSelf) strongSelf = weakSelf;
          [strongSelf handleSideSlideReturnIfNeeded:context];
        }];
    } else {
        [viewController.transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
          __strong typeof(weakSelf) strongSelf = weakSelf;
          [strongSelf handleSideSlideReturnIfNeeded:context];
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.currentShowVC == self.topViewController) {
            /**
             * 如果 currentShowVC 存在说明堆栈内的控制器数量大于 1 ，允许激活侧滑手势
             * If currentShowVC exists, it means that the number of controllers in the stack is greater than 1, allowing the side slide gesture to be activated
             */
            return YES;
        }
        return NO;
    }
    return YES;
}

- (void)handleSideSlideReturnIfNeeded:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if (context.isCancelled) {
        return;
    }
    UIViewController *fromVc = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([self.uiNaviDelegate respondsToSelector:@selector(navigationControllerDidSideSlideReturn:fromViewController:)]) {
        [self.uiNaviDelegate navigationControllerDidSideSlideReturn:self fromViewController:fromVc];
    }
}

@end

@implementation UIAlertController (TUITheme)

- (void)tuitheme_addAction:(UIAlertAction *)action {
    if (action.style == UIAlertActionStyleDefault || action.style == UIAlertActionStyleCancel) {
        UIColor *tempColor = TUICoreDynamicColor(@"primary_theme_color", @"#147AFF");
        [action setValue:tempColor forKey:@"_titleTextColor"];
    }
    [self addAction:action];
}

@end
static const void *tui_valueCallbackKey = @"tui_valueCallbackKey";
static const void *tui_nonValueCallbackKey = @"tui_nonValueCallbackKey";
static const void *tui_extValueObjKey = @"tui_extValueObjKey";

@implementation NSObject (TUIExtValue)

- (void)setTui_valueCallback:(TUIValueCallbck)tui_valueCallback {
    objc_setAssociatedObject(self, tui_valueCallbackKey, tui_valueCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TUIValueCallbck)tui_valueCallback {
    return objc_getAssociatedObject(self, tui_valueCallbackKey);
}

- (void)setTui_nonValueCallback:(TUINonValueCallbck)tui_nonValueCallback {
    objc_setAssociatedObject(self, tui_nonValueCallbackKey, tui_nonValueCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TUINonValueCallbck)tui_nonValueCallback {
    return objc_getAssociatedObject(self, tui_nonValueCallbackKey);
}

- (void)setTui_extValueObj:(id)tui_extValueObj {
    objc_setAssociatedObject(self, tui_extValueObjKey, tui_extValueObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id)tui_extValueObj {
    return objc_getAssociatedObject(self, tui_extValueObjKey);
}

@end
