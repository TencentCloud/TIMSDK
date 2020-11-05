//
//  TUILiveBottomToolBar.m
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveBottomToolBar.h"
#import "Masonry.h"
#import "TUILiveColor.h"
#import "TUILiveUtil.h"

@interface TUILiveBottomToolBar ()
/// public
@property(nonatomic, strong) UIButton *inputButton;
@end

@implementation TUILiveBottomToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inputButton.layer.cornerRadius = self.inputButton.frame.size.height/2.0;
        self.inputButton.clipsToBounds = YES;
        for (UIButton *button in self.rightButtons) {
            button.layer.cornerRadius = button.frame.size.height/2.0;
            button.clipsToBounds = YES;
        }
    });
}

- (void)layoutUI {
    if (!self.inputButton) {
        [self constructViewHierarchy];
    }
    [self.inputButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.height.equalTo(self).multipliedBy(0.8);
        make.centerY.equalTo(self);
    }];
    NSArray *rightButtons = self.rightButtons;
    UIButton *preButton = self.inputButton;
    for (UIButton *button in rightButtons) {
        [self addSubview:button];
        [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [TUILiveColor lightGrayColor];
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(preButton.mas_right).offset(5);
            make.height.width.equalTo(self.inputButton.mas_height);
            make.centerY.equalTo(self.mas_centerY);
            if ([button isEqual:rightButtons.lastObject]) {
                make.right.equalTo(self).offset(-15);
            }
        }];
        preButton = button;
    }
}

- (void)constructViewHierarchy {
    if (!self.inputButton) {
        self.inputButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        [self.inputButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.inputButton setTitle:@"  说点什么                                                  "
                          forState:UIControlStateNormal];
        self.inputButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        self.inputButton.backgroundColor = [TUILiveColor lightGrayColor];
        [self addSubview:self.inputButton];
    }
}

+ (UIButton *)createButtonWithImage:(nullable UIImage *)image selectedImage:(nullable UIImage *)selectedImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    selectedImage = selectedImage?:image;
    if (selectedImage) {
        [button setImage:selectedImage forState:UIControlStateSelected];
        [button setImage:selectedImage forState:UIControlStateHighlighted];
    }
    return button;
}

#pragma mark - setter getter
- (void)setRightButtons:(NSArray<UIButton *> *)inRightButtons {
    NSArray *rightButtons = inRightButtons.copy;
    [TUILiveUtil runInMainThread:^{
        if (self->_rightButtons.count != 0) {
            [self->_rightButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
        }
        self->_rightButtons = rightButtons;
        [self layoutUI];
    }];
}

#pragma mark - actions
- (IBAction)onClick:(UIButton *)sender {
    if (!sender) {
        return;
    }
    if ([sender isEqual:self.inputButton]) {
        [self callBackWithSender:sender];
    } else {
        [self callBackWithSender:sender];
    }
}

- (void)callBackWithSender:(UIButton *)sender {
    if (self.onClick) {
        self.onClick(self, sender);
    }
}

@end
