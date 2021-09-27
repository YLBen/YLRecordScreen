//
//  UIWindow+Log.m
//  YLRecordScreen
//
//  Created by 吕彦良 on 2021/9/26.
//

#import "UIWindow+Log.h"
#import "NSObject+Runtime.h"
@interface YLTouchHintView : UIImageView
- (instancetype)initWithCenterPt:(CGPoint)aCenterPt;
@end

@implementation YLTouchHintView
- (instancetype)initWithCenterPt:(CGPoint)aCenterPt{
    if(self = [super init]){
        [self setBackgroundColor:[UIColor redColor]];
        CGSize size = CGSizeMake(20, 20);
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:size.width/2.f];
        [self setFrame:CGRectMake(aCenterPt.x-size.width/2.f, aCenterPt.y-size.height/2.f, size.width, size.height)];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self performSelector:@selector(autoRemove) withObject:nil afterDelay:.15f];
}

- (void)autoRemove{
    [self removeFromSuperview];
}
@end

@implementation UIWindow (Log)
+ (void)load{
    [self swizzleInstanceMethodWithOriginSel:@selector(sendEvent:) swizzledSel:@selector(nk_sendEvent:)];
}

- (void)nk_sendEvent:(UIEvent *)event{
    NSSet *touches = [event allTouches];
    UIWindow *supWindow = self;
    for(UITouch *touch in touches){
        CGPoint pt = [touch locationInView:supWindow];
        YLTouchHintView *hintView = [[YLTouchHintView alloc] initWithCenterPt:pt];
        [supWindow addSubview:hintView];
        [supWindow bringSubviewToFront:hintView];
    }
    [self nk_sendEvent:event];
}

@end
