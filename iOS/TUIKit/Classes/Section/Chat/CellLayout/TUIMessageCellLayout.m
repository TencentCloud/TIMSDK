
#import "TUIMessageCellLayout.h"
#import "THeader.h"
#import "TUISystemMessageCellLayout.h"
#import "TUIOutgoingTextCellLayout.h"
#import "TUIIncommingTextCellLayout.h"

@implementation TUIMessageCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.avatarSize = CGSizeMake(40, 40);
    }
    return self;
}

static TUIMessageCellLayout *sIncommingMessageLayout;

+ (TUIMessageCellLayout *)incommingMessageLayout
{
    if (!sIncommingMessageLayout) {
        sIncommingMessageLayout = [TIncommingCellLayout new];
    }
    return sIncommingMessageLayout;
}

+ (void)setIncommingMessageLayout:(TUIMessageCellLayout *)incommingMessageLayout
{
    sIncommingMessageLayout = incommingMessageLayout;
}

static TUIMessageCellLayout *sOutgoingMessageLayout;

+ (TUIMessageCellLayout *)outgoingMessageLayout
{
    if (!sOutgoingMessageLayout) {
        sOutgoingMessageLayout = [TIncommingCellLayout new];
    }
    return sOutgoingMessageLayout;
}

+ (void)setOutgoingMessageLayout:(TUIMessageCellLayout *)outgoingMessageLayout
{
    sOutgoingMessageLayout = outgoingMessageLayout;
}

static TUIMessageCellLayout *sSystemMessageLayout;

+ (TUIMessageCellLayout *)systemMessageLayout
{
    if (!sSystemMessageLayout) {
        sSystemMessageLayout = [TUISystemMessageCellLayout new];
    }
    return sSystemMessageLayout;
}

+ (void)setSystemMessageLayout:(TUIMessageCellLayout *)systemMessageLayout
{
    sSystemMessageLayout = systemMessageLayout;
}

static TUIMessageCellLayout *sIncommingTextMessageLayout;

+ (TUIMessageCellLayout *)incommingTextMessageLayout
{
    if (!sIncommingTextMessageLayout) {
        sIncommingTextMessageLayout = [TUIIncommingTextCellLayout new];
    }
    return sIncommingTextMessageLayout;
}

+ (void)setIncommingTextMessageLayout:(TUIMessageCellLayout *)incommingTextMessageLayout
{
    sIncommingTextMessageLayout = incommingTextMessageLayout;
}

static TUIMessageCellLayout *sOutgingTextMessageLayout;

+ (TUIMessageCellLayout *)outgoingTextMessageLayout
{
    if (!sOutgingTextMessageLayout) {
        sOutgingTextMessageLayout = [TUIOutgoingTextCellLayout new];
    }
    return sOutgingTextMessageLayout;
}

+ (void)setOutgoingTextMessageLayout:(TUIMessageCellLayout *)outgoingTextMessageLayout
{
    sOutgingTextMessageLayout = outgoingTextMessageLayout;
}
@end


@implementation TIncommingCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.avatarInsets = (UIEdgeInsets){
            .left = 8,
            .top = 5,
            .bottom = 5,
        };
        self.messageInsets = (UIEdgeInsets){
            .top = 5,
            .bottom = 5,
            .left = 8,
        };
    }
    return self;
}

@end

@implementation TOutgoingCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.avatarInsets = (UIEdgeInsets){
            .right = 8,
            .top = 5,
            .bottom = 5,
        };
        self.messageInsets = (UIEdgeInsets){
            .top = 5,
            .bottom = 5,
            .right = 8,
        };

    }
    return self;
}

@end





@implementation TIncommingVoiceCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 20, .left = 19, .right = 22};
    }
    return self;
}

@end


@implementation TOutgoingVoiceCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 20, .left = 22, .right = 20};
    }
    return self;
}

@end
