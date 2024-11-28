// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaPasterSelectController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/RACEXTScope.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaImagePicker.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterSelectView.h"
#import "TUIMultimediaPlugin/TUIMultimediaPersistence.h"

@interface TUIMultimediaPasterSelectController () <TUIMultimediaPasterSelectViewDelegate> {
    TUIMultimediaPasterSelectView *_selectView;
    TUIMultimediaImagePicker *_picker;
}

@end

@implementation TUIMultimediaPasterSelectController
- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectView = [[TUIMultimediaPasterSelectView alloc] init];
    _selectView.config = [TUIMultimediaPasterConfig loadConfig];
    _selectView.delegate = self;
    self.mainView = _selectView;
}

- (void)popupControllerDidCanceled {
    [_delegate onPasterSelectControllerExit:self];
}

- (void)onPasterSelected:(UIImage *)image {
    [_delegate pasterSelectController:self onPasterSelected:image];
}
- (void)pasterSelectView:(TUIMultimediaPasterSelectView *)v needAddCustomPaster:(TUIMultimediaPasterGroupConfig *)group completeCallback:(void (^)(void))callback {
    _picker = [[TUIMultimediaImagePicker alloc] init];
    @weakify(self);
    _picker.callback = ^(UIImage *img) {
      @strongify(self);
      if (img == nil || self == nil) {
          return;
      }
      NSURL *url = [TUIMultimediaPasterConfig saveCustomPaster:img];
      if (url == nil) {
          return;
      }
      TUIMultimediaPasterItemConfig *item = [[TUIMultimediaPasterItemConfig alloc] init];
      item.imageUrl = url;
      item.isUserAdded = YES;
      group.itemList = [group.itemList arrayByAddingObject:item];
      [TUIMultimediaPasterConfig saveConfig:v.config];
      callback();
    };
    [_picker presentOn:self];
}
- (void)pasterSelectView:(TUIMultimediaPasterSelectView *)v
    needDeleteCustomPasterInGroup:(TUIMultimediaPasterGroupConfig *)group
                            index:(NSInteger)index
                 completeCallback:(void (^)(BOOL deleted))callback {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[TUIMultimediaCommon localizedStringForKey:@"remove_paster"]
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[TUIMultimediaCommon localizedStringForKey:@"cancel"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                           callback(NO);
                                                         }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[TUIMultimediaCommon localizedStringForKey:@"delete"]
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {
                                                           NSMutableArray<TUIMultimediaPasterItemConfig *> *list = [NSMutableArray arrayWithArray:group.itemList];
                                                           TUIMultimediaPasterItemConfig *paster = list[index];
                                                           [list removeObjectAtIndex:index];
                                                           group.itemList = list;
                                                           [TUIMultimediaPasterConfig removeCustomPaster:paster];
                                                           [TUIMultimediaPasterConfig saveConfig:self->_selectView.config];
                                                           callback(YES);
                                                         }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
