//
//  TCommonTextCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TCommonTextCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"

@implementation TCommonTextCellData
- (instancetype)init {
    self = [super init];

    return self;
}

@end

@interface TCommonTextCell()
@property TCommonTextCellData *textData;
@end

@implementation TCommonTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        _keyLabel = self.textLabel;
        
        _valueLabel = self.detailTextLabel;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.changeColorWhenTouched = YES;
        
        
    }
    return self;
}


- (void)fillWithData:(TCommonTextCellData *)textData
{
    [super fillWithData:textData];
    
    self.textData = textData;
    RAC(_keyLabel, text) = [RACObserve(textData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(textData, value) takeUntil:self.rac_prepareForReuseSignal];
    
    if (textData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}
/*
- (void)tapGesture:(UIGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateEnded){
        self.backgroundColor = [UIColor whiteColor];
        if (self.data.cselector) {
            UIViewController *vc = self.mm_viewController;
            if ([vc respondsToSelector:self.data.cselector]) {
                self.selected = YES;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [vc performSelector:self.data.cselector withObject:self];
    #pragma clang diagnostic pop
            }
        }
    }else if(gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateCancelled){
         self.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(touch.phase == UITouchPhaseBegan)
        //self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [super setHighlighted:YES animated:NO];
    else
        self.backgroundColor = [UIColor whiteColor];
    
    return  YES;
}
 */


/*
  - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(touch.phase == UITouchPhaseBegan && self.changeColorWhenTouched)
        self.backgroundColor = self.colorWhenTouched;
    return  YES;
}
*/


-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.changeColorWhenTouched){
        self.backgroundColor = self.colorWhenTouched;
    }
}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.changeColorWhenTouched){
        self.backgroundColor = [UIColor whiteColor];
    }
}


-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.changeColorWhenTouched){
        self.backgroundColor = [UIColor whiteColor];
    }
}

-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.changeColorWhenTouched){
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
