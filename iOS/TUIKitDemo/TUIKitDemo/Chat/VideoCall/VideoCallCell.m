#import "VideoCallCell.h"
#import <TUIKit.h>
#import <THeader.h>
#import <TIMFriendshipManager.h>

@implementation VideoCallCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         UITapGestureRecognizer *singleFingerTap =
             [[UITapGestureRecognizer alloc] initWithTarget:self
                                                     action:@selector(handleSingleTap:)];
           [self.container addGestureRecognizer:singleFingerTap];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillWithData:(VideoCallCellData *)data {
    [data setAvatarImage:DefaultAvatarImage];
    [data setAvatarUrl:[NSURL URLWithString:@""]];
    [data setName:data.requestUser];
    [super fillWithData:data];
    [[TIMFriendshipManager sharedInstance] getUsersProfile:@[data.requestUser] forceUpdate:NO succ:^(NSArray<TIMUserProfile *> *profiles) {
        [data setAvatarUrl:[NSURL URLWithString:profiles[0].faceURL]];
        [data setName:profiles[0].nickname];
    } fail:^(int code, NSString *msg) {

    }];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.videlClick) {
        self.videlClick();
    }
}

@end
