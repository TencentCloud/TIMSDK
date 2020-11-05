//
//  UIASViewController+MASAdditions.h
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ASMASUtilities.h"
#import "ASMASConstraintMaker.h"
#import "ASMASViewAttribute.h"

#ifdef ASMAS_VIEW_CONTROLLER

@interface ASMAS_VIEW_CONTROLLER (ASMASAdditions)

/**
 *	following properties return a new ASMASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_topLayoutGuide;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_bottomLayoutGuide;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_topLayoutGuideTop;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_bottomLayoutGuideBottom;


@end

#endif
