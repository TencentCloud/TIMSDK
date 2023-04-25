//
//  TUIContactActionCell_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//

#import "TUIContactActionCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import "TUICommonContactCellData_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUIContactActionCell_Minimalist ()
@property TUIContactActionCellData_Minimalist *actionData;
@property (nonatomic,strong) UIView *line;
@end

@implementation TUIContactActionCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"", @"#000000");
        self.titleLabel.font = [UIFont systemFontOfSize:kScale390(16)];
        self.unRead = [[TUIUnReadView alloc] init];
        [self.contentView addSubview:self.unRead];
        
        self.line = [[UIView alloc] init];
        [self.contentView addSubview:self.line];
        self.line.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
        self.contentView.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)fillWithData:(TUIContactActionCellData_Minimalist *)actionData {
    [super fillWithData:actionData];
    self.actionData = actionData;

    self.titleLabel.text = actionData.title;

    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(kScale390(16), (self.contentView.frame.size.height - self.titleLabel.frame.size.height) *0.5 , self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    
    self.line.hidden = actionData.needBottomLine?NO:YES;
    self.line.frame = CGRectMake(0, self.contentView.frame.size.height - 1, self.contentView.frame.size.width, 1);

    @weakify(self)
    [[RACObserve(self.actionData, readNum) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
        @strongify(self)
        [self.unRead setNum:[x integerValue]];
    }];

    self.unRead.mm__centerY(self.titleLabel.mm_centerY).mm_right(self.accessoryView.mm_w);
}


@end
